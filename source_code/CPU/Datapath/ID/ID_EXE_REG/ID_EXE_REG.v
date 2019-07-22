module ID_EXE_REG(clk, rst_n, ID_EXE_Stall, ID_EXE_Flush, is_div, ID_EXE_is_div_data, is_sign_div, ID_EXE_is_sign_div_data, exc_mask, ID_EXE_exc_mask_data, is_delayslot, ID_EXE_is_delayslot_data, wcp0, ID_EXE_wcp0_data, store_type, ID_EXE_store_type_data, load_type, ID_EXE_load_type_data, hi_i_sel, ID_EXE_hi_i_sel_data, lo_i_sel, ID_EXE_lo_i_sel_data, whi, ID_EXE_whi_data, wlo, ID_EXE_wlo_data, wreg, ID_EXE_wreg_data, result_sel, ID_EXE_result_sel_data, wmem, ID_EXE_wmem_data, aluop, ID_EXE_aluop_data, alusrc0_sel, ID_EXE_alusrc0_sel_data, alusrc1_sel, ID_EXE_alusrc1_sel_data, regdst, ID_EXE_regdst_data, rf_rdata0, ID_EXE_rf_rdata0_data, rf_rdata1, ID_EXE_rf_rdata1_data, hi, ID_EXE_hi_data, lo, ID_EXE_lo_data, COP0_data, ID_EXE_COP0_data_data, rs, ID_EXE_rs_data, rt, ID_EXE_rt_data, rd, ID_EXE_rd_data, Imm32, ID_EXE_Imm32_data, PC_plus4, ID_EXE_PC_plus4_data, fetch_exc, ID_EXE_fetch_exc_data, instruction, ID_EXE_Instruction_data, tlb_addr, ID_EXE_tlb_addr_data, tlb_wdata, ID_EXE_tlb_wdata_data, tlbr, ID_EXE_tlbr_data, tlbp, ID_EXE_tlbp_data, wtlb, ID_EXE_wtlb_data);
	/*********************
	 *	ID - EXE Pipeline Registers
	 *input:
	 *	clk							: clock
	 *	rst_n						: negetive reset signal
	 *	ID_EXE_Stall				: stall the whole ID/EXE Pipeline Registers
	 *	ID_EXE_Flush				: flush the whole ID/EXE Pipeline Registers
	 *	is_div						: whether is div operation
	 *	is_sign_div					: whether is sign div operation
	 *	exc_mask[7:0]				: exc mask(which will collect exc)
	 *	is_delayslot				: whether this instruction is in delayslot
	 *	wcp0						: write COP0 Regs
	 *	store_type[3:0]				: store type
	 *	load_type[3:0]				: load type
	 *	hi_i_sel					: hi_i select signal
	 *	lo_i_sel					: lo_i select signal
	 *	whi							: write HI Reg
	 *	wlo							: write LO Reg
	 *	wreg						: write RegisterFile
	 *	result_sel[1:0]				: result to write into RF select signal
	 *	wmem						: write Mem
	 *	aluop[7:0]					: ALU opcode
	 *	alusrc0_sel					: ALU src0 select signal
	 *	alusrc1_sel[1:0]			: ALU src1 select signal
	 *	regdst[1:0]					: reg which to write select signal
	 *	rf_rdata0[31:0]				: RF read data0
	 *	rf_rdata1[31:0]				: RF read data1
	 *	hi[31:0]					: HI read data
	 *	lo[31:0]					: LO read data
	 *	COP0_data[31:0]				: COP0 read data
	 *	rs[4:0]						: instruction rs segment
	 *	rt[4:0]						: instruction rt segment
	 *	rd[4:0]						: instruction rd segment
	 *	Imm32[31:0]					: Imm16 extend data
	 *	PC_plus4[31:0]				: PC_plus4 data
	 *	fetch_exc[7:0]				: instruction fetch exc?
	 *	tlb_addr[4:0]				: TLB access address
	 *	tlb_wdata[89:0]				: TLB write data
	 *	tlbr						: tlbr instruction signal
	 *	tlbp						: tlbp instruction signal
	 *	wtlb						: write TLB signal
	 *output:
	 *	ID_EXE_is_div_data			: ID/EXE is_div data
	 *	ID_EXE_is_sign_div_data		: ID/EXE is_sign_div data
	 *	ID_EXE_exc_mask_data[7:0]	: ID/EXE exc_mask data
	 *	ID_EXE_is_delayslot_data	: ID/EXE is_delayslot data
	 *	ID_EXE_wcp0_data			: ID/EXE wcp0 data
	 *	ID_EXE_store_type_data[3:0]	: ID/EXE store_type data
	 *	ID_EXE_load_type_data[3:0]	: ID/EXE load_type data
	 *	ID_EXE_hi_i_sel_data		: ID/EXE hi_i_sel data
	 *	ID_EXE_lo_i_sel_data		: ID/EXE lo_i_sel data
	 *	ID_EXE_whi_data				: ID/EXE whi data
	 *	ID_EXE_wlo_data				: ID/EXE wlo data
	 *	ID_EXE_wreg_data			: ID/EXE wreg data
	 *	ID_EXE_result_sel_data[1:0]	: ID/EXE result_sel data
	 *	ID_EXE_wmem_data			: ID/EXE wmem data
	 *	ID_EXE_aluop_data[7:0]		: ID/EXE aluop data
	 *	ID_EXE_alusrc0_sel_data		: ID/EXE alusrc0_sel data
	 *	ID_EXE_alusrc1_sel_data[1:0]: ID/EXE alusrc1_sel data
	 *	ID_EXE_regdst_data[1:0]		: ID/EXE regdst data
	 *	ID_EXE_rf_rdata0_data[31:0]	: ID/EXE rf_rdata0 data
	 *	ID_EXE_rf_rdata1_data[31:0]	: ID/EXE rf_rdata1 data
	 *	ID_EXE_hi_data[31:0]		: ID/EXE hi data
	 *	ID_EXE_lo_data[31:0]		: ID/EXE lo data
	 *	ID_EXE_COP0_data_data[31:0]	: ID/EXE COP0_data data
	 *	ID_EXE_rs_data[4:0]			: ID/EXE rs data
	 *	ID_EXE_rt_data[4:0]			: ID/EXE rt data
	 *	ID_EXE_rd_data[4:0]			: ID/EXE rd data
	 *	ID_EXE_Imm32_data[31:0]		: ID/EXE Imm32 data
	 *	ID_EXE_PC_plus4_data[31:0]	: ID/EXE PC_plus4 data
	 *	ID_EXE_fetch_exc_data[7:0]	: ID/EXE fetch_exc data
	 *	ID_EXE_tlb_addr_data[4:0]	: ID/EXE tlb_addr data
	 *	ID_EXE_tlb_wdata_data[89:0]	: ID/EXE tlb_wdata data
	 *	ID_EXE_tlbr_data			: ID/EXE tlbr data
	 *	ID_EXE_tlbp_data			: ID/EXE tlbp data
	 *	ID_EXE_wtlb_data			: ID/EXE wtlb data
	 *********************/
	input clk, rst_n;
	input ID_EXE_Stall, ID_EXE_Flush;
	input is_div, is_sign_div, is_delayslot, wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, wmem, alusrc0_sel, tlbr, tlbp, wtlb;
	input [1:0] result_sel, alusrc1_sel, regdst;
	input [3:0] store_type, load_type;
	input [4:0] rs, rt, rd, tlb_addr;
	input [7:0] exc_mask, aluop, fetch_exc;
	input [31:0] rf_rdata0, rf_rdata1, hi, lo, COP0_data, Imm32, PC_plus4, instruction;
	input [89:0] tlb_wdata;
	output ID_EXE_is_div_data, ID_EXE_is_sign_div_data, ID_EXE_is_delayslot_data, ID_EXE_wcp0_data, ID_EXE_hi_i_sel_data, ID_EXE_lo_i_sel_data;
	output ID_EXE_whi_data, ID_EXE_wlo_data, ID_EXE_wreg_data, ID_EXE_wmem_data, ID_EXE_alusrc0_sel_data, ID_EXE_tlbr_data, ID_EXE_tlbp_data;
	output ID_EXE_wtlb_data;
	output [1:0] ID_EXE_result_sel_data, ID_EXE_alusrc1_sel_data, ID_EXE_regdst_data;
	output [3:0] ID_EXE_store_type_data, ID_EXE_load_type_data;
	output [4:0] ID_EXE_rs_data, ID_EXE_rt_data, ID_EXE_rd_data, ID_EXE_tlb_addr_data;
	output [7:0] ID_EXE_exc_mask_data, ID_EXE_aluop_data, ID_EXE_fetch_exc_data;
	output [31:0] ID_EXE_rf_rdata0_data, ID_EXE_rf_rdata1_data, ID_EXE_hi_data, ID_EXE_lo_data, ID_EXE_COP0_data_data, ID_EXE_Imm32_data
				, ID_EXE_PC_plus4_data, ID_EXE_Instruction_data;
	output [89:0] ID_EXE_tlb_wdata_data;
	
	// ID_EXE_is_div
	flopr #(1) m_ID_EXE_is_div(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(is_div), 
		.data_o(ID_EXE_is_div_data)
	);
	
	// ID_EXE_is_sign_div
	flopr #(1) m_ID_EXE_is_sign_div(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(is_sign_div), 
		.data_o(ID_EXE_is_sign_div_data)
	);
	
	// ID_EXE_exc_mask
	flopr #(8) m_ID_EXE_exc_mask(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(exc_mask), 
		.data_o(ID_EXE_exc_mask_data)
	);
	
	// ID_EXE_is_delayslot
	flopr #(1) m_ID_EXE_is_delayslot(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(is_delayslot), 
		.data_o(ID_EXE_is_delayslot_data)
	);
	
	// ID_EXE_wcp0
	flopr #(1) m_ID_EXE_wcp0(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(wcp0), 
		.data_o(ID_EXE_wcp0_data)
	);
	
	// ID_EXE_store_type
	flopr #(4) m_ID_EXE_store_type(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(store_type), 
		.data_o(ID_EXE_store_type_data)
	);
	
	// ID_EXE_load_type
	flopr #(4) m_ID_EXE_load_type(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(load_type), 
		.data_o(ID_EXE_load_type_data)
	);
	
	// ID_EXE_hi_i_sel
	flopr #(1) m_ID_EXE_hi_i_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(hi_i_sel), 
		.data_o(ID_EXE_hi_i_sel_data)
	);
	
	// ID_EXE_lo_i_sel
	flopr #(1) m_ID_EXE_lo_i_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(lo_i_sel), 
		.data_o(ID_EXE_lo_i_sel_data)
	);
	
	// ID_EXE_whi
	flopr #(1) m_ID_EXE_whi(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(whi), 
		.data_o(ID_EXE_whi_data)
	);
	
	// ID_EXE_wlo
	flopr #(1) m_ID_EXE_wlo(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(wlo), 
		.data_o(ID_EXE_wlo_data)
	);
	
	// ID_EXE_wreg
	flopr #(1) m_ID_EXE_wreg(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(wreg), 
		.data_o(ID_EXE_wreg_data)
	);
	
	// ID_EXE_result_sel
	flopr #(2) m_ID_EXE_result_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(result_sel), 
		.data_o(ID_EXE_result_sel_data)
	);
	
	// ID_EXE_wmem
	flopr #(1) m_ID_EXE_wmem(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(wmem), 
		.data_o(ID_EXE_wmem_data)
	);
	
	// ID_EXE_aluop
	flopr #(8) m_ID_EXE_aluop(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(aluop), 
		.data_o(ID_EXE_aluop_data)
	);
	
	// ID_EXE_alusrc0_sel
	flopr #(1) m_ID_EXE_alusrc0_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(alusrc0_sel), 
		.data_o(ID_EXE_alusrc0_sel_data)
	);
	
	// ID_EXE_alusrc1_sel
	flopr #(2) m_ID_EXE_alusrc1_sel(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(alusrc1_sel), 
		.data_o(ID_EXE_alusrc1_sel_data)
	);
	
	// ID_EXE_regdst
	flopr #(2) m_ID_EXE_regdst(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(regdst), 
		.data_o(ID_EXE_regdst_data)
	);
	
	// ID_EXE_rf_rdata0
	flopr #(32) m_ID_EXE_rf_rdata0(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(rf_rdata0), 
		.data_o(ID_EXE_rf_rdata0_data)
	);
	
	// ID_EXE_rf_rdata1
	flopr #(32) m_ID_EXE_rf_rdata1(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(rf_rdata1), 
		.data_o(ID_EXE_rf_rdata1_data)
	);
	
	// ID_EXE_hi
	flopr #(32) m_ID_EXE_hi(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(hi), 
		.data_o(ID_EXE_hi_data)
	);
	
	// ID_EXE_lo
	flopr #(32) m_ID_EXE_lo(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(lo), 
		.data_o(ID_EXE_lo_data)
	);
	
	// ID_EXE_COP0_data
	flopr #(32) m_ID_EXE_COP0_data(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(COP0_data), 
		.data_o(ID_EXE_COP0_data_data)
	);
	
	// ID_EXE_rs
	flopr #(5) m_ID_EXE_rs(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(rs), 
		.data_o(ID_EXE_rs_data)
	);
	
	// ID_EXE_rt
	flopr #(5) m_ID_EXE_rt(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(rt), 
		.data_o(ID_EXE_rt_data)
	);
	
	// ID_EXE_rd
	flopr #(5) m_ID_EXE_rd(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(rd), 
		.data_o(ID_EXE_rd_data)
	);
	
	// ID_EXE_Imm32
	flopr #(32) m_ID_EXE_Imm32(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(Imm32), 
		.data_o(ID_EXE_Imm32_data)
	);
	
	// ID_EXE_PC_plus4
	flopr #(32) m_ID_EXE_PC_plus4(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(PC_plus4), 
		.data_o(ID_EXE_PC_plus4_data)
	);
	
	// ID_EXE_fetch_exc
	flopr #(8) m_ID_EXE_fetch_exc(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(fetch_exc), 
		.data_o(ID_EXE_fetch_exc_data)
	);	
	
	// ID_EXE_Instruction
	flopr #(32) m_ID_EXE_Instruction(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(instruction), 
		.data_o(ID_EXE_Instruction_data)
	);	
	
	// ID_EXE_tlb_addr
	flopr #(5) m_ID_EXE_tlb_addr(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(tlb_addr), 
		.data_o(ID_EXE_tlb_addr_data)
	);
	
	// ID_EXE_tlb_wdata
	flopr #(90) m_ID_EXE_tlb_wdata(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(tlb_wdata), 
		.data_o(ID_EXE_tlb_wdata_data)
	);
	
	// ID_EXE_tlbr
	flopr #(1) m_ID_EXE_tlbr(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(tlbr), 
		.data_o(ID_EXE_tlbr_data)
	);
	
	// ID_EXE_tlbp
	flopr #(1) m_ID_EXE_tlbp(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(tlbp), 
		.data_o(ID_EXE_tlbp_data)
	);
	
	// ID_EXE_wtlb
	flopr #(1) m_ID_EXE_wtlb(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(ID_EXE_Stall), 
		.flush(ID_EXE_Flush), 
		.data_i(wtlb), 
		.data_o(ID_EXE_wtlb_data)
	);
endmodule