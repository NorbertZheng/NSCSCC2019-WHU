`timescale 1us/1ps
module int_square_root_tb();
	/*********************
	 *	Integer Square Root testbench
	 *********************/
	reg clock, resetn;
	reg load;
	reg [31:0] d;
	wire [15:0] q;
	wire [16:0] r;
	wire busy, ready;
	wire [3:0] count;
	
	initial
		begin
		d = 32'hc0000000;
		resetn = 1'b0;
		load = 1'b0;
		clock = 1'b1;
		# 50;
		resetn = 1'b1;
		load = 1'b1;
		# 100;
		load = 1'b0;
		end
	
	always # 50
		begin
		clock = ~clock;
		end
	
	// test root_nonrestoring
	root_nonrestoring m_root_nonrestoring(
		.d(d), 
		.load(load), 
		.clock(clock), 
		.resetn(resetn), 
		.q(q), 
		.r(r), 
		.busy(busy), 
		.ready(ready), 
		.count(count)
	);
	
	/*
	// test root_restoring
	root_restoring m_root_restoring(
		.d(d), 
		.load(load), 
		.clock(clock), 
		.resetn(resetn), 
		.q(q), 
		.r(r), 
		.busy(busy), 
		.ready(ready), 
		.count(count)
	);
	*/
endmodule