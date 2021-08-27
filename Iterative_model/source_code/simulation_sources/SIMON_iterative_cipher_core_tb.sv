// Module: key_schedule
// Description : SIMON32/64 serialized model test bench
/* The test bench takes in 20 plaintext, key
 * and ciphertext test vectors from the mem 
 * files.
 * It uses input rst to reset the data and
 * input load to load the data before encryption
 * is completed via the core, countrolled by the counter
 */
// Author: Barry Smyth

module SIMON_iterative_cipher_core_tb (
);

// Declare variables
logic         clk;                  // System clock
logic         rst;                  // System reset
logic         load;                 // Load plaintext + key
logic [31:0]  plaintext;            // 32-bit plaintext block
logic [63:0]  key;                  // 64-bit encryption key
logic [4:0]   count;                // 5-bit round counter
logic [31:0]  ciphertext;           // 32-bit ciphertext block

// Declare test vector arrays
localparam  NUM_TEST_VECTORS = 20;
  reg [31:0]  plaintext_vectors  [0:(NUM_TEST_VECTORS-1)];
  reg [63:0]  key_vectors        [0:(NUM_TEST_VECTORS-1)];
  reg [31:0]  ciphertext_vectors [0:(NUM_TEST_VECTORS-1)];

  initial begin
    $display("Reading test vectors...");
    $readmemh("plaintext_test_vectors.mem", plaintext_vectors);
    $readmemh("key_test_vectors.mem", key_vectors);
    $readmemh("ciphertext_test_vectors.mem", ciphertext_vectors);
  end


  // Instantiate Design Under Test    
  SIMON_iterative_cipher_core design_under_test (
    .clk (clk),
    .rst (rst),
    .load (load),
    .plaintext (plaintext),
    .key (key),
    .count (count),
    .ciphertext (ciphertext)
  );

  // Create a clock that inverts periodically
  initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
  end


  // Assert reset
  initial begin
    rst = 1'b0;
    #25
    rst = 1'b1;
  end

  // Main stimulus
  initial begin

    // Initialize load and count inputs
    load <= 1'b0;
    count <= 5'b00000;

    // Wait for reset assertion and next clock edge
    @(posedge rst); 
    @(posedge clk);

    // Loop through each test vector
    for (int i=0; i<NUM_TEST_VECTORS; i=i+1) begin 
      // Load plaintext and key test vectors
      load <= 1'b1;
      plaintext <= plaintext_vectors[i];
      key <= key_vectors[i];
      
      $display("Test vector index    :%d", i);
      $display("Plaintext vector     :          %h", plaintext_vectors[i]);
      $display("Key vector           :          %h", key_vectors[i]);

      // De-assert load input and initialize count
      @(posedge clk);
      load <= 1'b0;
      count <= 5'b00000;

      // Increment count for 32 clock cycles
      for (int j=0; j<=31; j=j+1) begin
        @(posedge clk);
        count <= count + 1;
      end

      // Verify the cipher text is as expected
      $display("Encrypted ciphertext :          %h", ciphertext);
    
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