module IF_ID_REG_PACKED(clk, rst_n, stall0, stall1, stall2, stall3, irq, PC_plus4, IF_ID_PC_plus4_data, Instruction, IF_ID_Instruction_data, is_delayslot, IF_ID_is_delayslot_data, fetch_exc, IF_ID_fetch_exc_data);
	/*********************
	 *	IF - ID Pipeline Registers PACKED
	 *input:
	 *	clk							: clock
	 *	rst_n						: negetive reset signal
	 *	stall0						: stall0 signal
	 *	stall1						: stall1 signal
	 *	stall2						: stall2 signal
	 *	stall3						: stall3 signal
	 *	irq							: int request signal
	 *	PC_plus4[31:0]				: PC_plus4(which is the output of PCPlus4 module)
	 *	Instruction[31:0]			: Instruction(which is the output of IM cahce)
	 *	is_delayslot				: whether is delayslot instruction
	 *	fetch_exc[7:0]				: whether happpen fetch exc
	 *output:
	 *	IF_ID_PC_plus4_data[31:0]	: IF/ID PC_plus4 data
	 *	IF_ID_Instruction_data[31:0]: IF/ID Instruction data
	 *	IF_ID_is_delayslot_data		: IF/ID is_delayslot data
	 *	IF_ID_fetch_exc_data[7:0]	: IF/ID fetch_exc data
	 *********************/
	input clk, rst_n;
	input stall0, stall1, stall2, stall3, irq;
	input is_delayslot;
	input [7:0] fetch_exc;
	input [31:0] PC_plus4, Instruction;
	output IF_ID_is_delayslot_data;
	output [7:0] IF_ID_fetch_exc_data;
	output [31:0] IF_ID_PC_plus4_data, IF_ID_Instruction_data;
	
	wire IF_ID_Flush = irq;
	wire IF_ID_Stall = (stall0 || stall1 || stall2 || stall3) & ~irq;		// irq 的优先级更高，直接 flush 掉
	
	// IF_ID_REG
	IF_ID_REG m_IF_ID_REG(
		.clk(clk), 
		.rst_n(rst_n), 
		.IF_ID_Stall(IF_ID_Stall), 
		.IF_ID_Flush(IF_ID_Flush), 
		.PC_plus4(PC_plus4), 
		.IF_ID_PC_plus4_data(IF_ID_PC_plus4_data), 
		.Instruction(Instruction), 
		.IF_ID_Instruction_data(IF_ID_Instruction_data), 
		.is_delayslot(is_delayslot), 
		.IF_ID_is_delayslot_data(IF_ID_is_delayslot_data), 
		.fetch_exc(fetch_exc), 
		.IF_ID_fetch_exc_data(IF_ID_fetch_exc_data)
	);
endmodule