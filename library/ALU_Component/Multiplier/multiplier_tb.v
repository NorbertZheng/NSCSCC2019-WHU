`timescale 1us/1ps
module multiplier_tb();
	/*********************
	 *	8-bit multiplier testbench
	 *********************/
	reg [7:0] a, b;
	wire [15:0] z;
	
	initial
		begin
		a = 8'b0;
		b = 8'b0;
		# 100;
		a = 8'hff;
		b = 8'hff;
		# 100;
		a = 8'h7f;
		b = 8'h7f;
		# 100;
		a = 8'h81;
		b = 8'h81;
		# 100;
		a = 8'h7e;
		b = 8'h7e;
		# 100;
		a = 8'h82;
		b = 8'h82;
		# 100;
		a = 8'h7d;
		b = 8'h7d;
		# 100;
		a = 8'h83;
		b = 8'h83;
		# 100;
		a = 8'h7e;
		b = 8'h81;
		# 100;
		a = 8'h82;
		b = 8'h7d;
		# 100;
		a = 8'h00;
		b = 8'h00;
		# 100;
		a = 8'h01;
		b = 8'h01;
		# 100;
		a = 8'h02;
		b = 8'h02;
		# 100;
		a = 8'h03;
		b = 8'h03;
		# 100;
		end
	/*	
	// test mul_signed
	mul_signed m_mul_signed(
		.a(a), 
		.b(b), 
		.z(z)
	);
	
	// test mul_signed_v2
	mul_signed_v2 m_mul_signed_v2(
		.a(a), 
		.b(b), 
		.z(z)
	);
	
	// test wallace_tree8
	wallace_tree8 m_wallace_tree8(
		.a(a), 
		.b(b), 
		.z(z)
	);
	*/
	// test wallace_tree8_signed
	wallace_tree8_signed m_wallace_tree8_signed(
		.a(a), 
		.b(b), 
		.z(z)
	);
endmodule