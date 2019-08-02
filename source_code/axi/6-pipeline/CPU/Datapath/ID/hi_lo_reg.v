module hi_lo_reg(clk, rst_n, whi, wlo, hi_i, lo_i, hi_o, lo_o);
	/*********************
	 *	HI / LO Register
	 *input:
	 *	clk								: clock
	 *	rst_n							: negetive reset signal
	 *	whi								: write hi register
	 *	wlo								: write lo register
	 *	hi_i[31:0]						: data which will write into hi
	 *	lo_i[31:0]						: data which will write into lo
	 *output:
	 *	hi_o[31:0]						: hi data
	 *	lo_o[31:0]						: lo data
	 *********************/
	input clk, rst_n;
	input whi, wlo;
	input [31:0] hi_i, lo_i;
	output [31:0] hi_o, lo_o;
	
	reg [31:0] hi, lo;
	
	assign hi_o = (!rst_n) ? 32'b0 : ((whi) ? hi_i : hi);
	assign lo_o = (!rst_n) ? 32'b0 : ((wlo) ? lo_i : lo);
	
	// write hi register
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			hi <= 32'b0;
			end
		else if(whi)
			begin
			hi <= hi_i;
			end
		end
	
	// write lo register
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			lo <= 32'b0;
			end
		else if(wlo)
			begin
			lo <= lo_i;
			end
		end
endmodule