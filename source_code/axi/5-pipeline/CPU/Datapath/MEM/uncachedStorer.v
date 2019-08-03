module uncachedStorer(
	input				clk								,
	input				rst_n							,
	
	// AXI read channel signals
	output	reg			uncachedStorer_req				,
	input				uncachedStorer_grnt				,
	// AXI write channel signals
	// write address channel signals       
	output 		[3 :0]	uncachedStorer_awid				,
	output 		[31:0]	uncachedStorer_awaddr			,
	output		[3 :0]	uncachedStorer_awlen			,
	output		[2 :0]	uncachedStorer_awsize			,
	output		[1 :0]	uncachedStorer_awburst			,
	output		[1 :0]	uncachedStorer_awlock			,
	output		[3 :0]	uncachedStorer_awcache			,
	output		[2 :0]	uncachedStorer_awprot			,
	output	reg			uncachedStorer_awvalid			,
	input 				uncachedStorer_awready			,
	// write data channel signals
	output		[3 :0]	uncachedStorer_wid				,
	output		[31:0]	uncachedStorer_wdata			,
	output		[3 :0]	uncachedStorer_wstrb			,
	output	reg			uncachedStorer_wlast			,
	output	reg			uncachedStorer_wvalid			,
	input				uncachedStorer_wready			,
	// write response channel signals
	input		[3 :0]	uncachedStorer_bid				,
	input 		[1 :0]	uncachedStorer_bresp			,
	input				uncachedStorer_bvalid			,
	output				uncachedStorer_bready			,
	
	// CPU read
	input				uncachedStorer_cpu_uncached		,
	input				uncachedStorer_cpu_we			,
	input		[31:0]	uncachedStorer_cpu_addr			,
	input		[3 :0]	uncachedStorer_cpu_byte_enable	,
	input		[31:0]	uncachedStorer_cpu_wdata		,
	output				uncachedStorer_cpu_Stall		,
	output				uncachedStorer_cpu_PC_Stall		
);
	parameter	uncachedStorer_IDLE					=	3'd0	,
				// uncachedStorer_WriteBackWaitPre		=	3'd1	,
				uncachedStorer_WriteBackWait		=	3'd2	,
				uncachedStorer_WriteBackWaitLast	=	3'd3	,
				uncachedStorer_WriteBackWaitNow		=	3'd4	,
				uncachedStorer_WriteBack			=	3'd5	,
				uncachedStorer_Delay				=	3'd6	;
	
	wire need_writeback = (
		(uncachedStorer_cpu_uncached == 1'b1) &&
		(uncachedStorer_cpu_we == 1'b1)
	);
	
	reg [2:0] state;
	reg [2:0] pre_state;
	assign uncachedStorer_cpu_Stall = ~(
		(state == uncachedStorer_IDLE) && ~(need_writeback) || // && (pre_state != uncachedStorer_Delay)// || 
		(state == uncachedStorer_Delay)
		// (state == uncachedStorer_WriteBackWaitPre)
	);
	assign uncachedStorer_cpu_PC_Stall = uncachedStorer_cpu_Stall;/*~(
		(state == uncachedStorer_IDLE)// || 
		//(state == uncachedStorer_Delay)
	);*/
	
	assign uncachedStorer_awid = 4'b0010;
	assign uncachedStorer_awaddr = {uncachedStorer_cpu_addr[31:2], 2'b0};
	assign uncachedStorer_awlen = 4'b0000;
	assign uncachedStorer_awsize = 3'b010;
	assign uncachedStorer_awburst = 2'b00;
	assign uncachedStorer_awlock = 2'b00;
	assign uncachedStorer_awcache = 4'b0000;
	assign uncachedStorer_awprot = 3'b000;
	assign uncachedStorer_wid = 4'b0010;
	assign uncachedStorer_wdata = uncachedStorer_cpu_wdata;
	assign uncachedStorer_wstrb = uncachedStorer_cpu_byte_enable;
	assign uncachedStorer_bready = 1'b1;
	
	/*always@(posedge clk)
		begin
		# 1;
		$display("uncachedStorer state: 0x%1h, uncachedStorer_cpu_Stall: 0b%1b, uncachedStorer_wdata: 0x%8h, uncachedStorer_awaddr: 0x%8h"
				, state, uncachedStorer_cpu_Stall, uncachedStorer_wdata, uncachedStorer_awaddr);
		end*/
	
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			state <= uncachedStorer_IDLE;
			pre_state <= uncachedStorer_IDLE;
			// outputs
			uncachedStorer_req <= 1'b0;
			uncachedStorer_awvalid <= 1'b0;
			uncachedStorer_wlast <= 1'b0;
			uncachedStorer_wvalid <= 1'b0;
			end
		else
			begin
			pre_state <= state;
			case(state)
				uncachedStorer_IDLE:
					begin
					if(need_writeback)
						begin
						state <= uncachedStorer_WriteBackWait;		//state <= uncachedStorer_WriteBackWaitPre;
						uncachedStorer_req <= 1'b1;
						// set to 0
						uncachedStorer_awvalid <= 1'b0;
						uncachedStorer_wlast <= 1'b0;
						uncachedStorer_wvalid <= 1'b0;
						end
					else
						begin
						state <= uncachedStorer_IDLE;
						// set to 0
						uncachedStorer_req <= 1'b0;
						uncachedStorer_awvalid <= 1'b0;
						uncachedStorer_wlast <= 1'b0;
						uncachedStorer_wvalid <= 1'b0;
						end
					end
				/*uncachedStorer_WriteBackWaitPre:
					begin
					state <= uncachedStorer_WriteBackWait;
					end*/
				uncachedStorer_WriteBackWait:
					begin
					if(uncachedStorer_grnt)
						begin
						if(uncachedStorer_awready == 1'b1)
							begin
							state <= uncachedStorer_WriteBackWaitLast;
							end
						else
							begin
							state <= uncachedStorer_WriteBackWaitNow;
							end
						end
					else
						begin
						// do nothing
						end
					end
				uncachedStorer_WriteBackWaitLast:
					begin
					uncachedStorer_awvalid <= 1'b1;
					if(uncachedStorer_awready)
						begin
						state <= uncachedStorer_WriteBack;
						uncachedStorer_wlast <= 1'b1;
						uncachedStorer_wvalid <= 1'b1;
						end
					else
						begin
						// do nothing
						end
					end
				uncachedStorer_WriteBackWaitNow:
					begin
					if(uncachedStorer_awready)
						begin
						state <= uncachedStorer_WriteBack;
						uncachedStorer_wlast <= 1'b1;
						uncachedStorer_wvalid <= 1'b1;
						uncachedStorer_awvalid <= 1'b0;
						end
					else
						begin
						uncachedStorer_awvalid <= 1'b1;
						end
					end
				uncachedStorer_WriteBack:
					begin
					if(uncachedStorer_wready && (uncachedStorer_wid == 4'b0010))
						begin
						state <= uncachedStorer_Delay;
						uncachedStorer_awvalid <= 1'b0;
						uncachedStorer_wvalid <= 1'b0;
						uncachedStorer_wlast <= 1'b0;
						end
					else
						begin
						uncachedStorer_awvalid <= 1'b0;
						end
					end
				uncachedStorer_Delay:
					begin
					state <= uncachedStorer_IDLE;
					// set to 0
					uncachedStorer_req <= 1'b0;
					uncachedStorer_awvalid <= 1'b0;
					uncachedStorer_wlast <= 1'b0;
					uncachedStorer_wvalid <= 1'b0;
					end
				default:
					begin
					state <= uncachedStorer_IDLE;
					// outputs
					uncachedStorer_req <= 1'b0;
					uncachedStorer_awvalid <= 1'b0;
					uncachedStorer_wlast <= 1'b0;
					uncachedStorer_wvalid <= 1'b0;
					end
			endcase
			end
		end
endmodule