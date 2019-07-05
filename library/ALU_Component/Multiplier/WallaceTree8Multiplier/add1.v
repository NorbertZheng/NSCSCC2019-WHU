module add1(a, b, ci, s, co);
	/*********************
	 *	1-bitAdd
	 *input:
	 *	a	: add1 的第一个操作数
	 *	b	: add1 的第二个操作数
	 *	ci	: add1 的来自下一位的进位
	 *output:
	 *	s	: add1 的运算结果
	 *	co	: add1 的向上一位的进位
	 *********************/
	input a, b, ci;
	output s, co;
	
	assign s = a ^ b ^ ci;
	assign co = (a & b) | (b & ci) | (ci & a);
endmodule