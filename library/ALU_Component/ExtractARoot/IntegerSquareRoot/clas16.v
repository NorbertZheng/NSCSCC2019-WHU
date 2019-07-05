module clas16(sub, a, b, ci, s);
	/*********************
	 *	16-bit先行进位Add(Complete)
	 *input:
	 *	sub		: 1 -> - ; 0 -> +
	 *	a[15:0]	: 第一个16-bit操作数
	 *	b[15:0]	：第二个16-bit操作数
	 *	ci		: 来自低位的进位
	 *output:
	 *	s[15:0]	: 16-bit运算结果
	 *********************/
	input sub;		// 1- 0+
	input [15:0] a, b;
	input ci;		// active low for subtraction
	output [15:0] s;
	
	wire g_out, p_out;
	cla_16 cla(
		.a(a), 
		.b(b ^ {16{sub}}), 
		.c_in(ci), 
		.g_out(g_out), 
		.p_out(p_out), 
		.s(s)
	);
endmodule