module root_goldschmidt(d, start, clock, resetn, q, busy, ready, count, reg_x);
	/*********************
	 *	32-bit Goldschmidt Square Root
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
	output reg [2:0] count;	// for sim test only: 5 iterations
	output reg [34:0] reg_x;// for sim test only: 35-bit: 0.1xxx...xx
	
	reg [34:0] reg_d;		// 35-bit: x.xxxx...xx
	reg [34:0] reg_r;		// 35-bit: x.xxxx...xx
	reg busy2;
	wire [7:0] r0 = rom(d[31:28]);
	wire [34:0] ri = 35'h600000000 - {2'b0, reg_x[33:1]};
	wire [69:0] ci = ri * ri;				// 0x.xxx...xx
	wire [69:0] d70 = reg_d * ri;			// 01.xxx...xx
	wire [69:0] x70 = reg_x * ci[68:34];	// 0x.xxx...xx
	wire [34:0] x35 = {1'b0, {34{x70[68]}} | x70[67:34]};		// ! >= 1.0
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
				reg_d <= {1'b0, d, 2'b0};
				reg_x <= {1'b0, d, 2'b0};
				reg_r <= {1'b1, r0, 26'h0};		// 1.xxxx...x0
				count <= 3'b0;					// reset count
				busy <= 1'b1;					// set to busy
				end
			else				// execution: 5 iterations
				begin
				reg_d <= d70[68:34];			// x.xxx...x
				reg_x <= x35;					// x.xxx...x
				reg_r <= ri;					// x.xxx...x
				count <= count + 3'b1;			// count++
				if(count == 3'h5)				// finish
					begin
					busy <= 1'b0;
					end
				end
			end
		end
	
	assign ready = ~busy & busy2;		// generate 1-cycle ready
	assign q = reg_d[33:2] + {31'h0, (reg_d[1] | reg_d[0])};
	
	function [7:0] rom;		// 1 / d ^ {1 / 2}
		input [3:0] d;
		
		case(d)
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