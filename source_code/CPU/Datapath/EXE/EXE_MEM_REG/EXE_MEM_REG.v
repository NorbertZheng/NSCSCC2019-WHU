module EXE_MEM_REG(clk, rst_n, EXE_MEM_Stall, EXE_MEM_Flush, exc_mask, EXE_MEM_exc_mask_data, is_delayslot, EXE_MEM_is_delayslot_data, int_i, EXE_MEM_int_i_data, wcp0, EXE_MEM_wcp0_data, store_type, EXE_MEM_store_type_data, load_type, EXE_MEM_load_type_data, hi_i_sel, EXE_MEM_hi_i_sel_data, lo_i_sel,EXE_MEM_lo_i_sel_data, whi, EXE_MEM_whi_data, wlo, EXE_MEM_wlo_data, wreg, EXE_MEM_wreg_data, result_sel, EXE_MEM_result_sel_data, wmem, EXE_MEM_wmem_data, rf_rdata0_fw, EXE_MEM_rf_rdata0_fw_data, rf_rdata1_fw, EXE_MEM_rf_rdata1_fw_data, ALU_result, EXE_MEM_ALU_result_data, SC_result_sel, EXE_MEM_SC_result_sel_data, byte_valid, EXE_MEM_byte_valid_data, MulDiv_result, EXE_MEM_MulDiv_result_data, regdst, EXE_MEM_regdst_data, PC_plus4, EXE_MEM_PC_plus4_data, instruction, EXE_MEM_Instruction_data, tlbr, EXE_MEM_tlbr_data, tlbp, EXE_MEM_tlbp_data, tlbr_result, EXE_MEM_tlbr_result_data);
	/*********************
	 *	EXE - MEM Pipeline Registers
	 *input:
	 *	clk								: clock
	 *	rst_n							: negetive reset signal
	 *	EXE_MEM_Stall					: stall the whole EXE/MEM Pipeline Registers
	 *	EXE_MEM_Flush					: flush the whole EXE/MEM Pipeline Registers
	 *	exc_mask[7:0]					: exc mask(which will collect exc)
	 *	is_delayslot					: whether this instruction is in delayslot
	 *	int_i[4:0]						: int signal
	 *	wcp0							: write COP0 Regs
	 *	store_type[3:0]					: store type
	 *	load_type[3:0]					: load type
	 *	hi_i_sel						: hi_i select signal
	 *	lo_i_sel						: lo_i select signal
	 *	whi								: write HI Reg
	 *	wlo								: write LO Reg
	 *	wreg							: write RegisterFile
	 *	result_sel[1:0]					: result to write into RF select signal
	 *	wmem							: write Mem
	 *	rf_rdata0_fw[31:0]				: RF read data0 with forwarding
	 *	rf_rdata1_fw[31:0]				: RF read data1 with forwarding
	 *	ALU_result[31:0]				: ALU_result
	 *	SC_result_sel					: instruction SC result select signal
	 *	byte_valid[3:0]					: identity which byte in word is valid
	 *	MulDiv_result[63:0]				: Mul / Div result
	 *	regdst[4:0]						: select which reg to write
	 *	PC_plus4[31:0]					: PC_plus4
	 *	tlbr							: tlbr instruction
	 *	tlbp							: tlbp instruction
	 *	tlbr_result[89:0]				: tlbr_result
	 *output:
	 *	EXE_MEM_exc_mask_data[7:0]		: EXE/MEM exc_mask data
	 *	EXE_MEM_is_delayslot_data		: EXE/MEM is_delayslot data
	 *	EXE_MEM_int_i_data[4:0]			: EXE/MEM int_i data
	 *	EXE_MEM_wcp0_data				: EXE/MEM wcp0 data
	 *	EXE_MEM_store_type_data[3:0]	: EXE/MEM store_type data
	 *	EXE_MEM_load_type_data[3:0]		: EXE/MEM load_type data
	 *	EXE_MEM_hi_i_sel_data			: EXE/MEM hi_i_sel data
	 *	EXE_MEM_lo_i_sel_data			: EXE/MEM lo_i_sel data
	 *	EXE_MEM_whi_data				: EXE/MEM whi data
	 *	EXE_MEM_wlo_data				: EXE/MEM wlo data
	 *	EXE_MEM_wreg_data				: EXE/MEM wreg data
	 *	EXE_MEM_result_sel_data[1:0]	: EXE/MEM result_sel data
	 *	EXE_MEM_wmem_data				: EXE/MEM wmem data
	 *	EXE_MEM_rf_rdata0_fw_data[31:0]	: EXE/MEM rf_rdata0_fw data
	 *	EXE_MEM_rf_rdata1_fw_data[31:0]	: EXE/MEM rf_rdata1_fw data
	 *	EXE_MEM_ALU_result_data[31:0]	: EXE/MEM ALU_result data
	 *	EXE_MEM_SC_result_sel_data		: EXE/MEM SC_result_sel data
	 *	EXE_MEM_byte_valid_data[3:0]	: EXE/MEM byte_valid data
	 *	EXE_MEM_MulDiv_result_data[63:0]: EXE/MEM MulDiv_result data
	 *	EXE_MEM_regdst_data[4:0]		: EXE/MEM regdst data
	 *	EXE_MEM_PC_plus4_data[31:0]		: EXE/MEM PC_plus4 data
	 *	EXE_MEM_tlbr_data				: EXE/MEM tlbr data
	 *	EXE_MEM_tlbp_data				: EXE/MEM tlbp data
	 *	EXE_MEM_tlbr_result_data[89:0]	: EXE/MEM tlbr_result data
	 *********************/
	input clk, rst_n;
	input EXE_MEM_Stall, EXE_MEM_Flush;
	input is_delayslot, wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, wmem, SC_result_sel, tlbr, tlbp;
	input [1:0] result_sel;
	input [3:0] store_type, load_type, byte_valid;
	input [4:0] int_i, regdst;
	input [7:0] exc_mask;
	input [31:0] rf_rdata0_fw, rf_rdata1_fw, ALU_result, PC_plus4, instruction;
	input [63:0] MulDiv_result;
	input [89:0] tlbr_result;
	output EXE_MEM_is_delayslot_data, EXE_MEM_wcp0_data, EXE_MEM_hi_i_sel_data, EXE_MEM_lo_i_sel_data, EXE_MEM_whi_data, EXE_MEM_wlo_data, EXE_MEM_wreg_data;
	output EXE_MEM_wmem_data, EXE_MEM_SC_result_sel_data, EXE_MEM_tlbr_data, EXE_MEM_tlbp_data;
	output [1:0] EXE_MEM_result_sel_data;
	output [3:0] EXE_MEM_store_type_data, EXE_MEM_load_type_data, EXE_MEM_byte_valid_data;
	output [4:0] EXE_MEM_int_i_data, EXE_MEM_regdst_data;
	output [7:0] EXE_MEM_exc_mask_data;
	output [31:0] EXE_MEM_rf_rdata0_fw_data, EXE_MEM_rf_rdata1_fw_data, EXE_MEM_ALU_result_data, EXE_MEM_PC_plus4_data, EXE_MEM_Instruction_data;
	output [63:0] EXE_MEM_MulDiv_result_data;
	output [89:0] EXE_MEM_tlbr_result_data;
	
	// EXE_MEM_exc_mask
	flopr #(8) m_EXE_MEM_exc_mask(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(exc_mask), 
		.data_o(EXE_MEM_exc_mask_data)
	);
	
	// EXE_MEM_is_delayslot
	flopr #(1) m_EXE_MEM_is_delayslot(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(is_delayslot), 
		.data_o(EXE_MEM_is_delayslot_data)
	);
	
	// EXE_MEM_int_i
	flopr #(5) m_EXE_MEM_int_i(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(int_i), 
		.data_o(EXE_MEM_int_i_data)
	);
	
	// EXE_MEM_wcp0
	flopr #(1) m_EXE_MEM_wcp0(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(wcp0), 
		.data_o(EXE_MEM_wcp0_data)
	);
	
	// EXE_MEM_store_type
	flopr #(4) m_EXE_MEM_store_type(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(store_type), 
		.data_o(EXE_MEM_store_type_data)
	);
	
	// EXE_MEM_load_type
	flopr #(4) m_EXE_MEM_load_type(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(load_type), 
		.data_o(EXE_MEM_load_type_data)
	);
	
	// EXE_MEM_hi_i_sel
	flopr #(1) m_EXE_MEM_hi_i_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(hi_i_sel), 
		.data_o(EXE_MEM_hi_i_sel_data)
	);
	
	// EXE_MEM_lo_i_sel
	flopr #(1) m_EXE_MEM_lo_i_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(lo_i_sel), 
		.data_o(EXE_MEM_lo_i_sel_data)
	);
	
	// EXE_MEM_whi
	flopr #(1) m_EXE_MEM_whi(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(whi), 
		.data_o(EXE_MEM_whi_data)
	);
	
	// EXE_MEM_wlo
	flopr #(1) m_EXE_MEM_wlo(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(wlo), 
		.data_o(EXE_MEM_wlo_data)
	);
	
	// EXE_MEM_wreg
	flopr #(1) m_EXE_MEM_wreg(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(wreg), 
		.data_o(EXE_MEM_wreg_data)
	);
	
	// EXE_MEM_result_sel
	flopr #(2) m_EXE_MEM_result_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(result_sel), 
		.data_o(EXE_MEM_result_sel_data)
	);
	
	// EXE_MEM_wmem
	flopr #(1) m_EXE_MEM_wmem(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(wmem), 
		.data_o(EXE_MEM_wmem_data)
	);
	
	// EXE_MEM_rf_rdata0_fw
	flopr #(32) m_EXE_MEM_rf_rdata0_fw(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(rf_rdata0_fw), 
		.data_o(EXE_MEM_rf_rdata0_fw_data)
	);
	
	// EXE_MEM_rf_rdata1_fw
	flopr #(32) m_EXE_MEM_rf_rdata1_fw(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(rf_rdata1_fw), 
		.data_o(EXE_MEM_rf_rdata1_fw_data)
	);
	
	// EXE_MEM_ALU_result
	flopr #(32) m_EXE_MEM_ALU_result(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(ALU_result), 
		.data_o(EXE_MEM_ALU_result_data)
	);
	
	// EXE_MEM_SC_result_sel
	flopr #(1) m_EXE_MEM_SC_result_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(SC_result_sel), 
		.data_o(EXE_MEM_SC_result_sel_data)
	);
	
	// EXE_MEM_byte_valid
	flopr #(4) m_EXE_MEM_byte_valid(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(byte_valid), 
		.data_o(EXE_MEM_byte_valid_data)
	);
	
	// EXE_MEM_MulDiv_result
	flopr #(64) m_EXE_MEM_MulDiv_result(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(MulDiv_result), 
		.data_o(EXE_MEM_MulDiv_result_data)
	);
	
	// EXE_MEM_regdst
	flopr #(5) m_EXE_MEM_regdst(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(regdst), 
		.data_o(EXE_MEM_regdst_data)
	);
	
	// EXE_MEM_PC_plus4
	flopr #(32) m_EXE_MEM_PC_plus4(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(PC_plus4), 
		.data_o(EXE_MEM_PC_plus4_data)
	);
	
	// EXE_MEM_tlbr
	flopr #(1) m_EXE_MEM_tlbr(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(tlbr), 
		.data_o(EXE_MEM_tlbr_data)
	);
	
	// EXE_MEM_tlbp
	flopr #(1) m_EXE_MEM_tlbp(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(tlbp), 
		.data_o(EXE_MEM_tlbp_data)
	);
	
	// EXE_MEM_tlbr_result
	flopr #(90) m_EXE_MEM_tlbr_result(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(tlbr_result), 
		.data_o(EXE_MEM_tlbr_result_data)
	);
	
	// EXE_MEM_Instruction
	flopr #(32) m_EXE_MEM_Instruction(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(EXE_MEM_Stall), 
		.flush(EXE_MEM_Flush), 
		.data_i(instruction), 
		.data_o(EXE_MEM_Instruction_data)
	);
endmodule