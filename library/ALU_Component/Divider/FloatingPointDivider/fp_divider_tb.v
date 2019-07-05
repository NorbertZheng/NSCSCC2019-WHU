`timescale 1us/1ps
module fp_divider_tb();
	/*********************
	 *	Floating Point Divider testbench
	 *********************/
	reg clock, resetn;
	reg start;
	reg [31:0] a, b;
	wire [31:0] q;
	wire busy, ready;
	wire [2:0] count;
	
	initial
		begin
		a = 32'hc0000000;
		b = 32'h80000000;
		resetn = 1'b0;
		start = 1'b0;
		clock = 1'b1;
		# 50;
		resetn = 1'b1;
		start = 1'b1;
		# 100;
		start = 1'b0;
		end
	
	always # 50
		begin
		clock = ~clock;
		end
		
	// test goldschmidt
	wire [33:0] reg_a, reg_b;
	goldschmidt m_goldschmidt(
		.a(a), 
		.b(b), 
		.start(start), 
		.clock(clock), 
		.resetn(resetn), 
		.q(q),
		.busy(busy), 
		.ready(ready), 
		.count(count), 
		.reg_a(reg_a), 
		.reg_b(reg_b)
	);
	
	/*
	// test newton
	wire [33:0] reg_x;
	newton m_newton(
		.a(a), 
		.b(b), 
		.start(start), 
		.clock(clock), 
		.resetn(resetn), 
		.q(q),
		.busy(busy), 
		.ready(ready), 
		.count(count),
		.reg_x(reg_x)
	);
	*/
endmodule