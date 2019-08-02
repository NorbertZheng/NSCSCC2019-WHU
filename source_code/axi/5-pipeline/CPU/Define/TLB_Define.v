// TLB_EntryLo1
`define TLB_ENTRYLO1			24:0
`define TLB_ENTRYLO1_PFN1		24:5
`define TLB_ENTRYLO1_FLAG		4:0
`define TLB_ENTRYLO1_C			4:2
`define TLB_ENTRYLO1_D			1
`define TLB_ENTRYLO1_V			0

// TLB_EntryLo0
`define TLB_ENTRYLO0			49:25
`define TLB_ENTRYLO0_PFN0		49:30
`define TLB_ENTRYLO0_FLAG		29:25
`define TLB_ENTRYLO0_C			29:27
`define TLB_ENTRYLO0_D			26
`define TLB_ENTRYLO0_V			25

// TLB_G
`define TLB_G					50

// TLB_PageMask
`define TLB_PAGEMASK			62:51

// TLB_EntryHi
`define TLB_ENTRYHI				89:63
`define TLB_VPN2				89:71
`define TLB_ASID				70:63