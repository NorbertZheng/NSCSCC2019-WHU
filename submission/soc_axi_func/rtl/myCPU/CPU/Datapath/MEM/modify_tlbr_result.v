`include "../../Define/COP0_Define.v"
`include "../../Define/TLB_Define.v"
module modify_tlbr_result(tlbr_result, ID_EXE_rd_data, modified_tlbr_result);
	/*********************
	 *		Forwarding Unit
	 *input:
	 *	ID_EXE_rd_data[4:0]			: ID/EXE rd data
	 *	tlbr_result[89:0]			: tlbr_result
	 *output:
	 *	modified_tlbr_result[31:0]	: modified tlbr result
	 *********************/
	input [4:0] ID_EXE_rd_data;
	input [89:0] tlbr_result;
	output reg [31:0] modified_tlbr_result;
	
	always@(*)
		begin
		modified_tlbr_result = 32'b0;
		case(ID_EXE_rd_data)
			`CP0_ENTRYLO0:
				begin
				modified_tlbr_result[`CP0_ENTRYLO_PFN] = tlbr_result[`TLB_ENTRYLO0_PFN0];
				modified_tlbr_result[`CP0_ENTRYLO_C] = tlbr_result[`TLB_ENTRYLO0_C];
				modified_tlbr_result[`CP0_ENTRYLO_D] = tlbr_result[`TLB_ENTRYLO0_D];
				modified_tlbr_result[`CP0_ENTRYLO_V] = tlbr_result[`TLB_ENTRYLO0_V];
				modified_tlbr_result[`CP0_ENTRYLO_G] = tlbr_result[`TLB_G];
				end
			`CP0_ENTRYLO1:
				begin
				modified_tlbr_result[`CP0_ENTRYLO_PFN] = tlbr_result[`TLB_ENTRYLO1_PFN1];
				modified_tlbr_result[`CP0_ENTRYLO_C] = tlbr_result[`TLB_ENTRYLO1_C];
				modified_tlbr_result[`CP0_ENTRYLO_D] = tlbr_result[`TLB_ENTRYLO1_D];
				modified_tlbr_result[`CP0_ENTRYLO_V] = tlbr_result[`TLB_ENTRYLO1_V];
				modified_tlbr_result[`CP0_ENTRYLO_G] = tlbr_result[`TLB_G];
				end
			`CP0_PAGEMASK:
				begin
				modified_tlbr_result[`CP0_PAGEMASK_MASK] = tlbr_result[`TLB_PAGEMASK];
				end
			`CP0_ENTRYHI:
				begin
				modified_tlbr_result[`CP0_ENTRYHI_VPN2] = tlbr_result[`TLB_VPN2];
				modified_tlbr_result[`CP0_ENTRYHI_ASID] = tlbr_result[`TLB_ASID];
				end
		endcase
		end
endmodule