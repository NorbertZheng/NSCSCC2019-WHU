module TLBExcDetector(instMiss, dataMiss, instValid, dataValid, dataDirty, wmem, tlb_exc_type);
	/*********************
	 *		TLB Exception Detector
	 *input:
	 *	instMiss				: inst TLB miss
	 *	dataMiss				: data TLB miss
	 *	instValid				: inst TLB valid
	 *	dataValid				: data TLB valid
	 *	dataDirty				: data TLB dirty
	 *	wmem					: write mem signal
	 *output:
	 *	tlb_exc_type[31:0]		: tlb_exc_type
	 *********************/
	input instMiss, dataMiss, instValid, dataValid, dataDirty, wmem;
	output reg [31:0] tlb_exc_type;
	
	always@(*)
		begin
		tlb_exc_type = 32'b0;
		if(wmem == 1'b1 && dataValid == 1'b1 && dataDirty == 1'b0)
			begin
			tlb_exc_type[1] = 1'b1;
			end
		if(instMiss || ~instValid || (dataMiss && ~wmem) || (~dataValid && ~wmem))
			begin
			tlb_exc_type[2] = 1'b1;
			end
		if((dataMiss && wmem) || (~dataValid && wmem))
			begin
			tlb_exc_type[3] = 1'b1;
			end
		end
endmodule