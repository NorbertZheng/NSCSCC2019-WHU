module add(a, b, c, g, p ,s);
	/*********************
	 *input:
	 *	a: add 的第�?个操作数
	 *	b: add 的第二个操作�?
	 *	c: add 的来自下�?位的进位
	 *output:
	 *	g: add 的进位产生函�?
	 *	p: add 的进位传递函�?
	 *	s: add 的加法结�?
	 *********************/
	input a, b, c;
	output g, p, s;
	
	assign s = a ^ b ^ c;
	assign g = a & b;
	assign p = a | b;
endmodule