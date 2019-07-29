module victimInstDetector(PC_o, IF_ID_is_delayslot_data, IF_ID_PC_plus4_data, ID_EXE_is_delayslot_data, ID_EXE_PC_plus4_data, EXE_MEM_is_delayslot_data, EXE_MEM_PC_plus4_data, vic_is_delayslot, vic_inst_addr);
	/*********************
	 *	victim instruction detector
	 *input:
	 *	PC_o[31:0]					: IF PC data
	 *	IF_ID_is_delayslot_data		: identity whether instruction at ID stage is in delayslot
	 *	IF_ID_PC_plus4_data[31:0]	: instruction at ID stage addr + 4
	 *	ID_EXE_is_delayslot_data	: identity whether instruction at EXE stage is in delayslot
	 *	ID_EXE_PC_plus4_data[31:0]	: instruction at EXE stage addr + 4
	 *	EXE_MEM_is_delayslot_data	: identity whether instruction at MEM stage is in delayslot
	 *	EXE_MEM_PC_plus4_data[31:0]	: instruction at MEM stage addr + 4
	 *output:
	 *	vic_is_delayslot			: identity whether victim instruction is in delayslot
	 *	vic_inst_addr[31:0]			: victim instruction addr
	 *********************/
	input IF_ID_is_delayslot_data, ID_EXE_is_delayslot_data, EXE_MEM_is_delayslot_data;
	input [31:0] PC_o, IF_ID_PC_plus4_data, ID_EXE_PC_plus4_data, EXE_MEM_PC_plus4_data;
	output reg vic_is_delayslot;
	output reg [31:0] vic_inst_addr;
	
	always @(*)
		begin
		if(EXE_MEM_PC_plus4_data != 32'b0)
			begin
			vic_inst_addr = EXE_MEM_PC_plus4_data - 32'd4;
			vic_is_delayslot = EXE_MEM_is_delayslot_data;
			end
		else if(ID_EXE_PC_plus4_data != 32'b0)
			begin
			vic_inst_addr = ID_EXE_PC_plus4_data - 32'd4;
			vic_is_delayslot = ID_EXE_is_delayslot_data;
			end
		else if(IF_ID_PC_plus4_data != 32'b0)
			begin
			vic_inst_addr = IF_ID_PC_plus4_data - 32'd4;
			vic_is_delayslot = IF_ID_is_delayslot_data;
			end
		else		//针对中断信号持续有效的情况。此时受害指令刚刚从epc回到pc，且此指令必非延迟槽
			begin
			vic_inst_addr = PC_o;
			vic_is_delayslot = 1'b0;
			end
		end
endmodule