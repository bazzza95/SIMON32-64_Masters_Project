// Module: SIMON_iterative_cipher_core
// Description : SIMON32/64 cipher core iterative model
// Author: Barry Smyth

`timescale 1ns / 1ps

module SIMON_iterative_cipher_core (
  input  logic           clk,         // System clock
  input  logic           rst,         // System reset 
  input  logic           load,        // Load plaintext and key
  input  logic [31:0]    plaintext,   // 32-bit plaintext block
  input  logic [63:0]    key,         // 64-bit encryption key
  input  logic [4:0]     count,       // Round counter
  output logic [31:0]    ciphertext   // 32-bit ciphertext block   
);

  // Key and State registers
  reg [31:0] current_state;
  reg [63:0] current_key;
  
  // Key and state wires
  wire[31:0] next_state;
  wire[63:0] next_key;

  // Update State and Round Key Registers
  always @ (posedge clk) begin
      if (!rst) begin
          current_state <= '0;
          current_key <= '0;
      end else begin
          if (load) begin
              current_state <= plaintext;
              current_key <= key;  
          end else begin
              current_state <= next_state;
              current_key <= next_key;
          end
      end
  end

  // Key schedule
  key_schedule current_keys (
    .previous_four_keys(current_key),
    .next_key (next_key),
    .round_counter(count)
  );
  
  // Round schedule
  round_function current_round(
    .input_text(current_state),
    .round_key(current_key[15:0]),
    .output_text(next_state)
  );
  
  // Ciphertext update
  assign ciphertext = next_state;

endmodule