`include "../../Define/Instruction_Define.v"
`include "../../Define/LS_Define.v"
module Control_Unit(rst_n, inst, rf_read_data0, rf_read_data1, PC_plus4, is_delayslot_i, eret, is_div, is_sign_div, cu_inst_exc_type, is_delayslot_o, wcp0, store_type, load_type, hi_i_sel, lo_i_sel, whi, wlo, wreg, result_sel, wmem, sign, aluop, alusrc0_sel, alusrc1_sel, regdst, i_bj, i_b, PC_target_sel, PC_branch, tlbr, tlbp, wtlb);
	/*********************
	 *		Control Unit
	 *input:
	 *	rst_n					: negetive reset signal
	 *	inst[31:0]				: instruction
	 *	rf_read_data0[31:0]		: register file read data0
	 *	rd_read_data1[31:0]		: register file read data1
	 *	PC_plus4[31:0]			: current instruction PC + 4
	 *	is_delayslot_i			: assign is_delayslot_o = is_delayslot_i;
	 *output:
	 *	eret					: eret instruction
	 *	is_div					: whether is div operaton
	 *	is_sign_div				: whether is signed div operation
	 *	cu_inst_exc_type[31:0]	: exc mask
	 *	is_delayslot_o			: assign is_delayslot_o = is_delayslot_i;
	 *	wcp0					: write cop0
	 *	store_type[3:0]			: store type
	 *	load_type[3:0]			: load type
	 *	hi_i_sel				: hi_i select signal
	 *	lo_i_sel				: lo_i select signal
	 *	whi						: write hi register
	 *	wlo						: write lo register
	 *	wreg					: write register file
	 *	result_sel[1:0]			: select which result(ALU_result, mem_dout...) to write
	 *	wmem					: write mem
	 *	sign 					: sign extend?
	 *	aluop[7:0]				: ALU opcode
	 *	alusrc0_sel				: select which data to be src0
	 *	alusrc1_sel[1:0]		: select which data to be src1
	 *	regdst[1:0]				: select which register to write
	 *	i_bj					: branch / jump instruction
	 *	i_b 					: branch instruction
	 *	PC_target_sel			: whether select target(jump / branch) PC as PC_i
	 *	PC_branch[31:0]			: branch PC address
	 *	tlbp					: instruction tlbp
	 *	tlbr					: instruction tlbr
	 *	wtlb					: write tlb signal
	 *********************/
	input rst_n;
	input [31:0] inst;
	// for jump / branch
	input [31:0] rf_read_data0, rf_read_data1, PC_plus4;
	// for delayslot
	input is_delayslot_i;
	output is_delayslot_o;
	output reg eret, is_div, is_sign_div, wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, wmem, sign, alusrc0_sel, tlbr, tlbp, wtlb;
	output reg [1:0] result_sel, alusrc1_sel, regdst;
	output reg [3:0] store_type, load_type;
	output reg [7:0] aluop;
	output reg [31:0] cu_inst_exc_type;
	// for branch / jump
	output reg i_bj, i_b, PC_target_sel;		// i_bj is also for delayslot
	output reg [31:0] PC_branch;
	
	assign is_delayslot_o = is_delayslot_i;
	
	wire [5:0] op = inst[31:26];
	wire [4:0] rs = inst[25:21];
	wire [4:0] rt = inst[20:16];
	wire [5:0] func = inst[5:0];
	
	// ALU OPCODE
	always@(*)
		begin
		if(!rst_n)
			begin
			aluop = 8'b0;
			cu_inst_exc_type = 32'b0;
			eret = 1'b0;
			end
		else
			begin
			aluop = `ALUOP_NOP;
			cu_inst_exc_type = 32'b0;
			eret = 1'b0;
			case(op)
				`OPCODE_J:
					begin
					aluop = `ALUOP_NOP;
					end
				`OPCODE_JAL:
					begin
					aluop = `ALUOP_JALR;
					end
				`OPCODE_BEQ,
				`OPCODE_BNE:
					begin
					aluop = `ALUOP_NOP;
					end
				`OPCODE_BLEZ,
				`OPCODE_BGTZ:
					begin
					aluop = `ALUOP_NOP;
					cu_inst_exc_type[10] = |rt;		// RI
					end
				`OPCODE_ADDI:
					begin
					aluop = `ALUOP_ADDI;
					end
				`OPCODE_ADDIU:
					begin
					aluop = `ALUOP_ADDIU;
					end
				`OPCODE_SLTI:
					begin
					aluop = `ALUOP_SLTI;
					end
				`OPCODE_SLTIU:
					begin
					aluop = `ALUOP_SLTIU;
					end
				`OPCODE_ANDI:
					begin
					aluop = `ALUOP_ANDI;
					end
				`OPCODE_ORI:
					begin
					aluop = `ALUOP_ORI;
					end
				`OPCODE_XORI:
					begin
					aluop = `ALUOP_XORI;
					end
				`OPCODE_LUI:
					begin
					aluop = `ALUOP_LU;
					cu_inst_exc_type[10] = |rs;
					end
				`OPCODE_LB:
					begin
					aluop = `ALUOP_LB;
					end
				`OPCODE_LH:
					begin
					aluop = `ALUOP_LH;
					end
				`OPCODE_LWL:
					begin
					aluop = `ALUOP_LWL;
					end
				`OPCODE_LW:
					begin
					aluop = `ALUOP_LW;
					end
				`OPCODE_LBU:
					begin
					aluop = `ALUOP_LBU;
					end
				`OPCODE_LHU:
					begin
					aluop = `ALUOP_LHU;
					end
				`OPCODE_LWR:
					begin
					aluop = `ALUOP_LWR;
					end
				`OPCODE_SB:
					begin
					aluop = `ALUOP_SB;
					end
				`OPCODE_SH:
					begin
					aluop = `ALUOP_SH;
					end
				`OPCODE_SWL:
					begin
					aluop = `ALUOP_SWL;
					end
				`OPCODE_SW:
					begin
					aluop = `ALUOP_SW;
					end
				`OPCODE_SWR:
					begin
					aluop = `ALUOP_SWR;
					end
				`OPCODE_LL:
					begin
					aluop = `ALUOP_LL;
					end
				`OPCODE_PREF:
					begin
					aluop = `ALUOP_NOP;
					end
				`OPCODE_SC:
					begin
					aluop = `ALUOP_SC;
					end
				`OPCODE_COP0:
					begin
					case(rs)
						`RS_MFC0:
							begin
							aluop = `ALUOP_MFC;
							end
						`RS_MTC0:
							begin
							aluop = `ALUOP_MTC;
							end
						default:
							begin
							if(rs[4] == `CO_TLB)
								begin
								case(func)
									`FUNC_TLBR,
									`FUNC_TLBWI,
									`FUNC_TLBP:
										begin
										aluop = `ALUOP_NOP;
										end
									`FUNC_ERET:
										begin
										eret = 1'b1;
										end
									default:
										begin
										cu_inst_exc_type[10] = 1'b1;
										end
								endcase
								end
							else
								begin
								cu_inst_exc_type[10] = 1'b1;
								end
							end
					endcase
					end
				`OPCODE_COP1:
					begin
					cu_inst_exc_type[11] = 1'b1;		// CpU
					end
				`OPCODE_REGIMM:
					begin
					case(rt)
						`RT_BLTZ,
						`RT_BGEZ:
							begin
							aluop = `ALUOP_NOP;
							end
						`RT_TGEI:
							begin
							aluop = `ALUOP_TGE;
							end
						`RT_TGEIU:
							begin
							aluop = `ALUOP_TGEU;
							end
						`RT_TLTI:
							begin
							aluop = `ALUOP_TLT;
							end
						`RT_TLTIU:
							begin
							aluop = `ALUOP_TLTU;
							end
						`RT_TEQI:
							begin
							aluop = `ALUOP_TEQ;
							end
						`RT_TNEI:
							begin
							aluop = `ALUOP_TNE;
							end
						`RT_BLTZAL,
						`RT_BGEZAL:
							begin
							aluop = `ALUOP_JALR;
							end
						default:
							begin
							cu_inst_exc_type[10] = 1'b1;
							end
					endcase
					end
				`OPCODE_SPECIAL2:
					begin
					case(func)
						`FUNC_MADD:
							begin
							aluop = `ALUOP_MADD;
							end
						`FUNC_MADDU:
							begin
							aluop = `ALUOP_MADDU;
							end
						`FUNC_MUL:
							begin
							aluop = `ALUOP_MUL;
							end
						`FUNC_MSUB:
							begin
							aluop = `ALUOP_MSUB;
							end
						`FUNC_MSUBU:
							begin
							aluop = `ALUOP_MSUBU;
							end
						`FUNC_CLZ:
							begin
							aluop = `ALUOP_CLZ;
							end
						`FUNC_CLO:
							begin
							aluop = `ALUOP_CLO;
							end
						default:
							begin
							cu_inst_exc_type[10] = 1'b1;
							end
					endcase
					end
				`OPCODE_SPECIAL:
					begin
					case(func)
						`FUNC_SLL:
							begin
							aluop = `ALUOP_SLL;
							end
						`FUNC_SRL:
							begin
							aluop = `ALUOP_SRL;
							end
						`FUNC_SRA:
							begin
							aluop = `ALUOP_SRA;
							end
						`FUNC_SLLV:
							begin
							aluop = `ALUOP_SLLV;
							end
						`FUNC_SRLV:
							begin
							aluop = `ALUOP_SRLV;
							end
						`FUNC_SRAV:
							begin
							aluop = `ALUOP_SRAV;
							end
						`FUNC_JR:
							begin
							aluop = `ALUOP_NOP;
							end
						`FUNC_JALR:
							begin
							aluop = `ALUOP_JALR;
							end
						`FUNC_MOVZ:
							begin
							aluop = `ALUOP_MOVZ;
							end
						`FUNC_MOVN:
							begin
							aluop = `ALUOP_MOVN;
							end
						`FUNC_SYSCALL:
							begin
							cu_inst_exc_type[8] = 1'b1;
							end
						`FUNC_BREAK:
							begin
							cu_inst_exc_type[9] = 1'b1;
							end
						`FUNC_SYNC:
							begin
							aluop = `ALUOP_NOP;
							end
						`FUNC_MFHI:
							begin
							aluop = `ALUOP_MFHI;
							end
						`FUNC_MTHI:
							begin
							aluop = `ALUOP_MTHI;
							end
						`FUNC_MFLO:
							begin
							aluop = `ALUOP_MFLO;
							end
						`FUNC_MTLO:
							begin
							aluop = `ALUOP_MTLO;
							end
						`FUNC_MULT:
							begin
							aluop = `ALUOP_MULT;
							end
						`FUNC_MULTU:
							begin
							aluop = `ALUOP_MULTU;
							end
						`FUNC_DIV,
						`FUNC_DIVU:
							begin
							aluop = `ALUOP_NOP;
							end
						`FUNC_ADD:
							begin
							aluop = `ALUOP_ADD;
							end
						`FUNC_ADDU:
							begin
							aluop = `ALUOP_ADDU;
							end
						`FUNC_SUB:
							begin
							aluop = `ALUOP_SUB;
							end
						`FUNC_SUBU:
							begin
							aluop = `ALUOP_SUBU;
							end
						`FUNC_AND:
							begin
							aluop = `ALUOP_AND;
							end
						`FUNC_OR:
							begin
							aluop = `ALUOP_OR;
							end
						`FUNC_XOR:
							begin
							aluop = `ALUOP_XOR;
							end
						`FUNC_NOR:
							begin
							aluop = `ALUOP_NOR;
							end
						`FUNC_SLT:
							begin
							aluop = `ALUOP_SLT;
							end
						`FUNC_SLTU:
							begin
							aluop = `ALUOP_SLTU;
							end
						`FUNC_TGE:
							begin
							aluop = `ALUOP_TGE;
							end
						`FUNC_TGEU:
							begin
							aluop = `ALUOP_TGEU;
							end
						`FUNC_TLT:
							begin
							aluop = `ALUOP_TLT;
							end
						`FUNC_TLTU:
							begin
							aluop = `ALUOP_TLTU;
							end
						`FUNC_TEQ:
							begin
							aluop = `ALUOP_TEQ;
							end
						`FUNC_TNE:
							begin
							aluop = `ALUOP_TNE;
							end
						default:
							begin
							cu_inst_exc_type[10] = 1'b1;
							end
					endcase
					end
				default:
					begin
					cu_inst_exc_type[10] = 1'b1;
					end
			endcase
			end
		end
		
	wire [15:0] offset = inst[15:0];
	wire [25:0] target = inst[25:0];
	wire [31:0] PC_target_b = PC_plus4 + {{14{offset[15]}}, offset, 2'b00};
	wire [31:0] PC_target_j = {PC_plus4[31:28], target, 2'b00};
	// other control signal
	always@(*)
		begin
		if(!rst_n)
			begin
			is_div = 1'b0;
			is_sign_div = 1'b0;
			wcp0 = 1'b0;
			store_type = 4'b0;
			load_type = 4'b0;
			hi_i_sel = 1'b0;
			lo_i_sel = 1'b0;
			whi = 1'b0;
			wlo = 1'b0;
			wreg = 1'b0;
			result_sel = 2'b0;
			wmem = 1'b0;
			sign = 1'b1;		// 
			alusrc0_sel = 1'b0;
			alusrc1_sel = 2'b0;
			regdst = 2'b0;
			i_bj = 1'b0;
			i_b = 1'b0;
			PC_target_sel = 1'b0;
			PC_branch = 32'b0;
			tlbr = 1'b0;
			tlbp = 1'b0;
			wtlb = 1'b0;
			end
		else
			begin
			is_div = 1'b0;
			is_sign_div = 1'b0;
			wcp0 = 1'b0;
			store_type = 4'b0;
			load_type = 4'b0;
			hi_i_sel = 1'b0;
			lo_i_sel = 1'b0;
			whi = 1'b0;
			wlo = 1'b0;
			wreg = 1'b0;
			result_sel = 2'b0;
			wmem = 1'b0;
			sign = 1'b1;		// 
			alusrc0_sel = 1'b0;
			alusrc1_sel = 2'b0;
			regdst = 2'b0;
			i_bj = 1'b0;
			i_b = 1'b0;
			PC_target_sel = 1'b0;
			PC_branch = 32'b0;
			tlbr = 1'b0;
			tlbp = 1'b0;
			wtlb = 1'b0;
			case(op)
				`OPCODE_ANDI,
				`OPCODE_ORI,
				`OPCODE_XORI,
				`OPCODE_LUI:
					begin
					wreg = 1'b1;
					result_sel = 2'b01;
					sign = 1'b0;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_PREF:
					begin
					;
					end
				`OPCODE_ADDI,
				`OPCODE_ADDIU,
				`OPCODE_SLTI,
				`OPCODE_SLTIU:
					begin
					wreg = 1'b1;
					result_sel = 2'b01;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_LB:
					begin
					load_type = `LOAD_LB;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_LBU:
					begin
					load_type = `LOAD_LBU;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_LH:
					begin
					load_type = `LOAD_LH;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_LHU:
					begin
					load_type = `LOAD_LHU;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_LW:
					begin
					load_type = `LOAD_LW;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					// $display("LW -> instruction: 0x%8h, rs: 0x%2h, rt: 0x%2h", inst, inst[25:21], inst[20:16]);
					end
				`OPCODE_LWL:
					begin
					load_type = `LOAD_LWL;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_LWR:
					begin
					load_type = `LOAD_LWR;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_SB:
					begin
					store_type = `STORE_SB;
					wmem = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_SH:
					begin
					store_type = `STORE_SH;
					wmem = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_SW:
					begin
					store_type = `STORE_SW;
					wmem = 1'b1;
					alusrc1_sel = 2'b11;
					// $display("SW -> instruction: 0x%8h, rs: 0x%2h, rt: 0x%2h", inst, inst[25:21], inst[20:16]);
					end
				`OPCODE_SWL:
					begin
					store_type = `STORE_SWL;
					wmem = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_SWR:
					begin
					store_type = `STORE_SWR;
					wmem = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_LL:
					begin
					load_type = `LOAD_LL;
					wreg = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_SC:
					begin
					store_type = `STORE_SC;
					wreg = 1'b1;
					result_sel = 2'b10;
					wmem = 1'b1;
					alusrc1_sel = 2'b11;
					end
				`OPCODE_J:
					begin
					PC_target_sel = 1'b1;
					PC_branch = PC_target_j;
					i_bj = 1'b1;
					end
				`OPCODE_JAL:
					begin
					wreg = 1'b1;
					result_sel = 2'b01;
					regdst = 2'b10;
					PC_target_sel = 1'b1;
					PC_branch = PC_target_j;
					i_bj = 1'b1;
					end
				`OPCODE_BEQ:
					begin
					i_bj = 1'b1;
					i_b = 1'b1;
					PC_target_sel = ~|(rf_read_data0 ^ rf_read_data1);
					PC_branch = PC_target_b;
					end
				`OPCODE_BGTZ:
					begin
					i_bj = 1'b1;
					i_b = 1'b1;
					PC_target_sel = ((~rf_read_data0[31]) && (rf_read_data0 != 32'b0));
					PC_branch = PC_target_b;
					end
				`OPCODE_BLEZ:
					begin
					i_bj = 1'b1;
					i_b = 1'b1;
					PC_target_sel = ((rf_read_data0[31]) || (rf_read_data0 == 32'b0));
					PC_branch = PC_target_b;
					end
				`OPCODE_BNE:
					begin
					i_bj = 1'b1;
					i_b = 1'b1;
					PC_target_sel = (rf_read_data0 != rf_read_data1);
					PC_branch = PC_target_b;
					end
				`OPCODE_COP0:
					begin
					case(rs)
						`RS_MTC0:
							begin
							wcp0 = 1'b1;
							regdst = 2'b01;
							result_sel = 2'b01;
							end
						`RS_MFC0:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							end
						default:
							begin
							if(rs[4] == `CO_TLB)
								begin
								case(func)
									`FUNC_TLBR:
										begin
										tlbr = 1'b1;
										end
									`FUNC_TLBWI:
										begin
										wtlb = 1'b1;
										end
									`FUNC_TLBP:
										begin
										tlbp = 1'b1;
										result_sel = 2'b01;
										end
								endcase
								end
							end
					endcase
					end
				`OPCODE_REGIMM:
					begin
					case(rt)
						`RT_BLTZ:
							begin
							i_bj = 1'b1;
							i_b = 1'b1;
							PC_target_sel = (rf_read_data0[31]);
							PC_branch = PC_target_b;
							end
						`RT_BGEZ:
							begin
							i_bj = 1'b1;
							i_b = 1'b1;
							PC_target_sel = (~rf_read_data0[31]);
							PC_branch = PC_target_b;
							end
						`RT_BLTZAL:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b10;
							i_bj = 1'b1;
							i_b = 1'b1;
							PC_target_sel = (rf_read_data0[31]);
							PC_branch = PC_target_b;
							end
						`RT_BGEZAL:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b10;
							i_bj = 1'b1;
							i_b = 1'b1;
							PC_target_sel = (~rf_read_data0[31]);
							PC_branch = PC_target_b;
							end
						`RT_TGEI,
						`RT_TGEIU,
						`RT_TLTI,
						`RT_TLTIU,
						`RT_TEQI,
						`RT_TNEI:
							begin
							alusrc1_sel = 2'b11;
							end
					endcase
					end
				`OPCODE_SPECIAL2:
					begin
					case(func)
						`FUNC_CLZ,
						`FUNC_CLO:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b01;
							end
						`FUNC_MUL:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b01;
							end
						`FUNC_MADD,
						`FUNC_MADDU,
						`FUNC_MSUB,
						`FUNC_MSUBU:
							begin
							hi_i_sel = 1'b1;
							lo_i_sel = 1'b1;
							whi = 1'b1;
							wlo = 1'b1;
							end
					endcase
					end
				`OPCODE_SPECIAL:
					begin
					case(func)
						`FUNC_AND,
						`FUNC_OR,
						`FUNC_XOR,
						`FUNC_NOR:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b01;
							end
						`FUNC_SLL,
						`FUNC_SRL,
						`FUNC_SRA:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							alusrc0_sel = 1'b1;
							regdst = 2'b01;
							end
						`FUNC_SLLV,
						`FUNC_SRLV,
						`FUNC_SRAV:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b01;
							end
						`FUNC_SYNC:
							begin
							;
							end
						`FUNC_MOVZ,
						`FUNC_MOVN:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b01;
							end
						`FUNC_MFHI:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							alusrc1_sel = 2'b01;
							regdst = 2'b01;
							end
						`FUNC_MFLO:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							alusrc1_sel = 2'b10;
							regdst = 2'b01;
							end
						`FUNC_MTHI:
							begin
							whi = 1'b1;
							result_sel = 2'b01;
							end
						`FUNC_MTLO:
							begin
							wlo = 1'b1;
							result_sel = 2'b01;
							end
						`FUNC_ADD,
						`FUNC_ADDU,
						`FUNC_SUB,
						`FUNC_SUBU,
						`FUNC_SLT,
						`FUNC_SLTU:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b01;
							end
						`FUNC_MULT,
						`FUNC_MULTU:
							begin
							hi_i_sel = 1'b1;
							lo_i_sel = 1'b1;
							whi = 1'b1;
							wlo = 1'b1;
							end
						`FUNC_DIV:
							begin
							is_div = 1'b1;
							is_sign_div = 1'b1;
							hi_i_sel = 1'b1;
							lo_i_sel = 1'b1;
							whi = 1'b1;
							wlo = 1'b1;
							end
						`FUNC_DIVU:
							begin
							is_div = 1'b1;
							hi_i_sel = 1'b1;
							lo_i_sel = 1'b1;
							whi = 1'b1;
							wlo = 1'b1;
							end
						`FUNC_JR:
							begin
							PC_target_sel = 1'b1;
							PC_branch = rf_read_data0;
							i_b = 1'b1;
							i_bj = 1'b1;
							end
						`FUNC_JALR:
							begin
							wreg = 1'b1;
							result_sel = 2'b01;
							regdst = 2'b01;
							PC_target_sel = 1'b1;
							PC_branch = rf_read_data0;
							i_b = 1'b1;
							i_bj = 1'b1;
							end
						`FUNC_TGE,
						`FUNC_TGEU,
						`FUNC_TLT,
						`FUNC_TLTU,
						`FUNC_TEQ,
						`FUNC_TNE:
							begin
							;
							end
					endcase
					end
			endcase
			end
		end
endmodule