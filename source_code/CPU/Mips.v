`include "Define/LS_Define.v"
module Mips(clk, rst_n, inst_data, inst_addr, ram_en, ram_we, ram_din, ram_dout, ram_addr, ram_byte_valid, int_i, debug_wb_pc, debug_wb_rf_wen, debug_wb_rf_wnum, debug_wb_rf_wdata, debug_wb_inst);
	/*********************
	 *			Mips
	 *input:
	 *	clk					: clock
	 *	rst_n				: negetive reset signal
	 *	inst_data[31:0]		: instruction
	 *	ram_din[31:0]		: ram read data
	 *	int_i[4:0]			: interrupt signal
	 *output:
	 *	inst_addr[31:0]		: PC
	 *	ram_en				: ram enable signal
	 *	ram_we				: write ram
	 *	ram_dout[31:0]		: ram write data
	 *	ram_addr[31:0]		: ram access addr
	 *	ram_byte_valid[3:0]	: ram byte_valid signal
	 *********************/
	input clk, rst_n;
	// interrupt signal
	input [4:0] int_i;
	// instruction
	input [31:0] inst_data;
	output [31:0] inst_addr;
	// ram access
	input [31:0] ram_din;
	output ram_en, ram_we;
	output [3:0] ram_byte_valid;
	output [31:0] ram_addr, ram_dout;
	// for debug
	output [31:0] debug_wb_pc, debug_wb_rf_wdata, debug_wb_inst;
	output [3:0] debug_wb_rf_wen;
	output [4:0] debug_wb_rf_wnum;
	
	wire [31:0] mem_rdata = ram_din;
	/**************************/
	/*           IF           */
	/**************************/
	// PC
	wire PC_target_sel, exc_en, stcl_lw, stcl_jmp, stcl_f, stcl_ram_cache, stcl_div;
	assign stcl_f = 1'b0;			// temp for test
	assign stcl_ram_cache = 1'b0;	// temp for test
	wire [7:0] fetch_exc;
	wire [31:0] PC_branch, PC_exc, PC_o, PC_plus4;
	PC m_PC(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_lw), 
		.stall1(stcl_jmp), 
		.stall2(stcl_f), 
		.stall3(stcl_ram_cache | stcl_div), 
		.PC_exc_i(PC_exc), 
		.PC_target_i(PC_branch), 
		.PC_exc_sel(exc_en), 
		.PC_target_sel(PC_target_sel), 
		.PC_o(PC_o), 
		.PC_plus4(PC_plus4), 
		.fetch_exc(fetch_exc)
	);
	
	// IF_ID_REG_PACKED
	wire is_delayslot, IF_ID_is_delayslot_data;
	wire [7:0] IF_ID_fetch_exc_data;
	wire [31:0] IF_ID_PC_plus4_data, IF_ID_Instruction_data;
	IF_ID_REG_PACKED m_IF_ID_REG_PACKED(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_lw), 
		.stall1(stcl_jmp), 
		.stall2(stcl_f), 
		.stall3(stcl_ram_cache | stcl_div), 
		.irq(exc_en), 
		.PC_plus4(PC_plus4), 
		.IF_ID_PC_plus4_data(IF_ID_PC_plus4_data), 
		.Instruction(inst_data), 
		.IF_ID_Instruction_data(IF_ID_Instruction_data), 
		.is_delayslot(is_delayslot), 
		.IF_ID_is_delayslot_data(IF_ID_is_delayslot_data), 
		.fetch_exc(fetch_exc), 
		.IF_ID_fetch_exc_data(IF_ID_fetch_exc_data)
	);

	/**************************/
	/*           ID           */
	/**************************/
	// rf_jdata0_fw_mux
	wire [1:0] rf_jdata0_fw_sel;
	wire [31:0] rf_rdata0, EXE_MEM_ALU_result_data, WB_result_data, rf_jdata0_fw_mux_data;
	Mux3T1 m_rf_jdata0_fw_mux(
		.s(rf_jdata0_fw_sel), 
		.y(rf_jdata0_fw_mux_data), 
		.d0(rf_rdata0), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// rf_jdata1_fw_mux
	wire [1:0] rf_jdata1_fw_sel;
	wire [31:0] rf_rdata1, rf_jdata1_fw_mux_data;
	Mux3T1 m_rf_jdata1_fw_mux(
		.s(rf_jdata1_fw_sel), 
		.y(rf_jdata1_fw_mux_data), 
		.d0(rf_rdata1), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// Control_Unit
	wire is_div, is_sign_div, is_delayslot_o, wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, wmem, sign, alusrc0_sel, i_b;
	wire [1:0] result_sel, alusrc1_sel, regdst;
	wire [3:0] store_type, load_type;
	wire [7:0] exc_mask, aluop;
	Control_Unit m_Control_Unit(
		.rst_n(rst_n), 
		.inst(IF_ID_Instruction_data), 
		.rf_read_data0(rf_jdata0_fw_mux_data), 
		.rf_read_data1(rf_jdata1_fw_mux_data), 
		.PC_plus4(IF_ID_PC_plus4_data), 
		.is_delayslot_i(IF_ID_is_delayslot_data), 
		.is_div(is_div), 
		.is_sign_div(is_sign_div), 
		.exc_mask(exc_mask), 
		.is_delayslot_o(is_delayslot_o), 
		.wcp0(wcp0), 
		.store_type(store_type), 
		.load_type(load_type), 
		.hi_i_sel(hi_i_sel), 
		.lo_i_sel(lo_i_sel), 
		.whi(whi), 
		.wlo(wlo), 
		.wreg(wreg), 
		.result_sel(result_sel), 
		.wmem(wmem), 
		.sign(sign), 
		.aluop(aluop), 
		.alusrc0_sel(alusrc0_sel), 
		.alusrc1_sel(alusrc1_sel), 
		.regdst(regdst), 
		.i_bj(is_delayslot), 
		.i_b(i_b), 
		.PC_target_sel(PC_target_sel), 
		.PC_branch(PC_branch)
	);

	// Registers
	wire MEM_WB_wreg_data;
	wire [4:0] MEM_WB_regdst_data;
	Registers #(32, 5, 32) m_Registers(
		.clk(clk), 
		.rst_n(rst_n), 
		.RegWrite(MEM_WB_wreg_data), 
		.Read_register1(IF_ID_Instruction_data[25:21]), 
		.Read_register2(IF_ID_Instruction_data[20:16]), 
		.Write_register(MEM_WB_regdst_data), 
		.Write_data(WB_result_data), 
		.Read_data1(rf_rdata0), 
		.Read_data2(rf_rdata1)
	);
	
	// hi_lo_reg
	wire MEM_WB_whi_data, MEM_WB_wlo_data;
	wire [31:0] WB_hi_data, WB_lo_data, hi_o, lo_o;
	hi_lo_reg m_hi_lo_reg(
		.clk(clk), 
		.rst_n(rst_n), 
		.whi(MEM_WB_whi_data), 
		.wlo(MEM_WB_wlo_data), 
		.hi_i(WB_hi_data), 
		.lo_i(WB_lo_data), 
		.hi_o(hi_o), 
		.lo_o(lo_o)
	);
	
	// COP0
	wire [3:0] EXE_MEM_load_type_data, EXE_MEM_store_type_data;
	wire MEM_load_exc = ((EXE_MEM_load_type_data == `LOAD_LH || EXE_MEM_load_type_data == `LOAD_LHU) && ram_addr[0])||
						((EXE_MEM_load_type_data == `LOAD_LL || EXE_MEM_load_type_data == `LOAD_LW) && ram_addr[1:0] != 2'b00);
	wire MEM_store_exc = (EXE_MEM_store_type_data == `STORE_SH && ram_addr[0])||
						((EXE_MEM_store_type_data == `STORE_SW || EXE_MEM_store_type_data == `STORE_SC) && ram_addr[1:0] != 2'b00);
	wire MEM_WB_wcp0_data, vic_is_delayslot;
	wire [4:0] EXE_MEM_int_i_data;
	wire [7:0] EXE_MEM_exc_mask_data; 
	wire [31:0] vic_inst_addr, COP0_data;
	COP0 m_COP0(
		.clk(clk), 
		.rst_n(rst_n), 
		.wcp0(MEM_WB_wcp0_data), 
		.waddr(MEM_WB_regdst_data), 
		.raddr(IF_ID_Instruction_data[15:11]), 
		.wdata(WB_result_data), 
		.exc_type(EXE_MEM_exc_mask_data | {MEM_store_exc, MEM_load_exc, 6'b0}), 
		.int_i(EXE_MEM_int_i_data), 
		.victim_inst_addr(vic_inst_addr), 
		.is_delayslot(vic_is_delayslot), 
		.badvaddr(ram_addr), 
		.COP0_data(COP0_data), 
		.COP0_Count(), 
		.COP0_Compare(), 
		.COP0_Status(), 
		.COP0_Cause(), 
		.COP0_EPC(), 
		.COP0_Config(), 
		.COP0_Prid(), 
		.COP0_Badvaddr(), 
		.exc_en(exc_en), 
		.PC_exc(PC_exc)
	);
	
	// EXT
	wire [31:0] Imm32;
	EXT m_EXT(
		.EXTOp(sign), 
		.Imm16(IF_ID_Instruction_data[15:0]), 
		.Imm32(Imm32)
	);
	
	// victimInstDetector
	wire ID_EXE_is_delayslot_data, EXE_MEM_is_delayslot_data;
	wire [31:0] ID_EXE_PC_plus4_data, EXE_MEM_PC_plus4_data;
	victimInstDetector m_victimInstDetector(
		.PC_o(PC_o), 
		.IF_ID_is_delayslot_data(IF_ID_is_delayslot_data), 
		.IF_ID_PC_plus4_data(IF_ID_PC_plus4_data), 
		.ID_EXE_is_delayslot_data(ID_EXE_is_delayslot_data), 
		.ID_EXE_PC_plus4_data(ID_EXE_PC_plus4_data), 
		.EXE_MEM_is_delayslot_data(EXE_MEM_is_delayslot_data), 
		.EXE_MEM_PC_plus4_data(EXE_MEM_PC_plus4_data), 
		.vic_is_delayslot(vic_is_delayslot), 
		.vic_inst_addr(vic_inst_addr)
	);
	
	// Hazard_Detection_Unit
	wire ID_EXE_wreg_data;
	wire [3:0] ID_EXE_load_type_data, ID_EXE_store_type_data;
	wire [4:0] EXE_regdst_data;
	Hazard_Detection_Unit m_Hazard_Detection_Unit(
		.rst_n(rst_n), 
		.EXE_regdst_data(EXE_regdst_data), 
		.IF_ID_rs_data(IF_ID_Instruction_data[25:21]), 
		.IF_ID_rt_data(IF_ID_Instruction_data[20:16]), 
		.ID_EXE_load_type_data(ID_EXE_load_type_data), 
		.ID_EXE_store_type_data(ID_EXE_store_type_data), 
		.stcl_lw(stcl_lw), 
		.ID_i_b(i_b), 
		.ID_EXE_wreg_data(ID_EXE_wreg_data), 
		.EXE_MEM_load_type_data(EXE_MEM_load_type_data), 
		.EXE_MEM_store_type_data(EXE_MEM_store_type_data), 
		.MEM_WB_regdst_data(MEM_WB_regdst_data),
		.stcl_jmp(stcl_jmp)
	);
	
	// ID_EXE_REG_PACKED
	wire ID_EXE_is_div_data, ID_EXE_is_sign_div_data, ID_EXE_wcp0_data, ID_EXE_hi_i_sel_data, ID_EXE_lo_i_sel_data, ID_EXE_whi_data, ID_EXE_wlo_data;
	wire ID_EXE_wmem_data, ID_EXE_alusrc0_sel_data;
	wire [1:0] ID_EXE_result_sel_data, ID_EXE_alusrc1_sel_data, ID_EXE_regdst_data;
	wire [4:0] ID_EXE_rs_data, ID_EXE_rt_data, ID_EXE_rd_data;
	wire [7:0] ID_EXE_exc_mask_data, ID_EXE_aluop_data, ID_EXE_fetch_exc_data;
	wire [31:0] ID_EXE_rf_rdata0_data, ID_EXE_rf_rdata1_data, ID_EXE_hi_data, ID_EXE_lo_data, ID_EXE_COP0_data_data, ID_EXE_Imm32_data, ID_EXE_Instruction_data;
	ID_EXE_REG_PACKED m_ID_EXE_REG_PACKED(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_ram_cache | stcl_div), 
		.irq(exc_en), 
		.clr0(stcl_lw), 
		.clr1(stcl_jmp), 
		.clr2(stcl_f), 
		.is_div(is_div), 
		.ID_EXE_is_div_data(ID_EXE_is_div_data), 
		.is_sign_div(is_sign_div), 
		.ID_EXE_is_sign_div_data(ID_EXE_is_sign_div_data), 
		.exc_mask(exc_mask), 
		.ID_EXE_exc_mask_data(ID_EXE_exc_mask_data), 
		.is_delayslot(is_delayslot_o), 
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
		.hi(hi_o), 
		.ID_EXE_hi_data(ID_EXE_hi_data), 
		.lo(lo_o), 
		.ID_EXE_lo_data(ID_EXE_lo_data), 
		.COP0_data(COP0_data), 
		.ID_EXE_COP0_data_data(ID_EXE_COP0_data_data), 
		.rs(IF_ID_Instruction_data[25:21]), 
		.ID_EXE_rs_data(ID_EXE_rs_data), 
		.rt(IF_ID_Instruction_data[20:16]), 
		.ID_EXE_rt_data(ID_EXE_rt_data), 
		.rd(IF_ID_Instruction_data[15:11]), 
		.ID_EXE_rd_data(ID_EXE_rd_data), 
		.Imm32(Imm32), 
		.ID_EXE_Imm32_data(ID_EXE_Imm32_data), 
		.PC_plus4(IF_ID_PC_plus4_data), 
		.ID_EXE_PC_plus4_data(ID_EXE_PC_plus4_data), 
		.fetch_exc(IF_ID_fetch_exc_data), 
		.ID_EXE_fetch_exc_data(ID_EXE_fetch_exc_data),
		.instruction(IF_ID_Instruction_data),
		.ID_EXE_Instruction_data(ID_EXE_Instruction_data)
	);

	/**************************/
	/*          EXE           */
	/**************************/
	// rf_rdata0_fw_mux
	wire [1:0] rf_rdata0_fw_sel;
	wire [31:0] rf_rdata0_fw_mux_data;
	Mux3T1 m_rf_rdata0_fw_mux(
		.s(rf_rdata0_fw_sel), 
		.y(rf_rdata0_fw_mux_data), 
		.d0(rf_rdata0), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// rf_rdata1_fw_mux
	wire [1:0] rf_rdata1_fw_sel;
	wire [31:0] rf_rdata1_fw_mux_data;
	Mux3T1 m_rf_rdata1_fw_mux(
		.s(rf_rdata1_fw_sel), 
		.y(rf_rdata1_fw_mux_data), 
		.d0(rf_rdata1), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// hi_fw_mux
	wire [1:0] hi_fw_sel;
	wire [31:0] hi_fw_mux_data, MEM_hi_data;
	Mux3T1 m_hi_fw_mux(
		.s(hi_fw_sel), 
		.y(hi_fw_mux_data), 
		.d0(ID_EXE_hi_data), 
		.d1(MEM_hi_data), 
		.d2(WB_hi_data)
	);
	
	// lo_fw_mux
	wire [1:0] lo_fw_sel;
	wire [31:0] lo_fw_mux_data, MEM_lo_data;
	Mux3T1 m_lo_fw_mux(
		.s(lo_fw_sel), 
		.y(lo_fw_mux_data), 
		.d0(ID_EXE_lo_data), 
		.d1(MEM_lo_data), 
		.d2(WB_lo_data)
	);
	
	// ALU_src0_mux
	wire [31:0] src0;
	Mux2T1 m_ALU_src0_mux(
		.s(ID_EXE_alusrc0_sel_data), 
		.y(src0), 
		.d0(rf_rdata0_fw_mux_data), 
		.d1(ID_EXE_Imm32_data)
	);
	
	// ALU_src1_mux
	wire [31:0] src1;
	Mux4T1 m_ALU_src1_mux(
		.s(ID_EXE_alusrc1_sel_data), 
		.y(src1), 
		.d0(rf_rdata1_fw_mux_data), 
		.d1(hi_fw_mux_data), 
		.d2(lo_fw_mux_data), 
		.d3(ID_EXE_Imm32_data)
	);
	
	// ll_bit_fw_mux
	wire ll_bit_fw_mux_data, ll_bit_o;
	wire MEM_ll_bit_data = (EXE_MEM_load_type_data == `LOAD_LL);
	Mux2T1 #(1) m_ll_bit_fw_mux(
		.s(MEM_ll_bit_data), 
		.y(ll_bit_fw_mux_data), 
		.d0(ll_bit_o), 
		.d1(MEM_ll_bit_data)
	);
	
	// COP0_data_fw_mux
	wire [1:0] COP0_rdata_fw_sel;
	wire [31:0] COP0_data_fw_mux_data;
	Mux3T1 m_COP0_data_fw_mux(
		.s(COP0_rdata_fw_sel), 
		.y(COP0_data_fw_mux_data), 
		.d0(ID_EXE_COP0_data_data), 
		.d1(EXE_MEM_ALU_result_data),
		.d2(WB_result_data)
	);
	
	// ALU
	wire ALU_we, ALU_mwe;
	wire [3:0] byte_valid;
	wire [7:0] ALU_exc;
	wire [31:0] ALU_result;
	wire [63:0] Mul_result;
	ALU m_ALU(
		.aluop(ID_EXE_aluop_data), 
		.src0(src0), 
		.src1(src1), 
		.ll_bit_o(ll_bit_fw_mux_data), 
		.hilo_o({hi_fw_mux_data, lo_fw_mux_data}), 
		.EXE_PC_plus8(ID_EXE_PC_plus4_data + 32'h4), 
		.COP0_rdata(COP0_data_fw_mux_data), 
		.ALU_result(ALU_result), 
		.ALU_we(ALU_we), 
		.ALU_mwe(ALU_mwe), 
		.Mul_result(Mul_result), 
		.byte_valid(byte_valid), 
		.ALU_exc(ALU_exc)
	);
	
	// Divider
	wire [63:0] Div_result;
	Divider m_Divider(
		.clk(clk), 
		.rst_n(rst_n), 
		.a(src0), 
		.b(src1), 
		.start(ID_EXE_is_div_data), 
		.clr(1'b0), 
		.is_sign_div(ID_EXE_is_sign_div_data), 
		.result(Div_result), 
		.busy(stcl_div)
	);
	
	// regdst_mux		decoder
	Mux3T1 #(5) m_regdst_mux(
		.s(ID_EXE_regdst_data), 
		.y(EXE_regdst_data), 
		.d0(ID_EXE_rt_data), 
		.d1(ID_EXE_rd_data),
		.d2(5'd31)
	);
	
	// Forwawrding_Unit
	wire EXE_MEM_wreg_data, EXE_MEM_whi_data, EXE_MEM_wlo_data, EXE_MEM_wcp0_data;
	wire [4:0] EXE_MEM_regdst_data;
	Forwarding_Unit m_Forwawrding_Unit(
		.rst_n(rst_n), 
		.IF_ID_rs_data(IF_ID_Instruction_data[25:21]), 
		.IF_ID_rt_data(IF_ID_Instruction_data[20:16]), 
		.ID_EXE_rs_data(ID_EXE_rs_data), 
		.ID_EXE_rt_data(ID_EXE_rt_data), 
		.EXE_MEM_wreg_data(EXE_MEM_wreg_data), 
		.EXE_MEM_regdst_data(EXE_MEM_regdst_data), 
		.MEM_WB_wreg_data(MEM_WB_wreg_data), 
		.MEM_WB_regdst_data(MEM_WB_regdst_data), 
		.rf_rdata0_fw_sel(rf_rdata0_fw_sel), 
		.rf_rdata1_fw_sel(rf_rdata1_fw_sel), 
		.rf_jdata0_fw_sel(rf_jdata0_fw_sel), 
		.rf_jdata1_fw_sel(rf_jdata1_fw_sel), 
		.EXE_MEM_whi_data(EXE_MEM_whi_data), 
		.EXE_MEM_wlo_data(EXE_MEM_wlo_data), 
		.MEM_WB_whi_data(MEM_WB_whi_data), 
		.MEM_WB_wlo_data(MEM_WB_wlo_data), 
		.hi_fw_sel(hi_fw_sel), 
		.lo_fw_sel(lo_fw_sel), 
		.ID_EXE_rd_data(ID_EXE_rd_data), 
		.EXE_MEM_wcp0_data(EXE_MEM_wcp0_data), 
		.MEM_WB_wcp0_data(MEM_WB_wcp0_data), 
		.COP0_rdata_fw_sel(COP0_rdata_fw_sel)
	);

	// ll_bit
	wire [3:0] MEM_WB_load_type_data;
	wire WB_ll_bit_data = (MEM_WB_load_type_data == `LOAD_LL);
	ll_bit m_ll_bit(
		.clk(clk), 
		.rst_n(rst_n), 
		.clr(exc_en), 
		.ll_bit_i(WB_ll_bit_data), 
		.wll(WB_ll_bit_data), 
		.ll_bit_o(ll_bit_o)
	);
	
	// EXE_MEM_REG_PACKED
	wire EXE_MEM_hi_i_sel_data, EXE_MEM_lo_i_sel_data, EXE_MEM_wmem_data, EXE_MEM_SC_result_sel_data;
	wire [1:0] EXE_MEM_result_sel_data;
	wire [3:0] EXE_MEM_byte_valid_data;
	wire [31:0] EXE_MEM_rf_rdata0_fw_data, EXE_MEM_rf_rdata1_fw_data, EXE_MEM_Instruction_data;
	wire [63:0] EXE_MEM_MulDiv_result_data;
	EXE_MEM_REG_PACKED m_EXE_MEM_REG_PACKED(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(1'b0), 
		.stall1(stcl_ram_cache), 
		.irq(exc_en), 
		.clr(stcl_div), 
		.exc_mask(ID_EXE_exc_mask_data | ID_EXE_fetch_exc_data | ALU_exc), 
		.EXE_MEM_exc_mask_data(EXE_MEM_exc_mask_data), 
		.is_delayslot(ID_EXE_is_delayslot_data), 
		.EXE_MEM_is_delayslot_data(EXE_MEM_is_delayslot_data), 
		.int_i(int_i), 
		.EXE_MEM_int_i_data(EXE_MEM_int_i_data), 
		.wcp0(ID_EXE_wcp0_data), 
		.EXE_MEM_wcp0_data(EXE_MEM_wcp0_data), 
		.store_type(ID_EXE_store_type_data), 
		.EXE_MEM_store_type_data(EXE_MEM_store_type_data), 
		.load_type(ID_EXE_load_type_data), 
		.EXE_MEM_load_type_data(EXE_MEM_load_type_data), 
		.hi_i_sel(ID_EXE_hi_i_sel_data), 
		.EXE_MEM_hi_i_sel_data(EXE_MEM_hi_i_sel_data), 
		.lo_i_sel(ID_EXE_lo_i_sel_data),
		.EXE_MEM_lo_i_sel_data(EXE_MEM_lo_i_sel_data), 
		.whi(ID_EXE_whi_data & ALU_we), 
		.EXE_MEM_whi_data(EXE_MEM_whi_data), 
		.wlo(ID_EXE_wlo_data & ALU_we), 
		.EXE_MEM_wlo_data(EXE_MEM_wlo_data), 
		.wreg(ID_EXE_wreg_data & ALU_we), 
		.EXE_MEM_wreg_data(EXE_MEM_wreg_data), 
		.result_sel(ID_EXE_result_sel_data), 
		.EXE_MEM_result_sel_data(EXE_MEM_result_sel_data), 
		.wmem(ID_EXE_wmem_data & ALU_mwe), 
		.EXE_MEM_wmem_data(EXE_MEM_wmem_data), 
		.rf_rdata0_fw(rf_rdata0_fw_mux_data), 
		.EXE_MEM_rf_rdata0_fw_data(EXE_MEM_rf_rdata0_fw_data), 
		.rf_rdata1_fw(rf_rdata1_fw_mux_data), 
		.EXE_MEM_rf_rdata1_fw_data(EXE_MEM_rf_rdata1_fw_data), 
		.ALU_result(ALU_result), 
		.EXE_MEM_ALU_result_data(EXE_MEM_ALU_result_data), 
		.SC_result_sel(ALU_mwe), 
		.EXE_MEM_SC_result_sel_data(EXE_MEM_SC_result_sel_data), 
		.byte_valid(byte_valid), 
		.EXE_MEM_byte_valid_data(EXE_MEM_byte_valid_data), 
		.MulDiv_result(ID_EXE_is_div_data ? Div_result : Mul_result), 
		.EXE_MEM_MulDiv_result_data(EXE_MEM_MulDiv_result_data), 
		.regdst(EXE_regdst_data), 
		.EXE_MEM_regdst_data(EXE_MEM_regdst_data), 
		.PC_plus4(ID_EXE_PC_plus4_data), 
		.EXE_MEM_PC_plus4_data(EXE_MEM_PC_plus4_data),
		// for test only
		.instruction(ID_EXE_Instruction_data),
		.EXE_MEM_Instruction_data(EXE_MEM_Instruction_data)
	);

	/**************************/
	/*          MEM           */
	/**************************/
	// modifyStoreData
	wire [31:0] mem_wdata;
	modifyStoreData m_modifyStoreData(
		.mem_wdata_i(EXE_MEM_rf_rdata1_fw_data), 
		.store_type(EXE_MEM_store_type_data), 
		.byte_valid(EXE_MEM_byte_valid_data), 
		.mem_wdata_o(mem_wdata)
	);
	
	// MEM_hi_fw_mux
	Mux2T1 m_MEM_hi_fw_mux(
		.s(EXE_MEM_hi_i_sel_data), 
		.y(MEM_hi_data), 
		.d0(EXE_MEM_ALU_result_data), 
		.d1(EXE_MEM_MulDiv_result_data[63:32])
	);
	
	// MEM_lo_fw_mux
	Mux2T1 m_MEM_lo_fw_mux(
		.s(EXE_MEM_lo_i_sel_data), 
		.y(MEM_lo_data), 
		.d0(EXE_MEM_ALU_result_data), 
		.d1(EXE_MEM_MulDiv_result_data[31:0])
	);
	
	// MEM_WB_REG_PACKED
	wire MEM_WB_hi_i_sel_data, MEM_WB_lo_i_sel_data, MEM_WB_SC_result_sel_data;
	wire [1:0] MEM_WB_result_sel_data;
	wire [3:0] MEM_WB_byte_valid_data;
	wire [31:0] MEM_WB_rf_rdata0_fw_data, MEM_WB_rf_rdata1_fw_data, MEM_WB_ALU_result_data, MEM_WB_mem_rdata_data, MEM_WB_PC_plus4_data, MEM_WB_Instruction_data;
	wire [63:0] MEM_WB_MulDiv_result_data;
	MEM_WB_REG_PACKED m_MEM_WB_REG_PACKED(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_ram_cache), 
		.irq(exc_en), 
		.wcp0(EXE_MEM_wcp0_data), 
		.MEM_WB_wcp0_data(MEM_WB_wcp0_data), 
		.load_type(EXE_MEM_load_type_data), 
		.MEM_WB_load_type_data(MEM_WB_load_type_data), 
		.hi_i_sel(EXE_MEM_hi_i_sel_data), 
		.MEM_WB_hi_i_sel_data(MEM_WB_hi_i_sel_data), 
		.lo_i_sel(EXE_MEM_lo_i_sel_data),
		.MEM_WB_lo_i_sel_data(MEM_WB_lo_i_sel_data), 
		.whi(EXE_MEM_whi_data), 
		.MEM_WB_whi_data(MEM_WB_whi_data), 
		.wlo(EXE_MEM_wlo_data), 
		.MEM_WB_wlo_data(MEM_WB_wlo_data), 
		.wreg(EXE_MEM_wreg_data), 
		.MEM_WB_wreg_data(MEM_WB_wreg_data), 
		.result_sel(EXE_MEM_result_sel_data), 
		.MEM_WB_result_sel_data(MEM_WB_result_sel_data),  
		.rf_rdata0_fw(EXE_MEM_rf_rdata0_fw_data), 
		.MEM_WB_rf_rdata0_fw_data(MEM_WB_rf_rdata0_fw_data), 
		.rf_rdata1_fw(EXE_MEM_rf_rdata1_fw_data), 
		.MEM_WB_rf_rdata1_fw_data(MEM_WB_rf_rdata1_fw_data), 
		.ALU_result(EXE_MEM_ALU_result_data), 
		.MEM_WB_ALU_result_data(MEM_WB_ALU_result_data), 
		.SC_result_sel(EXE_MEM_SC_result_sel_data), 
		.MEM_WB_SC_result_sel_data(MEM_WB_SC_result_sel_data), 
		.byte_valid(EXE_MEM_byte_valid_data), 
		.MEM_WB_byte_valid_data(MEM_WB_byte_valid_data), 
		.MulDiv_result(EXE_MEM_MulDiv_result_data), 
		.MEM_WB_MulDiv_result_data(MEM_WB_MulDiv_result_data), 
		.regdst(EXE_MEM_regdst_data), 
		.MEM_WB_regdst_data(MEM_WB_regdst_data), 
		.mem_rdata(mem_rdata), 
		.MEM_WB_mem_rdata_data(MEM_WB_mem_rdata_data),
		// for test
		.PC_plus4(EXE_MEM_PC_plus4_data),
		.MEM_WB_PC_plus4_data(MEM_WB_PC_plus4_data),
		.instruction(EXE_MEM_Instruction_data),
		.MEM_WB_Instruction_data(MEM_WB_Instruction_data)
	);
	
	/**************************/
	/*           WB           */
	/**************************/
	// modifyLoaddata
	wire [31:0] modifiedLoadData;
	modifyLoaddata m_modifyLoaddata(
		.mem_rdata_i(MEM_WB_mem_rdata_data), 
		.rf_rdata_i(MEM_WB_rf_rdata1_fw_data), 
		.load_type(MEM_WB_load_type_data), 
		.byte_valid(MEM_WB_byte_valid_data), 
		.mem_rdata_o(modifiedLoadData)
	);
	
	// result_mux
	wire [31:0] result_mux_data;
	Mux4T1 m_result_mux(
		.s(MEM_WB_result_sel_data), 
		.y(result_mux_data), 
		.d0(modifiedLoadData), 
		.d1(MEM_WB_ALU_result_data), 
		.d2({31'b0, MEM_WB_SC_result_sel_data}), 
		.d3(MEM_WB_ALU_result_data)
	);
	assign WB_result_data = result_mux_data;
	always@(*)
		begin
		$display("modifiedLoadData: 0x%8h, MEM_WB_ALU_result_data: 0x%8h, EXE_MEM_ALU_result_data: 0x%8h, ALU_result: 0x%8h"
				, modifiedLoadData, MEM_WB_ALU_result_data, EXE_MEM_ALU_result_data, ALU_result);
		end
	
	// WB_hi_fw_mux
	Mux2T1 m_WB_hi_fw_mux(
		.s(MEM_WB_hi_i_sel_data), 
		.y(WB_hi_data), 
		.d0(result_mux_data), 
		.d1(MEM_WB_MulDiv_result_data[63:32])
	);
	
	// WB_lo_fw_mux
	Mux2T1 m_WB_lo_fw_mux(
		.s(MEM_WB_lo_i_sel_data), 
		.y(WB_lo_data), 
		.d0(result_mux_data), 
		.d1(MEM_WB_MulDiv_result_data[31:0])
	);

	assign inst_addr = PC_o;
	assign ram_en = (EXE_MEM_load_type_data != 4'd0) || (EXE_MEM_store_type_data != 4'd0);
	assign ram_byte_valid = EXE_MEM_byte_valid_data;
	assign ram_addr = EXE_MEM_ALU_result_data;
	assign ram_dout = mem_wdata;
	assign ram_we = EXE_MEM_wmem_data && !MEM_store_exc;
	
	// for debug
	always@(*)
		begin
		$display("wb_pc: 0x%8h, wb_pc_d: 0d%8d, wb_inst: 0x%8h", debug_wb_pc, debug_wb_pc[19:2], debug_wb_inst);
		end
	assign debug_wb_inst = MEM_WB_Instruction_data;
	assign debug_wb_pc = MEM_WB_PC_plus4_data - 32'h4;
	assign debug_wb_rf_wdata = WB_result_data;
	assign debug_wb_rf_wen = (MEM_WB_load_type_data == 4'b0) ? {4{MEM_WB_wreg_data}} : MEM_WB_byte_valid_data & {4{MEM_WB_wreg_data}};
	assign debug_wb_rf_wnum = MEM_WB_regdst_data;
endmodule