module Registers(clk, rst_n, RegWrite, Read_register1, Read_register2, Write_register, Write_data, Read_data1, Read_data2);
	parameter width = 32, AddrWidth = 5, num = 32;
	/*********************
	 *	width-bit DFF with stall and flush signal
	 *input:
	 *	clk								: clock
	 *	rst_n							: negetive reset signal
	 *	RegWrite						: write register file
	 *	Read_register1[AddrWidth - 1:0]	: register1 no to read
	 *	Read_register2[AddrWidth - 1:0]	: register2 no to read
	 *	Write_register[AddrWidth - 1:0]	: register no to write
	 *	Write_data[width - 1:0]			: width-bit data to write into Write_register
	 *output:
	 *	Read_data1[width - 1:0]			: width-bit data read from Read_register1
	 *	Read_data2[width - 1:0]			: width-bit data read from Read_register2
	 *********************/
	input clk;
	input rst_n;
	input RegWrite;
	input [AddrWidth - 1:0] Read_register1;
	input [AddrWidth - 1:0] Read_register2;
	input [AddrWidth - 1:0] Write_register;
	input [width - 1:0] Write_data;
	output reg [width - 1:0] Read_data1;
	output reg [width - 1:0] Read_data2;
	
	reg [width - 1:0] registers[num - 1:0];
	integer i;
	
	// Read_register1
	always@(*)
		begin
		if(!rst_n)
			begin
			Read_data1 = {width{1'b0}};
			end
		else if(Read_register1 == 5'b0)
			begin
			Read_data1 = {width{1'b0}};
			end
		else if((Read_register1 == Write_register) && RegWrite)
			begin
			Read_data1 = Write_data;
			end
		else
			begin
			Read_data1 = registers[Read_register1];
			end
		end
		
	// Read_register2
	always@(*)
		begin
		if(!rst_n)
			begin
			Read_data2 = {width{1'b0}};
			end
		else if(Read_register2 == 5'b0)
			begin
			Read_data2 = {width{1'b0}};
			end
		else if((Read_register2 == Write_register) && RegWrite)
			begin
			Read_data2 = Write_data;
			end
		else
			begin
			Read_data2 = registers[Read_register1];
			end
		end	
	
	// Write_register
	always@(posedge clk or negedge rst_n)
		begin
		if(!rst_n)
			begin
			for(i = 0;i < num;i = i + 1)
				registers[i] <= 0;
			registers[28] <= 32'h00001800;
			registers[29] <= 32'h00002ffe;
			end
		else if(RegWrite)
			begin
			registers[Write_register] <= (Write_register != 0) ? Write_data : 0;
			$display("R[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", 0, registers[1], registers[2], registers[3], registers[4], registers[5], registers[6], registers[7]);
			$display("R[08-15]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", registers[8], registers[9], registers[10], registers[11], registers[12], registers[13], registers[14], registers[15]);
			$display("R[16-23]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", registers[16], registers[17], registers[18], registers[19], registers[20], registers[21], registers[22], registers[23]);
			$display("R[24-31]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", registers[24], registers[25], registers[26], registers[27], registers[28], registers[29], registers[30], registers[31]);
			$display("Registers  %x  %x", Write_register, Write_data);
			end
		end
endmodule