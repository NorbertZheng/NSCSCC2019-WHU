`include "../Define/Fragment_Define.v"
module EXT(EXTOp, Imm16, Imm32);
	/*********************
	 *	16/32-bit Extend
	 *input:
	 *	EXTOp			: EXT opcode
	 *	Imm16[15:0]		: 16-bit immediate
	 *output:
	 *	Imm32[31:0]		: 32-bit immediate
	 *********************/
	input EXTOp;
	input [15:0] Imm16;
	output reg [31:0] Imm32;
	
	always@(*)
		begin
		case(EXTOp)
			`LogicEXT:
				begin
				Imm32 = {16'b0, Imm16};
				end
			`ArithmeticEXT:
				begin
				Imm32 = {{16{Imm16[15]}}, Imm16};
				end
		endcase
		end
endmodule