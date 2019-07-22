// CR_Addr
`define CP0_INDEX			5'b00001
`define CP0_ENTRYLO0		5'b00010
`define CP0_ENTRYLO1		5'b00011
`define CP0_CONTEXT			5'b00100
`define CP0_PAGEMASK		5'b00101
`define CP0_BADVADDR		5'b01000
`define CP0_COUNT			5'b01001
`define CP0_ENTRYHI			5'b01010      
`define CP0_COMPARE			5'b01011     
`define CP0_STATUS			5'b01100     
`define CP0_CAUSE			5'b01101       
`define CP0_EPC				5'b01110          
`define CP0_PRID			5'b01111       
`define CP0_CONFIG			5'b10000
`define CP0_WATCHLO			5'b10010
`define CP0_WATCHHI			5'b10011
`define CP0_TAGLO			5'b11100
`define CP0_TAGHI			5'b11101

/******************/
/*   CR_Segment   */
/******************/
// CP0_INDEX
`define CP0_INDEX_P			31
`define CP0_INDEX_INDEX		4:0

// CP0_ENTRYLO0 & CP0_ENTRYLO1
`define CP0_ENTRYLO_PFN		29:6
`define CP0_ENTRYLO_FLAG	5:0
`define CP0_ENTRYLO_C		5:3
`define CP0_ENTRYLO_D		2
`define CP0_ENTRYLO_V		1
`define CP0_ENTRYLO_G		0

// CP0_PAGEMASK
`define CP0_PAGEMASK_MASK	24:13

// CP0_ENTRYHI
`define CP0_ENTRYHI_VPN2	31:13
`define CP0_ENTRYHI_ASID	7:0

// ExeCode
`define Int					2'd0
`define Sys					2'd1
`define Unimpl				2'd2
`define Ov					2'd3

// Status
`define None_MASK			4'b1111
`define Int_MASK			4'b1110
`define Sys_MASK			4'b1101
`define Unimpl_MASK			4'b1011
`define Ov_MASK				4'b0111
`define All_MASK			4'b0000