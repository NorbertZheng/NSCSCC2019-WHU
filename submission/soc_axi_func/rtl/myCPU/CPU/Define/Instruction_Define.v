/****************************************/
/*                                      */
/*              INSTRUCTION             */
/*                                      */
/****************************************/
`define INST_NOP		32'b00000000000000000000000000000000
`define INST_ERET 		32'b01000010000000000000000000011000
/****************************************/
/*                                      */
/*                OPCODE                */
/*                                      */
/****************************************/
`define OPCODE_SPECIAL		6'b000000
`define OPCODE_REGIMM		6'b000001
`define OPCODE_J			6'b000010
`define OPCODE_JAL			6'b000011
`define OPCODE_BEQ			6'b000100
`define OPCODE_BNE			6'b000101
`define OPCODE_BLEZ			6'b000110
`define OPCODE_BGTZ			6'b000111
`define OPCODE_ADDI			6'b001000
`define OPCODE_ADDIU		6'b001001
`define OPCODE_SLTI			6'b001010
`define OPCODE_SLTIU		6'b001011
`define OPCODE_ANDI			6'b001100
`define OPCODE_ORI			6'b001101
`define OPCODE_XORI			6'b001110
`define OPCODE_LUI			6'b001111
`define OPCODE_COP0			6'b010000
`define OPCODE_COP1			6'b010001
`define OPCODE_SPECIAL2		6'b011100

`define OPCODE_LB			6'b100000
`define OPCODE_LH			6'b100001
`define OPCODE_LWL			6'b100010
`define OPCODE_LW			6'b100011
`define OPCODE_LBU			6'b100100
`define OPCODE_LHU			6'b100101
`define OPCODE_LWR			6'b100110

`define OPCODE_SB			6'b101000
`define OPCODE_SH			6'b101001
`define OPCODE_SWL			6'b101010
`define OPCODE_SW			6'b101011

`define OPCODE_SWR			6'b101110
`define OPCODE_LL			6'b110000
`define OPCODE_PREF			6'b110011
`define OPCODE_SC			6'b111000

/****************************************/
/*                                      */
/*                 RS                   */
/*                                      */
/****************************************/
`define RS_MFC0				5'b00000
`define RS_MTC0				5'b00100
// CO (rs[4] for tlb instructions and eret)
`define CO_TLB				1'b1

/****************************************/
/*                                      */
/*                 RT                   */
/*                                      */
/****************************************/
`define RT_BLTZ				5'b00000
`define RT_BGEZ				5'b00001
`define RT_TGEI				5'b01000
`define RT_TGEIU			5'b01001
`define RT_TLTI				5'b01010
`define RT_TLTIU			5'b01011
`define RT_TEQI				5'b01100
`define RT_TNEI				5'b01110
`define RT_BLTZAL			5'b10000
`define RT_BGEZAL			5'b10001

/****************************************/
/*                                      */
/*                FUNC                  */
/*                                      */
/****************************************/
// OPCODE_SPECIAL
`define FUNC_SLL			6'b000000

`define FUNC_SRL			6'b000010
`define FUNC_SRA			6'b000011
`define FUNC_SLLV			6'b000100

`define FUNC_SRLV			6'b000110
`define FUNC_SRAV			6'b000111
`define FUNC_JR				6'b001000
`define FUNC_JALR			6'b001001
`define FUNC_MOVZ			6'b001010
`define FUNC_MOVN			6'b001011
`define FUNC_SYSCALL		6'b001100
`define FUNC_BREAK			6'b001101

`define FUNC_SYNC			6'b001111

`define FUNC_MFHI			6'b010000
`define FUNC_MTHI			6'b010001
`define FUNC_MFLO			6'b010010
`define FUNC_MTLO			6'b010011
`define FUNC_MULT			6'b011000
`define FUNC_MULTU			6'b011001
`define FUNC_DIV			6'b011010
`define FUNC_DIVU			6'b011011

`define FUNC_ADD			6'b100000
`define FUNC_ADDU			6'b100001
`define FUNC_SUB			6'b100010
`define FUNC_SUBU			6'b100011
`define FUNC_AND			6'b100100
`define FUNC_OR				6'b100101
`define FUNC_XOR			6'b100110
`define FUNC_NOR			6'b100111

`define FUNC_SLT			6'b101010
`define FUNC_SLTU			6'b101011

`define FUNC_TGE			6'b110000
`define FUNC_TGEU			6'b110001
`define FUNC_TLT			6'b110010
`define FUNC_TLTU			6'b110011
`define FUNC_TEQ			6'b110100

`define FUNC_TNE			6'b110110

// OPCODE_COP0
`define FUNC_TLBR			6'b000001
`define FUNC_TLBWI			6'b000010
`define FUNC_TLBP			6'b001000
`define FUNC_ERET			6'b011000

// OPCODE_SPECIAL2
`define FUNC_MADD			6'b000000
`define FUNC_MADDU			6'b000001
`define FUNC_MUL			6'b000010

`define FUNC_MSUB			6'b000100
`define FUNC_MSUBU			6'b000101

`define FUNC_CLZ			6'b100000
`define FUNC_CLO			6'b100001