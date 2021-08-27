// Module: key_schedule
// Description : SIMON32/64 key schedule pipelined model
// Author: Barry Smyth

`timescale 1ns / 1ps

module key_schedule (
  input  logic [3:0][15:0] input_key,   // input key
  output logic [15:0] next_key,         // updated key
  input  logic [4:0]   round_counter    // round counter
    
);
  
  // Local Parameters
  reg [15:0] temp, temp2;
  localparam z = 62'b01100111000011010100100010111110110011100001101010010001011111;
  localparam c = 64'hfffffffffffffffc;

  // key update
  assign temp = {input_key[3][2:0],input_key[3][15:3]} ^ input_key[1];
  assign temp2 = temp ^ {temp[0],temp[15:1]};
  assign next_key = temp2 ^ input_key[0] ^ (z[round_counter] & 1) ^c;
  
endmodule
