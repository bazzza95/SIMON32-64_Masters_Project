// Module: SIMON_pipelined_cipher_core_cipher_core
// Description : SIMON32/64 cipher core pipelined model
// Author: Barry Smyth

`timescale 1ns / 1ps

module SIMON_pipelined_cipher_core (

  input  logic           clk,         // System clock
  input  logic           rst,         // System reset
  input logic            load,        // Load plaintext and key  
  input  logic [31:0]    plaintext,   // 32-bit plaintext block
  input  logic [63:0]    key,         // 64-bit encryption key
  output logic [31:0]    ciphertext   // 32-bit ciphertext block
    
);
  
  localparam rounds = 32;
  
  // key and state registers
  reg [rounds:0][31:0] states;
  reg [rounds+3:0][15:0] keys;
  
  // creation of required numeber of piped sections
  generate
    genvar i;
    for(i=0;i<rounds;i++)begin
      pipe_section sec_i(

        .round_counter (i),               
        .key_in        ({keys[i+3],keys[i+2],keys[i+1],keys[i]}),
        .key_out       (keys[i+4]),
        .state_in      (states[i]),
        .state_out     (states[i+1])
      );   
    end
  endgenerate
  
  // driver logic
  always @ (posedge clk) begin
    if (!rst) begin
      states[0] <= '0;
      keys[3:0] <= '0;
  
    end else begin
      if (load) begin
        states[0] <= plaintext;
        keys[0] <= key[15:0];
        keys[1] <= key[31:16];
        keys[2] <= key[47:32];
        keys[3] <= key[63:48];      
      end
    end
  end

  // Cipher text update
  assign ciphertext = states[rounds];
  
endmodule