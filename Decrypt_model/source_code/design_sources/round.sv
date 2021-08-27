// Module: round
// Description : SIMON32/64 round section decrypt model
// Author: Barry Smyth

// Note: This version is the inverse of the regular round function 

`timescale 1ns / 1ps

module round (

  input  logic [31:0] input_text, 
  input logic [15:0] round_key,
  output logic [31:0] output_text
);
  
  assign output_text = 	{input_text[15:0],(({input_text[14:0],input_text[15]} & 		 
                           {input_text[7:0],input_text[15:8]}) ^ 
                          input_text[31:16] ^ 
                          {input_text[13:0],input_text[15:14]} ^ 
                      round_key)
                         };
endmodule