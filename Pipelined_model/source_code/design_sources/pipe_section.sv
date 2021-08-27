// Module: key_schedule
// Description : SIMON32/64 pipe section pipelined model
// Author: Barry Smyth

`timescale 1ns / 1ps

module pipe_section (
  input  logic [4:0]   round_counter,
  input  logic [63:0] key_in,
  output  logic [15:0] key_out,
  input  logic [31:0]  state_in,
  output logic [31:0]  state_out
);
  
  // Round module
  round_function i_round_function (
    .input_text(state_in),
    .round_key(key_in[15:0]),
    .output_text(state_out)
  ); 
  
  // key_schedule module
  key_schedule i_key_schedule (
    .input_key   (key_in),
    .next_key      (key_out),
    .round_counter (round_counter)
  );
  
endmodule