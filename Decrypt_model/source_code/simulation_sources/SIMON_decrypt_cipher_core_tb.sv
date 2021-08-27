`timescale 1ns / 1ps
// Module: cipher_core_tb
// Description : SIMON32/64 decrypt mixed model test bench
/* The test bench takes in 20 plaintext, key
 * and ciphertext test vectors from the mem 
 * files.
 */
// Author: Barry Smyth

module SIMON_decrypt_cipher_core_tb (

);

  logic clk;				// System clock
  logic rst;                // System reset
  logic load;               // System load   
  logic [63:0] key;         // 64-bit key
  logic [4:0]   count;      // 5-bit round counter
  logic [31:0]  plaintext;  // 32-bit plaintext
  logic [31:0]  ciphertext; // 32bit ciphertext
 
  localparam  NUM_TEST_VECTORS = 20;

  reg [63:0] key_vectors        [0:(NUM_TEST_VECTORS-1)];
  reg [31:0]  plaintext_vectors  [0:(NUM_TEST_VECTORS-1)];
  reg [31:0]  ciphertext_vectors [0:(NUM_TEST_VECTORS-1)];

  // Read test vectors from memory files
  // NOTE: read ciphertext into plaintext and vice versa
  initial begin
      $display("Reading test vectors...");
      $readmemh("ciphertext_test_vectors.mem", plaintext_vectors);
      $readmemh("key_test_vectors.mem", key_vectors);
    $readmemh("plaintext_test_vectors.mem", ciphertext_vectors);
    end
  
  // Instantiate Design Under Test 
  SIMON_decrypt_cipher_core design_under_test (
    .clk (clk),
    .rst (rst),
    .load (load),
    .key (key),
    .count (count),
    .plaintext (plaintext),
    .ciphertext (ciphertext)
  );
 
  // Create a clock that inverts periodically
  initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
  end
  
  // Assert reset after delay
  initial begin
    rst = 1'b0;
    #45
    rst = 1'b1;
  end
 
  // Variable to be changed to number of pipelined units
  // per clock cycle
  // Value must be a factor of 32
  localparam x = 1;

  initial begin
    load <= 1'b0;
    count <= 5'b00001;

    @(posedge rst); 
    @(posedge clk);

    for (int i=0; i<NUM_TEST_VECTORS; i=i+1) begin
      $display("Test vector index    :%d", i);
      $display("Ciphertext vector     :          %h", plaintext_vectors[i]);
      $display("Key vector           :          %h", key_vectors[i]);

      plaintext <= plaintext_vectors[i];
      key <= key_vectors[i];
      load <= 1'b1;

      @(posedge clk);
      load <= 1'b0;
      count <= 5'b00000;

      
      for (int j=0; j<32/x; j=j+1) 		begin
        @(posedge clk);
        count <= count + 1;
      end 

// Verify the cipher text is as expected
      $display("Decrypted plaintexr :          %h", ciphertext);
    
      assert (ciphertext == ciphertext_vectors[i]) $display("The test vector passed! Matched expected");
      else begin
        $display("The test vector at index %d failed due to expected data mismatch", i);
        $display("Expected ciphertext: %h", ciphertext_vectors[i]);
      end
      $display("-------------------------");

    end
    $finish;    
  end
endmodule
