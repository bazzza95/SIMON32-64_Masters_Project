#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xparameters.h"
#include "SIMON_mixed_IP.h"
#include "xil_io.h"
#include "simon_hw.h"
#include "xtime_l.h"

int isExecuted;						// done interrupt trigger
uint32_t *ciphertext_ptr;			//
int num_blocks;

XTime start, end;
double t;


// Initiate Interrupt Function
// Interrupt is triggered when all ciphertext is read
void hw_interrupt() {

	XTime_GetTime(&end);
	t = (double)(end - start)/(double)(COUNTS_PER_SECOND/1000000);
	printf("Timer ended. Time to encrypt %d blocks in hardware: %f us \r\n", num_blocks, t);
	xil_printf("******************************** \r\n\n");

	// Read ciphertext from BRAM
	xil_printf("\nReading from ciphertext BRAM..\r\n");
	for (int i = 0; i < num_blocks; i++) {
		ciphertext_ptr[i] = Xil_In32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + (i*4));
	}
	xil_printf("Triggering Interrupt..\r\n");
	isExecuted = 1;

}

// Write the key to slave reg 2 and 3
void hw_key_write(uint32_t *key){
	// Write key to registers
	Xil_Out32(XPAR_SIMON_MIXED_IP_0_S00_AXI_BASEADDR + SIMON_MIXED_IP_S00_AXI_SLV_REG2_OFFSET, key[0]);
	Xil_Out32(XPAR_SIMON_MIXED_IP_0_S00_AXI_BASEADDR + SIMON_MIXED_IP_S00_AXI_SLV_REG3_OFFSET, key[1]);
	xil_printf("Writing key to slave reg 2 and 3..\r\n");
	xil_printf("Key: %08x%08x\r\n", key[0],key[1]);
}


// hardware initialization
XStatus hw_init(XScuGic *SIMONIntcInstance){

	xil_printf("Creating Interrupt Controller..\r\n");

	isExecuted = 0;		// set the done interrupt to low
	u32 status;

	XScuGic *intc_ptr = SIMONIntcInstance;
	XScuGic_Config *IntcConfig;

	// Get config for PS General Interrupt Controller (GIC)
	IntcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);

	// Initialize GIC driver
	status = XScuGic_CfgInitialize(SIMONIntcInstance, IntcConfig, IntcConfig->CpuBaseAddress);

	if(status != XST_SUCCESS){
			xil_printf("Interrupt Controllor Initialization Failure..");
			return XST_FAILURE;
		}

	// Set highest priority (0xA0) and rising edge triggered (0x03)
	XScuGic_SetPriorityTriggerType(SIMONIntcInstance, XPAR_FABRIC_SIMON_MIXED_IP_0_DONE_INTR_INTR, 0xA0, 0x03);

	// Register the Interrupt Service Routine (ISR)
	status = XScuGic_Connect(SIMONIntcInstance, XPAR_FABRIC_SIMON_MIXED_IP_0_DONE_INTR_INTR, (Xil_ExceptionHandler)hw_interrupt, (void *)SIMONIntcInstance);

	// Enable the relevant GIC interrupt
	XScuGic_Enable(SIMONIntcInstance, XPAR_FABRIC_SIMON_MIXED_IP_0_DONE_INTR_INTR);

	// Initialize exception table, register ISR and enable exceptions
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, intc_ptr);
	Xil_ExceptionEnable();

	xil_printf("Interrupt Controller Created Successfully..\r\n");
	return XST_SUCCESS;

}

// Write the key to slave reg 2 and 3
void plaintext_bram_write(uint32_t *plaintext, int length){

		xil_printf("Writing Plaintext to BRAM..\r\n");
		for (int i = 0; i < length; i++) {
			Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + (i*4), plaintext[i]);
		}
}


// Assert begin
XStatus initiate_encryption(uint32_t *plaintext, uint32_t *ciphertext, int length){

	xil_printf("Starting timer\r\n");
	XTime_GetTime(&start);
	Xil_Out32(XPAR_SIMON_MIXED_IP_0_S00_AXI_BASEADDR + SIMON_MIXED_IP_S00_AXI_SLV_REG0_OFFSET, (length<<1) | 0x1);

	ciphertext_ptr = ciphertext;
	num_blocks = length;

	// De-assert begin bit
	Xil_Out32(XPAR_SIMON_MIXED_IP_0_S00_AXI_BASEADDR + SIMON_MIXED_IP_S00_AXI_SLV_REG0_OFFSET, (length<<1) & 0xFFFFFFFE);

	xil_printf("Encryption complete\r\n");
	return XST_SUCCESS;
}




