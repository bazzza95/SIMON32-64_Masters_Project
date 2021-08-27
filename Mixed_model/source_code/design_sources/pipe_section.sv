// Module: SIMON_serialized_cipher_core
// Description : SIMON32/64 pipe section mixed model
// Author: Barry Smyth

`timescale 1ns / 1ps

module pipe_section 
#(
// Ediit mixed_size parameter to control
// the number of rounds encrypted in parallel
// Note: the size must be a factor of 32 
// and must be same across all modules
parameter mixed_size = 8)
(
  input  logic [mixed_size-1:0][15:0] key_in,
  input  logic [31:0]  state_in,
  output logic [31:0]  state_out
  
);

  // intermediate values
  wire [mixed_size:0][31:0] intermediate_state;
  assign intermediate_state[0] = state_in;
  
  // round function generation
  generate
    genvar i;
    for(i=0;i<mixed_size;i++)begin
       round_function round_function_i (
         .input_text(intermediate_state[i]),
         .round_key(key_in[i]),
         .output_text(intermediate_state[i+1])
  ); 
    end
  endgenerate
  
  // Update intemediate values
  assign state_out = intermediate_state[mixed_size];
endmodule