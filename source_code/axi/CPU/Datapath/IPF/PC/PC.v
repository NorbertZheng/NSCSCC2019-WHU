module PC(clk, rst_n, stall0, stall1, stall2, stall3, PC_exc_i, PC_target_i, PC_exc_sel, PC_target_sel, PC_o, PC_plus4, if_fetch_exc_type);
	/*********************
	 *	32-bit Packed PC 
	 *input:
	 *	clk						: clock
	 *	rst_n					: negetive reset signal
	 *	stall0					: stall0 signal
	 *	stall1					: stall1 signal
	 *	stall2					: stall2 signal
	 *	stall3					: stall3 signal
	 *	PC_exc_i[31:0]			: 32-bit Exc PC value			// 中断接口（优先）
	 *	PC_target_i[31:0]		: 32-bit Target PC value		// 常规跳转接口
	 *	PC_exc_sel				: whether select PC_exc_i(priorty first)
	 *	PC_target_sel			: whether select PC_target_i
	 *output:
	 *	PC_o[31:0]				: 32-bit PC value
	 *	PC_plus4[31:0]			: 32-bit PC_plus4
	 *	if_fetch_exc_type[31:0]	: 32-bit Exc Code (part)
	 *********************/
	input clk, rst_n;
	input stall0, stall1, stall2, stall3;
	// input minus4;
	input PC_exc_sel, PC_target_sel;
	input [31:0] PC_exc_i, PC_target_i;
	output [31:0] PC_o, PC_plus4, if_fetch_exc_type;
	
	wire wpc = ~(stall0 || stall1 || stall2 || stall3) || PC_exc_sel;
	wire [31:0] PC_i, tempPC_i;
	// targetPC_Mux
	Mux2T1 #(32, 1) m_targetPC_Mux(
		.s(PC_target_sel), 
		.y(tempPC_i), 
		.d0(PC_plus4), 
		.d1(PC_target_i)
	);
	// excPC_Mux
	Mux2T1 #(32, 1) m_excPC_Mux(
		.s(PC_exc_sel), 
		.y(PC_i), 
		.d0(tempPC_i), 
		.d1(PC_exc_i)
	);
	// PCReg
	PCReg m_PCReg(
		.clk(clk), 
		.rst_n(rst_n), 
		.wpc(wpc), 
		// .minus4(minus4),
		.PC_i(PC_i), 
		.PC_o(PC_o)
	);
	// PCPlus4
	PCPlus4 m_PCPlus4(
		.PC_o(PC_o), 
		.PC_plus4(PC_plus4)
	);
	assign if_fetch_exc_type = (~|PC_o[1:0]) ? 32'h0000 : 32'h0010;
endmodule