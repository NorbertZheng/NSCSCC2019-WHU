// CR_Addr
`define CP0_BADVADDR		5'b01000
`define CP0_COUNT			5'b01001        
`define CP0_COMPARE			5'b01011     
`define CP0_STATUS			5'b01100     
`define CP0_CAUSE			5'b01101       
`define CP0_EPC				5'b01110          
`define CP0_PRID			5'b01111       
`define CP0_CONFIG			5'b10000 

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