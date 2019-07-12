module IF_ID_REG(clk, rst_n, IF_ID_Stall, IF_ID_Flush, PC_plus4, IF_ID_PC_plus4_data, Instruction, IF_ID_Instruction_data, is_delayslot, IF_ID_is_delayslot_data, fetch_exc, IF_ID_fetch_exc_data);
	/*********************
	 *	IF - ID Pipeline Registers
	 *input:
	 *	clk							: clock
	 *	rst_n						: negetive reset signal
	 *	IF_ID_Stall					: stall the whole IF/ID Pipeline Registers
	 *	IF_ID_Flush					: flush the whole IF/ID Pipeline Registers
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
	input IF_ID_Stall, IF_ID_Flush;
	input is_delayslot;
	input [7:0] fetch_exc;
	input [31:0] PC_plus4, Instruction;
	output IF_ID_is_delayslot_data;
	output [7:0] IF_ID_fetch_exc_data;
	output [31:0] IF_ID_PC_plus4_data, IF_ID_Instruction_data;
	
	// IF_ID_is_delayslot
	flopr #(1) m_IF_ID_is_delayslot(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(is_delayslot), 
		.data_o(IF_ID_is_delayslot_data)
	);
	
	// IF_ID_fetch_exc
	flopr #(8) m_IF_ID_fetch_exc(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(fetch_exc), 
		.data_o(IF_ID_fetch_exc_data)
	);
	
	// IF_ID_PCplus4
	flopr #(32) m_IF_ID_PCplus4(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(PC_plus4), 
		.data_o(IF_ID_PC_plus4_data)
	);
	
	// IF_ID_Instruction
	flopr #(32) m_IF_ID_Instruction(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(Instruction), 
		.data_o(IF_ID_Instruction_data)
	);
endmodule