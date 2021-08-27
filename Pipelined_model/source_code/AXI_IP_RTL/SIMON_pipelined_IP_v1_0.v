
`timescale 1 ns / 1 ps

	module SIMON_pipelined_IP_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
		// Plaintext BRAM interface ports
        output wire           pt_clka,
        output wire           pt_rsta,
        output wire [31:0]    pt_addra,
        output wire [31:0]    pt_wr_data,
        input  wire [31:0]    pt_rd_data,
        output wire           pt_ena,
        output wire [3:0]     pt_wea,
        
        // Ciphertext BRAM interface ports
        output wire           ct_clka,
        output wire           ct_rsta,
        output wire [31:0]    ct_addra,
        output wire [31:0]    ct_wr_data,
        input  wire [31:0]    ct_rd_data,
        output wire           ct_ena,
        output wire [3:0]     ct_wea,
        
        // Done interupt output wire to be connected to processor
        output wire done_intr,
        
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
		
	);
	
	// AXI slave interface connections
	wire [63:0] ctrl_in_key;
    wire        ctrl_in_begin;
    wire [10:0] ctrl_in_num_blocks;
    
    // Cipher core ports
    wire         core_load;
    wire [31:0]  core_plaintext;
    wire [63:0]  core_key;
    wire [4:0]   core_count;
    wire [31:0]  core_ciphertext;
    
// Instantiation of Axi Bus Interface S00_AXI
	SIMON_pipelined_IP_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) SIMON_pipelined_IP_v1_0_S00_AXI_inst (
	    .ctrl_in_key(ctrl_in_key),
        .ctrl_in_begin(ctrl_in_begin),
        .ctrl_in_num_blocks(ctrl_in_num_blocks),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here
    
    SIMON_pipelined_cipher_core_ctrl i_SIMON_pipelined_cipher_core_ctrl (
        // System + register interface
        .clk                (s00_axi_aclk),
        .rst                (s00_axi_aresetn),
        .ctrl_in_begin      (ctrl_in_begin),
        .ctrl_in_num_blocks (ctrl_in_num_blocks),
        .done_intr          (done_intr),
        .ctrl_in_key        (ctrl_in_key),
        // Plaintext block RAM interface
        .pt_clka          (pt_clka),
        .pt_rsta          (pt_rsta),
        .pt_addra         (pt_addra),
        .pt_wr_data       (pt_wr_data),
        .pt_rd_data       (pt_rd_data),
        .pt_ena           (pt_ena),
        .pt_wea           (pt_wea),
        
        // Ciphertext block RAM interface
        .ct_clka          (ct_clka),
        .ct_rsta          (ct_rsta),
        .ct_addra         (ct_addra),
        .ct_wr_data       (ct_wr_data),
        .ct_rd_data       (ct_rd_data),
        .ct_ena           (ct_ena),
        .ct_wea           (ct_wea),
        
        // Cipher core interface
        .core_load        (core_load),
        .core_plaintext   (core_plaintext),
        .core_key         (core_key),
        .core_count       (core_count),
        .core_ciphertext  (core_ciphertext)
    );
    
    SIMON_pipelined_cipher_core i_SIMON_pipelined_cipher_core (
        .clk              (s00_axi_aclk),
        .rst              (s00_axi_aresetn),       
        .load             (core_load),        
        .plaintext        (core_plaintext),   
        .key              (core_key),                
        .ciphertext       (core_ciphertext)
    );
	// User logic ends

	endmodule
