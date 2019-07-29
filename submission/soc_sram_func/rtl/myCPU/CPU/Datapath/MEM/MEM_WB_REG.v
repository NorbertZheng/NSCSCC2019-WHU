module MEM_WB_REG(clk, rst_n, MEM_WB_Stall, MEM_WB_Flush, wcp0, MEM_WB_wcp0_data, load_type, MEM_WB_load_type_data, hi_i_sel, MEM_WB_hi_i_sel_data, lo_i_sel,MEM_WB_lo_i_sel_data, whi, MEM_WB_whi_data, wlo, MEM_WB_wlo_data, wreg, MEM_WB_wreg_data, result_sel, MEM_WB_result_sel_data,  rf_rdata0_fw, MEM_WB_rf_rdata0_fw_data, rf_rdata1_fw, MEM_WB_rf_rdata1_fw_data, ALU_result, MEM_WB_ALU_result_data, SC_result_sel, MEM_WB_SC_result_sel_data, byte_valid, MEM_WB_byte_valid_data, MulDiv_result, MEM_WB_MulDiv_result_data, regdst, MEM_WB_regdst_data, mem_rdata, MEM_WB_mem_rdata_data, PC_plus4, MEM_WB_PC_plus4_data, instruction, MEM_WB_Instruction_data);
	/*********************
	 *	MEM - WB Pipeline Registers
	 *input:
	 *	clk								: clock
	 *	rst_n							: negetive reset signal
	 *	MEM_WB_Stall					: stall the whole MEM/WB Pipeline Registers
	 *	MEM_WB_Flush					: flush the whole MEM/WB Pipeline Registers
	 *	wcp0							: write COP0 Regs
	 *	load_type[3:0]					: load type
	 *	hi_i_sel						: hi_i select signal
	 *	lo_i_sel						: lo_i select signal
	 *	whi								: write HI Reg
	 *	wlo								: write LO Reg
	 *	wreg							: write RegisterFile
	 *	result_sel[1:0]					: result to write into RF select signal
	 *	rf_rdata0_fw[31:0]				: RF read data0 with forwarding
	 *	rf_rdata1_fw[31:0]				: RF read data1 with forwarding
	 *	ALU_result[31:0]				: ALU_result
	 *	SC_result_sel					: instruction SC result select signal
	 *	byte_valid[3:0]					: identity which byte in word is valid
	 *	MulDiv_result[63:0]				: Mul / Div result
	 *	regdst[4:0]						: select which reg to write
	 *	mem_rdata[31:0]					: mem read data
	 *	PC_plus4[31:0]					: PC_plus4 data
	 *output:
	 *	MEM_WB_wcp0_data				: MEM/WB wcp0 data
	 *	MEM_WB_load_type_data[3:0]		: MEM/WB load_type data
	 *	MEM_WB_hi_i_sel_data			: MEM/WB hi_i_sel data
	 *	MEM_WB_lo_i_sel_data			: MEM/WB lo_i_sel data
	 *	MEM_WB_whi_data					: MEM/WB whi data
	 *	MEM_WB_wlo_data					: MEM/WB wlo data
	 *	MEM_WB_wreg_data				: MEM/WB wreg data
	 *	MEM_WB_result_sel_data[1:0]		: MEM/WB result_sel data
	 *	MEM_WB_rf_rdata0_fw_data[31:0]	: MEM/WB rf_rdata0_fw data
	 *	MEM_WB_rf_rdata1_fw_data[31:0]	: MEM/WB rf_rdata1_fw data
	 *	MEM_WB_ALU_result_data[31:0]	: MEM/WB ALU_result data
	 *	MEM_WB_SC_result_sel_data		: MEM/WB SC_result_sel data
	 *	MEM_WB_byte_valid_data[3:0]		: MEM/WB byte_valid data
	 *	MEM_WB_MulDiv_result_data[63:0]	: MEM/WB MulDiv_result data
	 *	MEM_WB_regdst_data[4:0]			: MEM/WB regdst data
	 *	MEM_WB_mem_rdata_data[31:0]		: MEM/WB mem_rdata data
	 *	MEM_WB_PC_plus4_data[31:0]		: MEM/WB PC_plus4 data
	 *********************/
	input clk, rst_n;
	input MEM_WB_Stall, MEM_WB_Flush;
	input wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, SC_result_sel;
	input [1:0] result_sel;
	input [3:0] load_type, byte_valid;
	input [4:0] regdst;
	input [31:0] rf_rdata0_fw, rf_rdata1_fw, ALU_result, mem_rdata, PC_plus4, instruction;
	input [63:0] MulDiv_result;
	output MEM_WB_wcp0_data, MEM_WB_hi_i_sel_data, MEM_WB_lo_i_sel_data, MEM_WB_whi_data, MEM_WB_wlo_data, MEM_WB_wreg_data, MEM_WB_SC_result_sel_data;
	output [1:0] MEM_WB_result_sel_data;
	output [3:0] MEM_WB_load_type_data, MEM_WB_byte_valid_data;
	output [4:0] MEM_WB_regdst_data;
	output [31:0] MEM_WB_rf_rdata0_fw_data, MEM_WB_rf_rdata1_fw_data, MEM_WB_ALU_result_data, MEM_WB_mem_rdata_data, MEM_WB_PC_plus4_data, MEM_WB_Instruction_data;
	output [63:0] MEM_WB_MulDiv_result_data;
	
	// MEM_WB_wcp0
	flopr #(1) m_MEM_WB_wcp0(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(wcp0), 
		.data_o(MEM_WB_wcp0_data)
	);

	// MEM_WB_load_type
	flopr #(4) m_MEM_WB_load_type(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(load_type), 
		.data_o(MEM_WB_load_type_data)
	);
	
	// MEM_WB_hi_i_sel
	flopr #(1) m_MEM_WB_hi_i_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(hi_i_sel), 
		.data_o(MEM_WB_hi_i_sel_data)
	);
	
	// MEM_WB_lo_i_sel
	flopr #(1) m_MEM_WB_lo_i_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(lo_i_sel), 
		.data_o(MEM_WB_lo_i_sel_data)
	);
	
	// MEM_WB_whi
	flopr #(1) m_MEM_WB_whi(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(whi), 
		.data_o(MEM_WB_whi_data)
	);
	
	// MEM_WB_wlo
	flopr #(1) m_MEM_WB_wlo(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(wlo), 
		.data_o(MEM_WB_wlo_data)
	);
	
	// MEM_WB_wreg
	flopr #(1) m_MEM_WB_wreg(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(wreg), 
		.data_o(MEM_WB_wreg_data)
	);
	
	// MEM_WB_result_sel
	flopr #(2) m_MEM_WB_result_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(result_sel), 
		.data_o(MEM_WB_result_sel_data)
	);

	// MEM_WB_rf_rdata0_fw
	flopr #(32) m_MEM_WB_rf_rdata0_fw(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(rf_rdata0_fw), 
		.data_o(MEM_WB_rf_rdata0_fw_data)
	);
	
	// MEM_WB_rf_rdata1_fw
	flopr #(32) m_MEM_WB_rf_rdata1_fw(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(rf_rdata1_fw), 
		.data_o(MEM_WB_rf_rdata1_fw_data)
	);
	
	// MEM_WB_ALU_result
	flopr #(32) m_MEM_WB_ALU_result(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(ALU_result), 
		.data_o(MEM_WB_ALU_result_data)
	);
	
	// MEM_WB_SC_result_sel
	flopr #(1) m_MEM_WB_SC_result_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(SC_result_sel), 
		.data_o(MEM_WB_SC_result_sel_data)
	);
	
	// MEM_WB_byte_valid
	flopr #(4) m_MEM_WB_byte_valid(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(byte_valid), 
		.data_o(MEM_WB_byte_valid_data)
	);
	
	// MEM_WB_MulDiv_result
	flopr #(64) m_MEM_WB_MulDiv_result(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(MulDiv_result), 
		.data_o(MEM_WB_MulDiv_result_data)
	);
	
	// MEM_WB_regdst
	flopr #(5) m_MEM_WB_regdst(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(regdst), 
		.data_o(MEM_WB_regdst_data)
	);
	
	// MEM_WB_mem_rdata
	flopr #(32) m_MEM_WB_mem_rdata(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(mem_rdata), 
		.data_o(MEM_WB_mem_rdata_data)
	);	
	
	// MEM_WB_PC_plus4
	flopr #(32) m_MEM_WB_PC_plus4(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(PC_plus4), 
		.data_o(MEM_WB_PC_plus4_data)
	);
	
	// MEM_WB_Instruction
	flopr #(32) m_MEM_WB_Instruction(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(MEM_WB_Stall), 
		.flush(MEM_WB_Flush), 
		.data_i(instruction), 
		.data_o(MEM_WB_Instruction_data)
	);
endmodule