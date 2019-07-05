`timescale 1us/1ps
module fp_square_root_tb();
	/*********************
	 *	Floating Point Square Root testbench
	 *********************/
	reg clock, resetn;
	reg start;
	reg [31:0] d;
	wire [31:0] q;
	wire busy, ready;
	
	initial
		begin
		d = 32'hfffe0001;
		// d = 32'hc0000000;
		// d = 32'h40000000;
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
	
	// test root_newton
	wire [1:0] count;
	wire [33:0] reg_x;
	root_newton m_root_newton(
		.d(d), 
		.start(start), 
		.clock(clock), 
		.resetn(resetn), 
		.q(q), 
		.busy(busy), 
		.ready(ready), 
		.count(count), 
		.reg_x(reg_x)
	);
	
	/*
	// test root_goldschmidt
	wire [2:0] count;
	wire [34:0] reg_x;
	root_goldschmidt m_root_goldschmidt(
		.d(d), 
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