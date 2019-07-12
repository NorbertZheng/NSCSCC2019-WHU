module Control_Unit(rst_n, op, rs, rt, rd, func, wreg, rn, rmem, wmem, );
	/*********************
	 *		Control Unit
	 *input:
	 *	rst_n				: negetive reset signal
	 *	op[5:0]				: instruction opcode segment
	 *	rs[4:0]				: instruction rs segment
	 *	rt[4:0]				: instruction rt segment
	 *	rd[4:0]				: instruction rd segment
	 *	func[5:0]			: instruction func segment
	 *output:
	 *	wreg				: write register file signal
	 *	rn[4:0]				: select which register to write
	 *	rmem				: read mem signal
	 *	wmem				: write mem signal
	 *********************/
	input rst_n;
	input [4:0] rs, rt, rd;
	input [5:0] op, func;
	output wreg, rmem, wmem;
	output reg [4:0] rn;
	
	/**********************************/
	/*		nop instruction		 	  */
	/**********************************/
	wire i_nop = ~((|op) | (|rs) | (|rt) | (|func));
	/**********************************/
	/*		R type instruction		  */
	/**********************************/
	wire r_type = ~|op;
	// arith & logic 
	wire i_add = r_type & func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];
	wire i_addu = r_type & func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & func[0];
	wire i_and = r_type & func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & ~func[0];
	wire i_div = r_type & ~func[5] & func[4] & func[3] & ~func[2] & func[1] & ~func[0];
	wire i_divu = r_type & ~func[5] & func[4] & func[3] & ~func[2] & func[1] & func[0];
	wire i_mult = r_type & ~func[5] & func[4] & func[3] & ~func[2] & ~func[1] & ~func[0];
	wire i_multu = r_type & ~func[5] & func[4] & func[3] & ~func[2] & ~func[1] & func[0];
	wire i_nor = r_type & func[5] & ~func[4] & ~func[3] & func[2] & func[1] & func[0];
	wire i_or = r_type & func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & func[0];
	wire i_sll = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];
	wire i_sllv = r_type & ~func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & ~func[0];
	wire i_sra = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & func[0];
	wire i_srav = r_type & ~func[5] & ~func[4] & ~func[3] & func[2] & func[1] & func[0];
	wire i_srl = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & ~func[0];
	wire i_srlv = r_type & ~func[5] & ~func[4] & ~func[3] & func[2] & func[1] & ~func[0];
	wire i_sub = r_type & func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & ~func[0];
	wire i_subu = r_type & func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & func[0];
	wire i_xor = r_type & func[5] & ~func[4] & ~func[3] & func[2] & func[1] & ~func[0];
	wire i_slt = r_type & func[5] & ~func[4] & func[3] & ~func[2] & func[1] & ~func[0];
	wire i_sltu = r_type & func[5] & ~func[4] & func[3] & ~func[2] & func[1] & func[0];
	// jump
	wire i_jalr = r_type & ~func[5] & ~func[4] & func[3] & ~func[2] & ~func[1] & func[0];
	wire i_jr = r_type & ~func[5] & ~func[4] & func[3] & ~func[2] & ~func[1] & ~func[0];
	// trap
	wire i_teq = r_type & func[5] & func[4] & ~func[3] & func[2] & ~func[1] & ~func[0];
	wire i_tne = r_type & func[5] & func[4] & ~func[3] & func[2] & func[1] & ~func[0];
	wire i_tge = r_type & func[5] & func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];
	wire i_tgeu = r_type & func[5] & func[4] & ~func[3] & ~func[2] & ~func[1] & func[0];
	wire i_tlt = r_type & func[5] & func[4] & ~func[3] & ~func[2] & func[1] & ~func[0];
	wire i_tltu = r_type & func[5] & func[4] & ~func[3] & ~func[2] & func[1] & func[0];
	// operate on hi & lo
	wire i_mfhi = r_type & ~func[5] & func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];
	wire i_mflo = r_type & ~func[5] & func[4] & ~func[3] & ~func[2] & func[1] & ~func[0];
	wire i_mthi = r_type & ~func[5] & func[4] & ~func[3] & ~func[2] & ~func[1] & func[0];
	wire i_mtlo = r_type & ~func[5] & func[4] & ~func[3] & ~func[2] & func[1] & func[0];
	// conditional mov
	wire i_movn = r_type & ~func[5] & ~func[4] & func[3] & ~func[2] & func[1] & func[0];
	wire i_movz = r_type & ~func[5] & ~func[4] & func[3] & ~func[2] & func[1] & ~func[0];
	// exception and interrupt instruction
	wire i_syscall = r_type & ~func[5] & ~func[4] & func[3] & func[2] & ~func[1] & ~func[0];
	wire i_break = r_type & ~func[5] & ~func[4] & func[3] & func[2] & ~func[1] & func[0];
	/**********************************/
	/*		I type instruction		  */
	/**********************************/
	wire i_addi = ~op[5] & ~op[4] & op[3] & ~op[2] & ~op[1] & ~op[0];
	wire i_addiu = ~op[5] & ~op[4] & op[3] & ~op[2] & ~op[1] & op[0];
	wire i_andi = ~op[5] & ~op[4] & op[3] & op[2] & ~op[1] & ~op[0];
	wire i_ori = ~op[5] & ~op[4] & op[3] & op[2] & ~op[1] & op[0];
	wire i_xori = ~op[5] & ~op[4] & op[3] & op[2] & op[1] & ~op[0];
	wire i_lui = ~op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0];
	wire i_slti = ~op[5] & ~op[4] & op[3] & ~op[2] & op[1] & ~op[0];
	wire i_sltiu = ~op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
	// opcode == 0x1c
	wire op_1c = ~op[5] & op[4] & op[3] & op[2] & ~op[1] & ~op[0];
	wire i_clo = op_1c & func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & func[0];
	wire i_clz = op_1c & func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];
	wire i_mul = op_1c & ~func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & ~func[0];
	wire i_madd = op_1c & ~func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];
	wire i_maddu = op_1c & ~func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & func[0];
	wire i_msub = op_1c & ~func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & ~func[0];
	wire i_msubu = op_1c & ~func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & func[0];
	// branch instruction
	wire op_1 = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & op[0];
	wire i_beq = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
	wire i_bgtz = ~op[5] & ~op[4] & ~op[3] & op[2] & op[1] & op[0];
	wire i_blez = ~op[5] & ~op[4] & ~op[3] & op[2] & op[1] & ~op[0];
	wire i_bne = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
	wire i_bgez = op_1 & ~rt[4] & ~rt[3] & ~rt[2] & ~rt[1] & rt[0];
	wire i_bgezal = op_1 & rt[4] & ~rt[3] & ~rt[2] & ~rt[1] & rt[0];
	wire i_bltzal = op_1 & rt[4] & ~rt[3] & ~rt[2] & ~rt[1] & ~rt[0];
	wire i_bltz = op_1 & ~rt[4] & ~rt[3] & ~rt[2] & ~rt[1] & ~rt[0];
	// trap
	wire i_teqi = op_1 & ~rt[4] & rt[3] & rt[2] & ~rt[1] & ~rt[0];
	wire i_tnei = op_1 & ~rt[4] & rt[3] & rt[2] & rt[1] & ~rt[0];
	wire i_tgei = op_1 & ~rt[4] & rt[3] & ~rt[2] & ~rt[1] & ~rt[0];
	wire i_tgeiu = op_1 & ~rt[4] & rt[3] & ~rt[2] & ~rt[1] & rt[0];
	wire i_tlti = op_1 & ~rt[4] & rt[3] & ~rt[2] & rt[1] & ~rt[0];
	wire i_tltiu = op_1 & ~rt[4] & rt[3] & ~rt[2] & rt[1] & rt[0];
	// jump
	wire i_j = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
	wire i_jal = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
	// load
	wire i_lb = op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
	wire i_lbu = op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
	wire i_lh = op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & op[0];
	wire i_lhu = op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
	wire i_lw = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
	wire i_lwl = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
	wire i_lwr = op[5] & ~op[4] & ~op[3] & op[2] & op[1] & ~op[0];
	wire i_ll = op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
	/// store
	wire i_sb = op[5] & ~op[4] & op[3] & ~op[2] & ~op[1] & ~op[0];
	wire i_sh = op[5] & ~op[4] & op[3] & ~op[2] & ~op[1] & op[0];
	wire i_sw = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
	wire i_swl = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & ~op[0];
	wire i_swr = op[5] & ~op[4] & op[3] & op[2] & op[1] & ~op[0];
	wire i_sc = op[5] & op[4] & op[3] & ~op[2] & ~op[1] & ~op[0];
	// CoPR0 instruction
	wire op_10 = ~op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
	wire i_mfc0 = op_10 & ~rs[4] & ~rs[3] & ~rs[2] & ~rs[1] & ~rs[0];
	wire i_mtc0 = op_10 & ~rs[4] & ~rs[3] & rs[2] & ~rs[1] & ~rs[0];
	wire i_eret = op_10 & rs[4] & ~func[5] & func[4] & func[3] & ~func[2] & ~func[1] & ~func[0];
	
	assign wreg = 	(i_add | i_addu | i_and | i_nor | i_or | i_sll | i_sllv | i_sra | i_srav | i_srl | i_srlv | i_sub | i_subu | i_xor | i_slt | i_sltu | 
					i_jalr | i_mfhi | i_mflo | i_movn | i_movz | i_addi | i_addiu | i_andi | i_ori | i_xori | i_lui | i_slti | i_sltiu | i_clo | i_clz | 
					i_mul | i_lb | i_lbu | i_lh | i_lhu | i_lw | i_lwl | i_lwr | i_ll | i_mfc0) & rst_n;
	wire write_rd =	i_add | i_addu | i_and | i_nor | i_or | i_sll | i_sllv | i_sra | i_srav | i_srl | i_srlv | i_sub | i_subu | i_xor | i_slt | i_sltu | 
					i_jalr | i_mfhi | i_mflo | i_movn | i_movz | i_clo | i_clz | i_mul;
	wire write_rt =	i_addi | i_addiu | i_andi | i_ori | i_xori | i_lui | i_slti | i_sltiu | i_lb | i_lbu | i_lh | i_lhu | i_lw | i_lwl | i_lwr | i_ll | 
					i_mfc0;
	always@(*)
		begin
		if(!rst_n)
			begin
			rn = 5'b0;
			end
		else
			begin
			if(write_rd)
				begin
				rn = rd;
				end
			else if(write_rt)
				begin
				rn = rt;
				end
			else
				begin
				rn = 5'b0;
				end
			end
		end
	assign rmem = i_lb | i_lbu | i_lh | i_lhu | i_lw | i_lwl | i_lwr | i_ll;
	assign wmem = i_sb | i_sh | i_sw | i_swl | i_swr | i_sc;
endmodule