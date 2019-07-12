module Hazard_Detection_Unit(rst_n, EXE_regdst_data, IF_ID_rs_data, IF_ID_rt_data, ID_EXE_load_type_data, ID_EXE_store_type_data, stcl_lw, ID_i_bj, ID_EXE_wreg_data, EXE_MEM_load_type_data, EXE_MEM_store_type_data, stcl_jmp);
	/*********************
	 *		Forwarding Unit
	 *input:
	 *	rst_n						: negetive reset signal
	 *	EXE_regdst_data[4:0]		: EXE regdst data(already decoded by ID_EXE_regdst_data)
	 *	IF_ID_rs_data[4:0]			: IF/ID rs data
	 *	IF_ID_rt_data[4:0]			: IF/ID rt data
	 *	ID_EXE_load_type_data[3:0]	: ID/EXE load_type data
	 *	ID_EXE_store_type_data[3:0]	: ID/EXE store_type data
	 *	ID_i_bj						: ID i_bj data(produced by Control Unit)
	 *	ID_EXE_wreg_data			: ID/EXE wreg data
	 *	EXE_MEM_load_type_data[3:0]	: EXE/MEM load_type data
	 *	EXE_MEM_store_type_data[3:0]: EXE/MEM store_type data
	 *	MEM_WB_regdst_data[4:0]		: MEM/WB regdst data
	 *output:
	 *	stcl_lw						: stall/clrn signal because of lw
	 *	stcl_jmp					: stall/clrn signal because of jump
	 *********************/
	input rst_n;
	// LOAD阻塞
	input [3:0] ID_EXE_load_type_data, ID_EXE_store_type_data;
	input [4:0] EXE_regdst_data, IF_ID_rs_data, IF_ID_rt_data;
	output stcl_lw;
	// 跳转阻塞
	input ID_i_bj, ID_EXE_wreg_data;
	input [3:0] EXE_MEM_load_type_data, EXE_MEM_store_type_data;
	input [4:0] MEM_WB_regdst_data;
	output stcl_jmp;
	
	// LOAD阻塞
	always @(*)
		begin
		if(!rst_n)
			begin
			stcl_lw = 1'b0;
			end
		else if(((IF_ID_rs_data == EXE_regdst_data) || (IF_ID_rt_data == EXE_regdst_data)) && (ID_EXE_load_type_data != 4'd0))
			begin
			stcl_lw = 1'b1;
			end
		else if(((IF_ID_rs_data == EXE_regdst_data) || (IF_ID_rt_data == EXE_regdst_data)) && (ID_EXE_store_type_data == `STR_SC))
			begin
			stcl_lw = 1'b1;
			end
		else
			begin
			stcl_lw = 1'b0;
			end
		end

	// 跳转阻塞
	always @(*)
		begin
		if(!rst_n)
			begin
			stcl_jmp = 1'b0;
			end
		else if(ID_i_bj)
			begin
			if(((IF_ID_rs_data == EXE_regdst_data) || (IF_ID_rt_data == EXE_regdst_data)) && ID_EXE_wreg_data)	//执行阶段相关的ALU指令、LOAD指令、sc指令
				begin
				stcl_jmp = 1'b1;
				end
			else if(((IF_ID_rs_data == MEM_WB_regdst_data) || (IF_ID_rt_data == MEM_WB_regdst_data)) && (EXE_MEM_load_type_data != 4'd0))	//访存阶段相关的LOAD指令
				begin
				stcl_jmp = 1'b1;
				end
			else if(((IF_ID_rs_data == MEM_WB_regdst_data) || (IF_ID_rt_data == MEM_WB_regdst_data)) && (EXE_MEM_store_type_data == `STR_SC))	//访存阶段相关的sc指令
				begin
				stcl_jmp = 1'b1;
				end
			else
				begin
				stcl_jmp = 1'b0;
				end
			end
		else
			begin
			stcl_jmp = 1'b0;
			end
		end
endmodule