module root_nonrestoring(d, load, clock, resetn, q, r, busy, ready, count);
	/*********************
	 *	32/16-bit Non-Restoring Square Root
	 *input:
	 *	d[31:0]	: 32-bit radicand
	 *	load	: 开始信号 ID stage: load = is_sqrt & ~busy
	 *	clock	: 用于和 CPU 同步
	 *	resetn	: 置位信号
	 *output:
	 *	q[15:0]	: 16-bit root
	 *	r[16:0] : 17-bit remainder
	 *	busy	: 指示现在是否正在进行开方运算, 如果为 1 ，表示不能接受 new sqrt
	 *	ready	: 指示开方运算完成，结果 CPU 可以取走
	 *********************/
	input [31:0] d;			// radicand
	input load;				// ID-stage: load = is_sqrt & ~busy;
	input clock, resetn;
	output [15:0] q;		// root
	output [16:0] r;		// remainder
	output reg busy;		// cannot receive new sqrt
	output ready;			// ready to save result
	output reg [3:0] count;	// for sim test only
	
	reg [31:0] reg_d;
	reg [15:0] reg_q;
	reg [17:0] reg_r;
	reg busy2, r_sign;
	wire [15:0] add_sub;
	// clas16(sub, a, b, ci, s);		// active low for subtraction
	clas16 as(
		.sub(~reg_r[17]),
		.a(reg_r[15:0]),
		.b(reg_q),
		.ci(reg_d[31] | reg_d[30]),
		.s(add_sub)
	);
	always@(posedge clock or negedge resetn)
		begin
		if(resetn == 1'b0)
			begin
			count <= 4'b0;		// reset count
			busy <= 1'b0;		// reset to not busy
			busy2 <= 1'b0;		// for generating 1-cycle ready
			end
		else					// not reset
			begin
			busy2 <= busy;		// 1-cycle delay of busy
			if(load)			// laod: 1 cycle only
				begin
				reg_d <= d;		// load d
				reg_q <= 16'h0;	// reset root
				reg_r <= 16'h0;	// reset remainder
				count <= 4'b0;	// reset count
				busy <= 1'b1;	// set to busy
				end
			else if(busy)		// execution: 16-cycles
				begin
				reg_d <= {reg_d[29:0], 2'b0};			// shift 2-bit
				reg_q <= {reg_q[14:0], ~add_sub[15]};	// 1-bit q
				reg_r[17:2] <= add_sub;					// partial remainder
				reg_r[1] <= reg_d[31] ~^ reg_d[30];		// remainder
				reg_r[0] <= ~reg_d[30];					// remainder
				count <= count + 4'b1;					// count++
				if(count == 4'hf)						// finish
					begin
					busy <= 1'b0;
					end
				end
			end
		end
		
	assign ready = ~busy & busy2;												// generate 1-cycle ready
	assign q = reg_q;
	assign r = reg_r[17] ? reg_r[16:0] + {reg_q[15:0], 1'b1} : reg_r[16:0];		// adjust remainder
endmodule