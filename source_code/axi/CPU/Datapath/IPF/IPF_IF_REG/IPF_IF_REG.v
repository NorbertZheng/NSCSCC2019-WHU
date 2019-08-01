module IPF_IF_REG(clk, rst_n, IPF_IF_Stall, IPF_IF_Flush, PC_plus4, IPF_IF_PC_plus4_data, Instruction, IPF_IF_Instruction_data, is_delayslot, IPF_IF_is_delayslot_data, if_fetch_exc_type, IPF_IF_if_fetch_exc_type_data, asid, IPF_IF_asid_data, instMiss, IPF_IF_instMiss_data, instValid, IPF_IF_instValid_data);
	/*********************
	 *	IF - ID Pipeline Registers
	 *input:
	 *	clk									: clock
	 *	rst_n								: negetive reset signal
	 *	IPF_IF_Stall						: stall the whole IPF/IF Pipeline Registers
	 *	IPF_IF_Flush						: flush the whole IPF/IF Pipeline Registers
	 *	PC_plus4[31:0]						: PC_plus4(which is the output of PCPlus4 module)
	 *	is_delayslot						: whether is delayslot instruction
	 *	if_fetch_exc_type[31:0]				: whether happpen fetch exc
	 *	asid[7:0]							: asid
	 *	instMiss							: inst TLB miss signal
	 *	instValid							: inst TLB valid signal
	 *output:
	 *	IPF_IF_PC_plus4_data[31:0]			: IPF/IF PC_plus4 data
	 *	IPF_IF_is_delayslot_data			: IPF/IF is_delayslot data
	 *	IPF_IF_if_fetch_exc_type_data[31:0]	: IPF/IF fetch_exc data
	 *	IPF_IF_asid_data[7:0]				: IPF/IF asid data
	 *	IPF_IF_instMiss_data				: IPF/IF instMiss data
	 *	IPF_IF_instValid_data				: IPF/IF instValid data
	 *********************/
	input clk, rst_n;
	input IPF_IF_Stall, IPF_IF_Flush;
	input is_delayslot, instMiss, instValid;
	input [7:0] asid;
	input [31:0] PC_plus4, if_fetch_exc_type;
	output IPF_IF_is_delayslot_data, IPF_IF_instMiss_data, IPF_IF_instValid_data;
	output [7:0] IPF_IF_asid_data;
	output [31:0] IPF_IF_PC_plus4_data, IPF_IF_if_fetch_exc_type_data;
	
	// IPF_IF_is_delayslot
	flopr #(1) m_IPF_IF_is_delayslot(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IPF_IF_Stall), 
		.flush(IPF_IF_Flush), 
		.data_i(is_delayslot), 
		.data_o(IPF_IF_is_delayslot_data)
	);
	
	// IPF_IF_if_fetch_exc_type
	flopr #(32) m_IPF_IF_if_fetch_exc_type(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IPF_IF_Stall), 
		.flush(IPF_IF_Flush), 
		.data_i(if_fetch_exc_type), 
		.data_o(IPF_IF_if_fetch_exc_type_data)
	);
	
	// IPF_IF_PCplus4
	flopr #(32) m_IPF_IF_PCplus4(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IPF_IF_Stall), 
		.flush(IPF_IF_Flush), 
		.data_i(PC_plus4), 
		.data_o(IPF_IF_PC_plus4_data)
	);
	
	// IPF_IF_asid
	flopr #(8) m_IPF_IF_asid(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IPF_IF_Stall), 
		.flush(IPF_IF_Flush), 
		.data_i(asid), 
		.data_o(IPF_IF_asid_data)
	);
	
	// IPF_IF_instMiss
	flopr #(1) m_IPF_IF_instMiss(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IPF_IF_Stall), 
		.flush(IPF_IF_Flush), 
		.data_i(instMiss), 
		.data_o(IPF_IF_instMiss_data)
	);
	
	// IPF_IF_instValid
	flopr #(1) m_IPF_IF_instValid(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(IPF_IF_Stall), 
		.flush(IPF_IF_Flush), 
		.data_i(instValid), 
		.data_o(IPF_IF_instValid_data)
	);
endmodule