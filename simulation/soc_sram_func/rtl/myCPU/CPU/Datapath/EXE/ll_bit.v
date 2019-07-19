module ll_bit(clk, rst_n, clr, ll_bit_i, wll, ll_bit_o);
	/*********************
	 *	ll_bit register
	 *input:
	 *	clk				: clock
	 *	rst_n			: negetive reset signal
	 *	clr				: clr signal
	 *	ll_bit_i		: ll_bit input
	 *	wll				: write ll_bit
	 *output:
	 *	ll_bit_o		: ll_bit output
	 *********************/
	input clk, rst_n;
	input clr, wll;
	input ll_bit_i;
	output reg ll_bit_o;
	
	reg ll_bit;
	
	// ll_bit_o output
	always@(*)
		begin
		if(!rst_n)
			begin
			ll_bit_o = 1'b0;
			end
		else if(clr)
			begin
			ll_bit_o = 1'b0;
			end
		else if(wll)
			begin
			ll_bit_o = ll_bit_i;
			end
		else
			begin
			ll_bit_o = ll_bit;
			end
		end
		
	// ll_bit inside reg
	always@(posedge clk or negedge rst_n)
		begin
		if(!rst_n)
			begin
			ll_bit <= 1'b0;
			end
		else if(clr)
			begin
			ll_bit <= 1'b0;
			end
		else
			begin
			ll_bit <= ll_bit_i;
			end
		end
endmodule