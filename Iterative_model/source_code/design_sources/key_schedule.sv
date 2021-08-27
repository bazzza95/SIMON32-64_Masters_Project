// Module: key_schedule
// Description : SIMON32/64 key schedule iterative model
// Author: Barry Smyth

`timescale 1ns / 1ps

module key_schedule (
  input  reg [3:0][15:0] previous_four_keys,    // input key
  output wire [63:0] next_key,                  // updated key
  input  reg [4:0]   round_counter              // round counter
);
  
  // Local Parameters
  wire [15:0] temp, temp2;
  localparam z = 62'b01100111000011010100100010111110110011100001101010010001011111;
  localparam c = 64'hfffffffffffffffc;
  
  // Key update
  assign temp = {previous_four_keys[3][2:0],previous_four_keys[3][15:3]} ^ previous_four_keys[1];
  assign temp2 = temp ^ {temp[0],temp[15:1]};
  assign next_key = {temp2 ^ previous_four_keys[0] ^ (z[round_counter] & 1) ^c, previous_four_keys[3],previous_four_keys[2],previous_four_keys[1]};

endmodule