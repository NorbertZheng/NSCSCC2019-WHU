/****************************************/
/*            二选一  MUX               */
/****************************************/
module Mux2T1(s, y, d0, d1);
	parameter width = 32, signWidth = 1;
	/*********************
	 *	width-bit 2T1 Mux
	 *input:
	 *	s				: select signal
	 *	d0[width - 1:0]	: d0
	 *	d1[width - 1:0]	: d1
	 *output:
	 *	y[width - 1:0]	: y
	 *********************/
	input [signWidth - 1:0] s;
	input [width - 1:0] d0;
	input [width - 1:0] d1;
	output [width - 1:0] y;
	
	assign y = 	 (s == 1) ? d1 : 
				((s == 0) ? d0 : 0);
endmodule

/****************************************/
/*             三选一   MUX             */
/****************************************/
module Mux3T1(s, y, d0, d1, d2);
	parameter width = 32, signWidth = 2;
	/*********************
	 *	width-bit 3T1 Mux
	 *input:
	 *	s[1:0]			: select signal
	 *	d0[width - 1:0]	: d0
	 *	d1[width - 1:0]	: d1
	 *	d2[width - 1:0]	: d2
	 *output:
	 *	y[width - 1:0]	: y
	 *********************/
	input [signWidth - 1:0] s;
	input [width - 1:0] d0;
	input [width - 1:0] d1;
	input [width - 1:0] d2;
	output [width - 1:0] y;
	
	assign y = 	 (s == 2) ? d2 :
				((s == 1) ? d1 : 
				((s == 0) ? d0 : 0));
endmodule

/****************************************/
/*            四选一  MUX               */
/****************************************/
module Mux4T1(s, y, d0, d1, d2, d3);
	parameter width = 32, signWidth = 2;
	/*********************
	 *	width-bit 4T1 Mux
	 *input:
	 *	s[1:0]			: select signal
	 *	d0[width - 1:0]	: d0
	 *	d1[width - 1:0]	: d1
	 *	d2[width - 1:0]	: d2
	 *	d3[width - 1:0]	: d3
	 *output:
	 *	y[width - 1:0]	: y
	 *********************/
	input [signWidth - 1:0] s;
	input [width - 1:0] d0;
	input [width - 1:0] d1;
	input [width - 1:0] d2;
	input [width - 1:0] d3;
	output [width - 1:0] y;
	
	assign y = 	 (s == 3) ? d3 : 
				((s == 2) ? d2 :
				((s == 1) ? d1 : 
				((s == 0) ? d0 : 0)));
endmodule

/****************************************/
/*            五选一  MUX               */
/****************************************/
module Mux5T1(s, y, d0, d1, d2, d3, d4);
	parameter width = 32, signWidth = 3;
	/*********************
	 *	width-bit 5T1 Mux
	 *input:
	 *	s[2:0]			: select signal
	 *	d0[width - 1:0]	: d0
	 *	d1[width - 1:0]	: d1
	 *	d2[width - 1:0]	: d2
	 *	d3[width - 1:0]	: d3
	 *	d4[width - 1:0]	: d4
	 *output:
	 *	y[width - 1:0]	: y
	 *********************/
	input [signWidth - 1:0] s;
	input [width - 1:0] d0;
	input [width - 1:0] d1;
	input [width - 1:0] d2;
	input [width - 1:0] d3;
	input [width - 1:0] d4;
	output [width - 1:0] y;
	
	assign y = 	 (s == 4) ? d4 : 
				((s == 3) ? d3 : 
				((s == 2) ? d2 :
				((s == 1) ? d1 : 
				((s == 0) ? d0 : 0))));
endmodule

/****************************************/
/*            六选一  MUX               */
/****************************************/
module Mux6T1(s, y, d0, d1, d2, d3, d4, d5);
	parameter width = 32, signWidth = 3;
	/*********************
	 *	width-bit 6T1 Mux
	 *input:
	 *	s[2:0]			: select signal
	 *	d0[width - 1:0]	: d0
	 *	d1[width - 1:0]	: d1
	 *	d2[width - 1:0]	: d2
	 *	d3[width - 1:0]	: d3
	 *	d4[width - 1:0]	: d4
	 *	d5[width - 1:0]	: d5
	 *output:
	 *	y[width - 1:0]	: y
	 *********************/
	input [signWidth - 1:0] s;
	input [width - 1:0] d0;
	input [width - 1:0] d1;
	input [width - 1:0] d2;
	input [width - 1:0] d3;
	input [width - 1:0] d4;
	input [width - 1:0] d5;
	output [width - 1:0] y;
	
	assign y = 	 (s == 5) ? d5 : 
				((s == 4) ? d4 : 
				((s == 3) ? d3 : 
				((s == 2) ? d2 :
				((s == 1) ? d1 : 
				((s == 0) ? d0 : 0)))));
