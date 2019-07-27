module IF_ID_REG_PACKED(clk, rst_n, stall0, stall1, stall2, stall3, irq, PC_plus4, IF_ID_PC_plus4_data, Instruction, IF_ID_Instruction_data, is_delayslot, IF_ID_is_delayslot_data, if_fetch_exc_type, IF_ID_if_fetch_exc_type_data, asid, IF_ID_asid_data, instMiss, IF_ID_instMiss_data, instValid, IF_ID_instValid_data);
	/*********************
	 *	IF - ID Pipeline Registers PACKED
	 *input:
	 *	clk									: clock
	 *	rst_n								: negetive reset signal
	 *	stall0								: stall0 signal
	 *	stall1								: stall1 signal
	 *	stall2								: stall2 signal
	 *	stall3								: stall3 signal
	 *	irq									: int request signal
	 *	PC_plus4[31:0]						: PC_plus4(which is the output of PCPlus4 module)
	 *	Instruction[31:0]					: Instruction(which is the output of IM cahce)
	 *	is_delayslot						: whether is delayslot instruction
	 *	if_fetch_exc_type[31:0]				: whether happpen fetch exc
	 *	asid[7:0]							: asid
	 *	instMiss							: inst TLB miss signal
	 *	instValid							: inst TLB valid signal
	 *output:
	 *	IF_ID_PC_plus4_data[31:0]			: IF/ID PC_plus4 data
	 *	IF_ID_Instruction_data[31:0]		: IF/ID Instruction data
	 *	IF_ID_is_delayslot_data				: IF/ID is_delayslot data
	 *	IF_ID_if_fetch_exc_type_data[31:0]	: IF/ID if_fetch_exc_type data
	 *	IF_ID_asid_data[7:0]				: IF/ID asid data
	 *	IF_ID_instMiss_data					: IF/ID instMiss data
	 *	IF_ID_instValid_data				: IF/ID instValid data
	 *********************/
	input clk, rst_n;
	input stall0, stall1, stall2, stall3, irq;
	input is_delayslot, instMiss, instValid;
	input [7:0] asid;
	input [31:0] PC_plus4, Instruction, if_fetch_exc_type;
	output reg IF_ID_is_delayslot_data, IF_ID_instMiss_data, IF_ID_instValid_data;
	output reg [7:0] IF_ID_asid_data;
	output reg [31:0] IF_ID_PC_plus4_data, IF_ID_Instruction_data, IF_ID_if_fetch_exc_type_data;
	
	wire IF_ID_Flush = irq;
	wire IF_ID_Stall = (stall0 || stall1 || stall2 || stall3) & ~irq;		// irq 的优先级更高，直接 flush 掉
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			IF_ID_PC_plus4_data <= 32'b0;
			IF_ID_Instruction_data <= 32'b0;
			IF_ID_is_delayslot_data <= 1'b0;
			IF_ID_if_fetch_exc_type_data <= 32'b0;
			IF_ID_asid_data <= 8'b0;
			IF_ID_instMiss_data <= 1'b0;
			IF_ID_instValid_data <= 1'b0;
			end
		else if(!IF_ID_Stall)
			begin
			if(IF_ID_Flush)
				begin
				IF_ID_PC_plus4_data <= 32'b0;
				IF_ID_Instruction_data <= 32'b0;
				IF_ID_is_delayslot_data <= 1'b0;
				IF_ID_if_fetch_exc_type_data <= 32'b0;
				IF_ID_asid_data <= 8'b0;
				IF_ID_instMiss_data <= 1'b0;
				IF_ID_instValid_data <= 1'b0;
				end
			else
				begin
				IF_ID_PC_plus4_data <= PC_plus4;
				IF_ID_Instruction_data <= Instruction;
				IF_ID_is_delayslot_data <= is_delayslot;
				IF_ID_if_fetch_exc_type_data <= if_fetch_exc_type;
				IF_ID_asid_data <= asid;
				IF_ID_instMiss_data <= instMiss;
				IF_ID_instValid_data <= instValid;
				end
			end
		end
	/*
	// IF_ID_REG
	IF_ID_REG m_IF_ID_REG(
		.clk(clk), 
		.rst_n(rst_n), 
		.IF_ID_Stall(IF_ID_Stall), 
		.IF_ID_Flush(IF_ID_Flush), 
		.PC_plus4(PC_plus4), 
		.IF_ID_PC_plus4_data(IF_ID_PC_plus4_data), 
		.Instruction(Instruction), 
		.IF_ID_Instruction_data(IF_ID_Instruction_data), 
		.is_delayslot(is_delayslot), 
		.IF_ID_is_delayslot_data(IF_ID_is_delayslot_data), 
		.if_fetch_exc_type(if_fetch_exc_type), 
		.IF_ID_if_fetch_exc_type_data(IF_ID_if_fetch_exc_type_data),
		.asid(asid),
		.IF_ID_asid_data(IF_ID_asid_data),
		.instMiss(instMiss),
		.IF_ID_instMiss_data(IF_ID_instMiss_data),
		.instValid(instValid),
		.IF_ID_instValid_data(IF_ID_instValid_data)
	);
	*/
endmodule