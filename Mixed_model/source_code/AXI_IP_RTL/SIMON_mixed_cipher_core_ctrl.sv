`timescale 1ns / 1ps

module SIMON_mixed_cipher_core_ctrl(
    // System + register inputs
   input  logic           clk,                  // System clock
   input  logic           rst,                  // System reset 
   input  logic           ctrl_in_begin,        // Begin signal driven by slave regs
   input  logic [10:0]    ctrl_in_num_blocks,   // No. of blocks for encryptions taken in from slave regs
   output logic           done_intr,            // Edge triggered interrupt to indicate encryption completion
   input  logic [63:0]    ctrl_in_key,          // Key taken in from slave regs
   
   // Plaintext block RAM interface   
   output logic           pt_clka,     // BRAM clock
   output logic           pt_rsta,     // Optional output latch/register reset
   output logic [31:0]    pt_addra,    // Address for read + write operations
   output logic [31:0]    pt_wr_data,  // Write data 
   input  logic [31:0]    pt_rd_data,  // Read data 
   output logic           pt_ena,      // Enable read, reset and write operations
   output logic [3:0]     pt_wea,      // Byte write enable 
   
   // Ciphertext block RAM interface
   output logic           ct_clka,     // BRAM clock
   output logic           ct_rsta,     // Optional output latch/register reset
   output logic [31:0]    ct_addra,    // Address for read + write operations (check width)
   output logic [31:0]    ct_wr_data,  // Write data (check width)
   input  logic [31:0]    ct_rd_data,  // Read data (check width)
   output logic           ct_ena,      // Optional clock enable (check if it's present on block RAM)
   output logic [3:0]     ct_wea,      // Byte write enable
   
   // Cipher core interface   
   output logic           core_load,
   output logic [31:0]    core_plaintext,
   output logic [63:0]    core_key,
   output logic [4:0]     core_count,
   input  logic [31:0]    core_ciphertext

);

// Define FSM states
localparam START = 3'b000;
localparam READ  = 3'b001;
localparam LOAD  = 3'b010;
localparam COUNT = 3'b011;
localparam WRITE = 3'b100;
localparam DONE  = 3'b101;

// Declare variables for state and count
reg [2:0]  current_state;
reg [2:0]  next_state;
reg [4:0]  cnt;
reg [10:0] current_block;
reg [31:0] current_addr;
reg        enable_counter;
reg        incr_block_count;

// Direct assignments to cipher core
assign core_count     = cnt;
assign core_key       = ctrl_in_key;        
assign core_plaintext = pt_rd_data;

// Direct assignments to Plaintext BRAM
assign pt_clka    = clk;        // System clock
assign pt_rsta    = ~rst;     // Active high BRAM output register reset
assign pt_wr_data = '0;         // Tie off write data (won't be writing to this BRAM)
assign pt_ena     = 1'b1;       // Internal BRAM clock gating disabled
assign pt_wea     = '0;         // Tie off write enable (won't be writing to this BRAM)

// Direct assignments to Ciphertext BRAM
assign ct_clka    = clk;        // System clock
assign ct_rsta    = ~rst;     // Active high BRAM output register reset
assign ct_ena     = 1'b1;       // Internal BRAM clock gating disabled

// Reset transition
always @ (posedge clk) begin
   if (rst == 1'b0) begin
       current_state <= START;
   end else begin
       current_state <= next_state;
   end
end

// State Transitions
always @ (*) begin

   // Default behaviour
   next_state = current_state;

   case (current_state)

        START: begin
             if (ctrl_in_begin == 1'b1) begin
                 next_state = READ;   // Begin Load
             end else begin 
                 next_state = START;         // Else remain in INIT state
             end
         end
         
         READ: begin
             next_state = LOAD;       // Unconditional transition to LOAD_BLOCK state
         end
         
         LOAD: begin
             next_state = COUNT;             // Unconditional transition to BUSY state
         end
         
         COUNT: begin
             if (cnt == 5'b00011) begin
                 next_state = WRITE;  // Move to WRITE_BLOCK state if 2 rounds elapsed
             end else begin
                 next_state = COUNT;         // Else remain in BUSY state
             end
         end
         
         WRITE: begin
             if (current_block != ctrl_in_num_blocks - 1) begin
                 next_state = READ;   // Move to READ_BLOCK state - more blocks to be encrypted
             end else begin
                 next_state = DONE;         // Move to DONE state - all blocks encrypted
             end
         end
         
         DONE: begin
             next_state = START;             // Unconditional transition to INIT state
         end
   
   endcase
end

// Output Logic
always @ (*) begin

   // Default assignments
   enable_counter   = 1'b0;
   core_load        = 1'b0;
   incr_block_count = 1'b0;
   done_intr        = 1'b0;
   
   pt_addra       = current_addr;
   ct_addra       = current_addr;
   ct_wr_data     = '0;
   ct_wea         = '0;
   
   case (current_state)
   
       START: begin
       end
   
       READ: begin
           pt_addra = current_addr;
       end

       LOAD: begin
           core_load = 1'b1;
       end

       COUNT: begin
           enable_counter = 1'b1;
       end

       WRITE: begin
           ct_addra         = current_addr;
           ct_wr_data       = core_ciphertext;
           ct_wea           = '1;
           incr_block_count = 1'b1;
       end
       
       DONE: begin
           done_intr = 1'b1;
       end     
   endcase
end

// Round Counter
always @ (posedge clk) begin
   if (rst == 1'b0) begin
       cnt <= 5'b00000;
   end else if (enable_counter == 1'b0) begin
       cnt <= 5'b00000;
   end else if (enable_counter == 1'b1) begin
       cnt <= cnt + 1;
   end
end

// Current block control
always @ (posedge clk) begin
   if ((rst == 1'b0) || (current_state == START)) begin
       current_block <= 11'b0;
       current_addr <= 'b0;
   end else if (incr_block_count) begin
       current_block <= current_block + 1;
       current_addr <= current_addr + 4;
   end
end
endmodule
