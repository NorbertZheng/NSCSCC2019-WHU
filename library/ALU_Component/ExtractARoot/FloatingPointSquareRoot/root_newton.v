module root_newton(d, start, clock, resetn, q, busy, ready, count, reg_x);
	/*********************
	 *	32-bit Newton Square Root
	 *input:
	 *	d[31:0]	: 32-bit radicand: .1xxx...x or .01xx...x
	 *	start	: 开始信号 ID stage: start = is_sqrt & ~busy
	 *	clock	: 用于和 CPU 同步
	 *	resetn	: 置位信号
	 *output:
	 *	q[31:0]	: 32-bit root: .1xxx...x
	 *	busy	: 指示现在是否正在进行开方运算, 如果为 1 ，表示不能接受 new sqrt
	 *	ready	: 指示开方运算完成，结果 CPU 可以取走
	 *********************/
	input [31:0] d;			// radicand: .1xxx...x or .01xx...x
	input start;			// ID-stage: start = is_sqrt & ~busy;
	input clock, resetn;
	output [31:0] q;		// root: .1xxx...x
	output reg busy;		// cannot receive new sqrt
	output ready;			// ready to save result
	output reg [1:0] count;	// for sim test only: 2 iterations
	output reg [33:0] reg_x;// for sim test only: 34-bit xx.1xxx...xx
	
	reg [31:0] reg_d;		// 32-bit: .xxxx...xx
	reg busy2;
	wire [7:0] x0 = rom(d[31:27]);
	// x_{i + 1} = x_i * ( 3 - x_i * x_i * d) / 2
	wire [67:0] x_2 = reg_x * reg_x;				// xxxx.xxxx...x
	wire [67:0] x2d = reg_d * x_2[67:32];			// xxxx.xxxx...x
	wire [33:0] b34 = 34'h300000000 - x2d[65:32];	//   xx.xxxx...x
	wire [67:0] x68 = reg_x * b34;					// xxxx.xxxx...x
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
				reg_d <= d;						//   .1xxxx...x
				count <= 2'b0;					// reset count
				busy <= 1'b1;					// set to busy
				end
			else				// execution: 3 iterations
				begin
				reg_x <= x68[66:33];			// x68 / 2
				count <= count + 2'b1;			// count++
				if(count == 2'h2)				// finish
					begin
					busy <= 1'b0;
					end
				end
			end
		end
	
	// q = d * x_n
	assign ready = ~busy & busy2;					// generate 1-cycle ready
	wire [65:0] d_x = reg_d * reg_x;				//   xx.xxxx...x
	assign q = d_x[63:32] + {31'h0, | d_x[31:0]};	// rounding
	
	function [7:0] rom;		// 1 / d ^ {1 / 2}
		input [4:0] d;
		
		case(d)
			5'h08:
				begin
				rom = 8'hf0;
				end
			5'h09:
				begin
				rom = 8'hd5;
				end
			5'h0a:
				begin
				rom = 8'hbe;
				end
			5'h0b:
				begin
				rom = 8'hab;
				end
			5'h0c:
				begin
				rom = 8'h99;
				end
			5'h0d:
				begin
				rom = 8'h8a;
				end
			5'h0e:
				begin
				rom = 8'h7c;
				end
			5'h0f:
				begin
				rom = 8'h6f;
				end
			5'h10:
				begin
				rom = 8'h64;
				end
			5'h11:
				begin
				rom = 8'h5a;
				end
			5'h12:
				begin
				rom = 8'h50;
				end
			5'h13:
				begin
				rom = 8'h47;
				end
			5'h14:
				begin
				rom = 8'h3f;
				end
			5'h15:
				begin
				rom = 8'h38;
				end
			5'h16:
				begin
				rom = 8'h31;
				end
			5'h17:
				begin
				rom = 8'h2a;
				end
			5'h18:
				begin
				rom = 8'h24;
				end
			5'h19:
				begin
				rom = 8'h1e;
				end
			5'h1a:
				begin
				rom = 8'h19;
				end
			5'h1b:
				begin
				rom = 8'h14;
				end
			5'h1c:
				begin
				rom = 8'h0f;
				end
			5'h1d:
				begin
				rom = 8'h0a;
				end
			5'h1e:
				begin
				rom = 8'h06;
				end
			5'h1f:
				begin
				rom = 8'h02;
				end
			default:
				begin
				rom = 8'hff;
				end
		endcase
	endfunction
endmodule