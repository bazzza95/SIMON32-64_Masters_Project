// Module: SIMON_serialized_cipher_core
// Description : SIMON32/64 pipe section decrypt model
// Author: Barry Smyth

`timescale 1ns / 1ps

module pipe_section (
  //key in width to be changed
  input  logic [1:0][15:0] key_in,
  input  logic [31:0]  state_in,
  output logic [31:0]  state_out
  
);

  // Variable to be changed to number of pipelined units
  // per clock cycle
  // Value must be a factor of 32
  localparam x = 1;
  
  wire [x:0][31:0] intermediate_state;
  assign intermediate_state[0] = state_in;
  
  generate
    genvar i;
    for(i=0;i<x;i++)begin
       round round_i (
         .input_text(intermediate_state[i]),
         .round_key(key_in[i]),
         .output_text(intermediate_state[i+1])
  ); 
    end
  endgenerate
  
  assign state_out = intermediate_state[x];

endmodule