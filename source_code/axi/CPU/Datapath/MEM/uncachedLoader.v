module uncachedLoader(
	input				clk								,
	input				rst_n							,
	input				AXI_Load_Bus_busy				,
	
	// AXI read channel signals
	output	reg			uncachedLoader_req				,
	input				uncachedLoader_grnt				,
	// read address channel signals
	output		[3 :0]	uncachedLoader_arid				,
	output		[31:0]	uncachedLoader_araddr			,
	output		[3 :0]	uncachedLoader_arlen			,
	output		[2 :0]	uncachedLoader_arsize			,
	output		[1 :0]	uncachedLoader_arburst			,
	output		[1 :0]	uncachedLoader_arlock			,
	output		[3 :0]	uncachedLoader_arcache			,
	output		[2 :0]	uncachedLoader_arprot 			,
	output	reg			uncachedLoader_arvalid 			,
	input				uncachedLoader_arready			,
	// read data channel signals           
	input 		[3 :0]	uncachedLoader_rid				,
	input 		[31:0] 	uncachedLoader_rdata			,
	input 		[1 :0]	uncachedLoader_rresp			,
	input				uncachedLoader_rlast			,
	input 				uncachedLoader_rvalid 			,
	output	reg			uncachedLoader_rready			,
	
	// CPU read 
	input				uncachedLoader_cpu_uncached		,
	input				uncachedLoader_cpu_re			,
	input		[31:0]	uncachedLoader_cpu_addr			,
	output		[31:0]	uncachedLoader_cpu_rdata		,
	output				uncachedLoader_cpu_Stall		,
	output				uncachedLoader_cpu_PC_Stall		
);
	parameter	uncachedLoader_IDLE				=	3'd0	,
				// uncachedLoader_MemReadWaitPre	=	3'd1	,
				uncachedLoader_MemReadWait		=	3'd2	,
				uncachedLoader_MemReadWaitLast	=	3'd3	,
				uncachedLoader_MemReadWaitNow	=	3'd4	,
				uncachedLoader_MemRead			=	3'd5	,
				uncachedLoader_Delay			=	3'd6	;
				
	wire need_read = (
		(uncachedLoader_cpu_uncached == 1'b1) &&	// is uncached data access
		(uncachedLoader_cpu_re == 1'b1)				// also is loading data
	);
	
	reg [2:0] state;
	reg [2:0] pre_state;
	wire busy = AXI_Load_Bus_busy && (uncachedLoader_req == 1'b0 || uncachedLoader_grnt == 1'b0);
	assign uncachedLoader_cpu_Stall = ~(
		((state == uncachedLoader_IDLE) && ~(need_read && ~busy)) ||
		// (state == uncachedLoader_Delay)
		((state == uncachedLoader_IDLE) && (pre_state == uncachedLoader_Delay))
	);
	
	assign uncachedLoader_cpu_PC_Stall = uncachedLoader_cpu_Stall;/*~(
		(state == uncachedLoader_IDLE) ||
		(state == uncachedLoader_Delay)
	);*/
	
	assign uncachedLoader_arid = 4'b0010;
	assign uncachedLoader_araddr = {uncachedLoader_cpu_addr[31:2], 2'b0};
	assign uncachedLoader_arlen = 4'b0000;
	assign uncachedLoader_arsize = 3'b010;
	assign uncachedLoader_arburst = 2'b00;
	assign uncachedLoader_arlock = 2'b00;
	assign uncachedLoader_arcache = 4'b0000;
	assign uncachedLoader_arprot = 3'b000;
	
	reg [31:0] uncachedLoader_cpu_rdata_reg;
	assign uncachedLoader_cpu_rdata = uncachedLoader_cpu_rdata_reg;
	
	always@(posedge clk)
		begin
		# 1;
		$display("uncachedLoader state: 0x%1h, uncachedLoader_cpu_Stall: 0b%1b, uncachedLoader_cpu_rdata: 0x%8h, uncachedLoader_rdata: 0x%8h"
				, state, uncachedLoader_cpu_Stall, uncachedLoader_cpu_rdata, uncachedLoader_rdata);
		end
	
	reg [1:0] cnt;
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			pre_state <= uncachedLoader_IDLE;
			state <= uncachedLoader_IDLE;
			// temp save rdata reg
			uncachedLoader_cpu_rdata_reg <= 32'b0;
			// outputs
			uncachedLoader_req <= 1'b0;
			uncachedLoader_arvalid <= 1'b0;
			uncachedLoader_rready <= 1'b0;
			cnt <= 2'b0;
			end
		else
			begin
			pre_state <= state;
			case(state)
				uncachedLoader_IDLE:
					begin
					if(AXI_Load_Bus_busy == 1'b1)
						begin
						state <= uncachedLoader_IDLE;
						// set to 0
						uncachedLoader_req <= 1'b0;
						uncachedLoader_arvalid <= 1'b0;
						uncachedLoader_rready <= 1'b0;
						// uncachedLoader_cpu_rdata_reg <= 32'b0;
						end
					else if(need_read && pre_state != uncachedLoader_Delay)
						begin
						state <= uncachedLoader_MemReadWait;		// state <= uncachedLoader_MemReadWaitPre;
						uncachedLoader_req <= 1'b1;
						// set to 0
						uncachedLoader_arvalid <= 1'b0;
						uncachedLoader_rready <= 1'b0;
						// uncachedLoader_cpu_rdata_reg <= 32'b0;
						end
					else
						begin
						state <= uncachedLoader_IDLE;
						// set to 0
						uncachedLoader_req <= 1'b0;
						uncachedLoader_arvalid <= 1'b0;
						uncachedLoader_rready <= 1'b0;
						// uncachedLoader_cpu_rdata_reg <= 32'b0;
						end
					end
				/*uncachedLoader_MemReadWaitPre:
					begin
					state <= uncachedLoader_MemReadWait;
					end*/
				uncachedLoader_MemReadWait:
					begin
					cnt <= 2'b0;
					uncachedLoader_cpu_rdata_reg <= 32'b0;
					if(uncachedLoader_grnt)
						begin
						if(uncachedLoader_arready == 1'b1)
							begin
							state <= uncachedLoader_MemReadWaitLast;
							end
						else
							begin
							state <= uncachedLoader_MemReadWaitNow;
							end
						end
					else
						begin
						// do nothing
						end
					end
				uncachedLoader_MemReadWaitLast:
					begin
					uncachedLoader_arvalid <= 1'b1;
					if(uncachedLoader_arready)// && (uncachedLoader_rid == 4'b0010))
						begin
						state <= uncachedLoader_MemRead;
						// uncachedLoader_arvalid <= 1'b0;
						uncachedLoader_rready <= 1'b0;	// uncachedLoader_rready <= 1'b1;
						end
					end
				uncachedLoader_MemReadWaitNow:
					begin
					if(uncachedLoader_arready)// && (uncachedLoader_rid == 4'b0010))
						begin
						state <= uncachedLoader_MemRead;
						uncachedLoader_arvalid <= 1'b0;
						uncachedLoader_rready <= 1'b0;	// uncachedLoader_rready <= 1'b1;
						end
					else
						begin
						uncachedLoader_arvalid <= 1'b1;
						end
					end
				uncachedLoader_MemRead:
					begin
					if(uncachedLoader_rvalid && (uncachedLoader_rid == 4'b0010))
						begin
						uncachedLoader_arvalid <= 1'b0;
						if(cnt == 2'b00)
							begin
							uncachedLoader_cpu_rdata_reg <= uncachedLoader_rdata;
							state <= uncachedLoader_Delay;		// state <= uncachedLoader_IDLE;
							uncachedLoader_rready <= 1'b1;
							end
						else
							begin
							cnt <= cnt + 1'b1;
							end
						end
					else
						begin
						uncachedLoader_arvalid <= 1'b0;
						end
					end
				uncachedLoader_Delay:
					begin
					state <= uncachedLoader_IDLE;
					// set to 0
					uncachedLoader_req <= 1'b0;
					uncachedLoader_arvalid <= 1'b0;
					uncachedLoader_rready <= 1'b0;
					cnt <= 2'b0;
					// uncachedLoader_cpu_rdata_reg <= 32'b0;
					end
				default:
					begin
					state <= uncachedLoader_IDLE;
					// temp save rdata reg
					uncachedLoader_cpu_rdata_reg <= 32'b0;
					// outputs
					uncachedLoader_req <= 1'b0;
					uncachedLoader_arvalid <= 1'b0;
					uncachedLoader_rready <= 1'b0;
					end
			endcase
			end
		end
endmodule