endmodule

/****************************************/
/*            八选一  MUX               */
/****************************************/
module Mux8T1(s, y, d0, d1, d2, d3, d4, d5, d6, d7);
	parameter width = 32, signWidth = 3;
	/*********************
	 *	width-bit 8T1 Mux
	 *input:
	 *	s[2:0]			: select signal
	 *	d0[width - 1:0]	: d0
	 *	d1[width - 1:0]	: d1
	 *	d2[width - 1:0]	: d2
	 *	d3[width - 1:0]	: d3
	 *	d4[width - 1:0]	: d4
	 *	d5[width - 1:0]	: d5
	 *	d6[width - 1:0]	: d6
	 *	d7[width - 1:0]	: d7
	 *output:
	 *	y[width - 1:0]	: y
	 *********************/
	input [signWidth - 1:0] s;
	input [width - 1:0] d0;
	input [width - 1:0] d1;
	input [width - 1:0] d2;
	input [width - 1:0] d3;
	input [width - 1:0] d4;
	input [width - 1:0] d5;
	input [width - 1:0] d6;
	input [width - 1:0] d7;
	output [width - 1:0] y;

	assign y = 	 (s == 7) ? d7 : 
				((s == 6) ? d6 : 
				((s == 5) ? d5 : 
				((s == 4) ? d4 : 
				((s == 3) ? d3 : 
				((s == 2) ? d2 :
				((s == 1) ? d1 : 
				((s == 0) ? d0 : 0)))))));
endmodule

/****************************************/
/*           十六选一  MUX              */
/****************************************/
module Mux16T1(s, y, d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15);
	parameter width = 32, signWidth = 4;
	/*********************
	 *	width-bit 16T1 Mux
	 *input:
	 *	s[3:0]				: select signal
	 *	d0[width - 1:0]		: d0
	 *	d1[width - 1:0]		: d1
	 *	d2[width - 1:0]		: d2
	 *	d3[width - 1:0]		: d3
	 *	d4[width - 1:0]		: d4
	 *	d5[width - 1:0]		: d5
	 *	d6[width - 1:0]		: d6
	 *	d7[width - 1:0]		: d7
	 *	d8[width - 1:0]		: d8
	 *	d9[width - 1:0]		: d9
	 *	d10[width - 1:0]	: d10
	 *	d11[width - 1:0]	: d11
	 *	d12[width - 1:0]	: d12
	 *	d13[width - 1:0]	: d13
	 *	d14[width - 1:0]	: d14
	 *	d15[width - 1:0]	: d15
	 *output:
	 *	y[width - 1:0]	: y
	 *********************/
	input [signWidth - 1:0] s;
	input [width - 1:0] d0;
	input [width - 1:0] d1;
	input [width - 1:0] d2;
	input [width - 1:0] d3;
	input [width - 1:0] d4;
	input [width - 1:0] d5;
	input [width - 1:0] d6;
	input [width - 1:0] d7;
	input [width - 1:0] d8;
	input [width - 1:0] d9;
	input [width - 1:0] d10;
	input [width - 1:0] d11;
	input [width - 1:0] d12;
	input [width - 1:0] d13;
	input [width - 1:0] d14;
	input [width - 1:0] d15;
	output [width - 1:0] y;
	
	assign y = 	(s == 15) 	? 	d15	: 
				((s == 14) 	? 	d14 : 
				((s == 13) 	? 	d13 : 
				((s == 12) 	? 	d12 : 
				((s == 11) 	? 	d11 : 
				((s == 10) 	? 	d10 :
				((s == 9) 	? 	d9	: 
				((s == 8) 	? 	d8 	:
				((s == 7) 	? 	d7 	: 
				((s == 6) 	? 	d6 	: 
				((s == 5) 	? 	d5 	: 
				((s == 4) 	? 	d4 	: 
				((s == 3) 	? 	d3 	: 
				((s == 2) 	? 	d2 	:
				((s == 1) 	? 	d1 	: 
				((s == 0) 	? 	d0 	: 0)))))))))))))));
endmodule