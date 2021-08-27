#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "simon_hw.h"
#include "simon_sw.h"
#include "xstatus.h"
#include "xgpio.h"
#include "main.h"
#include "xtime_l.h"

int test_vector_number = 20;

static XScuGic SIMONIntcInstance;	// SIMON Interrupt instance
static int sw_value;				// Switch value
static XGpio SWInst;				// Switch GPIO Instance
XScuGic INTCInst;					// Switch Interrupt Instance


// Function Triggered when switch interrupt is triggered
// Handles the action when triggered
void sw_Intr_Handler(void *InstancePtr) {
	// Disable GPIO interrupts
	XGpio_InterruptDisable(&SWInst, SW_INT);

	// Ignore additional switch toggles
	if ((XGpio_InterruptGetStatus(&SWInst) & SW_INT) != SW_INT) {
		return;
	}

	// Read switch value
	sw_value = XGpio_DiscreteRead(&SWInst, 1);

	if(sw_value == 1){
		xil_printf("Switch INTERRUPT TRIGERED %d!\r\n", sw_value);
	}

	// Clear Interrupt
	(void) XGpio_InterruptClear(&SWInst, SW_INT);

	// Enable GPIO interrupts
	XGpio_InterruptEnable(&SWInst, SW_INT);
}

// Enables the Interconnect and configures the handler
XStatus interrupt_setup(XScuGic *XScuGicInstancePtr) {
	// Enable interrupt
	XGpio_InterruptEnable(&SWInst, SW_INT);
	XGpio_InterruptGlobalEnable(&SWInst);

	// Configure Interrupt Handler
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
			XScuGicInstancePtr);

	// Enable Exceptions
	Xil_ExceptionEnable();

	return XST_SUCCESS;

}

// Initialise the switch interrupt controller
int interconnect_init(u16 DeviceId, XGpio *GpioInstancePtr) {
	XScuGic_Config *IntcConfig;
	int status;

	// Interrupt controller initialisation
	IntcConfig = XScuGic_LookupConfig(DeviceId);
	status = XScuGic_CfgInitialize(&INTCInst, IntcConfig,
			IntcConfig->CpuBaseAddress);
	if (status != XST_SUCCESS)
		return XST_FAILURE;

	// Call to interrupt setup
	status = interrupt_setup(&INTCInst);
	if (status != XST_SUCCESS)
		return XST_FAILURE;

	// Connect GPIO interrupt to handler
	status = XScuGic_Connect(&INTCInst, INTC_GPIO_INTERRUPT_ID,
			(Xil_ExceptionHandler) sw_Intr_Handler, (void *) GpioInstancePtr);
	if (status != XST_SUCCESS)
		return XST_FAILURE;

	// Enable GPIO interrupts interrupt
	XGpio_InterruptEnable(GpioInstancePtr, 1);
	XGpio_InterruptGlobalEnable(GpioInstancePtr);

	// Enable GPIO and timer interrupts in the controller
	XScuGic_Enable(&INTCInst, INTC_GPIO_INTERRUPT_ID);

	return XST_SUCCESS;
}

// Calls functions to set up switch interrupt
XStatus interrupt(){

	XStatus status;

	// Initialise the Switches
	status = XGpio_Initialize(&SWInst, SW_DEVICE_ID);

	// Check success
	if (status != XST_SUCCESS)
		return XST_FAILURE;

	// Set switch direction to input
	XGpio_SetDataDirection(&SWInst, 1, 0xFF);

	// Initialize switch interrupt controller
	status = interconnect_init(INTC_DEVICE_ID, &SWInst);

	// Check success
	if (status != XST_SUCCESS)
		return XST_FAILURE;

	// Wait until switch is set to high
	while(sw_value!= 1){
		}

	return XST_SUCCESS;
}

/*
 *  Initialises the hardware
 *  Writes the key to slave registers
 *  Writes plaintext to BRAM
 *  Initiates Encryption
 *  Verifies results
 */
XStatus simon_encrypt(int length, uint32_t *plaintext_test_vectors, uint32_t *key, uint32_t *ciphertext_test_vectors, uint32_t *encrypted_ciphertext) {

	hw_init(&SIMONIntcInstance);
	hw_key_write(key);
	plaintext_bram_write(plaintext_test_vectors, length);
	initiate_encryption(plaintext_test_vectors, encrypted_ciphertext, length);

	// Block until ISR executes
	xil_printf("Waiting for interrupt...\r\n");
	while(isExecuted == 0){}

	xil_printf("Interrupt triggered!\r\n");
	isExecuted = 0;

	// Dont print the timing test
	if(length == 20){
		for(int i = 0; i < length; i++){
			xil_printf("--- Teset Vector: %d --- \r\n", i );
			xil_printf("\tPlaintex:\t0x%08x \r\n", plaintext_test_vectors[i]);
			xil_printf("\tExpected ciphertext:\t0x%08x \r\n", ciphertext_test_vectors[i]);
			xil_printf("\tActual ciphertext:\t\t0x%08x \r\n", encrypted_ciphertext[i]);

			if ((encrypted_ciphertext[i] != ciphertext_test_vectors[i])){
					xil_printf("Data mismatch at test vector %d\r\n", i);
					xil_printf("Encryption Falied\r\n", i);
					return XST_FAILURE;
			}
		}
	}

	xil_printf("All vectors passed!\r\n");
	return XST_SUCCESS;
}


