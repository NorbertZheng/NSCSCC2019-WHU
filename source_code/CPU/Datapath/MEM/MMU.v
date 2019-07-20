module MMU(virtual_sram_addr, physical_sram_addr);
	/*********************
	 *			MMU
	 *input:
	 *	virtual_sram_addr[31:0]	: virtual sram access address
	 *output:
	 *	physical_sram_addr[31:0]: physical sram access address
	 *********************/
	input [31:0] virtual_sram_addr;
	output [31:0] physical_sram_addr;
	
	assign physical_sram_addr = ~virtual_sram_addr[31] ? virtual_sram_addr : (virtual_sram_addr[30] ? virtual_sram_addr : {3'b000, virtual_sram_addr[28:0]});
endmodule