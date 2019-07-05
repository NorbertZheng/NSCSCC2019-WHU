module newton(a, b, start, clock, resetn, q, busy, ready, count, reg_x);
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
	output reg [1:0] count;	// for sim test only: 3 iterations
	output reg [33:0] reg_x;// for sim test only: 34-bit: xx.xxxxx...xx
	
	reg [31:0] reg_a;		// 32-bit: .1xxxx...xx
	reg [31:0] reg_b;		// 32-bit: .1xxxx...xx
	reg busy2;
	
	// xi (2 - xi b)
	wire [7:0] x0 = rom(b[30:27]);
	wire [65:0] bxi = reg_x * reg_b;			//  xx.xxxxx...x
	wire [33:0] b34 = ~bxi[64:31] + 1'b1;		//   x.xxxxx...x
	wire [67:0] x68 = reg_x * b34;				// xxx.xxxxx...x
	always@(posedge clock or negedge resetn)
		begin
		if(resetn == 1'b0)
			begin
			count <= 2'b0;		// reset count
			busy <= 1'b0;		// reset to not busy
			busy2 <= 1'b0;		// for generating 1-cycle ready
			end
		else					// not reset
			begin
			busy2 <= busy;		// 1-cycle delay of busy
			if(start)			// start: 1 cycle only
				begin
				reg_x <= {2'b1, x0, 24'b0};		// 01.xxxx0...0
				reg_a <= a;						// .1xxxx...x
				reg_b <= b;						// .1xxxx...x
				count <= 2'b0;					// reset count
				busy <= 1'b1;					// set to busy
				end
			else				// executions: 3 iterations
				begin
				reg_x <= x68[66:33];			// xx.xxxxx...x
				count <= count + 2'b1;			// count++
				if(count == 2'h2)				// finish
					begin
					busy <= 1'b0;
					end
				end
			end
		end
	
	assign ready = ~busy & busy2;				// generate 1-cycle ready
	wire [65:0] d_x = reg_a * reg_x;			// xx.xxxxx...x
	assign q = d_x[64:33] + {31'h0, |d_x[32:0]};// rounding
	
	function [7:0] rom;
		input [3:0] b;
		
		case(b)
			4'h0:
				begin
				rom = 8'hf0;
				end
			4'h1:
				begin
				rom = 8'hd4;
				end
			4'h2:
				begin
				rom = 8'hba;
				end
			4'h3:
				begin
				rom = 8'ha4;
				end
			4'h4:
				begin
				rom = 8'h8f;
				end
			4'h5:
				begin
				rom = 8'h7d;
				end
			4'h6:
				begin
				rom = 8'h6c;
				end
			4'h7:
				begin
				rom = 8'h5c;
				end
			4'h8:
				begin
				rom = 8'h4e;
				end
			4'h9:
				begin
				rom = 8'h41;
				end
			4'ha:
				begin
				rom = 8'h35;
				end
			4'hb:
				begin
				rom = 8'h29;
				end
			4'hc:
				begin
				rom = 8'h1f;
				end
			4'hd:
				begin
				rom = 8'h15;
				end
			4'he:
				begin
				rom = 8'h0c;
				end
			4'hf:
				begin
				rom = 8'h04;
				end
		endcase
	endfunction
endmodule