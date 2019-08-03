module PCPlus4(PC_o, PC_plus4);
	/*********************
	 *	32-bit PC plus 4
	 *input:
	 *	PC_o[31:0]			: 32-bit PC value
	 *output:
	 *	PC_plus4[31:0]		: 32-bit PC_plus4
	 *********************/
	input [31:0] PC_o;
	output [31:0] PC_plus4;
	
	// PCPlus4_cal32
	cla32 PCPlus4_cal32(
		.a(PC_o), 
		.b(32'h4), 
		.ci(1'b0), 
		.s(PC_plus4), 
		.co()
	);
endmodule