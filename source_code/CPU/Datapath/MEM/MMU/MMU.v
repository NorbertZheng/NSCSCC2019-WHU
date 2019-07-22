module MMU(clk, rst_n, rtlb, wtlb, tlb_addr, tlb_wdata, inst_enable, data_enable, inst_addr_i, data_addr_i, asid, kseg0_uncached, inst_address_o, data_address_o, inst_uncached, data_uncached, tlbp_result, tlbr_result);
	/*********************
	 *		MMU
	 *input:
	 *	clk					: clock
	 *	rst_n				: negetive reset signal
	 *	rtlb				: read TLB signal
	 *	wtlb				: write TLB signal
	 *	tlb_addr[4:0]		: TLB access address
	 *	tlb_wdata[89:0]		: TLB write data
	 *	inst_enable			: instruction TLB enable signal
	 *	data_enable			: data TLB enable signal
	 *	inst_addr_i[31:0]	: instruction mem access virtual address
	 *	data_addr_i[31:0]	: data mem access virtual address
	 *	asid[7:0]			: current process id
	 *	kseg0_uncached		: kseg0_uncached signal from COP0_Config[2:0]
	 *output:
	 *	tlbr_result[89:0]	: tlbr instruction result
	 *	tlbp_result[31:0]	: tlbp instruction result
	 *	inst_addr_o[31:0]	: instruction mem access physical address
	 *	data_addr_o[31:0]	: data mem access physical address
	 *	inst_uncached		: instruction mem uncached signal
	 *	data_uncached		: data mem uncached signal
	 *********************/
	input clk, rst_n;
	input rtlb, wtlb,kseg0_uncached, inst_enable, data_enable;
	input [4:0] tlb_addr;
	input [7:0] asid;
	input [31:0] inst_addr_i, data_addr_i;
	input [89:0] tlb_wdata;
	output inst_uncached, data_uncached;
	output [31:0] inst_addr_o, data_addr_o, tlbp_result;
	output [89:0] tlbr_result;
	
	parameter WITH_TLB = 1;
	
	wire data_tlb_map, inst_tlb_map, data_map_uncached, inst_map_uncached, inst_access_invalid, data_access_invalid;
	wire dataMiss, instMiss, dataDirty, dataValid, instValid, dataBypassCache, instBypassCache;
	wire[31:0] data_address_direct, inst_address_direct, data_address_tlb, inst_address_tlb;
	
	assign inst_uncached = inst_map_uncached || instBypassCache;
	assign data_uncached = data_map_uncached || dataBypassCache;
	
	// instruction memory map
	memoryMap #(WITH_TLB) m_instruction_memory_map(
		.addr_i(inst_addr_i), 
		.enable(inst_enable), 
		.user_mode(user_mode), 
		.kseg0_uncached(kseg0_uncached), 
		.addr_o(inst_address_direct), 
		.access_invalid(inst_access_invalid), 
		.using_tlb(inst_tlb_map), 
		.uncached(inst_map_uncached)
	);
	
	// data memory map
	memoryMap #(WITH_TLB) m_data_memory_map(
		.addr_i(data_addr_i), 
		.enable(data_enable), 
		.user_mode(user_mode), 
		.kseg0_uncached(kseg0_uncached), 
		.addr_o(data_address_direct), 
		.access_invalid(data_access_invalid), 
		.using_tlb(data_tlb_map), 
		.uncached(data_map_uncached)
	);
	
	// TLB
	generate
	if(WITH_TLB)
		begin : gen_tlb
		TLB m_TLB(
			.clk(clk), 
			.rst_n(rst_n), 
			.rtlb(rtlb), 
			.wtlb(wtlb), 
			.tlb_addr(tlb_addr), 
			.tlb_wdata(tlb_wdata), 
			.inst_addr_i(inst_addr_i), 
			.data_addr_i(data_addr_i), 
			.asid(asid), 
			.tlbr_result(tlbr_result), 
			.tlbp_result(tlbp_result), 
			.inst_addr_o(inst_address_tlb), 
			.data_addr_o(data_address_tlb), 
			.instMiss(instMiss), 
			.dataMiss(dataMiss), 
			.instDirty(instDirty), 
			.dataDirty(dataDirty), 
			.instValid(instValid),
			.dataValid(dataValid), 
			.instBypassCache(instBypassCache), 
			.dataBypassCache(dataBypassCache)
		);
		end
	endgenerate
endmodule