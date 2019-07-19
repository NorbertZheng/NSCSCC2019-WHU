/****************************************/
/*                                      */
/*                 NOP                  */
/*                                      */
/****************************************/
//nop
`define ALUOP_NOP		8'd0

/****************************************/
/*                                      */
/*               逻辑运算               */
/*                                      */
/****************************************/
// logic
`define ALUOP_AND		8'd1
`define ALUOP_OR		8'd2
`define ALUOP_XOR		8'd3
`define ALUOP_NOR		8'd4
`define ALUOP_LU		8'd5
`define ALUOP_ANDI		8'd6
`define ALUOP_XORI		8'd7
`define ALUOP_ORI		8'd8
 
 // shift
`define ALUOP_SLL		8'd9
`define ALUOP_SRL		8'd10
`define ALUOP_SRA		8'd11
`define ALUOP_SLLV		8'd12
`define ALUOP_SRLV		8'd13
`define ALUOP_SRAV		8'd14

// mov
`define ALUOP_MOVN		8'd15
`define ALUOP_MOVZ		8'd16
`define ALUOP_MFHI		8'd17
`define ALUOP_MFLO		8'd18
`define ALUOP_MTHI		8'd19
`define ALUOP_MTLO		8'd20

/****************************************/
/*                                      */
/*               算术运算               */
/*                                      */
/****************************************/
// origin
`define ALUOP_ADD		8'd21
`define ALUOP_ADDU		8'd22
`define ALUOP_SUB		8'd23
`define ALUOP_SUBU		8'd24
`define ALUOP_SLT		8'd25
`define ALUOP_SLTU		8'd26
`define ALUOP_ADDI		8'd27
`define ALUOP_ADDIU		8'd28
`define ALUOP_SLTI		8'd29
`define ALUOP_SLTIU		8'd30
`define ALUOP_CLZ		8'd31
`define ALUOP_CLO		8'd32
`define ALUOP_MUL		8'd33
`define ALUOP_MULT		8'd34
`define ALUOP_MULTU		8'd35
`define ALUOP_LB		8'd36
`define ALUOP_LBU		8'd37
`define ALUOP_LH		8'd38
`define ALUOP_LHU		8'd39
`define ALUOP_LW		8'd40
`define ALUOP_LWL		8'd41
`define ALUOP_LWR		8'd42
`define ALUOP_SB		8'd43
`define ALUOP_SH		8'd44
`define ALUOP_SW		8'd45
`define ALUOP_SWL		8'd46
`define ALUOP_SWR		8'd47
`define ALUOP_LL		8'd48
`define ALUOP_SC		8'd49
`define ALUOP_JALR		8'd50
`define ALUOP_MADD		8'd51
`define ALUOP_MADDU		8'd52
`define ALUOP_MSUB		8'd53		
`define ALUOP_MSUBU		8'd54
`define ALUOP_MTC		8'd55
`define ALUOP_MFC		8'd56

// trap
`define ALUOP_TEQ		8'd57
`define ALUOP_TGE		8'd58
`define ALUOP_TGEU		8'd59
`define ALUOP_TLT		8'd60
`define ALUOP_TLTU		8'd61
`define ALUOP_TNE		8'd62