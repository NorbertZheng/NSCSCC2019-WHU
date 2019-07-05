module goldschmidt(a, b, start, clock, resetn, q, busy, ready, count, reg_a, reg_b);
	/*********************
	 *	32-bit Goldschmidt Divider
	 *input:
	 *	a[31:0]	: 32-bit dividend: fraction .1xxx...x
	 *	b[31:0]	: 32-bit divisor:  fraction .1xxx...x
	 *	start	: 开始信号 ID stage: start = is_div & ~busy
	 *	clock	: 用于和 CPU 同步
	 *	resetn	: 置位信号
	 *output:
	 *	q[31:0]	: 32-bit quotient: fraction x.xxxx...x
	 *	busy	: 指示现在是否正在进行除法, 如果为 1 ，表示不能接受 new div
	 *	ready	: 指示除法完成，结果 CPU 可以取走
	 *********************/
	input [31:0] a;			// dividend: fraction: .1xxx...x
	input [31:0] b;			// divisor:  fraction: .1xxx...x
	input start;			// ID-stage: start = is_div & ~busy;
	input clock, resetn;
	output [31:0] q;		// quotient: fraction: x.xxxx...x
	output reg busy;		// cannot receive new div
	output ready;			// ready to save result
	output reg [2:0] count;	// for sim test only: 5 iterations
	output reg [33:0] reg_a;// for sim test only: 34-bit: x.xxxx...xx
	output reg [33:0] reg_b;// for sim test only: 34-bit: 0.1xxx...xx
	
	reg busy2;
	wire [33:0] b34 = ~reg_b + 1'b1;			// 2 - yi
	wire [67:0] a68 = reg_a * b34;				// 0x.xxx...xx
	wire [67:0] b68 = reg_b * b34;				// 0x.xxx...xx
	always@(posedge clock or negedge resetn)
		begin
		if(resetn == 1'b0)
			begin
			count <= 3'b0;		// reset count
			busy <= 1'b0;		// reset to not busy
			busy2 <= 1'b0;		// for generating 1-cycle ready
			end
		else					// not reset
			begin
			busy2 <= busy;		// 1-cycle delay of busy
			if(start)			// start: 1-cycle only
				begin
				reg_a <= {1'b0, a, 1'b0};		// 0.1xxx...x0
				reg_b <= {1'b0, b, 1'b0};		// 0.1xxx...x0
				count <= 3'b0;					// reset count
				busy <= 1'b1;					// set to busy
				end
			else				// execution: 5 iterations
				begin
				reg_a <= a68[66:33];			// x.xxx...x
				reg_b <= b68[66:33];			// x.xxx...x
				count <= count + 3'b1;			// count++
				if(count == 3'h4)				// finish
					begin
					busy <= 1'b0;
					end
				end
			end
		end
	
	assign ready = ~busy & busy2;					// generate 1-cycle ready
	assign q = reg_a[33:2] + (reg_a[1] | reg_a[0]);	// rounding
endmodule