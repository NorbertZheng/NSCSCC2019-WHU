module ID_EXE_REG_PACKED(clk, rst_n, stall0, irq, clr0, clr1, clr2, is_div, ID_EXE_is_div_data, is_sign_div, ID_EXE_is_sign_div_data, cu_inst_exc_type, ID_EXE_cu_inst_exc_type_data, is_delayslot, ID_EXE_is_delayslot_data, wcp0, ID_EXE_wcp0_data, store_type, ID_EXE_store_type_data, load_type, ID_EXE_load_type_data, hi_i_sel, ID_EXE_hi_i_sel_data, lo_i_sel, ID_EXE_lo_i_sel_data, whi, ID_EXE_whi_data, wlo, ID_EXE_wlo_data, wreg, ID_EXE_wreg_data, result_sel, ID_EXE_result_sel_data, wmem, ID_EXE_wmem_data, aluop, ID_EXE_aluop_data, alusrc0_sel, ID_EXE_alusrc0_sel_data, alusrc1_sel, ID_EXE_alusrc1_sel_data, regdst, ID_EXE_regdst_data, rf_rdata0, ID_EXE_rf_rdata0_data, rf_rdata1, ID_EXE_rf_rdata1_data, hi, ID_EXE_hi_data, lo, ID_EXE_lo_data, COP0_data, ID_EXE_COP0_data_data, rs, ID_EXE_rs_data, rt, ID_EXE_rt_data, rd, ID_EXE_rd_data, Imm32, ID_EXE_Imm32_data, PC_plus4, ID_EXE_PC_plus4_data, if_fetch_exc_type, ID_EXE_if_fetch_exc_type_data, instruction, ID_EXE_Instruction_data, tlb_addr, ID_EXE_tlb_addr_data, tlb_wdata, ID_EXE_tlb_wdata_data, tlbr, ID_EXE_tlbr_data, tlbp, ID_EXE_tlbp_data, wtlb, ID_EXE_wtlb_data, asid, ID_EXE_asid_data, eret, ID_EXE_eret_data, instMiss, ID_EXE_instMiss_data, instValid, ID_EXE_instValid_data);
	/*********************
	 *	ID - EXE Pipeline Registers PACKED
	 *input:
	 *	clk									: clock
	 *	rst_n								: negetive reset signal
	 *	stall0								: stall0 signal
	 *	irq									: int request
	 *	clr0								: clr0 signal
	 *	clr1								: clr1 signal
	 *	clr2								: clr2 signal
	 *	is_div								: whether is div operation
	 *	is_sign_div							: whether is sign div operation
	 *	cu_inst_exc_type[31:0]				: exc mask(which will collect exc)
	 *	is_delayslot						: whether this instruction is in delayslot
	 *	wcp0								: write COP0 Regs
	 *	store_type[3:0]						: store type
	 *	load_type[3:0]						: load type
	 *	hi_i_sel							: hi_i select signal
	 *	lo_i_sel							: lo_i select signal
	 *	whi									: write HI Reg
	 *	wlo									: write LO Reg
	 *	wreg								: write RegisterFile
	 *	result_sel[1:0]						: result to write into RF select signal
	 *	wmem								: write Mem
	 *	aluop[7:0]							: ALU opcode
	 *	alusrc0_sel							: ALU src0 select signal
	 *	alusrc1_sel[1:0]					: ALU src1 select signal
	 *	regdst[1:0]							: reg which to write select signal
	 *	rf_rdata0[31:0]						: RF read data0
	 *	rf_rdata1[31:0]						: RF read data1
	 *	hi[31:0]							: HI read data
	 *	lo[31:0]							: LO read data
	 *	COP0_data[31:0]						: COP0 read data
	 *	rs[4:0]								: instruction rs segment
	 *	rt[4:0]								: instruction rt segment
	 *	rd[4:0]								: instruction rd segment
	 *	Imm32[31:0]							: Imm16 extend data
	 *	PC_plus4[31:0]						: PC_plus4 data
	 *	if_fetch_exc_type[31:0]				: instruction fetch exc?
	 *	tlb_addr[4:0]						: TLB access address
	 *	tlb_wdata[89:0]						: TLB write data
	 *	tlbr								: tlbr instruction signal
	 *	tlbp								: tlbp instruction signal
	 *	wtlb								: write TLB signal
	 *	asid[7:0]							: asid
	 *	eret								: eret
	 *	instMiss							: inst TLB miss signal
	 *	instValid							: inst TLB valid signal
	 *output:
	 *	ID_EXE_is_div_data					: ID/EXE is_div data
	 *	ID_EXE_is_sign_div_data				: ID/EXE is_sign_div data
	 *	ID_EXE_cu_inst_exc_type_data[31:0]	: ID/EXE cu_inst_exc_type data
	 *	ID_EXE_is_delayslot_data			: ID/EXE is_delayslot data
	 *	ID_EXE_wcp0_data					: ID/EXE wcp0 data
	 *	ID_EXE_store_type_data[3:0]			: ID/EXE store_type data
	 *	ID_EXE_load_type_data[3:0]			: ID/EXE load_type data
	 *	ID_EXE_hi_i_sel_data				: ID/EXE hi_i_sel data
	 *	ID_EXE_lo_i_sel_data				: ID/EXE lo_i_sel data
	 *	ID_EXE_whi_data						: ID/EXE whi data
	 *	ID_EXE_wlo_data						: ID/EXE wlo data
	 *	ID_EXE_wreg_data					: ID/EXE wreg data
	 *	ID_EXE_result_sel_data[1:0]			: ID/EXE result_sel data
	 *	ID_EXE_wmem_data					: ID/EXE wmem data
	 *	ID_EXE_aluop_data[7:0]				: ID/EXE aluop data
	 *	ID_EXE_alusrc0_sel_data				: ID/EXE alusrc0_sel data
	 *	ID_EXE_alusrc1_sel_data[1:0]		: ID/EXE alusrc1_sel data
	 *	ID_EXE_regdst_data[1:0]				: ID/EXE regdst data
	 *	ID_EXE_rf_rdata0_data[31:0]			: ID/EXE rf_rdata0 data
	 *	ID_EXE_rf_rdata1_data[31:0]			: ID/EXE rf_rdata1 data
	 *	ID_EXE_hi_data[31:0]				: ID/EXE hi data
	 *	ID_EXE_lo_data[31:0]				: ID/EXE lo data
	 *	ID_EXE_COP0_data_data[31:0]			: ID/EXE COP0_data data
	 *	ID_EXE_rs_data[4:0]					: ID/EXE rs data
	 *	ID_EXE_rt_data[4:0]					: ID/EXE rt data
	 *	ID_EXE_rd_data[4:0]					: ID/EXE rd data
	 *	ID_EXE_Imm32_data[31:0]				: ID/EXE Imm32 data
	 *	ID_EXE_PC_plus4_data[31:0]			: ID/EXE PC_plus4 data
	 *	ID_EXE_if_fetch_exc_type_data[31:0]	: ID/EXE if_fetch_exc_type data
	 *	ID_EXE_tlb_addr_data[4:0]			: ID/EXE tlb_addr data
	 *	ID_EXE_tlb_wdata_data[89:0]			: ID/EXE tlb_wdata data
	 *	ID_EXE_tlbr_data					: ID/EXE tlbr data
	 *	ID_EXE_tlbp_data					: ID/EXE tlbp data
	 *	ID_EXE_wtlb_data					: ID/EXE wtlb data
	 *	ID_EXE_asid_data[7:0]				: ID/EXE asid data
	 *	ID_EXE_eret_data					: ID/EXE eret data
	 *	ID_EXE_instMiss_data				: ID/EXE instMiss data
	 *	ID_EXE_instValid_data				: ID/EXE instValid data
	 *********************/
	input clk, rst_n;
	input stall0, irq, clr0, clr1, clr2;
	input is_div, is_sign_div, is_delayslot, wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, wmem, alusrc0_sel, tlbr, tlbp, wtlb, eret, instMiss, instValid;
	input [1:0] result_sel, alusrc1_sel, regdst;
	input [3:0] store_type, load_type;
	input [4:0] rs, rt, rd, tlb_addr;;
	input [7:0] aluop, asid;
	input [31:0] rf_rdata0, rf_rdata1, hi, lo, COP0_data, Imm32, PC_plus4, instruction, if_fetch_exc_type, cu_inst_exc_type;
	input [89:0] tlb_wdata;
	output reg ID_EXE_is_div_data, ID_EXE_is_sign_div_data, ID_EXE_is_delayslot_data, ID_EXE_wcp0_data, ID_EXE_hi_i_sel_data, ID_EXE_lo_i_sel_data;
	output reg ID_EXE_whi_data, ID_EXE_wlo_data, ID_EXE_wreg_data, ID_EXE_wmem_data, ID_EXE_alusrc0_sel_data, ID_EXE_tlbr_data, ID_EXE_tlbp_data;
	output reg ID_EXE_wtlb_data, ID_EXE_eret_data, ID_EXE_instMiss_data, ID_EXE_instValid_data;
	output reg [1:0] ID_EXE_result_sel_data, ID_EXE_alusrc1_sel_data, ID_EXE_regdst_data;
	output reg [3:0] ID_EXE_store_type_data, ID_EXE_load_type_data;
	output reg [4:0] ID_EXE_rs_data, ID_EXE_rt_data, ID_EXE_rd_data, ID_EXE_tlb_addr_data;
	output reg [7:0] ID_EXE_aluop_data, ID_EXE_asid_data;
	output reg [31:0] ID_EXE_rf_rdata0_data, ID_EXE_rf_rdata1_data, ID_EXE_hi_data, ID_EXE_lo_data, ID_EXE_COP0_data_data, ID_EXE_Imm32_data
				, ID_EXE_PC_plus4_data, ID_EXE_Instruction_data, ID_EXE_cu_inst_exc_type_data, ID_EXE_if_fetch_exc_type_data;
	output reg [89:0] ID_EXE_tlb_wdata_data;

	wire ID_EXE_Stall = stall0 && ~irq;
	wire ID_EXE_Flush = irq || clr0 || clr1 || clr2;
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			ID_EXE_is_div_data <= 1'b0;
			ID_EXE_is_sign_div_data <= 1'b0;
			ID_EXE_cu_inst_exc_type_data <= 32'b0;
			ID_EXE_is_delayslot_data <= 1'b0;
			ID_EXE_wcp0_data <= 1'b0;
			ID_EXE_store_type_data <= 4'b0;
			ID_EXE_load_type_data <= 4'b0;
			ID_EXE_hi_i_sel_data <= 1'b0;
			ID_EXE_lo_i_sel_data <= 1'b0;
			ID_EXE_whi_data <= 1'b0;
			ID_EXE_wlo_data <= 1'b0;
			ID_EXE_wreg_data <= 1'b0; 
			ID_EXE_result_sel_data <= 2'b0;
			ID_EXE_wmem_data <= 1'b0;
			ID_EXE_aluop_data <= 8'b0;
			ID_EXE_alusrc0_sel_data <= 1'b0;
			ID_EXE_alusrc1_sel_data <= 2'b0;
			ID_EXE_regdst_data <= 2'b0;
			ID_EXE_rf_rdata0_data <= 32'b0;
			ID_EXE_rf_rdata1_data <= 32'b0;
			ID_EXE_hi_data <= 32'b0;
			ID_EXE_lo_data <= 32'b0;
			ID_EXE_COP0_data_data <= 32'b0;
			ID_EXE_rs_data <= 5'b0;
			ID_EXE_rt_data <= 5'b0;
			ID_EXE_rd_data <= 5'b0;
			ID_EXE_Imm32_data <= 32'b0;
			ID_EXE_PC_plus4_data <= 32'b0;
			ID_EXE_if_fetch_exc_type_data <= 32'b0;
			ID_EXE_Instruction_data <= 32'b0;
			ID_EXE_tlb_addr_data <= 5'b0;
			ID_EXE_tlb_wdata_data <= 90'b0;
			ID_EXE_tlbr_data <= 1'b0;
			ID_EXE_tlbp_data <= 1'b0;
			ID_EXE_wtlb_data <= 1'b0;
			ID_EXE_asid_data <= 8'b0;
			ID_EXE_eret_data <= 1'b0;
			ID_EXE_instMiss_data <= 1'b0;
			ID_EXE_instValid_data <= 1'b0;
			end
		else if(!ID_EXE_Stall)
			begin
			if(ID_EXE_Flush)
				begin
				ID_EXE_is_div_data <= 1'b0;
				ID_EXE_is_sign_div_data <= 1'b0;
				ID_EXE_cu_inst_exc_type_data <= 32'b0;
				ID_EXE_is_delayslot_data <= 1'b0;
				ID_EXE_wcp0_data <= 1'b0;
				ID_EXE_store_type_data <= 4'b0;
				ID_EXE_load_type_data <= 4'b0;
				ID_EXE_hi_i_sel_data <= 1'b0;
				ID_EXE_lo_i_sel_data <= 1'b0;
				ID_EXE_whi_data <= 1'b0;
				ID_EXE_wlo_data <= 1'b0;
				ID_EXE_wreg_data <= 1'b0; 
				ID_EXE_result_sel_data <= 2'b0;
				ID_EXE_wmem_data <= 1'b0;
				ID_EXE_aluop_data <= 8'b0;
				ID_EXE_alusrc0_sel_data <= 1'b0;
				ID_EXE_alusrc1_sel_data <= 2'b0;
				ID_EXE_regdst_data <= 2'b0;
				ID_EXE_rf_rdata0_data <= 32'b0;
				ID_EXE_rf_rdata1_data <= 32'b0;
				ID_EXE_hi_data <= 32'b0;
				ID_EXE_lo_data <= 32'b0;
				ID_EXE_COP0_data_data <= 32'b0;
				ID_EXE_rs_data <= 5'b0;
				ID_EXE_rt_data <= 5'b0;
				ID_EXE_rd_data <= 5'b0;
				ID_EXE_Imm32_data <= 32'b0;
				ID_EXE_PC_plus4_data <= 32'b0;
				ID_EXE_if_fetch_exc_type_data <= 32'b0;
				ID_EXE_Instruction_data <= 32'b0;
				ID_EXE_tlb_addr_data <= 5'b0;
				ID_EXE_tlb_wdata_data <= 90'b0;
				ID_EXE_tlbr_data <= 1'b0;
				ID_EXE_tlbp_data <= 1'b0;
				ID_EXE_wtlb_data <= 1'b0;
				ID_EXE_asid_data <= 8'b0;
				ID_EXE_eret_data <= 1'b0;
				ID_EXE_instMiss_data <= 1'b0;
				ID_EXE_instValid_data <= 1'b0;
				end
			else
				begin
				ID_EXE_is_div_data <= is_div;
				ID_EXE_is_sign_div_data <= is_sign_div;
				ID_EXE_cu_inst_exc_type_data <= cu_inst_exc_type;
				ID_EXE_is_delayslot_data <= is_delayslot;
				ID_EXE_wcp0_data <= wcp0;
				ID_EXE_store_type_data <= store_type;
				ID_EXE_load_type_data <= load_type;
				ID_EXE_hi_i_sel_data <= hi_i_sel;
				ID_EXE_lo_i_sel_data <= lo_i_sel;
				ID_EXE_whi_data <= whi;
				ID_EXE_wlo_data <= wlo;
				ID_EXE_wreg_data <= wreg; 
				ID_EXE_result_sel_data <= result_sel;
				ID_EXE_wmem_data <= wmem;
				ID_EXE_aluop_data <= aluop;
				ID_EXE_alusrc0_sel_data <= alusrc0_sel;
				ID_EXE_alusrc1_sel_data <= alusrc1_sel;
				ID_EXE_regdst_data <= regdst;
				ID_EXE_rf_rdata0_data <= rf_rdata0;
				ID_EXE_rf_rdata1_data <= rf_rdata1;
				ID_EXE_hi_data <= hi;
				ID_EXE_lo_data <= lo;
				ID_EXE_COP0_data_data <= COP0_data;
				ID_EXE_rs_data <= rs;
				ID_EXE_rt_data <= rt;
				ID_EXE_rd_data <= rd;
				ID_EXE_Imm32_data <= Imm32;
				ID_EXE_PC_plus4_data <= PC_plus4;
				ID_EXE_if_fetch_exc_type_data <= if_fetch_exc_type;
				ID_EXE_Instruction_data <= instruction;
				ID_EXE_tlb_addr_data <= tlb_addr;
				ID_EXE_tlb_wdata_data <= tlb_wdata;
				ID_EXE_tlbr_data <= tlbr;
				ID_EXE_tlbp_data <= tlbp;
				ID_EXE_wtlb_data <= wtlb;
				ID_EXE_asid_data <= asid;
				ID_EXE_eret_data <= eret;
				ID_EXE_instMiss_data <= instMiss;
				ID_EXE_instValid_data <= instValid;
				end
			end
		end
	/*
	// ID_EXE_REG
	ID_EXE_REG m_ID_EXE_REG(
		.clk(clk), 
		.rst_n(rst_n), 
		.ID_EXE_Stall(ID_EXE_Stall), 
		.ID_EXE_Flush(ID_EXE_Flush), 
		.is_div(is_div), 
		.ID_EXE_is_div_data(ID_EXE_is_div_data), 
		.is_sign_div(is_sign_div), 
		.ID_EXE_is_sign_div_data(ID_EXE_is_sign_div_data), 
		.cu_inst_exc_type(cu_inst_exc_type), 
		.ID_EXE_cu_inst_exc_type_data(ID_EXE_cu_inst_exc_type_data), 
		.is_delayslot(is_delayslot), 
		.ID_EXE_is_delayslot_data(ID_EXE_is_delayslot_data), 
		.wcp0(wcp0), 
		.ID_EXE_wcp0_data(ID_EXE_wcp0_data), 
		.store_type(store_type), 
		.ID_EXE_store_type_data(ID_EXE_store_type_data), 
		.load_type(load_type), 
		.ID_EXE_load_type_data(ID_EXE_load_type_data), 
		.hi_i_sel(hi_i_sel), 
		.ID_EXE_hi_i_sel_data(ID_EXE_hi_i_sel_data), 
		.lo_i_sel(lo_i_sel), 
		.ID_EXE_lo_i_sel_data(ID_EXE_lo_i_sel_data), 
		.whi(whi), 
		.ID_EXE_whi_data(ID_EXE_whi_data), 
		.wlo(wlo), 
		.ID_EXE_wlo_data(ID_EXE_wlo_data), 
		.wreg(wreg), 
		.ID_EXE_wreg_data(ID_EXE_wreg_data), 
		.result_sel(result_sel), 
		.ID_EXE_result_sel_data(ID_EXE_result_sel_data), 
		.wmem(wmem), 
		.ID_EXE_wmem_data(ID_EXE_wmem_data), 
		.aluop(aluop), 
		.ID_EXE_aluop_data(ID_EXE_aluop_data), 
		.alusrc0_sel(alusrc0_sel), 
		.ID_EXE_alusrc0_sel_data(ID_EXE_alusrc0_sel_data), 
		.alusrc1_sel(alusrc1_sel), 
		.ID_EXE_alusrc1_sel_data(ID_EXE_alusrc1_sel_data), 
		.regdst(regdst), 
		.ID_EXE_regdst_data(ID_EXE_regdst_data), 
		.rf_rdata0(rf_rdata0), 
		.ID_EXE_rf_rdata0_data(ID_EXE_rf_rdata0_data), 
		.rf_rdata1(rf_rdata1), 
		.ID_EXE_rf_rdata1_data(ID_EXE_rf_rdata1_data), 
		.hi(hi), 
		.ID_EXE_hi_data(ID_EXE_hi_data), 
		.lo(lo), 
		.ID_EXE_lo_data(ID_EXE_lo_data), 
		.COP0_data(COP0_data), 
		.ID_EXE_COP0_data_data(ID_EXE_COP0_data_data), 
		.rs(rs), 
		.ID_EXE_rs_data(ID_EXE_rs_data), 
		.rt(rt), 
		.ID_EXE_rt_data(ID_EXE_rt_data), 
		.rd(rd), 
		.ID_EXE_rd_data(ID_EXE_rd_data), 
		.Imm32(Imm32), 
		.ID_EXE_Imm32_data(ID_EXE_Imm32_data), 
		.PC_plus4(PC_plus4), 
		.ID_EXE_PC_plus4_data(ID_EXE_PC_plus4_data), 
		.if_fetch_exc_type(if_fetch_exc_type), 
		.ID_EXE_if_fetch_exc_type_data(ID_EXE_if_fetch_exc_type_data),
		.instruction(instruction),
		.ID_EXE_Instruction_data(ID_EXE_Instruction_data),
		.tlb_addr(tlb_addr), 
		.ID_EXE_tlb_addr_data(ID_EXE_tlb_addr_data), 
		.tlb_wdata(tlb_wdata), 
		.ID_EXE_tlb_wdata_data(ID_EXE_tlb_wdata_data), 
		.tlbr(tlbr), 
		.ID_EXE_tlbr_data(ID_EXE_tlbr_data), 
		.tlbp(tlbp), 
		.ID_EXE_tlbp_data(ID_EXE_tlbp_data),
		.wtlb(wtlb),
		.ID_EXE_wtlb_data(ID_EXE_wtlb_data),
		.asid(asid),
		.ID_EXE_asid_data(ID_EXE_asid_data),
		.eret(eret),
		.ID_EXE_eret_data(ID_EXE_eret_data),
		.instMiss(instMiss),
		.ID_EXE_instMiss_data(ID_EXE_instMiss_data),
		.instValid(instValid),
		.ID_EXE_instValid_data(ID_EXE_instValid_data)
	);
	*/
endmodule
