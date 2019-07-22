module memoryMap(addr_i, enable, user_mode, kseg0_uncached, addr_o, access_invalid, using_tlb, uncached);
	/*********************
	 *		Memory Map
	 *input:
	 *	addr_i[31:0]		: virtual address
	 *	enable				: map enable signal
	 *	user_mode			: 1 -> user, 0 -> kernel
	 *	kseg0_uncached		: kseg0_uncached signal from COP0_Config[2:0]
	 *output:
	 *	addr_o[31:0]		: direct-mapped physical address
	 *	access_invalid		: access_invalid = (enable & user_mode & addr_i[31]);
	 *	using_tlb			: use tlb signal
	 *	uncached			: identity whether this block memory is cached
	 *********************/
	input enable, user_mode, kseg0_uncached;
	input [31:0] addr_i;
	output access_invalid;
	output reg using_tlb, uncached;
	output reg [31:0] addr_o;
	
	parameter WITH_TLB = 1;
	
	assign access_invalid = (enable & user_mode & addr_i[31]);
	
	always@(*)
		begin
		using_tlb = 1'b0;
		uncached = 1'b0;
		addr_o = 32'b0;
		if(enable)
			begin
			case(addr_i[31:29])
				3'b000,
				3'b001,
				3'b010,
				3'b011,		// kuseg
				3'b110,		// kseg2
				3'b111:		// kseg3
					begin
					if(WITH_TLB)
						begin
						using_tlb = 1'b1;
						end
					else
						begin
						addr_o = addr_i;
						end
					end
				3'b100:		// kseg0
					begin
					uncached = kseg0_uncached;
					addr_o = {3'b0, addr_i[28:0]};
					end
				3'b101:		// kseg1
					begin
					uncached = 1'b1;
					addr_o = {3'b0, addr_i[28:0]};
					end
			endcase
			end
		end
endmodule