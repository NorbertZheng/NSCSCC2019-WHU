module CacheLineDist(clk, rst_n, rtag, roff, rdata, rdirty, rvalid, we, wtag, woff, wdata, w_byte_enable, wdirty, wvalid);
	/*********************
	 *		MMU
	 *input:
	 *	clk							: clock
	 *	rst_n						: negetive reset signal
	 *	roff[OFFSET_WIDTH - 1:0]	: read word offset
	 *	we							: write cache signal
	 *	wtag[TAG_WIDTH - 1:0]		: write tag
	 *	woff[OFFSET_WIDTH - 1:0]	: write word offset
	 *	wdata[31:0]					: write data(bit width limited by AXI interface)
	 *	w_byte_enable[3:0]			: write data byte enable
	 *	wdirty						: write dirty
	 *	wvalid						: write valid
	 *output:
	 *	rtag[TAG_WIDTH - 1:0]		: read tag
	 *	rdata[31:0]					: read data
	 *	rdirty						: read dirty
	 *	rvalid						: read valid
	 *********************/
	parameter	CACHE_LINE_WIDTH 	= 	6,						// block max 64B = 4B * 16(limited by AXI interface arsize)
				TAG_WIDTH			=	20,
				OFFSET_WIDTH		= CACHE_LINE_WIDTH - 2;		// 1 block contains 16 words(4B)
	 
	input clk, rst_n;
	// write
	input we;
	input [TAG_WIDTH - 1:0]wtag;
	input [OFFSET_WIDTH - 1:0]woff;
	input wdirty, wvalid;
	input [3:0] w_byte_enable;
	input [31:0] wdata;
	// read
	input [OFFSET_WIDTH - 1:0] roff;
	output rdirty, rvalid;
	output [TAG_WIDTH - 1:0] rtag;
	output [31:0] rdata;
	
	reg [TAG_WIDTH - 1:0] tag;
	reg dirty;
	reg valid;
	wire [31:0] dout;
	
	// read data
	assign rtag = tag;
	assign rdata = valid ? dout : 32'b0;
	assign rdirty = valid ? dirty : 1'b0;
	assign rvalid = valid;
	
	// set valid, dirty, tag
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			dirty <= 1'b0;
			valid <= 1'b0;
			tag <= 0;
			end
		else if(we)
			begin
			dirty <= wdirty;
			valid <= wvalid;
			tag <= wtag;
			end
		end
	
	wire [OFFSET_WIDTH - 1:0] access_offset = we ? woff : roff;
	genvar i;
	generate
	// distributed_cacheline_data_mini
	for(i = 0;i < 4;i = i + 1)
		begin
		distributed_cacheline_data_mini m_distributed_cacheline_data_mini(
			.a(access_offset), 
			.d(wdata[i * 8 +: 8]), 
			.clk(clk), 
			.we(w_byte_enable[i] & we), 
			.spo(dout[i * 8 +: 8])
		);
		end
	endgenerate
endmodule