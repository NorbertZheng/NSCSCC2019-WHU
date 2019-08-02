/******************/
/*   CR_Addr      */
/******************/
// CP0_INDEX
`define CP0_INDEX				5'b00000
`define CP0_INDEX_SEL			3'b000

// CP0_RANDOM
`define CP0_RANDOM				5'b00001
`define CP0_RANDOM_SEL			3'b000

// CP0_ENTRYLO0
`define CP0_ENTRYLO0			5'b00010
`define CP0_ENTRYLO0_SEL		3'b000

// CP0_ENTRYLO1
`define CP0_ENTRYLO1			5'b00011
`define CP0_ENTRYLO1_SEL		3'b000

// CP0_CONTEXT
`define CP0_CONTEXT				5'b00100
`define CP0_CONTEXT_SEL			3'b000

// CP0_PAGEMASK
`define CP0_PAGEMASK			5'b00101
`define CP0_PAGEMASK_SEL		3'b000

// CP0_WIRED
`define CP0_WIRED				5'b00110
`define CP0_WIRED_SEL			3'b000

// CP0_BADVADDR
`define CP0_BADVADDR			5'b01000
`define CP0_BADVADDR_SEL		3'b000

// CP0_COUNT
`define CP0_COUNT				5'b01001
`define CP0_COUNT_SEL			3'b000

// CP0_ENTRYHI
`define CP0_ENTRYHI				5'b01010
`define CP0_ENTRYHI_SEL			3'b000

// CP0_COMPARE    
`define CP0_COMPARE				5'b01011
`define CP0_COMPARE_SEL			3'b000

// CP0_STATUS 
`define CP0_STATUS				5'b01100
`define CP0_STATUS_SEL			3'b000

// CP0_CAUSE    
`define CP0_CAUSE				5'b01101
`define CP0_CAUSE_SEL			3'b000

// CP0_EPC
`define CP0_EPC					5'b01110
`define CP0_EPC_SEL				3'b000

// CP0_PRID
`define CP0_PRID				5'b01111
`define CP0_PRID_SEL			3'b000
`define CP0_EBASE_SEL			3'b001

// CP0_CONFIG
`define CP0_CONFIG				5'b10000
`define CP0_CONFIG_SEL			3'b000
`define CP0_CONFIG1_SEL			3'b001
`define CP0_CONFIG2_SEL			3'b010
`define CP0_CONFIG3_SEL			3'b011

// CP0_LLADDR
`define CP0_LLADDR				5'b10001
`define CP0_LLADDR_SEL			3'b000

// CP0_WATCHLO
`define CP0_WATCHLO				5'b10010

// CP0_WATCHHI
`define CP0_WATCHHI				5'b10011

// CP0_DEBUG
`define CP0_DEBUG				5'b10111
`define CP0_DEBUG_SEL			3'b000

// CP0_DEPC
`define CP0_DEPC				5'b11000
`define CP0_DEPC_SEL			3'b000

// CP0_PERFCNT
`define CP0_PERFCNT				5'b11001

// CP0_ERRCTL
`define CP0_ERRCTL				5'b11010
`define CP0_ERRCTL_SEL			3'b000

// CP0_CACHEERR
`define CP0_CACHEERR			5'b11011

// CP0_TAGLO
`define CP0_TAGLO				5'b11100
`define CP0_TAGLO_SEL			3'b000
`define CP0_DATALO_SEL			3'b001

// CP0_TAGHI
`define CP0_TAGHI				5'b11101
`define CP0_TAGHI_SEL			3'b000
`define CP0_DATAHI_SEL			3'b001

// CP0_ERROREPC
`define CP0_ERROREPC			5'b11110
`define CP0_ERROREPC_SEL		3'b000

// CP0_DESAVE
`define CP0_DESAVE				5'b11111
`define CP0_DESAVE_SEL			3'b000

/******************/
/*   CR_Segment   */
/******************/
// CP0_INDEX
`define CP0_INDEX_P				31
`define CP0_INDEX_INDEX			4:0

