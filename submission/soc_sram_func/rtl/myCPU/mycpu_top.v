module mycpu_top(clk, resetn, int, inst_sram_en, inst_sram_wen, inst_sram_addr, inst_sram_wdata, inst_sram_rdata, data_sram_en, data_sram_wen, data_sram_addr, data_sram_wdata, data_sram_rdata, debug_wb_pc, debug_wb_rf_wen, debug_wb_rf_wnum, debug_wb_rf_wdata, debug_wb_inst);
	input clk, resetn;
	input [5:0] int;
	output inst_sram_en, inst_sram_wen;
	output [31:0] inst_sram_addr, inst_sram_wdata;
	input [31:0] inst_sram_rdata;
	output data_sram_en;
	output [3:0] data_sram_wen;
	output [31:0] data_sram_addr, data_sram_wdata;
	input [31:0] data_sram_rdata;
	output [31:0] debug_wb_pc, debug_wb_rf_wdata, debug_wb_inst;
	output [3:0] debug_wb_rf_wen;
	output [4:0] debug_wb_rf_wnum;
	
	// Mips
	Mips m_Mips(
		.clk(~clk), 
		.rst_n(resetn), 
		.inst_data(inst_sram_rdata), 
		.inst_addr(inst_sram_addr), 
		.ram_en(data_sram_en), 
		.ram_we(data_sram_wen), 
		.ram_din(data_sram_rdata), 
		.ram_dout(data_sram_wdata), 
		.ram_addr(data_sram_addr), 
		.ram_byte_valid(), 
		.int_i(int[5:1]),
		.debug_wb_pc(debug_wb_pc), 
		.debug_wb_rf_wdata(debug_wb_rf_wdata),
		.debug_wb_rf_wen(debug_wb_rf_wen),
		.debug_wb_rf_wnum(debug_wb_rf_wnum),
		.debug_wb_inst(debug_wb_inst)
	);
	assign inst_sram_en = 1'b1;
	assign inst_sram_wen = 1'b0;
endmodule