module EXE_MEM_REG_PACKED(clk, rst_n, stall0, stall1, irq, clr, exc_type, EXE_MEM_exc_type_data, is_delayslot, EXE_MEM_is_delayslot_data, int_i, EXE_MEM_int_i_data, wcp0, EXE_MEM_wcp0_data, store_type, EXE_MEM_store_type_data, load_type, EXE_MEM_load_type_data, hi_i_sel, EXE_MEM_hi_i_sel_data, lo_i_sel,EXE_MEM_lo_i_sel_data, whi, EXE_MEM_whi_data, wlo, EXE_MEM_wlo_data, wreg, EXE_MEM_wreg_data, result_sel, EXE_MEM_result_sel_data, wmem, EXE_MEM_wmem_data, rf_rdata0_fw, EXE_MEM_rf_rdata0_fw_data, rf_rdata1_fw, EXE_MEM_rf_rdata1_fw_data, ALU_result, EXE_MEM_ALU_result_data, SC_result_sel, EXE_MEM_SC_result_sel_data, byte_valid, EXE_MEM_byte_valid_data, MulDiv_result, EXE_MEM_MulDiv_result_data, regdst, EXE_MEM_regdst_data, PC_plus4, EXE_MEM_PC_plus4_data, instruction, EXE_MEM_Instruction_data, tlbr, EXE_MEM_tlbr_data, tlbp, EXE_MEM_tlbp_data, tlbr_result, EXE_MEM_tlbr_result_data, asid, EXE_MEM_asid_data, eret, EXE_MEM_eret_data, instMiss, EXE_MEM_instMiss_data, instValid, EXE_MEM_instValid_data);
	/*********************
	 *	EXE - MEM Pipeline Registers PACKED
	 *input:
	 *	clk								: clock
	 *	rst_n							: negetive reset signal
	 *	stall0							: stall0 signal
	 *	stall1							: stall1 signal
	 *	irq								: int request
	 *	clr								: clr signal
	 *	exc_type[31:0]					: exc mask(which will collect exc)
	 *	is_delayslot					: whether this instruction is in delayslot
	 *	int_i[5:0]						: int signal
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
	 *	asid[7:0]						: asid
	 *	eret							: eret instruction 
	 *	instMiss						: inst TLB miss signal
	 *	instValid						: inst TLB valid signal
	 *output:
	 *	EXE_MEM_exc_type_data[31:0]		: EXE/MEM exc_type data
	 *	EXE_MEM_is_delayslot_data		: EXE/MEM is_delayslot data
	 *	EXE_MEM_int_i_data[5:0]			: EXE/MEM int_i data
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
	 *	EXE_MEM_asid_data[7:0]			: EXE/MEM asid data
	 *	EXE_MEM_eret_data				: EXE/MEM eret data
	 *	EXE_MEM_instMiss_data			: EXE/MEM instMiss data
	 *	EXE_MEM_instValid_data			: EXE/MEM instValid data
	 *********************/
	input clk, rst_n;
	input stall0, stall1, irq, clr;
	input is_delayslot, wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, wmem, SC_result_sel, tlbr, tlbp, eret, instMiss, instValid;
	input [1:0] result_sel;
	input [3:0] store_type, load_type, byte_valid;
	input [4:0] regdst;
	input [5:0] int_i;
	input [7:0] asid;
	input [31:0] rf_rdata0_fw, rf_rdata1_fw, ALU_result, PC_plus4, instruction, exc_type;
	input [63:0] MulDiv_result;
	input [89:0] tlbr_result;
	output EXE_MEM_is_delayslot_data, EXE_MEM_wcp0_data, EXE_MEM_hi_i_sel_data, EXE_MEM_lo_i_sel_data, EXE_MEM_whi_data, EXE_MEM_wlo_data, EXE_MEM_wreg_data;
	output EXE_MEM_wmem_data, EXE_MEM_SC_result_sel_data, EXE_MEM_tlbr_data, EXE_MEM_tlbp_data, EXE_MEM_eret_data, EXE_MEM_instMiss_data, EXE_MEM_instValid_data;
	output [1:0] EXE_MEM_result_sel_data;
	output [3:0] EXE_MEM_store_type_data, EXE_MEM_load_type_data, EXE_MEM_byte_valid_data;
	output [4:0] EXE_MEM_regdst_data;
	output [5:0] EXE_MEM_int_i_data;
	output [7:0] EXE_MEM_asid_data;
	output [31:0] EXE_MEM_rf_rdata0_fw_data, EXE_MEM_rf_rdata1_fw_data, EXE_MEM_ALU_result_data, EXE_MEM_PC_plus4_data, EXE_MEM_Instruction_data
				, EXE_MEM_exc_type_data;
	output [63:0] EXE_MEM_MulDiv_result_data;
	output [89:0] EXE_MEM_tlbr_result_data;
	
	wire EXE_MEM_Stall = (stall0 || stall1) && ~irq;
	wire EXE_MEM_Flush = irq || clr;
	// EXE_MEM_REG
	EXE_MEM_REG m_EXE_MEM_REG(
		.clk(clk), 
		.rst_n(rst_n), 
		.EXE_MEM_Stall(EXE_MEM_Stall), 
		.EXE_MEM_Flush(EXE_MEM_Flush), 
		.exc_type(exc_type), 
		.EXE_MEM_exc_type_data(EXE_MEM_exc_type_data), 
		.is_delayslot(is_delayslot), 
		.EXE_MEM_is_delayslot_data(EXE_MEM_is_delayslot_data), 
		.int_i(int_i), 
		.EXE_MEM_int_i_data(EXE_MEM_int_i_data), 
		.wcp0(wcp0), 
		.EXE_MEM_wcp0_data(EXE_MEM_wcp0_data), 
		.store_type(store_type), 
		.EXE_MEM_store_type_data(EXE_MEM_store_type_data), 
		.load_type(load_type), 
		.EXE_MEM_load_type_data(EXE_MEM_load_type_data), 
		.hi_i_sel(hi_i_sel), 
		.EXE_MEM_hi_i_sel_data(EXE_MEM_hi_i_sel_data), 
		.lo_i_sel(lo_i_sel),
		.EXE_MEM_lo_i_sel_data(EXE_MEM_lo_i_sel_data), 
		.whi(whi), 
		.EXE_MEM_whi_data(EXE_MEM_whi_data), 
		.wlo(wlo), 
		.EXE_MEM_wlo_data(EXE_MEM_wlo_data), 
		.wreg(wreg), 
		.EXE_MEM_wreg_data(EXE_MEM_wreg_data), 
		.result_sel(result_sel), 
		.EXE_MEM_result_sel_data(EXE_MEM_result_sel_data), 
		.wmem(wmem), 
		.EXE_MEM_wmem_data(EXE_MEM_wmem_data), 
		.rf_rdata0_fw(rf_rdata0_fw), 
		.EXE_MEM_rf_rdata0_fw_data(EXE_MEM_rf_rdata0_fw_data), 
		.rf_rdata1_fw(rf_rdata1_fw), 
		.EXE_MEM_rf_rdata1_fw_data(EXE_MEM_rf_rdata1_fw_data), 
		.ALU_result(ALU_result), 
		.EXE_MEM_ALU_result_data(EXE_MEM_ALU_result_data), 
		.SC_result_sel(SC_result_sel), 
		.EXE_MEM_SC_result_sel_data(EXE_MEM_SC_result_sel_data), 
		.byte_valid(byte_valid), 
		.EXE_MEM_byte_valid_data(EXE_MEM_byte_valid_data), 
		.MulDiv_result(MulDiv_result), 
		.EXE_MEM_MulDiv_result_data(EXE_MEM_MulDiv_result_data), 
		.regdst(regdst), 
		.EXE_MEM_regdst_data(EXE_MEM_regdst_data), 
		.PC_plus4(PC_plus4), 
		.EXE_MEM_PC_plus4_data(EXE_MEM_PC_plus4_data),
		.tlbr(tlbr),
		.EXE_MEM_tlbr_data(EXE_MEM_tlbr_data),
		.tlbp(tlbp),
		.EXE_MEM_tlbp_data(EXE_MEM_tlbp_data),
		.tlbr_result(tlbr_result),
		.EXE_MEM_tlbr_result_data(EXE_MEM_tlbr_result_data),
		.asid(asid),
		.EXE_MEM_asid_data(EXE_MEM_asid_data),
		.eret(eret),
		.EXE_MEM_eret_data(EXE_MEM_eret_data),
		.instMiss(instMiss),
		.EXE_MEM_instMiss_data(EXE_MEM_instMiss_data),
		.instValid(instValid),
		.EXE_MEM_instValid_data(EXE_MEM_instValid_data),
		// for test
		.instruction(instruction),
		.EXE_MEM_Instruction_data(EXE_MEM_Instruction_data)
	);
endmodule