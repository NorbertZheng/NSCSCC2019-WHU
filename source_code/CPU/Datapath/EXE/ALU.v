module ALU(aluop, src0, src1, ll_bit_o, hilo_o, EXE_PC_plus8, COP0_rdata, ALU_result, ALU_we, ALU_mwe, Mul_result, byte_valid, ALU_exc);
	/*********************
	 *			ALU
	 *input:
	 *	aluop[7:0]			: ALU opcode
	 *	src0[31:0]			: src0
	 *	src1[31:0]			: src1
	 *	ll_bit_o			: ll_bit_o
	 *	hilo_o[63:0]		: {hi_o, lo_o}
	 *	EXE_PC_plus8[31:0]	: ID_EXE_PC_plus4_data + 4
	 *	COP0_rdata[31:0]	: COP0 read data
	 *output:
	 *	ALU_result[31:0]	: ALU result
	 *	ALU_we				: ???
	 *	ALU_mwe				: ???
	 *	Mul_result[63:0]	: Mul result
	 *	byte_valid[3:0]		: identity which byte in word is valid
	 *	ALU_exc[7:0]		: exc produced by ALU
	 *********************/
	input ll_bit_o;
	input [7:0] aluop;
	input [31:0] src0, src1, EXE_PC_plus8, COP0_rdata;
	input [63:0] hilo_o;
	output ALU_we;
	output reg ALU_mwe;
	output reg [3:0] byte_valid;
	output reg [7:0] ALU_exc;
	output reg [31:0] ALU_result;
	output reg [63:0] Mul_result;
	
	reg reg_we_mov;
	wire reg_we_arithm;
	reg [31:0] logic_result, shift_result, mov_result, load_result, arith_result, COP0_result;
	wire [63:0] mult_result;
	
	// Logic
	always@(*)
		begin
		case (aluop)
			`ALUOP_AND,
			`ALUOP_ANDI:
				begin
				logic_result = src0 & src1;
				end
			`ALUOP_OR,
			`ALUOP_ORI:
				begin
				logic_result = src0 | src1;
				end
			`ALUOP_XOR,
			`ALUOP_XORI:
				begin
				logic_result = src0 ^ src1;
				end
			`ALUOP_NOR:
				begin
				logic_result = ~(src0 | src1);
				end
			`ALUOP_LU:
				begin
				logic_result = {src1[15:0], 16'd0};
				end
			default:
				begin
				logic_result = 32'b0;
				end
		endcase
		end
		
	// Shift
	always@(*)
		begin
		case(aluop)
			`ALUOP_SLL:
				begin
				shift_result = src1 << src0[10:6];
				end
			`ALUOP_SRL:
				begin
				shift_result = src1 >> src0[10:6];
				end
			`ALUOP_SRA:
				begin
				shift_result = ({32{src1[31]}} << (6'd32-{1'b0, src0[10:6]})) | (src1 >> src0[10:6]);
				end
			`ALUOP_SLLV:
				begin
				shift_result = src1 << src0[4:0];
				end
			`ALUOP_SRLV:
				begin
				shift_result = src1 >> src0[4:0];
				end
			`ALUOP_SRAV:
				begin
				shift_result = ({32{src1[31]}} << (6'd32-{1'b0, src0[4:0]})) | (src1 >> src0[4:0]);
				end
			default:
				begin
				shift_result = 32'b0;
				end
		endcase
		end
		
	// MOV
	always@(*)
		begin
		reg_we_mov = 1'b1;
		case(aluop)
			`ALUOP_MOVN:
				begin
				mov_result = src0;
				reg_we_mov = (src1 == 32'b0) ? 1'b0 : 1'b1;
				end
			`ALUOP_MOVZ:
				begin
				mov_result = src0;
				reg_we_mov = (src1 == 32'b0) ? 1'b1 : 1'b0;
				end
			`ALUOP_MFHI:
				begin
				mov_result = src1;
				reg_we_mov = 1'b1;
				end
			`ALUOP_MFLO:
				begin
				mov_result = src1;
				reg_we_mov = 1'b1;
				end
			`ALUOP_MTHI:
				begin
				mov_result = src0;
				reg_we_mov = 1'b1;
				end
			`ALUOP_MTLO:
				begin
				mov_result = src0;
				reg_we_mov = 1'b1;
				end	
			default:
				begin
				mov_result = 32'b0;
				end
		endcase
		end
		
	// 有关 ov 的 signal
	wire[31:0] sec_opnum = ((aluop == `ALUOP_SUB) || (aluop == `ALUOP_SUBU) || (aluop == `ALUOP_SLT) || 
							(aluop == `ALUOP_SLTI) || (aluop == `ALUOP_TLT) || (aluop == `ALUOP_TGE)) ? (~src1) + 32'b1 : src1;
	wire[31:0] result_sum = src0 + sec_opnum;
	wire add_ov = (((!src0[31] && !sec_opnum[31]) && result_sum[31]) || ((src0[31] && sec_opnum[31]) && (!result_sum[31])));
	wire sub_ov = add_ov | (!src0[31] && src1 == 32'h80000000);
	wire alu_ov = ((aluop == `ALUOP_ADD) || (aluop == `ALUOP_ADDI)) ? add_ov : (aluop == `ALUOP_SUB) ? sub_ov : 1'b0;  
	wire src0_lt_src1_sign = ((src0[31] && !src1[31]) || (!src0[31] && !src1[31] && result_sum[31])|| (src0[31] && src1[31] && result_sum[31]));
	wire[31:0] src0_n = ~src0;
	assign ALU_we = reg_we_mov & (~alu_ov);
	
	// Mul
	wire is_sign_mul = (aluop == `ALUOP_MUL) || (aluop == `ALUOP_MULT) || (aluop == `ALUOP_MADD) || (aluop == `ALUOP_MSUB);
	wire[31:0] mul_op0 = (is_sign_mul && (src0[31]==1'b1)) ? ((~src0) + 1) : src0;
	wire[31:0] mul_op1 = (is_sign_mul && (src1[31]==1'b1)) ? ((~src1) + 1) : src1;
	wire[63:0] mul_tmp = mul_op0 * mul_op1;												// 真直接，有待以后修正
	assign mult_result = (is_sign_mul && (src0[31]^src1[31])) ? (~mul_tmp)+64'd1 : mul_tmp;
	
	// Arith
	wire [63:0] mult_result_n = (~mult_result) + 64'd1;
	wire [63:0] mulacc = ((aluop == `ALUOP_MSUB) || (aluop == `ALUOP_MSUBU)) ? (hilo_o + mult_result_n) : (hilo_o + mult_result);
	always@(*)
		begin
		arith_result = 32'b0;
		Mul_result = 64'b0;
		case (aluop)
			`ALUOP_ADD,
			`ALUOP_ADDU,
			`ALUOP_SUB,
			`ALUOP_SUBU,
			`ALUOP_ADDI,
			`ALUOP_ADDIU:
				begin
				arith_result = result_sum;
				end
			`ALUOP_SLT,
			`ALUOP_SLTI:
				begin
				arith_result = {31'b0, src0_lt_src1_sign};
				end
			`ALUOP_SLTU,
			`ALUOP_SLTIU:
				begin
				arith_result = {31'b0, (src0 < src1)};
				end
			`ALUOP_CLZ:
				begin
				arith_result = 	src0[31] ? 0 : src0[30] ? 1 : src0[29] ? 2 :
								src0[28] ? 3 : src0[27] ? 4 : src0[26] ? 5 :
								src0[25] ? 6 : src0[24] ? 7 : src0[23] ? 8 : 
								src0[22] ? 9 : src0[21] ? 10 : src0[20] ? 11 :
								src0[19] ? 12 : src0[18] ? 13 : src0[17] ? 14 : 
								src0[16] ? 15 : src0[15] ? 16 : src0[14] ? 17 : 
								src0[13] ? 18 : src0[12] ? 19 : src0[11] ? 20 :
								src0[10] ? 21 : src0[9] ? 22 : src0[8] ? 23 : 
								src0[7] ? 24 : src0[6] ? 25 : src0[5] ? 26 : 
								src0[4] ? 27 : src0[3] ? 28 : src0[2] ? 29 : 
								src0[1] ? 30 : src0[0] ? 31 : 32 ;
				end
			`ALUOP_CLO:
				begin
				arith_result = 	src0_n[31] ? 0 : src0_n[30] ? 1 : src0_n[29] ? 2 :
								src0_n[28] ? 3 : src0_n[27] ? 4 : src0_n[26] ? 5 :
								src0_n[25] ? 6 : src0_n[24] ? 7 : src0_n[23] ? 8 : 
								src0_n[22] ? 9 : src0_n[21] ? 10 : src0_n[20] ? 11 :
								src0_n[19] ? 12 : src0_n[18] ? 13 : src0_n[17] ? 14 : 
								src0_n[16] ? 15 : src0_n[15] ? 16 : src0_n[14] ? 17 : 
								src0_n[13] ? 18 : src0_n[12] ? 19 : src0_n[11] ? 20 :
								src0_n[10] ? 21 : src0_n[9] ? 22 : src0_n[8] ? 23 : 
								src0_n[7] ? 24 : src0_n[6] ? 25 : src0_n[5] ? 26 : 
								src0_n[4] ? 27 : src0_n[3] ? 28 : src0_n[2] ? 29 : 
								src0_n[1] ? 30 : src0_n[0] ? 31 : 32;
				end
			`ALUOP_MUL:
				begin
				arith_result = mult_result[31:0];
				end
			`ALUOP_MULT,
			`ALUOP_MULTU:
				begin
				Mul_result = mult_result;
				end
			`ALUOP_MADD,
			`ALUOP_MADDU,
			`ALUOP_MSUB,
			`ALUOP_MSUBU:
				begin
				Mul_result = mulacc;
				end
		endcase
		end
	
	// byte_valid
	// left & right
	wire[3:0] byte_vldp = (result_sum[1:0] == 2'b00) ? 4'b0001 : (result_sum[1:0] == 2'b01) ? 4'b0011 : (result_sum[1:0] == 2'b10) ? 4'b0111 : 4'b1111;	
	wire[3:0] byte_vldn = (result_sum[1:0] == 2'b00) ? 4'b1111 : (result_sum[1:0] == 2'b01) ? 4'b1110 : (result_sum[1:0] == 2'b10) ? 4'b1100 : 4'b1000;
	// byte
	wire[3:0] byte_vldb = (result_sum[1:0] == 2'b00) ? 4'b0001 : (result_sum[1:0] == 2'b01) ? 4'b0010 : (result_sum[1:0] == 2'b10) ? 4'b0100 : 4'b1000;
	// half word
	wire[3:0] byte_vldh = result_sum[1] ? 4'b1100 : 4'b0011;
	always @(*)
		begin
		load_result = 32'd0;
		byte_valid = 4'b0;
		ALU_mwe = 1'b1;
		case (aluop)
			`ALUOP_LB,
			`ALUOP_LBU:
				begin
				byte_valid = byte_vldb;
				load_result = result_sum;
				end
			`ALUOP_LH,
			`ALUOP_LHU:
				begin
				byte_valid = byte_vldh;
				load_result = result_sum;
				end
			`ALUOP_LW:
				begin
				byte_valid = 4'b1111;
				load_result = result_sum;
				end
			`ALUOP_LWL:
				begin
				byte_valid = byte_vldp;
				load_result = result_sum;
				end
			`ALUOP_LWR:
				begin
				byte_valid = byte_vldn;
				load_result = result_sum;
				end
			`ALUOP_SB:
				begin
				byte_valid = byte_vldb;
				load_result = result_sum;
				end
			`ALUOP_SH:
				begin
				byte_valid = byte_vldh;
				load_result = result_sum;
				end
			`ALUOP_SW:
				begin
				byte_valid = 4'b1111;
				load_result = result_sum;
				end
			`ALUOP_SWL:
				begin
				byte_valid = byte_vldp;
				load_result = result_sum;
				end
			`ALUOP_SWR:
				begin
				byte_valid = byte_vldn;
				load_result = result_sum;
				end
			`ALUOP_LL:
				begin
				load_result = result_sum;
				end
			`ALUOP_SC:
				begin
				byte_valid = 4'b1111;
				load_result = result_sum;
				if(!ll_bit_o)
					begin
					ALU_mwe = 1'b0;
					end
				end
		endcase
		end
		
	// COP0_result
	always@(*)
		begin
		COP0_result = 32'd0;
		case(aluop)
		`ALUOP_MTC:
			COP0_result = src1;
		`ALUOP_MFC:
			COP0_result = COP0_rdata;
		endcase
		end
	
	// ALU_result
	always @(*)
		begin
		case (aluop)
			// Logic
			`ALUOP_AND,
			`ALUOP_ANDI,
			`ALUOP_OR,
			`ALUOP_ORI,
			`ALUOP_XOR,
			`ALUOP_XORI,
			`ALUOP_NOR,
			`ALUOP_LU:
				begin
				ALU_result = logic_result;
				end
			// Shift
			`ALUOP_SLL,
			`ALUOP_SRL,
			`ALUOP_SRA,
			`ALUOP_SLLV,
			`ALUOP_SRLV,
			`ALUOP_SRAV:
				begin
				ALU_result = shift_result;
				end
			// MOV
			`ALUOP_MOVN,
			`ALUOP_MOVZ,
			`ALUOP_MFHI,
			`ALUOP_MFLO,
			`ALUOP_MTHI,
			`ALUOP_MTLO:
				begin
				ALU_result = mov_result;
				end
			// Arith
			`ALUOP_ADD,
			`ALUOP_ADDU,
			`ALUOP_SUB,
			`ALUOP_SUBU,
			`ALUOP_ADDI,
			`ALUOP_ADDIU,
			`ALUOP_SLT,
			`ALUOP_SLTI,
			`ALUOP_SLTU,
			`ALUOP_SLTIU,
			`ALUOP_CLZ,
			`ALUOP_CLO,
			`ALUOP_MUL,
			`ALUOP_MULT,
			`ALUOP_MULTU,
			`ALUOP_MADD,
			`ALUOP_MADDU,
			`ALUOP_MSUB,
			`ALUOP_MSUBU:
				begin
				ALU_result = arith_result;
				end
			// Load
			`ALUOP_LB,
			`ALUOP_LBU,
			`ALUOP_LH,
			`ALUOP_LHU,
			`ALUOP_LW,
			`ALUOP_LWL,
			`ALUOP_LWR,
			`ALUOP_SB,
			`ALUOP_SH,
			`ALUOP_SW,
			`ALUOP_SWL,
			`ALUOP_SWR,
			`ALUOP_LL,
			`ALUOP_SC:
				begin
				ALU_result = load_result;
				end
			// JALR
			`ALUOP_JALR:
				begin
				ALU_result = EXE_PC_plus8;		// 跳过 delayslot
				end
			// COP0
			`ALUOP_MTC,
			`ALUOP_MFC:
				begin
				ALU_result = COP0_result;
				end
			default:
				begin
				ALU_result = 32'b0;
				end
		endcase
		end
	
	// ALU_exc
	always@(*)
		begin
		ALU_exc = {4'b0, alu_ov, 3'b0};
		case(aluop)
			`ALUOP_TEQ:
				begin
				ALU_exc[4] = (src0 == src1);
				end
			`ALUOP_TGE:
				begin
				ALU_exc[4] = ~src0_lt_src1_sign;
				end
			`ALUOP_TGEU:
				begin
				ALU_exc[4] = (src0 >= src1);
				end
			`ALUOP_TLT:
				begin
				ALU_exc[4] = src0_lt_src1_sign;
				end
			`ALUOP_TLTU:
				begin
				ALU_exc[4] = (src0 < src1);
				end
			`ALUOP_TNE:
				begin
				ALU_exc[4] = ~(src0 == src1);
				end
		endcase
		end
endmodule