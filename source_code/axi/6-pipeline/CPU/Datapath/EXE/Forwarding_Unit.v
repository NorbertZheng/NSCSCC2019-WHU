`include "../../Define/COP0_Define.v"
module Forwarding_Unit(rst_n, IF_ID_rs_data, IF_ID_rt_data, ID_EXE_rs_data, ID_EXE_rt_data, EXE_MEM_wreg_data, EXE_MEM_regdst_data, MEM_WB_wreg_data, MEM_WB_regdst_data, rf_rdata0_fw_sel, rf_rdata1_fw_sel, rf_jdata0_fw_sel, rf_jdata1_fw_sel, EXE_MEM_whi_data, EXE_MEM_wlo_data, MEM_WB_whi_data, MEM_WB_wlo_data, hi_fw_sel, lo_fw_sel, ID_EXE_rd_data, EXE_MEM_wcp0_data, EXE_MEM_tlbp_data, EXE_MEM_tlbr_data, MEM_WB_wcp0_data, MEM_WB_tlbp_data, MEM_WB_tlbr_data, COP0_rdata_fw_sel);
	/*********************
	 *		Forwarding Unit
	 *input:
	 *	rst_n						: negetive reset signal
	 *	IF_ID_rs_data[4:0]			: IF/ID rs data
	 *	IF_ID_rt_data[4:0]			: IF/ID rt data
	 *	ID_EXE_rs_data[4:0]			: ID/EXE rs data
	 *	ID_EXE_rt_data[4:0]			: ID/EXE rt data
	 *	EXE_MEM_wreg_data			: EXE/MEM wreg data
	 *	EXE_MEM_regdst_data[4:0]	: EXE/MEM regdst data
	 *	MEM_WB_wreg_data			: MEM/WB wreg data
	 *	MEM_WB_regdst_data[4:0]		: MEM/WB regdst data
	 *	EXE_MEM_whi_data			: EXE/MEM whi data
	 *	EXE_MEM_wlo_data			: EXE/MEM wlo data
	 *	MEM_WB_whi_data				: MEM/WB whi data
	 *	MEM_WB_wlo_data				: MEM/WB wlo data
	 *	ID_EXE_rd_data[4:0]			: ID/EXE rd data
	 *	EXE_MEM_wcp0_data			: EXE/MEM wcp0 data
	 *	EXE_MEM_tlbp_data			: EXE/MEM tlbp data
	 *	EXE_MEM_tlbr_data			: EXE/MEM tlbr data
	 *	MEM_WB_wcp0_data			: MEM/WB wcp0 data
	 *	MEM_WB_tlbp_data			: MEM/WB tlbp data
	 *	MEM_WB_tlbr_data			: MEM/WB tlbr data
	 *output:
	 *	rf_rdata0_fw_sel[1:0]		: rf_rdata0 forwarding select signal
	 *	rf_rdata1_fw_sel[1:0]		: rf_rdata1 forwarding select signal
	 *	rf_jdata0_fw_sel[1:0]		: rf_jdata0 forwarding select signal
	 *	rf_jdata1_fw_sel[1:0]		: rf_jdata1 forwarding select signal
	 *	hi_fw_sel[1:0]				: hi forwarding select signal
	 *	lo_fw_sel[1:0]				: lo forwarding select signal
	 *	COP0_rdata_fw_sel[2:0]		: COP0_rdata forwarding select signal
	 *********************/
	input rst_n;
	// 寄存器数据前推
	input EXE_MEM_wreg_data, MEM_WB_wreg_data;
	input [4:0] IF_ID_rs_data, IF_ID_rt_data, ID_EXE_rs_data, ID_EXE_rt_data, EXE_MEM_regdst_data, MEM_WB_regdst_data;
	output reg [1:0] rf_rdata0_fw_sel, rf_rdata1_fw_sel, rf_jdata0_fw_sel, rf_jdata1_fw_sel;
	// hilo数据前推
	input EXE_MEM_whi_data, EXE_MEM_wlo_data, MEM_WB_whi_data, MEM_WB_wlo_data;
	output reg [1:0] hi_fw_sel, lo_fw_sel;
	// COP0数据前推
	input EXE_MEM_wcp0_data, EXE_MEM_tlbp_data, EXE_MEM_tlbr_data, MEM_WB_wcp0_data, MEM_WB_tlbp_data, MEM_WB_tlbr_data;
	input [4:0] ID_EXE_rd_data;
	output reg [2:0] COP0_rdata_fw_sel;
	
	// 寄存器数据前推(用于 EXE stage 的 ALU)
	always @(*)
		begin
		if(!rst_n)
			begin
			rf_rdata0_fw_sel = 2'b00;
			end
		else if((ID_EXE_rs_data != 5'd0) && (ID_EXE_rs_data == EXE_MEM_regdst_data) && (EXE_MEM_wreg_data))
			begin
			rf_rdata0_fw_sel = 2'b01;
			end
		else if((ID_EXE_rs_data != 5'd0) && (ID_EXE_rs_data == MEM_WB_regdst_data) && (MEM_WB_wreg_data))
			begin
			rf_rdata0_fw_sel = 2'b10;
			end
		else
			begin
			rf_rdata0_fw_sel = 2'b00;
			end
		end

	always @(*)
		begin
		if(!rst_n)
			begin
			rf_rdata1_fw_sel = 2'b00;
			end
		else if((ID_EXE_rt_data != 5'd0) && (ID_EXE_rt_data == EXE_MEM_regdst_data) && (EXE_MEM_wreg_data))
			begin
			rf_rdata1_fw_sel = 2'b01;
			end
		else if((ID_EXE_rt_data != 5'd0) && (ID_EXE_rt_data == MEM_WB_regdst_data) && (MEM_WB_wreg_data))
			begin
			rf_rdata1_fw_sel = 2'b10;
			end
		else
			begin
			rf_rdata1_fw_sel = 2'b00;
			end
		end
		
	// 寄存器数据前推(用于 ID stage 的 Control Unit)
	always @(*)
		begin
		if(!rst_n)
			begin
			rf_jdata0_fw_sel = 2'b00;
			end
		else if((IF_ID_rs_data != 5'd0) && (IF_ID_rs_data == EXE_MEM_regdst_data) && (EXE_MEM_wreg_data))
			begin
			rf_jdata0_fw_sel = 2'b01;
			end
		else if((IF_ID_rs_data != 5'd0) && (IF_ID_rs_data == MEM_WB_regdst_data) && (MEM_WB_wreg_data))
			begin
			rf_jdata0_fw_sel = 2'b10;
			end
		else
			begin
			rf_jdata0_fw_sel = 2'b00;
			end
		end

	always @(*)
		begin
		if(!rst_n)
			begin
			rf_jdata1_fw_sel = 2'b00;
			end
		else if((IF_ID_rt_data != 5'd0) && (IF_ID_rt_data == EXE_MEM_regdst_data) && (EXE_MEM_wreg_data))
			begin
			rf_jdata1_fw_sel = 2'b01;
			end
		else if((IF_ID_rt_data != 5'd0) && (IF_ID_rt_data == MEM_WB_regdst_data) && (MEM_WB_wreg_data))
			begin
			rf_jdata1_fw_sel = 2'b10;
			end
		else
			begin
			rf_jdata1_fw_sel = 2'b00;
			end
		end

	// hilo数据前推
	always @(*)
		begin
		if(!rst_n)
			begin
			hi_fw_sel = 2'b00;
			end
		else if(EXE_MEM_whi_data)
			begin
			hi_fw_sel = 2'b01;
			end
		else if(MEM_WB_whi_data)
			begin
			hi_fw_sel = 2'b10;
			end
		else
			begin
			hi_fw_sel = 2'b00;
			end
		end

	always @(*)
		begin
		if(!rst_n)
			begin
			lo_fw_sel = 2'b00;
			end
		else if(EXE_MEM_wlo_data)
			begin
			lo_fw_sel = 2'b01;
			end
		else if(MEM_WB_wlo_data)
			begin
			lo_fw_sel = 2'b10;
			end
		else
			begin
			lo_fw_sel = 2'b00;
			end
		end

	// COP0数据前推
	always @(*)
		begin
		if(!rst_n)
			begin
			COP0_rdata_fw_sel = 3'd0;
			end
		else if((ID_EXE_rd_data == EXE_MEM_regdst_data) && EXE_MEM_wcp0_data)
			begin
			COP0_rdata_fw_sel = 3'd1;
			end
		else if((ID_EXE_rd_data == `CP0_INDEX) && EXE_MEM_tlbp_data)
			begin
			COP0_rdata_fw_sel = 3'd1;
			end
		else if(((ID_EXE_rd_data == `CP0_ENTRYLO0) || 
				 (ID_EXE_rd_data == `CP0_ENTRYLO1) || 
				 (ID_EXE_rd_data == `CP0_PAGEMASK) || 
				 (ID_EXE_rd_data == `CP0_ENTRYHI)) && EXE_MEM_tlbr_data)
			begin
			COP0_rdata_fw_sel = 3'd3;
			end
		else if((ID_EXE_rd_data == MEM_WB_regdst_data) && MEM_WB_wcp0_data)
			begin
			COP0_rdata_fw_sel = 3'd2;
			end
		else if((ID_EXE_rd_data == `CP0_INDEX) && MEM_WB_tlbp_data)
			begin
			COP0_rdata_fw_sel = 3'd2;
			end
		else if(((ID_EXE_rd_data == `CP0_ENTRYLO0) || 
				 (ID_EXE_rd_data == `CP0_ENTRYLO1) || 
				 (ID_EXE_rd_data == `CP0_PAGEMASK) || 
				 (ID_EXE_rd_data == `CP0_ENTRYHI)) && MEM_WB_tlbr_data)
			begin
			COP0_rdata_fw_sel = 3'd4;
			end
		else
			begin
			COP0_rdata_fw_sel = 3'd0;
			end
		end
endmodule