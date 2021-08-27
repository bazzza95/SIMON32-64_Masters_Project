#include <stdio.h>
#include "platform.h"
#include "xtime_l.h"
#include "xil_printf.h"
#include "xstatus.h"

// Rotate function macros
#define ROTATE_LEFT(x,n) ( ((x) << (n)) | ((x) >> (16-(n))) )
#define ROTATE_RIGHT(x,n) ( ((x) >> (n)) | ((x) << (16-(n))) )

// Expanded key
uint16_t key_expansion[32];

// Constant z0
static u8 z[62] =
{1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0,1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0};


// Key Expansion Function
void KeyExpansion (uint16_t master_key[]){
	uint16_t temp;

    for (int i=0 ; i<4 ; i++ ){
	   key_expansion[i] = master_key[i];
    }

    for (int i=4 ; i<32 ; i++ )
    {
        temp = ROTATE_RIGHT(key_expansion[i-1],3);
        temp = temp ^ key_expansion[i-3];
        temp = temp ^ ROTATE_RIGHT(temp,1);
        key_expansion[i] = ~key_expansion[i-4] ^ temp ^ z[i-4] ^ 3;
    }
}

// Round Function
void round_function (uint16_t plaintext[])
{
    u8 i;
    u16 tmp;

    uint16_t ciphertext[2];
    ciphertext[0] = plaintext[0];
    ciphertext[1] = plaintext[1];
    for ( i=0 ; i<32 ; i++ )
    {
        tmp = ciphertext[0];
        ciphertext[0] = ciphertext[1] ^ ((ROTATE_LEFT(ciphertext[0],1)) & (ROTATE_LEFT(ciphertext[0],8))) ^ (ROTATE_LEFT(ciphertext[0],2)) ^ key_expansion[i];
        ciphertext[1] = tmp;

    }
    //xil_printf("\tPlaintext: %x%x%r \r\n", plaintext[0], plaintext[1]);
	//xil_printf("\tEncrypted ciphertext:%x%x%r \r\n\n", ciphertext[0], ciphertext[1]);
}


// Software core and timing analysis
void sw_encrypt_init(int length, uint32_t *plaintext_test_vectors, uint32_t *master_key){

	uint16_t current_plaintext[2];
	uint16_t key[4] = {master_key[1], master_key[1] >> 16, master_key[0], master_key[0] >> 16};

	XTime start, end;
	double t;
	XTime_GetTime(&start);

	KeyExpansion(key);

	for(int i = 0; i < length; i++){
		current_plaintext[0] = plaintext_test_vectors[i]>>16;
		current_plaintext[1] = plaintext_test_vectors[i]>>0;

		//xil_printf("\tTest vector: %d \r\n", i);
		round_function(current_plaintext);
	}

	XTime_GetTime(&end);
	t = (double)(end - start)/(double)(COUNTS_PER_SECOND/1000000);
	printf("\nTime to encrypt %d blocks in software: %f us\r\n", length, t);
	xil_printf("******************************** \r\n");

}
