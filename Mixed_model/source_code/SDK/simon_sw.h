#ifndef SRC_SIMON_SW_H_
#define SRC_SIMON_SW_H_

void key_expansion (uint16_t master_key[]);
void round_function(uint16_t plaintext[]);
void sw_encrypt_init(int length, uint32_t *plaintext_test_vectors, uint32_t *master_key);

#endif /* SRC_SIMON_SW_H_ */