int main(){

	init_platform();

	//Test Vectors
	uint32_t plaintext_test_vectors[test_vector_number];
	plaintext_test_vectors[0] = 0x65656877;
	plaintext_test_vectors[1] = 0xc7e6b04b;
	plaintext_test_vectors[2] = 0x571affb0;
	plaintext_test_vectors[3] = 0xb6e2ccce;
	plaintext_test_vectors[4] = 0x4cf96326;
	plaintext_test_vectors[5] = 0x2a6ea759;
	plaintext_test_vectors[6] = 0x82f65107;
	plaintext_test_vectors[7] = 0xd6dadc2d;
	plaintext_test_vectors[8] = 0xd77c429c;
	plaintext_test_vectors[9] = 0xd7433856;
	plaintext_test_vectors[10] = 0x530f3626;
	plaintext_test_vectors[11] = 0x86824ae3;
	plaintext_test_vectors[12] = 0xbf85fac6;
	plaintext_test_vectors[13] = 0x425f870d;
	plaintext_test_vectors[14] = 0x57995e33;
	plaintext_test_vectors[15] = 0x97945dc0;
	plaintext_test_vectors[16] = 0x38d85140;
	plaintext_test_vectors[17] = 0x6c30a460;
	plaintext_test_vectors[18] = 0x0a7e83ad;
	plaintext_test_vectors[19] = 0x64792443;

	uint32_t key[2]        = {0x19181110, 0x09080100};

	uint32_t ciphertext_test_vectors[test_vector_number];
	ciphertext_test_vectors[0] = 0xc69be9bb;
	ciphertext_test_vectors[1] = 0x5a26ccc5;
	ciphertext_test_vectors[2] = 0xdd871e06;
	ciphertext_test_vectors[3] = 0x1b30f7c5;
	ciphertext_test_vectors[4] = 0x0d79e4cc;
	ciphertext_test_vectors[5] = 0xe2715914;
	ciphertext_test_vectors[6] = 0xf1bbbc97;
	ciphertext_test_vectors[7] = 0x8e565c39;
	ciphertext_test_vectors[8] = 0x55d82f51;
	ciphertext_test_vectors[9] = 0x71f9a9a6;
	ciphertext_test_vectors[10] = 0x09bcd774;
	ciphertext_test_vectors[11] = 0x7a79ecaa;
	ciphertext_test_vectors[12] = 0x46ca93e9;
	ciphertext_test_vectors[13] = 0x21994dbf;
	ciphertext_test_vectors[14] = 0x968016ee;
	ciphertext_test_vectors[15] = 0x931e85b6;
	ciphertext_test_vectors[16] = 0x52259a92;
	ciphertext_test_vectors[17] = 0xbc270afa;
	ciphertext_test_vectors[18] = 0x8125df61;
	ciphertext_test_vectors[19] = 0x51b1f587;

	uint32_t encrypted_ciphertext[test_vector_number];

	xil_printf("\n\nSet switch 0 to high to trigger interrupt and begin encryption..\r\n");

	XStatus status = interrupt();

	if (status == XST_SUCCESS) {
		xil_printf("\r\nSwitch Interrupt successfully triggered!\r\n");
		xil_printf("\r\n*********************\r\n\r\n");
	} else {
		xil_printf("\r\nInterrypt failed\r\n");
	}


	xil_printf("Beginning encryption..\r\n");

	// begin hardware encryption
	status = simon_encrypt(test_vector_number, plaintext_test_vectors, key, ciphertext_test_vectors, encrypted_ciphertext);


	if (status == XST_SUCCESS) {
		xil_printf("\r\nEncryption complete!\r\n");
		xil_printf("\r\n*********************\r\n\r\n");
	} else {
		xil_printf("\r\nfail\r\n");
	}

	// begin software encryption
	sw_encrypt_init(test_vector_number, plaintext_test_vectors, key);

	// Randomly initiated vecors, contents does not matter
	uint32_t plaintext[1000];
	uint32_t ciphertext[1000];
	uint32_t master_key[2];

	// Performance Tests
	// NOTE: BUG IN CODE WHEN 1 BLOCK IS ENCRYPTED IN HARDWARE
	// FOR MIXED VERSION
	// TO ESTIMATE LATENCY FOR ONE BLOCK
	// (TIME TAKEN TO ENCRYPT 2) - (TIME TAKEN TO ENCRYPT 1000/1000)
	status = simon_encrypt(1, plaintext, master_key, ciphertext, ciphertext);
	status = simon_encrypt(1000, plaintext, master_key, ciphertext, ciphertext);
	sw_encrypt_init(1, plaintext, master_key);
	sw_encrypt_init(1000, plaintext, master_key);

	cleanup_platform();

	return 0;

}

