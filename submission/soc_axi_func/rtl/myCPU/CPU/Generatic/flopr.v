module flopr(clk, rst_n, stall, flush, data_i, data_o);
	parameter width = 32;
	/*********************
	 *	width-bit DFF with stall and flush signal
	 *input:
	 *	clk					: clock
	 *	rst_n				: negetive reset signal
	 *	stall				: stall signal
	 *	flush				: flush signal
	 *	data_i[width - 1:0]	: data input
	 *output:
	 *	data_o[width - 1:0]	: data output
	 *********************/
	input clk, rst_n;
	input stall, flush;
	input [width - 1:0] data_i;
	output reg [width - 1:0] data_o;
	
	always@(posedge clk or negedge rst_n)
		begin
		if(!rst_n)							// reset
			begin
			data_o <= {width{1'b0}};
			end
		else if(!stall)						// this pipeline stage is not stalled
			begin
			if(flush)						// this pipeline stage is flushed
				begin
				data_o <= {width{1'b0}};
				end
			else							// this pipeline stage is permitted to accept value
				begin
				data_o <= data_i;
				end
			end
		end
endmodule