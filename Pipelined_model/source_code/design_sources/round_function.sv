// Module: key_schedule
// Description : SIMON32/64 round function logic, pipelined model
// Author: Barry Smyth

`timescale 1ns / 1ps

module round_function (

  input  logic [31:0] input_text,   // text in
  input logic  [15:0] round_key,    // round key
  output logic [31:0] output_text   // text out
);
  
  // round function 
  assign output_text = 	{(({input_text[30:16],input_text[31]} & 		 
                           {input_text[23:16],input_text[31:24]}) ^ 
                          input_text[15:0] ^ 
                          {input_text[29:16],input_text[31:30]} ^ 
                          round_key),
                         input_text[31:16]};  
endmodule