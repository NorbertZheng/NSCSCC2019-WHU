module Divider(clk, rst_n, a, b, start, clr, is_sign_div, result, busy);
	/*********************
	 *		Divider
	 *input:
	 *	clk			: clock
	 *	rst_n		: negetive reset signal
	 *	a[31:0]		: 32-bit dividend
	 *	b[31:0]		: 32-bit divisor
	 *	start		: 开始信号 ID stage: start = is_div
	 *	clr			: 置位信号
	 *	is_sign_div	: signed div signal
	 *output:
	 *	result[63:0]: result
	 *	busy		: 总线阻塞信号
	 *********************/
	input clk, rst_n;
	input start, clr, is_sign_div;
	input [31:0] a, b;
	output reg busy;
	output reg [63:0] result;
	
	wire[32:0] div_temp; 
	reg[5:0] cnt; 			// 计数器
	reg[64:0] dividend; 	// 试除中间结果
	reg[1:0] state; 		// 状态
	reg[31:0] divisor;		// 被除数
	// reg[31:0] temp_op1; 	// 临时操作数1
	// reg[31:0] temp_op2;	// 临时操作数2
	reg sgn_fix1;
	reg sgn_fix2;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

	always@(posedge clk or negedge rst_n) 
		begin
		if (!rst_n) 
			begin
			state <= 2'd0;
			end 
		else 
			begin
			case(state)
				2'd0:			
					begin		//DivFree״̬
					if(start == 1'b1 && clr == 1'b0)	//允许除
						begin
						if(b == 32'd0)				//0作除数触发异常
							begin
							state <= 2'd1;
							end 
						else								//正常情况
							begin
							state <= 2'd2;
							cnt <= 6'b000000;
							if(is_sign_div == 1'b1 && a[31] == 1'b1)	//处理第1个立即数为负
								begin
								// temp_op1 = ~a + 1;
								dividend[32:1] <= ~a + 1;			//商初值
								sgn_fix1 <= 1;
								end 
							else 
								begin
								// temp_op1 = a;
								dividend[32:1] <= a;			//商初值
								sgn_fix1 <= 0;
								end
							if(is_sign_div == 1'b1 && b[31] == 1'b1 )	//处理第2个立即数为负
								begin
								// temp_op2 = ~b + 1;
								divisor <= ~b + 1;
								sgn_fix2 <= 1;
								end 
							else 
								begin
								// temp_op2 = b;
								divisor <= b;
								sgn_fix2 <= 0;
								end
							// dividend <= {32'd0,32'd0};
							dividend[63:33] <= 31'b0;
							dividend[0] <= 1'b0;
							end
						end        	
					end
				2'd1:		
					begin               						//DivByZero״̬
					dividend <= {32'd0,32'd0};
					state <= 2'd3;		 		
					end
				2'd2:				
					begin              							//DivOn״̬
					if(clr == 1'b0) 
						begin
						if(cnt != 6'b100000) 
							begin
							if(div_temp[32] == 1'b1)										//试除
								begin
								dividend <= {dividend[63:0], 1'b0};							//除不尽商自然移位，余数移位
								end 
							else 
								begin
								dividend <= {div_temp[31:0], dividend[31:0], 1'b1};			//除得尽商移位补1，余数更新
								end
							cnt <= cnt + 1;
							end 
						else 
							begin
							if((is_sign_div == 1'b1) && ((sgn_fix1 ^ sgn_fix2) == 1'b1))	//恢复商
								begin
								dividend[31:0] <= (~dividend[31:0] + 1);
								end
							if((is_sign_div == 1'b1) && ((sgn_fix1 ^ dividend[64]) == 1'b1))//恢复余数
								begin              
								dividend[64:33] <= (~dividend[64:33] + 1);
								end
							state <= 2'd3;
							cnt <= 6'b000000;            	
							end
						end 
					else 
						begin
						state <= 2'd0;
						end	
					end
				2'd3:												//DivEnd״̬
					begin
					if(start == 1'b0 || clr == 1'b1)
						begin
						state <= 2'd0;
						end
					end
			endcase
			end
		end

	always @(*)
		begin
		if(!rst_n) 
			begin
			busy = 1'b0;
			result = {32'd0,32'd0}; 
			end
		else
			begin
			case(state)
				2'd0:
					begin
					if(start == 1'b1 && clr == 1'b0) 
						begin
						busy = 1'b1;
						result = {32'd0,32'd0}; 
						end
					else
						begin
						busy = 1'b0;
						result = {32'd0,32'd0}; 
						end
					end
				2'd1:
					begin
					busy = 1'b1;
					result = {32'd0,32'd0}; 
					end
				2'd2:
					begin
					busy = 1'b1;
					result = {32'd0,32'd0}; 
					end
				2'd3:
					begin
					result = {dividend[64:33], dividend[31:0]};  //余数->hi 商->lo
					busy = 1'b0;
					end
			endcase
			end
		end	
endmodule