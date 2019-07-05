module div_nonrestoring(a, b, start, clock, resetn, q, r, busy, ready, count);
	/*********************
	 *	32/16-bit Non-Restoring Divider
	 *input:
	 *	a[31:0]	: 32-bit dividend
	 *	b[15:0]	: 16-bit divisor
	 *	start	: 开始信号 ID stage: start = is_div & ~busy
	 *	clock	: 用于和 CPU 同步
	 *	resetn	: 置位信号
	 *output:
	 *	q[31:0]	: 32-bit 除法器无符号商
	 *	r[15:0] : 16-bit 除法器无符号余数
	 *	busy	: 指示现在是否正在进行除法, 如果为 1 ，表示不能接受 new div
	 *	ready	: 指示除法完成，结果 CPU 可以取走
	 *********************/
	input [31:0] a;		// divided
	input [15:0] b;		// divisor
	input start;		// ID stage: start = is_div & ~busy
	input clock, resetn;
	output [31:0] q;	// quotient
	output [15:0] r;	// remainder
	output reg busy;	// cannot receive new div
	output ready;		// ready to save result
	output reg [4:0] count;		// for sim test only
	
	reg [31:0] reg_q;
	reg [15:0] reg_r;
	reg [15:0] reg_b;
	reg busy2, r_sign;
	wire [16:0] sub_add = r_sign ? {reg_r, q[31]} + {1'b0, reg_b} : {reg_r, q[31]} - {1'b0, reg_b};
	always@(posedge clock or negedge resetn)
		begin
		if(resetn == 0)
			begin
			count <= 5'b0;		// reset count
			busy <= 0;			// reset to not busy
			busy2 <= 0;			// for generating 1-cycle ready
			end
		else		// not reset
			begin
			busy2 <= busy;		// 1-cycle delay of busy
			if(start)			// start: 1 cycle only
				begin
				reg_r <= 16'h0;	// reset remainder
				r_sign <= 0;	// sub first
				reg_q <= a;		// load a
				reg_b <= b;		// load b
				count <= 5'b0;	// reset count
				busy <= 1'b1;	// set to busy
				end
			else if(busy)		// execution: 32 cycles
				begin
				reg_r <= sub_add[15:0];		// partial remainder
				r_sign <= sub_add[16];		// if minus, add next
				reg_q <= {reg_q[30:0], ~sub_add[16]};		// 1-bit q
				count <= count + 5'b1;		// count++
				if(count == 5'h1f)
					begin
					busy <= 0;				// finish
					end
				end
			end
		end
	assign ready = ~busy & busy2;			// generate 1-cycle ready
	assign r = r_sign ? reg_r + reg_b : reg_r;		// adjust remainder
	assign q = reg_q;
endmodule