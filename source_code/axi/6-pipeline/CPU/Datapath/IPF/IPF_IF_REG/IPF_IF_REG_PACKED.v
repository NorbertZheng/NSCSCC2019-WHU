module IPF_IF_REG_PACKED(
	input				clk								, 
	input				rst_n							, 
	
	input				stall0							, 
	input				stall1							, 
	input				stall2							, 
	input				stall3							, 
	input				irq								, 
	input				clr0							, 
	input		[31:0]	PC_plus4						, 
	output	reg	[31:0]	IPF_IF_PC_plus4_data			,
	input				is_delayslot					, 
	output	reg			IPF_IF_is_delayslot_data		, 
	input		[31:0]	if_fetch_exc_type				, 
	output	reg	[31:0]	IPF_IF_if_fetch_exc_type_data	, 
	input		[7 :0]	asid							, 
	output	reg	[7 :0]	IPF_IF_asid_data				, 
	input				instMiss						, 
	output	reg			IPF_IF_instMiss_data			, 
	input				instValid						, 
	output	reg			IPF_IF_instValid_data			
);
	wire IPF_IF_Flush = irq || clr0;
	wire IPF_IF_Stall = (stall0 || stall1 || stall2 || stall3) & ~irq;		// irq 的优先级更高，直接 flush 掉
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			IPF_IF_PC_plus4_data <= 32'b0;
			IPF_IF_is_delayslot_data <= 1'b0;
			IPF_IF_if_fetch_exc_type_data <= 32'b0;
			IPF_IF_asid_data <= 8'b0;
			IPF_IF_instMiss_data <= 1'b0;
			IPF_IF_instValid_data <= 1'b0;
			end
		else if(!IPF_IF_Stall)
			begin
			if(IPF_IF_Flush)
				begin
				IPF_IF_PC_plus4_data <= 32'b0;
				IPF_IF_is_delayslot_data <= 1'b0;
				IPF_IF_if_fetch_exc_type_data <= 32'b0;
				IPF_IF_asid_data <= 8'b0;
				IPF_IF_instMiss_data <= 1'b0;
				IPF_IF_instValid_data <= 1'b0;
				end
			else
				begin
				IPF_IF_PC_plus4_data <= PC_plus4;
				IPF_IF_is_delayslot_data <= is_delayslot;
				IPF_IF_if_fetch_exc_type_data <= if_fetch_exc_type;
				IPF_IF_asid_data <= asid;
				IPF_IF_instMiss_data <= instMiss;
				IPF_IF_instValid_data <= instValid;
				end
			end
		end
	/*
	// IPF_IF_REG
	IPF_IF_REG m_IPF_IF_REG(
		.clk(clk), 
		.rst_n(rst_n), 
		.IPF_IF_Stall(IPF_IF_Stall), 
		.IPF_IF_Flush(IPF_IF_Flush), 
		.PC_plus4(PC_plus4), 
		.IPF_IF_PC_plus4_data(IPF_IF_PC_plus4_data),
		.is_delayslot(is_delayslot), 
		.IPF_IF_is_delayslot_data(IPF_IF_is_delayslot_data), 
		.if_fetch_exc_type(if_fetch_exc_type), 
		.IPF_IF_if_fetch_exc_type_data(IPF_IF_if_fetch_exc_type_data),
		.asid(asid),
		.IPF_IF_asid_data(IPF_IF_asid_data),
		.instMiss(instMiss),
		.IPF_IF_instMiss_data(IPF_IF_instMiss_data),
		.instValid(instValid),
		.IPF_IF_instValid_data(IPF_IF_instValid_data)
	);
	*/
endmodule