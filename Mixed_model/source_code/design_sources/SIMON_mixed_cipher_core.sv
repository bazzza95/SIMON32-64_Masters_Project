// Module: SIMON_mixed_cipher_core_cipher_core
// Description : SIMON32/64 cipher core mixed model
// Author: Barry Smyth

`timescale 1ns / 1ps

module SIMON_mixed_cipher_core 
#(
// Ediit mixed_size parameter to control
// the number of rounds encrypted in parallel
// Note: the size must be a factor of 32 
// and must be same across all modules
parameter mixed_size = 8)
(
  input  logic clk,        
  input  logic rst,     
  input  logic load,        
  input  logic [63:0]   key,         
  input  logic [4:0]     count,   
  input logic [31:0] plaintext,
  output [31:0] ciphertext    
);
  
  localparam rounds = 32;
  reg [33:0][15:0] keys;
  reg [31:0] states;
  wire [31:0] next_state;


  // State and Round Key Registers
  always @ (posedge clk) begin
    if (!rst) begin
      keys[3:0] <= '0;
      states <= '0;
    end else begin
      if (load) begin
        states <= plaintext;
        keys[0] <= key[15:0];
        keys[1] <= key[31:16];
        keys[2] <= key[47:32];
        keys[3] <= key[63:48]; 
      end else begin
        states <= next_state;
      end
    end
  end
  
  generate
    genvar i;
    for(i=0;i<rounds-4;i++)begin
      key_schedule sec_i(
        .round_counter (i),               
        .input_key        ({keys[i+3],keys[i+2],keys[i+1],keys[i]}),
        .next_key       (keys[i+4])
        );   
    end
  endgenerate
  
  pipe_section sec(            
    .key_in        (keys[(count*mixed_size)+:mixed_size]),
    .state_in      (states),
    .state_out     (next_state)
  );  

  assign ciphertext = next_state;

endmodule
