module IF_ID_REG(clk, rst_n, IF_ID_Stall, IF_ID_Flush, PC_plus4, IF_ID_PC_plus4_data, Instruction, IF_ID_Instruction_data, is_delayslot, IF_ID_is_delayslot_data, if_fetch_exc_type, IF_ID_if_fetch_exc_type_data, asid, IF_ID_asid_data, instMiss, IF_ID_instMiss_data, instValid, IF_ID_instValid_data);
	/*********************
	 *	IF - ID Pipeline Registers
	 *input:
	 *	clk									: clock
	 *	rst_n								: negetive reset signal
	 *	IF_ID_Stall							: stall the whole IF/ID Pipeline Registers
	 *	IF_ID_Flush							: flush the whole IF/ID Pipeline Registers
	 *	PC_plus4[31:0]						: PC_plus4(which is the output of PCPlus4 module)
	 *	Instruction[31:0]					: Instruction(which is the output of IM cahce)
	 *	is_delayslot						: whether is delayslot instruction
	 *	if_fetch_exc_type[31:0]				: whether happpen fetch exc
	 *	asid[7:0]							: asid
	 *	instMiss							: inst TLB miss signal
	 *	instValid							: inst TLB valid signal
	 *output:
	 *	IF_ID_PC_plus4_data[31:0]			: IF/ID PC_plus4 data
	 *	IF_ID_Instruction_data[31:0]		: IF/ID Instruction data
	 *	IF_ID_is_delayslot_data				: IF/ID is_delayslot data
	 *	IF_ID_if_fetch_exc_type_data[31:0]	: IF/ID fetch_exc data
	 *	IF_ID_asid_data[7:0]				: IF/ID asid data
	 *	IF_ID_instMiss_data					: IF/ID instMiss data
	 *	IF_ID_instValid_data				: IF/ID instValid data
	 *********************/
	input clk, rst_n;
	input IF_ID_Stall, IF_ID_Flush;
	input is_delayslot, instMiss, instValid;
	input [7:0] asid;
	input [31:0] PC_plus4, Instruction, if_fetch_exc_type;
	output IF_ID_is_delayslot_data, IF_ID_instMiss_data, IF_ID_instValid_data;
	output [7:0] IF_ID_asid_data;
	output [31:0] IF_ID_PC_plus4_data, IF_ID_Instruction_data, IF_ID_if_fetch_exc_type_data;
	
	// IF_ID_is_delayslot
	flopr #(1) m_IF_ID_is_delayslot(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(is_delayslot), 
		.data_o(IF_ID_is_delayslot_data)
	);
	
	// IF_ID_if_fetch_exc_type
	flopr #(32) m_IF_ID_if_fetch_exc_type(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(if_fetch_exc_type), 
		.data_o(IF_ID_if_fetch_exc_type_data)
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
	
	// IF_ID_asid
	flopr #(8) m_IF_ID_asid(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(asid), 
		.data_o(IF_ID_asid_data)
	);
	
	// IF_ID_instMiss
	flopr #(1) m_IF_ID_instMiss(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(instMiss), 
		.data_o(IF_ID_instMiss_data)
	);
	
	// IF_ID_instValid
	flopr #(1) m_IF_ID_instValid(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IF_ID_Stall), 
		.flush(IF_ID_Flush), 
		.data_i(instValid), 
		.data_o(IF_ID_instValid_data)
	);
endmodule