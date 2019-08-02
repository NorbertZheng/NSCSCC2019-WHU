module PCReg(clk, rst_n, wpc, PC_i, PC_o);
	/*********************
	 *	32-bit Program Counter
	 *input:
	 *	clk					: clock
	 *	rst_n				: negetive reset signal
	 *	wpc					: write PC signal
	 *	PC_i[31:0]			: 32-bit new PC
	 *output:
	 *	PC_o[31:0]			: 32-bit PC output
	 *********************/
	input clk, rst_n;
	input wpc;
	// input minus4;
	input [31:0] PC_i;
	output reg [31:0] PC_o;
	
	always@(posedge clk)
		begin
		if(!rst_n)							// reset
			begin
			PC_o <= 32'hbfc00000;
			// PC_o <= 32'hbfaff000;
			end
		else if(wpc)
			begin
			PC_o <= PC_i;
			end
		/*else if(minus4)
			begin
			PC_o <= PC_o - 32'h4;
			end*/
		end
endmodule