#ifndef SRC_SIMON_HW_H_
#define SRC_SIMON_HW_H_

#include "xscugic.h"

extern int isExecuted;
extern uint32_t *ciphertext_ptr;

void hw_interrupt();
XStatus hw_init(XScuGic *SIMONIntcInstance);
void hw_key_write(uint32_t *key);
void plaintext_bram_write(uint32_t *plaintext, int length);
XStatus initiate_encryption(uint32_t *plaintext, uint32_t *ciphertext, int length);

#endif
