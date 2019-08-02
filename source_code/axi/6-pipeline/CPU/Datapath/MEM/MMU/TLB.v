`include "../../../Define/TLB_Define.v"
module TLB(clk, rst_n, wtlb, tlb_addr, tlb_wdata, inst_addr_i, data_addr_i, asid, tlbr_result, tlbp_result, inst_addr_o, data_addr_o, instMiss, dataMiss, instDirty, dataDirty, instValid, dataValid, instBypassCache, dataBypassCache);
	/*********************
	 *		TLB
	 *input:
	 *	clk					: clock
	 *	rst_n				: negetive reset signal
	 *	wtlb				: write TLB signal
	 *	tlb_addr[4:0]		: TLB access address
	 *	tlb_wdata[89:0]		: TLB write data
	 *	inst_addr_i[31:0]	: instruction mem access virtual address
	 *	data_addr_i[31:0]	: data mem access virtual address
	 *	asid[7:0]			: current process id
	 *output:
	 *	tlbr_result[89:0]	: tlbr instruction result
	 *	tlbp_result[31:0]	: tlbp instruction result
	 *	inst_addr_o[31:0]	: instruction mem access physical address
	 *	data_addr_o[31:0]	: data mem access physical address
	 *	instMiss			: instruction tlb miss signal
	 *	dataMiss			: data tlb miss signal
	 *	instDirty			: instruction tlb dirty signal
	 *	dataDirty			: data tlb dirty signal
	 *	instValid			: instruction tlb valid signal
	 *	dataValid			: data tlb valid signal
	 *	instBypassCache		: instruction bypass cache signal
	 *	dataBypassCache		: data bypass cache signal
	 *********************/
	input clk, rst_n;
	input wtlb;
	input [4:0] tlb_addr;
	input [7:0] asid;
	input [31:0] inst_addr_i, data_addr_i;
	input [89:0] tlb_wdata;
	output instMiss, dataMiss, instDirty, dataDirty, instValid, dataValid, instBypassCache, dataBypassCache;
	output [31:0] inst_addr_o, data_addr_o, tlbp_result;
	output [89:0] tlbr_result;
	
	reg [89:0] TLB_Entries[31:0];
	
	// read TLB Entry
	assign tlbr_result = TLB_Entries[tlb_addr];
	// write TLB Entry
	always@(posedge clk)
		begin
		if(!rst_n)
			begin : label
			integer i;
			for(i = 0;i < 32;i = i + 1)
				begin
				TLB_Entries[i] <= 90'b0;
				end
			end
		else
			begin
			if(wtlb)
				begin
				TLB_Entries[tlb_addr] <= tlb_wdata;
				end
			end
		end

	// data mem access address transmit
	wire [4:0] dataMatchIndex;
	wire [31:0] dataMatch;
	wire [19:0] dataPFN = data_addr_i[12] ? TLB_Entries[dataMatchIndex][`TLB_ENTRYLO1_PFN1] : TLB_Entries[dataMatchIndex][`TLB_ENTRYLO0_PFN0];
	assign dataDirty = data_addr_i[12] ? TLB_Entries[dataMatchIndex][`TLB_ENTRYLO1_D] : TLB_Entries[dataMatchIndex][`TLB_ENTRYLO0_D];
	assign dataValid = data_addr_i[12] ? TLB_Entries[dataMatchIndex][`TLB_ENTRYLO1_V] : TLB_Entries[dataMatchIndex][`TLB_ENTRYLO0_V];
	wire dataCacheFlag = data_addr_i[12] ? TLB_Entries[dataMatchIndex][`TLB_ENTRYLO1_C] : TLB_Entries[dataMatchIndex][`TLB_ENTRYLO0_C];
	assign dataBypassCache = (dataCacheFlag == 3'b010);
	assign dataMiss = ~|dataMatch;
	assign data_addr_o = {dataPFN, data_addr_i[11:0]};
	// dataMatch
	assign dataMatch[0] = (TLB_Entries[0][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[0][`TLB_ASID] == asid) || TLB_Entries[0][`TLB_G]);
	assign dataMatch[1] = (TLB_Entries[1][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[1][`TLB_ASID] == asid) || TLB_Entries[1][`TLB_G]);
	assign dataMatch[2] = (TLB_Entries[2][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[2][`TLB_ASID] == asid) || TLB_Entries[2][`TLB_G]);
	assign dataMatch[3] = (TLB_Entries[3][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[3][`TLB_ASID] == asid) || TLB_Entries[3][`TLB_G]);
	assign dataMatch[4] = (TLB_Entries[4][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[4][`TLB_ASID] == asid) || TLB_Entries[4][`TLB_G]);
	assign dataMatch[5] = (TLB_Entries[5][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[5][`TLB_ASID] == asid) || TLB_Entries[5][`TLB_G]);
	assign dataMatch[6] = (TLB_Entries[6][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[6][`TLB_ASID] == asid) || TLB_Entries[6][`TLB_G]);
	assign dataMatch[7] = (TLB_Entries[7][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[7][`TLB_ASID] == asid) || TLB_Entries[7][`TLB_G]);
	assign dataMatch[8] = (TLB_Entries[8][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[8][`TLB_ASID] == asid) || TLB_Entries[8][`TLB_G]);
	assign dataMatch[9] = (TLB_Entries[9][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[9][`TLB_ASID] == asid) || TLB_Entries[9][`TLB_G]);
	assign dataMatch[10] = (TLB_Entries[10][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[10][`TLB_ASID] == asid) || TLB_Entries[10][`TLB_G]);
	assign dataMatch[11] = (TLB_Entries[11][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[11][`TLB_ASID] == asid) || TLB_Entries[11][`TLB_G]);
	assign dataMatch[12] = (TLB_Entries[12][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[12][`TLB_ASID] == asid) || TLB_Entries[12][`TLB_G]);
	assign dataMatch[13] = (TLB_Entries[13][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[13][`TLB_ASID] == asid) || TLB_Entries[13][`TLB_G]);
	assign dataMatch[14] = (TLB_Entries[14][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[14][`TLB_ASID] == asid) || TLB_Entries[14][`TLB_G]);
	assign dataMatch[15] = (TLB_Entries[15][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[15][`TLB_ASID] == asid) || TLB_Entries[15][`TLB_G]);
	assign dataMatch[16] = (TLB_Entries[16][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[16][`TLB_ASID] == asid) || TLB_Entries[16][`TLB_G]);
	assign dataMatch[17] = (TLB_Entries[17][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[17][`TLB_ASID] == asid) || TLB_Entries[17][`TLB_G]);
	assign dataMatch[18] = (TLB_Entries[18][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[18][`TLB_ASID] == asid) || TLB_Entries[18][`TLB_G]);
	assign dataMatch[19] = (TLB_Entries[19][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[19][`TLB_ASID] == asid) || TLB_Entries[19][`TLB_G]);
	assign dataMatch[20] = (TLB_Entries[20][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[20][`TLB_ASID] == asid) || TLB_Entries[20][`TLB_G]);
	assign dataMatch[21] = (TLB_Entries[21][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[21][`TLB_ASID] == asid) || TLB_Entries[21][`TLB_G]);
	assign dataMatch[22] = (TLB_Entries[22][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[22][`TLB_ASID] == asid) || TLB_Entries[22][`TLB_G]);
	assign dataMatch[23] = (TLB_Entries[23][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[23][`TLB_ASID] == asid) || TLB_Entries[23][`TLB_G]);
	assign dataMatch[24] = (TLB_Entries[24][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[24][`TLB_ASID] == asid) || TLB_Entries[24][`TLB_G]);
	assign dataMatch[25] = (TLB_Entries[25][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[25][`TLB_ASID] == asid) || TLB_Entries[25][`TLB_G]);
	assign dataMatch[26] = (TLB_Entries[26][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[26][`TLB_ASID] == asid) || TLB_Entries[26][`TLB_G]);
	assign dataMatch[27] = (TLB_Entries[27][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[27][`TLB_ASID] == asid) || TLB_Entries[27][`TLB_G]);
	assign dataMatch[28] = (TLB_Entries[28][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[28][`TLB_ASID] == asid) || TLB_Entries[28][`TLB_G]);
	assign dataMatch[29] = (TLB_Entries[29][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[29][`TLB_ASID] == asid) || TLB_Entries[29][`TLB_G]);
	assign dataMatch[30] = (TLB_Entries[30][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[30][`TLB_ASID] == asid) || TLB_Entries[30][`TLB_G]);
	assign dataMatch[31] = (TLB_Entries[31][`TLB_VPN2] == data_addr_i[31:13]) && ((TLB_Entries[31][`TLB_ASID] == asid) || TLB_Entries[31][`TLB_G]);
	// dataMatchIndex
	assign dataMatchIndex =  dataMatch[0] 	? 5'd0 	: 
							(dataMatch[1] 	? 5'd1 	: 
							(dataMatch[2] 	? 5'd2 	: 
							(dataMatch[3] 	? 5'd3 	: 
							(dataMatch[4] 	? 5'd4 	: 
							(dataMatch[5] 	? 5'd5 	: 
							(dataMatch[6] 	? 5'd6 	: 
							(dataMatch[7] 	? 5'd7 	: 
							(dataMatch[8] 	? 5'd8 	: 
							(dataMatch[9] 	? 5'd9 	: 
							(dataMatch[10] 	? 5'd10 : 
							(dataMatch[11] 	? 5'd11 : 
							(dataMatch[12] 	? 5'd12	: 
							(dataMatch[13] 	? 5'd13	: 
							(dataMatch[14] 	? 5'd14	: 
							(dataMatch[15] 	? 5'd15	: 
							(dataMatch[16] 	? 5'd16	: 
							(dataMatch[17] 	? 5'd17	: 
							(dataMatch[18] 	? 5'd18	: 
							(dataMatch[19] 	? 5'd19	: 
							(dataMatch[20] 	? 5'd20	: 
							(dataMatch[21] 	? 5'd21	: 
							(dataMatch[22] 	? 5'd22	: 
							(dataMatch[23] 	? 5'd23	: 
							(dataMatch[24] 	? 5'd24	: 
							(dataMatch[25] 	? 5'd25	: 
							(dataMatch[26] 	? 5'd26	: 
							(dataMatch[27] 	? 5'd27	: 
							(dataMatch[28] 	? 5'd28	: 
							(dataMatch[29] 	? 5'd29	: 
							(dataMatch[30] 	? 5'd30	: 
							(dataMatch[31] 	? 5'd31	: 5'd0)))))))))))))))))))))))))))))));
	
	// instruction mem access address transmit
	wire [4:0] instMatchIndex;
	wire [31:0] instMatch;
	wire [19:0] instPFN = inst_addr_i[12] ? TLB_Entries[instMatchIndex][`TLB_ENTRYLO1_PFN1] : TLB_Entries[instMatchIndex][`TLB_ENTRYLO0_PFN0];
	assign instDirty = inst_addr_i[12] ? TLB_Entries[instMatchIndex][`TLB_ENTRYLO1_D] : TLB_Entries[instMatchIndex][`TLB_ENTRYLO0_D];
	assign instValid = inst_addr_i[12] ? TLB_Entries[instMatchIndex][`TLB_ENTRYLO1_V] : TLB_Entries[instMatchIndex][`TLB_ENTRYLO0_V];
	wire instCacheFlag = inst_addr_i[12] ? TLB_Entries[instMatchIndex][`TLB_ENTRYLO1_C] : TLB_Entries[instMatchIndex][`TLB_ENTRYLO0_C];
	assign instBypassCache = (instCacheFlag == 3'b010);
	assign instMiss = ~|instMatch;
	assign inst_addr_o = {instPFN, inst_addr_i[11:0]};
	// instMatch
	assign instMatch[0] = (TLB_Entries[0][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[0][`TLB_ASID] == asid) || TLB_Entries[0][`TLB_G]);
	assign instMatch[1] = (TLB_Entries[1][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[1][`TLB_ASID] == asid) || TLB_Entries[1][`TLB_G]);
	assign instMatch[2] = (TLB_Entries[2][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[2][`TLB_ASID] == asid) || TLB_Entries[2][`TLB_G]);
	assign instMatch[3] = (TLB_Entries[3][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[3][`TLB_ASID] == asid) || TLB_Entries[3][`TLB_G]);
	assign instMatch[4] = (TLB_Entries[4][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[4][`TLB_ASID] == asid) || TLB_Entries[4][`TLB_G]);
	assign instMatch[5] = (TLB_Entries[5][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[5][`TLB_ASID] == asid) || TLB_Entries[5][`TLB_G]);
	assign instMatch[6] = (TLB_Entries[6][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[6][`TLB_ASID] == asid) || TLB_Entries[6][`TLB_G]);
	assign instMatch[7] = (TLB_Entries[7][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[7][`TLB_ASID] == asid) || TLB_Entries[7][`TLB_G]);
	assign instMatch[8] = (TLB_Entries[8][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[8][`TLB_ASID] == asid) || TLB_Entries[8][`TLB_G]);
	assign instMatch[9] = (TLB_Entries[9][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[9][`TLB_ASID] == asid) || TLB_Entries[9][`TLB_G]);
	assign instMatch[10] = (TLB_Entries[10][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[10][`TLB_ASID] == asid) || TLB_Entries[10][`TLB_G]);
	assign instMatch[11] = (TLB_Entries[11][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[11][`TLB_ASID] == asid) || TLB_Entries[11][`TLB_G]);
	assign instMatch[12] = (TLB_Entries[12][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[12][`TLB_ASID] == asid) || TLB_Entries[12][`TLB_G]);
	assign instMatch[13] = (TLB_Entries[13][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[13][`TLB_ASID] == asid) || TLB_Entries[13][`TLB_G]);
	assign instMatch[14] = (TLB_Entries[14][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[14][`TLB_ASID] == asid) || TLB_Entries[14][`TLB_G]);
	assign instMatch[15] = (TLB_Entries[15][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[15][`TLB_ASID] == asid) || TLB_Entries[15][`TLB_G]);
	assign instMatch[16] = (TLB_Entries[16][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[16][`TLB_ASID] == asid) || TLB_Entries[16][`TLB_G]);
	assign instMatch[17] = (TLB_Entries[17][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[17][`TLB_ASID] == asid) || TLB_Entries[17][`TLB_G]);
	assign instMatch[18] = (TLB_Entries[18][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[18][`TLB_ASID] == asid) || TLB_Entries[18][`TLB_G]);
	assign instMatch[19] = (TLB_Entries[19][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[19][`TLB_ASID] == asid) || TLB_Entries[19][`TLB_G]);
	assign instMatch[20] = (TLB_Entries[20][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[20][`TLB_ASID] == asid) || TLB_Entries[20][`TLB_G]);
	assign instMatch[21] = (TLB_Entries[21][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[21][`TLB_ASID] == asid) || TLB_Entries[21][`TLB_G]);
	assign instMatch[22] = (TLB_Entries[22][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[22][`TLB_ASID] == asid) || TLB_Entries[22][`TLB_G]);
	assign instMatch[23] = (TLB_Entries[23][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[23][`TLB_ASID] == asid) || TLB_Entries[23][`TLB_G]);
	assign instMatch[24] = (TLB_Entries[24][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[24][`TLB_ASID] == asid) || TLB_Entries[24][`TLB_G]);
	assign instMatch[25] = (TLB_Entries[25][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[25][`TLB_ASID] == asid) || TLB_Entries[25][`TLB_G]);
	assign instMatch[26] = (TLB_Entries[26][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[26][`TLB_ASID] == asid) || TLB_Entries[26][`TLB_G]);
	assign instMatch[27] = (TLB_Entries[27][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[27][`TLB_ASID] == asid) || TLB_Entries[27][`TLB_G]);
	assign instMatch[28] = (TLB_Entries[28][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[28][`TLB_ASID] == asid) || TLB_Entries[28][`TLB_G]);
	assign instMatch[29] = (TLB_Entries[29][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[29][`TLB_ASID] == asid) || TLB_Entries[29][`TLB_G]);
	assign instMatch[30] = (TLB_Entries[30][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[30][`TLB_ASID] == asid) || TLB_Entries[30][`TLB_G]);
	assign instMatch[31] = (TLB_Entries[31][`TLB_VPN2] == inst_addr_i[31:13]) && ((TLB_Entries[31][`TLB_ASID] == asid) || TLB_Entries[31][`TLB_G]);
	// instMatchIndex
	assign instMatchIndex =  instMatch[0] 	? 5'd0 	: 
							(instMatch[1] 	? 5'd1 	: 
							(instMatch[2] 	? 5'd2 	: 
							(instMatch[3] 	? 5'd3 	: 
							(instMatch[4] 	? 5'd4 	: 
							(instMatch[5] 	? 5'd5 	: 
							(instMatch[6] 	? 5'd6 	: 
							(instMatch[7] 	? 5'd7 	: 
							(instMatch[8] 	? 5'd8 	: 
							(instMatch[9] 	? 5'd9 	: 
							(instMatch[10] 	? 5'd10 : 
							(instMatch[11] 	? 5'd11 : 
							(instMatch[12] 	? 5'd12	: 
							(instMatch[13] 	? 5'd13	: 
							(instMatch[14] 	? 5'd14	: 
							(instMatch[15] 	? 5'd15	: 
							(instMatch[16] 	? 5'd16	: 
							(instMatch[17] 	? 5'd17	: 
							(instMatch[18] 	? 5'd18	: 
							(instMatch[19] 	? 5'd19	: 
							(instMatch[20] 	? 5'd20	: 
							(instMatch[21] 	? 5'd21	: 
							(instMatch[22] 	? 5'd22	: 
							(instMatch[23] 	? 5'd23	: 
							(instMatch[24] 	? 5'd24	: 
							(instMatch[25] 	? 5'd25	: 
							(instMatch[26] 	? 5'd26	: 
							(instMatch[27] 	? 5'd27	: 
							(instMatch[28] 	? 5'd28	: 
							(instMatch[29] 	? 5'd29	: 
							(instMatch[30] 	? 5'd30	: 
							(instMatch[31] 	? 5'd31	: 5'd0)))))))))))))))))))))))))))))));
							
	// tlbp instruction execute
	wire [31:0] tlbpMatch;
	wire [31:0] tlbp_addr_i = {tlb_wdata[`TLB_VPN2], 13'b0};
	assign tlbp_result[31] = ~|tlbpMatch;
	assign tlbp_result[30:5] = 26'b0;
	// tlbpMatch
	assign tlbpMatch[0] = (TLB_Entries[0][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[0][`TLB_ASID] == asid) || TLB_Entries[0][`TLB_G]);
	assign tlbpMatch[1] = (TLB_Entries[1][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[1][`TLB_ASID] == asid) || TLB_Entries[1][`TLB_G]);
	assign tlbpMatch[2] = (TLB_Entries[2][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[2][`TLB_ASID] == asid) || TLB_Entries[2][`TLB_G]);
	assign tlbpMatch[3] = (TLB_Entries[3][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[3][`TLB_ASID] == asid) || TLB_Entries[3][`TLB_G]);
	assign tlbpMatch[4] = (TLB_Entries[4][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[4][`TLB_ASID] == asid) || TLB_Entries[4][`TLB_G]);
	assign tlbpMatch[5] = (TLB_Entries[5][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[5][`TLB_ASID] == asid) || TLB_Entries[5][`TLB_G]);
	assign tlbpMatch[6] = (TLB_Entries[6][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[6][`TLB_ASID] == asid) || TLB_Entries[6][`TLB_G]);
	assign tlbpMatch[7] = (TLB_Entries[7][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[7][`TLB_ASID] == asid) || TLB_Entries[7][`TLB_G]);
	assign tlbpMatch[8] = (TLB_Entries[8][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[8][`TLB_ASID] == asid) || TLB_Entries[8][`TLB_G]);
	assign tlbpMatch[9] = (TLB_Entries[9][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[9][`TLB_ASID] == asid) || TLB_Entries[9][`TLB_G]);
	assign tlbpMatch[10] = (TLB_Entries[10][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[10][`TLB_ASID] == asid) || TLB_Entries[10][`TLB_G]);
	assign tlbpMatch[11] = (TLB_Entries[11][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[11][`TLB_ASID] == asid) || TLB_Entries[11][`TLB_G]);
	assign tlbpMatch[12] = (TLB_Entries[12][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[12][`TLB_ASID] == asid) || TLB_Entries[12][`TLB_G]);
	assign tlbpMatch[13] = (TLB_Entries[13][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[13][`TLB_ASID] == asid) || TLB_Entries[13][`TLB_G]);
	assign tlbpMatch[14] = (TLB_Entries[14][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[14][`TLB_ASID] == asid) || TLB_Entries[14][`TLB_G]);
	assign tlbpMatch[15] = (TLB_Entries[15][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[15][`TLB_ASID] == asid) || TLB_Entries[15][`TLB_G]);
	assign tlbpMatch[16] = (TLB_Entries[16][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[16][`TLB_ASID] == asid) || TLB_Entries[16][`TLB_G]);
	assign tlbpMatch[17] = (TLB_Entries[17][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[17][`TLB_ASID] == asid) || TLB_Entries[17][`TLB_G]);
	assign tlbpMatch[18] = (TLB_Entries[18][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[18][`TLB_ASID] == asid) || TLB_Entries[18][`TLB_G]);
	assign tlbpMatch[19] = (TLB_Entries[19][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[19][`TLB_ASID] == asid) || TLB_Entries[19][`TLB_G]);
	assign tlbpMatch[20] = (TLB_Entries[20][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[20][`TLB_ASID] == asid) || TLB_Entries[20][`TLB_G]);
	assign tlbpMatch[21] = (TLB_Entries[21][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[21][`TLB_ASID] == asid) || TLB_Entries[21][`TLB_G]);
	assign tlbpMatch[22] = (TLB_Entries[22][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[22][`TLB_ASID] == asid) || TLB_Entries[22][`TLB_G]);
	assign tlbpMatch[23] = (TLB_Entries[23][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[23][`TLB_ASID] == asid) || TLB_Entries[23][`TLB_G]);
	assign tlbpMatch[24] = (TLB_Entries[24][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[24][`TLB_ASID] == asid) || TLB_Entries[24][`TLB_G]);
	assign tlbpMatch[25] = (TLB_Entries[25][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[25][`TLB_ASID] == asid) || TLB_Entries[25][`TLB_G]);
	assign tlbpMatch[26] = (TLB_Entries[26][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[26][`TLB_ASID] == asid) || TLB_Entries[26][`TLB_G]);
	assign tlbpMatch[27] = (TLB_Entries[27][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[27][`TLB_ASID] == asid) || TLB_Entries[27][`TLB_G]);
	assign tlbpMatch[28] = (TLB_Entries[28][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[28][`TLB_ASID] == asid) || TLB_Entries[28][`TLB_G]);
	assign tlbpMatch[29] = (TLB_Entries[29][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[29][`TLB_ASID] == asid) || TLB_Entries[29][`TLB_G]);
	assign tlbpMatch[30] = (TLB_Entries[30][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[30][`TLB_ASID] == asid) || TLB_Entries[30][`TLB_G]);
	assign tlbpMatch[31] = (TLB_Entries[31][`TLB_VPN2] == tlbp_addr_i[31:13]) && ((TLB_Entries[31][`TLB_ASID] == asid) || TLB_Entries[31][`TLB_G]);
	// tlbp_result[4:0]
	assign tlbp_result[4:0] =	 tlbpMatch[0] 	? 5'd0 	: 
								(tlbpMatch[1] 	? 5'd1 	: 
								(tlbpMatch[2] 	? 5'd2 	: 
								(tlbpMatch[3] 	? 5'd3 	: 
								(tlbpMatch[4] 	? 5'd4 	: 
								(tlbpMatch[5] 	? 5'd5 	: 
								(tlbpMatch[6] 	? 5'd6 	: 
								(tlbpMatch[7] 	? 5'd7 	: 
								(tlbpMatch[8] 	? 5'd8 	: 
								(tlbpMatch[9] 	? 5'd9 	: 
								(tlbpMatch[10] 	? 5'd10 : 
								(tlbpMatch[11] 	? 5'd11 : 
								(tlbpMatch[12] 	? 5'd12	: 
								(tlbpMatch[13] 	? 5'd13	: 
								(tlbpMatch[14] 	? 5'd14	: 
								(tlbpMatch[15] 	? 5'd15	: 
								(tlbpMatch[16] 	? 5'd16	: 
								(tlbpMatch[17] 	? 5'd17	: 
								(tlbpMatch[18] 	? 5'd18	: 
								(tlbpMatch[19] 	? 5'd19	: 
								(tlbpMatch[20] 	? 5'd20	: 
								(tlbpMatch[21] 	? 5'd21	: 
								(tlbpMatch[22] 	? 5'd22	: 
								(tlbpMatch[23] 	? 5'd23	: 
								(tlbpMatch[24] 	? 5'd24	: 
								(tlbpMatch[25] 	? 5'd25	: 
								(tlbpMatch[26] 	? 5'd26	: 
								(tlbpMatch[27] 	? 5'd27	: 
								(tlbpMatch[28] 	? 5'd28	: 
								(tlbpMatch[29] 	? 5'd29	: 
								(tlbpMatch[30] 	? 5'd30	: 
								(tlbpMatch[31] 	? 5'd31	: 5'd0)))))))))))))))))))))))))))))));
endmodule