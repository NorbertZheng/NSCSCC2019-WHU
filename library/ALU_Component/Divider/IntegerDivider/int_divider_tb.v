`timescale 1us/1ps
module int_divider_tb();
	/*********************
	 *	Integer Divider testbench
	 *********************/
	reg clock, resetn;
	reg start;
	reg [31:0] a;
	reg [15:0] b;
	wire [31:0] q;
	wire [15:0] r;
	wire busy, ready;
	wire [4:0] count;
	
	initial
		begin
		a = 32'h4c7f228a;
		b = 16'h6a0e;
		/* for div_nonrestoring_signed only
		a = 32'h55555555;
		b = 16'hfffe;
		*/
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
		
	// test div_restoring
	div_restoring m_div_restoring(
		.a(a), 
		.b(b), 
		.start(start), 
		.clock(clock), 
		.resetn(resetn), 
		.q(q), 
		.r(r), 
		.busy(busy), 
		.ready(ready), 
		.count(count)
	);
	
	/*
	// test div_nonrestoring
	div_nonrestoring m_div_nonrestoring(
		.a(a), 
		.b(b), 
		.start(start), 
		.clock(clock), 
		.resetn(resetn), 
		.q(q), 
		.r(r), 
		.busy(busy), 
		.ready(ready), 
		.count(count)
	);
	*/
	
	/*
	// test div_nonrestoring_signed
	div_nonrestoring_signed m_div_nonrestoring_signed(
		.a(a), 
		.b(b), 
		.start(start), 
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