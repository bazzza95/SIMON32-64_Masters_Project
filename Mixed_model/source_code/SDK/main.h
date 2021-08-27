#ifndef SRC_MAIN_H_
#define SRC_MAIN_H_

#define INTC_DEVICE_ID		XPAR_PS7_SCUGIC_0_DEVICE_ID
#define SW_DEVICE_ID		XPAR_AXI_GPIO_0_DEVICE_ID
#define INTC_GPIO_INTERRUPT_ID XPAR_FABRIC_AXI_GPIO_0_IP2INTC_IRPT_INTR
#define SW_INT 			XGPIO_IR_CH1_MASK

static void sw_Intr_Handler(void *InstancePtr);
static XStatus interrupt_setup(XScuGic *XScuGicInstancePtr);
static int interconnect_init(u16 DeviceId, XGpio *GpioInstancePtr);
static XStatus interrupt();
XStatus simon_encrypt(int length, uint32_t *plaintext_test_vectors, uint32_t *key, uint32_t *ciphertext_test_vectors, uint32_t *encrypted_ciphertext);

#endif /* SRC_MAIN_H_ */