// CP0_RANDOM
`define CP0_RANDOM_RANDOM		4:0

// CP0_ENTRYLO0 & CP0_ENTRYLO1
// `define CP0_ENTRYLO_PFN			29:6
`define CP0_ENTRYLO_PFN			25:6
`define CP0_ENTRYLO_FLAG		5:0
`define CP0_ENTRYLO_C			5:3
`define CP0_ENTRYLO_D			2
`define CP0_ENTRYLO_V			1
`define CP0_ENTRYLO_G			0

// CP0_CONTEXT
`define CP0_CONTEXT_PTEBASE		31:23
`define CP0_CONTEXT_BADVPN2		22:4

// CP0_PAGEMASK
`define CP0_PAGEMASK_MASK		24:13

// CP0_WIRED
`define CP0_WIRED_WIRED			4:0

// CP0_ENTRYHI
`define CP0_ENTRYHI_VPN2		31:13
`define CP0_ENTRYHI_ASID		7:0

// CP0_STATUS
`define CP0_STATUS_CU			31:28
`define CP0_STATUS_RP			27
`define CP0_STATUS_FR			26
`define CP0_STATUS_RE			25
`define CP0_STATUS_MX			24
`define CP0_STATUS_PX			23
`define CP0_STATUS_BEV			22
`define CP0_STATUS_TS			21
`define CP0_STATUS_SR			20
`define CP0_STATUS_NMI			19
`define CP0_STATUS_IMPL			17:16
`define CP0_STATUS_INTMASK		15:8
`define CP0_STATUS_HW_INTMASK	15:10
`define CP0_STATUS_SW_INTMASK	9:8
`define CP0_STATUS_KX			7
`define CP0_STATUS_SX			6
`define CP0_STATUS_UX			5
`define CP0_STATUS_KSU			4:3
`define CP0_STATUS_UM			4
`define CP0_STATUS_R0			3
`define CP0_STATUS_ERL			2
`define CP0_STATUS_EXL			1
`define CP0_STATUS_IE			0

// CP0_CAUSE
`define CP0_CAUSE_BD			31
`define CP0_CAUSE_TI			30
`define CP0_CAUSE_CE			29:28
`define CP0_CAUSE_IV			23
`define CP0_CAUSE_WP			22
`define CP0_CAUSE_INT			15:8
`define CP0_CAUSE_HW_INT		15:10
`define CP0_CAUSE_SW_INT		9:8
`define CP0_CAUSE_EXCCODE		6:2

// CP0_CONFIG
`define CP0_CONFIG_M			31
`define CP0_CONFIG_IMPL			30:16
`define CP0_CONFIG_BE			15
`define CP0_CONFIG_AT			14:13
`define CP0_CONFIG_AR			12:10
`define CP0_CONFIG_MT			9:7
`define CP0_CONFIG_K0			2:0

// CP0_CONFIG1
`define CP0_CONFIG1_M			31
`define CP0_CONFIG1_MMU			30:25
`define CP0_CONFIG1_IS			24:22
`define CP0_CONFIG1_IL			21:19
`define CP0_CONFIG1_IA			18:16
`define CP0_CONFIG1_DS			15:13
`define CP0_CONFIG1_DL			12:10
`define CP0_CONFIG1_DA			9:7
`define CP0_CONFIG1_C2			6
`define CP0_CONFIG1_MD			5
`define CP0_CONFIG1_PC			4
`define CP0_CONFIG1_WR			3
`define CP0_CONFIG1_CA			2
`define CP0_CONFIG1_EP			1
`define CP0_CONFIG1_FP			0

/******************/
/*    ExcCode     */
/******************/
`define Int						5'h00
`define Mod						5'h01
`define TLBL					5'h02
`define TLBS					5'h03
`define AdEL					5'h04
`define AdES					5'h05
`define Sys						5'h08
`define Bp						5'h09
`define RI						5'h0a
`define CpU						5'h0b
`define Ov						5'h0c
`define Tr						5'h0d