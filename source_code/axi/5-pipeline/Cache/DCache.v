module DCache(
	input				clk						,
	input				rst_n					,
	
	// AXI read channel signals
	input				DCache_grnt				,
	output	reg			DCache_req				,
	// read address channel signals
	output		[3 :0]	DCache_arid				,
	output		[31:0]	DCache_araddr			,
	output		[3 :0]	DCache_arlen			,
	output		[2 :0]	DCache_arsize			,
	output		[1 :0]	DCache_arburst			,
	output		[1 :0]	DCache_arlock			,
	output		[3 :0]	DCache_arcache			,
	output		[2 :0]	DCache_arprot 			,
	output	reg			DCache_arvalid 			,
	input				DCache_arready			,
	// read data channel signals           
	input 		[3 :0]	DCache_rid				,
	input 		[31:0] 	DCache_rdata			,
	input 		[1 :0]	DCache_rresp			,
	input				DCache_rlast			,
	input 				DCache_rvalid 			,
	output	reg			DCache_rready			,
	// AXI write channel signals
	input				DCache_write_grnt		,
	output	reg			DCache_write_req		,
	// write address channel signals       
	output 		[3 :0]	DCache_awid				,
	output 		[31:0]	DCache_awaddr			,
	output		[3 :0]	DCache_awlen			,
	output		[2 :0]	DCache_awsize			,
	output		[1 :0]	DCache_awburst			,
	output		[1 :0]	DCache_awlock			,
	output		[3 :0]	DCache_awcache			,
	output		[2 :0]	DCache_awprot			,
	output	reg			DCache_awvalid			,
	input 				DCache_awready			,
	// write data channel signals
	output		[3 :0]	DCache_wid				,
	output		[31:0]	DCache_wdata			,
	output		[3 :0]	DCache_wstrb			,
	output	reg			DCache_wlast			,
	output	reg			DCache_wvalid			,
	input				DCache_wready			,
	// write response channel signals
	input		[3 :0]	DCache_bid				,
	input 		[1 :0]	DCache_bresp			,
	input				DCache_bvalid			,
	output				DCache_bready			,
	
	// CPU read 
	input				DCache_cpu_uncached		,
	input				DCache_cpu_re			,
	input				DCache_cpu_we			,
	input		[31:0]	DCache_cpu_addr			,
	input		[3 :0]	DCache_cpu_byte_enable	,
	input		[31:0]	DCache_cpu_wdata		,
	output		[31:0]	DCache_cpu_rdata		,
	output				DCache_cpu_Stall		,
	output				DCache_IF_Stall			,
	output				DCache_State_Hit		
);
	parameter	CACHE_LINE_WIDTH		=	6,
				TAG_WIDTH				=	19,
				INDEX_WIDTH				=	32 - CACHE_LINE_WIDTH - TAG_WIDTH,
				NUM_CACHE_LINES			=	2 ** INDEX_WIDTH,
				OFFSET_WIDTH			=	CACHE_LINE_WIDTH - 2;
	parameter	DCache_IDLE				=	4'd0,
				DCache_Hit				=	4'd1,
				DCache_CheckDirty		=	4'd2,
				DCache_MemReadWait		=	4'd3,
				DCache_MemReadWaitLast	=	4'd4,
				DCache_MemReadWaitNow	=	4'd5,
				DCache_MemReadFirst		=	4'd6,
				DCache_MemRead			=	4'd7,
				DCache_WriteBackWait	=	4'd8,
				DCache_WriteBackWaitLast=	4'd9,
				DCache_WriteBackWaitNow	=	4'd10,
				DCache_WriteBackFirst	=	4'd11,
				DCache_WriteBack		=	4'd12,
				DCache_WaitWrFinish		=	4'd13,
				DCache_MemReadExc		=	4'd14;
	
	// wires to CacheLines0
	wire [TAG_WIDTH - 1:0] rtag0[NUM_CACHE_LINES - 1:0];
	wire [31:0] rdata0[NUM_CACHE_LINES - 1:0];
	wire rdirty0[NUM_CACHE_LINES - 1:0];
	wire rvalid0[NUM_CACHE_LINES - 1:0];
	wire we0[NUM_CACHE_LINES - 1:0];
	
	// wires to CacheLines1
	// use tag to judge which rdata, use we to judge which 
	wire [TAG_WIDTH - 1:0] rtag1[NUM_CACHE_LINES - 1:0];
	wire [31:0] rdata1[NUM_CACHE_LINES - 1:0];
	wire rdirty1[NUM_CACHE_LINES - 1:0];
	wire rvalid1[NUM_CACHE_LINES - 1:0];
	wire we1[NUM_CACHE_LINES - 1:0];
	
	// common signals
	wire [OFFSET_WIDTH - 1:0] roff;
	reg [TAG_WIDTH - 1:0] wtag;
	reg [OFFSET_WIDTH - 1:0] woff;
	reg [31:0] wdata;
	reg [3:0] w_byte_enable;
	reg wdirty;
	reg wvalid;
	
	// 2-way DCache
	reg [NUM_CACHE_LINES - 1:0] LRU;		// record recent access which way 0 / 1
	genvar i;
	generate
	// CacheLines0
	for(i = 0;i < NUM_CACHE_LINES;i = i + 1)
		begin
		CacheLineDist #(
			.CACHE_LINE_WIDTH (CACHE_LINE_WIDTH),
			.TAG_WIDTH        (TAG_WIDTH)
		) m_CacheLines0 (
			.clk(clk), 
			.rst_n(rst_n), 
			.rtag(rtag0[i]), 
			.roff(roff), 
			.rdata(rdata0[i]), 
			.rdirty(rdirty0[i]), 
			.rvalid(rvalid0[i]), 
			.we(we0[i]), 
			.wtag(wtag), 
			.woff(woff), 
			.wdata(wdata), 
			.w_byte_enable(w_byte_enable), 
			.wdirty(wdirty), 
			.wvalid(wvalid)
		);
		end
	// CacheLines1
	for(i = 0;i < NUM_CACHE_LINES;i = i + 1)
		begin
		CacheLineDist #(
			.CACHE_LINE_WIDTH (CACHE_LINE_WIDTH),
			.TAG_WIDTH        (TAG_WIDTH)
		) m_CacheLines1 (
			.clk(clk), 
			.rst_n(rst_n), 
			.rtag(rtag1[i]), 
			.roff(roff), 
			.rdata(rdata1[i]), 
			.rdirty(rdirty1[i]), 
			.rvalid(rvalid1[i]), 
			.we(we1[i]), 
			.wtag(wtag), 
			.woff(woff), 
			.wdata(wdata), 
			.w_byte_enable(w_byte_enable), 
			.wdirty(wdirty), 
			.wvalid(wvalid)
		);
		end
	endgenerate
	
	reg [3:0] state;
	reg [3:0] pre_state;
	// Cache access tag, index, offset, byteoffset
	wire [TAG_WIDTH - 1:0] DCache_addr_tag;
	wire [INDEX_WIDTH - 1:0] DCache_addr_index;
	wire [OFFSET_WIDTH - 1:0] DCache_addr_offset;
	wire [1:0] DCache_addr_byteoffset;
	assign {DCache_addr_tag, DCache_addr_index, DCache_addr_offset, DCache_addr_byteoffset} = DCache_cpu_addr;
	reg [31:0] DCache_cpu_addr_pre;
	wire [TAG_WIDTH - 1:0] DCache_addr_pre_tag;
	wire [INDEX_WIDTH - 1:0] DCache_addr_pre_index;
	wire [OFFSET_WIDTH - 1:0] DCache_addr_pre_offset;
	wire [1:0] DCache_addr_pre_byteoffset;
	assign {DCache_addr_pre_tag, DCache_addr_pre_index, DCache_addr_pre_offset, DCache_addr_pre_byteoffset} = DCache_cpu_addr_pre;
	
	// MEM / DCacheLine Traverse offset
	reg [TAG_WIDTH - 1:0] Mem_access_tag;
	reg [OFFSET_WIDTH - 1:0] Mem_access_offset;
	reg [OFFSET_WIDTH - 1:0] DCache_access_offset;
	
	// for DCache_access_offset, next period will get the rdata
	assign roff = (state == DCache_IDLE) ? DCache_addr_offset : DCache_access_offset;
	wire [OFFSET_WIDTH - 1:0] DCache_addr_offset_end = 0 - 1;
	
	// Status
	wire CacheLines0_valid = rvalid0[DCache_addr_index];
	wire CacheLines0_dirty = rdirty0[DCache_addr_index];
	wire [TAG_WIDTH-1:0] CacheLines0_tag = rtag0[DCache_addr_index];
	wire CacheLines0_hit = (CacheLines0_tag == DCache_addr_tag);
	wire [31:0] CacheLines0_rdata = rdata0[DCache_addr_pre_index];
	wire CacheLines1_valid = rvalid1[DCache_addr_index];
	wire CacheLines1_dirty = rdirty1[DCache_addr_index];
	wire [TAG_WIDTH-1:0] CacheLines1_tag = rtag1[DCache_addr_index];
	wire CacheLines1_hit = (CacheLines1_tag == DCache_addr_tag);
	wire [31:0] CacheLines1_rdata = rdata1[DCache_addr_pre_index];		// get last period roff read data
	
	// cache write control signals
	reg cache_we;
	reg cache_replace;
	reg [INDEX_WIDTH - 1:0] cache_windex;
	generate
	for(i = 0; i < NUM_CACHE_LINES; i = i + 1)
		begin
		// 						   (replace block	0 - old	   old && on replacing		)	(not replace block, check hit && refresh)
		assign we0[i] = cache_we ? (cache_replace ? (LRU[i] ? (i == cache_windex) : 1'b0) : (i == DCache_addr_index && CacheLines0_hit)) : 1'b0;
		// 						   (replace block	1 - old	   old && on replacing		)	(not replace block, check hit && refresh)
		assign we1[i] = cache_we ? (cache_replace ? (~LRU[i] ? (i == cache_windex) : 1'b0) : (i == DCache_addr_index && CacheLines1_hit)) : 1'b0;
		// we set Cache's clk is ~CPU'clk, so once we find Hit then we can write cache or read cache before the pipeline reg move
		// additionally, when we read / write cache(Hit first), we will stall the pipeline reg before EXE_MEM(including) and flush
		// MEM_WB pipeline reg for 1 cycle!
		end
	endgenerate
	
	// AXI static signals
	assign DCache_arid = 4'b0001;
	assign DCache_araddr = {Mem_access_tag, DCache_addr_index, Mem_access_offset, 2'b00};
	assign DCache_arlen = 4'b1111;
	assign DCache_arsize = 3'b010;
	assign DCache_arburst = 2'b01;		// ?
	assign DCache_arlock = 2'b00;		// single CPU, no need for lock
	assign DCache_arcache = 4'b0000;
	assign DCache_arprot = 3'b000;
	assign DCache_awid = 4'b0001;
	assign DCache_awaddr = {Mem_access_tag, DCache_addr_index, Mem_access_offset, 2'b00};
	assign DCache_awlen = 4'b1111;
	assign DCache_awsize = 3'b010;
	assign DCache_awburst = 2'b01;		// ?
	assign DCache_awlock = 2'b00;
	assign DCache_awcache = 4'b00;
	assign DCache_awprot = 3'b000;
	assign DCache_wid = 4'b0001;
	assign DCache_wstrb = 4'b1111;		// all gating
	assign DCache_bready = 1'b1;		// about write response channel signals, all ignore
	
	// DCache_wdata_prefetch
	reg [31:0] DCache_wdata_prefetch;
	reg DCache_wdata_fetched;
	wire DCache_wdata_Stall = DCache_wdata_fetched & ~DCache_wready;		// unconfirm transfer
	assign DCache_wdata = DCache_wdata_Stall ? DCache_wdata_prefetch : (LRU[cache_windex] ? CacheLines0_rdata : CacheLines1_rdata);
	
	// 						0 - old, 					check 0 D & V
	wire need_writeback = LRU[DCache_addr_index] ? (CacheLines0_dirty && CacheLines0_valid && 
													((DCache_cpu_re && ~(CacheLines0_hit || CacheLines1_hit)) ||		// read
													 (DCache_cpu_we && ~(CacheLines0_hit || CacheLines1_hit))))	:		// write
	//													check 1 D & V
												   (CacheLines1_dirty && CacheLines1_valid && 
													((DCache_cpu_re && ~(CacheLines0_hit || CacheLines1_hit)) ||		// read
													 (DCache_cpu_we && ~(CacheLines0_hit || CacheLines1_hit))));		// write
	wire need_memread = (
		(DCache_cpu_re && (~CacheLines0_hit || ~CacheLines0_valid) && (~CacheLines1_hit || ~CacheLines1_valid)) ||		// read
		(DCache_cpu_we && (~CacheLines0_hit || ~CacheLines0_valid) && (~CacheLines1_hit || ~CacheLines1_valid))
	);
	assign DCache_cpu_Stall = ~(											// Here is a ~
		// (state == DCache_Hit) ||											// Hit! read / write data
		(state == DCache_IDLE && ~(need_memread || need_writeback)) || //&& (pre_state == DCache_IDLE || pre_state == DCache_Hit))		// IDLE! and will not change into other state soon
		(state == DCache_IDLE && DCache_cpu_uncached)
	);
	assign DCache_IF_Stall = ~(
		(state == DCache_IDLE || state == DCache_Hit)
	);
	assign DCache_State_Hit = (pre_state == DCache_Hit);
	// already wait for 1 cycle
	assign DCache_cpu_rdata = CacheLines0_hit ? CacheLines0_rdata : (CacheLines1_hit ? CacheLines1_rdata : 32'b0);
	
	/*always@(posedge clk)
		begin
		# 1;
		$display("DCache-> CacheLines0_rdata: 0x%8h, CacheLines1_rdata: 0x%8h", CacheLines0_rdata, CacheLines1_rdata);
		$display("DCache state: 0x%1h, DCache_cpu_Stall: 0b%1b, DCache_cpu_rdata: 0x%8h, DCache_cpu_uncached"
				, state, DCache_cpu_Stall, DCache_cpu_rdata, DCache_cpu_uncached);
		end*/
	
	reg flag;
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			// reset LRU
			LRU <= 0;
			// cache replace / write select
			cache_we <= 1'b0;
			cache_replace <= 1'b0;
			cache_windex <= 0;
			// addr save for 1 cycle delay read / write 
			DCache_cpu_addr_pre <= 32'b0;
			// mem access
			Mem_access_tag <= 0;
			Mem_access_offset <= 0;
			// cache access
			DCache_access_offset <= 0;
			// state
			state <= DCache_IDLE;
			// write cache data
			wtag <= 0;
			woff <= 0;
			wdata <= 32'b0;
			w_byte_enable <= 4'b0;
			wdirty <= 1'b0;
			wvalid <= 1'b0;
			// DCache_wdata prefetch
			DCache_wdata_prefetch <= 32'b0;
			DCache_wdata_fetched <= 1'b0;
			// outputs
			DCache_req <= 1'b0;
			DCache_arvalid <= 1'b0;
			DCache_rready <= 1'b0;
			DCache_write_req <= 1'b0;
			DCache_awvalid <= 1'b0;
			DCache_wlast <= 1'b0;
			DCache_wvalid <= 1'b0;
			pre_state <= DCache_IDLE;
			end
		else
			begin
			pre_state <= state;
			DCache_cpu_addr_pre <= DCache_cpu_addr;
			case(state)
				DCache_IDLE:
					begin
					if(DCache_cpu_uncached)
						begin
						DCache_access_offset <= 0;
						state <= DCache_IDLE;
						cache_we <= 1'b0;
						wtag <= 0;
						woff <= 0;
						wdata <= 32'b0;
						w_byte_enable <= 4'b0000;
						wdirty <= 1'b0;
						wvalid <= 1'b0;
						cache_windex <= 0;
						cache_replace <= 1'b0;
						Mem_access_tag <= 0;
						Mem_access_offset <= 0;
						DCache_req <= 1'b0;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b0;
						DCache_write_req <= 1'b0;
						DCache_awvalid <= 1'b0;
						DCache_wlast <= 1'b0;
						DCache_wvalid <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_wdata_fetched <= 1'b0;
						end
					else if(need_writeback)
						begin
						state <= DCache_WriteBackWait;
						Mem_access_tag <= LRU[DCache_addr_index] ? CacheLines0_tag : CacheLines1_tag;
						DCache_access_offset <= 0;
						Mem_access_offset <= 0;
						DCache_awvalid <= 1'b1;
						cache_windex <= DCache_addr_index;
						DCache_write_req <= 1'b1;
						// set to 0
						cache_we <= 1'b0;
						cache_replace <= 1'b0;
						wtag <= 0;
						woff <= 0;
						wdata <= 32'b0;
						w_byte_enable <= 4'b0;
						wdirty <= 1'b0;
						wvalid <= 1'b0;
						DCache_req <= 1'b0;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b0;
						DCache_wlast <= 1'b0;
						DCache_wvalid <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_wdata_fetched <= 1'b0;
						end
					else if(need_memread)
						begin
						state <= DCache_MemReadWait;
						DCache_access_offset <= 0;
						Mem_access_tag <= DCache_addr_tag;
						Mem_access_offset <= 0;
						DCache_req <= 1'b1;
						// set to 0
						cache_we <= 1'b0;
						cache_replace <= 1'b0;
						cache_windex <= 0;
						wtag <= 0;
						woff <= 0;
						wdata <= 32'b0;
						w_byte_enable <= 4'b0;
						wdirty <= 1'b0;
						wvalid <= 1'b0;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b1;
						DCache_write_req <= 1'b0;
						DCache_awvalid <= 1'b0;
						DCache_wlast <= 1'b0;
						DCache_wvalid <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_wdata_fetched <= 1'b0;
						flag <= 1'b0;
						end
					else if(DCache_cpu_we)
						begin
						cache_we <= 1'b1;
						DCache_access_offset <= DCache_addr_offset;
						wtag <= CacheLines0_hit ? CacheLines0_tag : (CacheLines1_hit ? CacheLines1_tag : 0);
						woff <= DCache_addr_offset;
						wdata <= DCache_cpu_wdata;
						w_byte_enable <= DCache_cpu_byte_enable;
						wdirty <= 1'b1;
						wvalid <= CacheLines0_hit ? CacheLines0_valid : (CacheLines1_hit ? CacheLines1_valid : 1'b0);
						cache_windex <= DCache_addr_index;
						state <= DCache_Hit;
						// set to 0
						cache_replace <= 1'b0;
						Mem_access_tag <= 0;
						Mem_access_offset <= 0;
						DCache_req <= 1'b0;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b0;
						DCache_write_req <= 1'b0;
						DCache_awvalid <= 1'b0;
						DCache_wlast <= 1'b0;
						DCache_wvalid <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_wdata_fetched <= 1'b0;
						end
					else if(DCache_cpu_re)
						begin
						DCache_access_offset <= DCache_addr_offset;
						state <= DCache_Hit;
						// set to 0
						cache_we <= 1'b0;
						wtag <= 0;
						woff <= 0;
						wdata <= 32'b0;
						w_byte_enable <= 4'b0000;
						wdirty <= 1'b0;
						wvalid <= 1'b0;
						cache_windex <= 0;
						cache_replace <= 1'b0;
						Mem_access_tag <= 0;
						Mem_access_offset <= 0;
						DCache_req <= 1'b0;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b0;
						DCache_write_req <= 1'b0;
						DCache_awvalid <= 1'b0;
						DCache_wlast <= 1'b0;
						DCache_wvalid <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_wdata_fetched <= 1'b0;
						end
					else		// all set to 0
						begin
						DCache_access_offset <= 0;
						state <= DCache_IDLE;
						cache_we <= 1'b0;
						wtag <= 0;
						woff <= 0;
						wdata <= 32'b0;
						w_byte_enable <= 4'b0000;
						wdirty <= 1'b0;
						wvalid <= 1'b0;
						cache_windex <= 0;
						cache_replace <= 1'b0;
						Mem_access_tag <= 0;
						Mem_access_offset <= 0;
						DCache_req <= 1'b0;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b0;
						DCache_write_req <= 1'b0;
						DCache_awvalid <= 1'b0;
						DCache_wlast <= 1'b0;
						DCache_wvalid <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_wdata_fetched <= 1'b0;
						end
					end
				DCache_Hit:		// for generating 1-cycle delay, because DCache'clk is negetive CPU'clk
					begin
					DCache_access_offset <= 0;
					state <= DCache_IDLE;
					cache_we <= 1'b0;
					wtag <= 0;
					woff <= 0;
					wdata <= 32'b0;
					w_byte_enable <= 4'b0000;
					wdirty <= 1'b0;
					wvalid <= 1'b0;
					cache_windex <= 0;
					cache_replace <= 1'b0;
					Mem_access_tag <= 0;
					Mem_access_offset <= 0;
					DCache_req <= 1'b0;
					DCache_arvalid <= 1'b0;
					DCache_rready <= 1'b0;
					DCache_awvalid <= 1'b0;
					DCache_wlast <= 1'b0;
					DCache_wvalid <= 1'b0;
					DCache_wdata_prefetch <= 32'b0;
					DCache_wdata_fetched <= 1'b0;
					end
				DCache_WriteBackWait:
					begin
					if(DCache_write_grnt)
						begin
						if(DCache_awready == 1'b1)
							begin
							state <= DCache_WriteBackWaitLast;
							end
						else
							begin
							state <= DCache_WriteBackWaitNow;
							end
						end
					else
						begin
						// do nothing
						end
					/*if(DCache_awready)		// AXI write req is accepted by slave
						begin
						state <= DCache_WriteBackFirst;
						DCache_wdata_fetched <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_req <= 1'b0;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b0;
						DCache_awvalid <= 1'b0;
						end
					else
						begin
						// do nothing
						end*/
					end
				DCache_WriteBackWaitLast:
					begin
					DCache_awvalid <= 1'b1;
					if(DCache_awready)
						begin
						state <= DCache_WriteBackFirst;
						DCache_wdata_fetched <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						end
					end
				DCache_WriteBackWaitNow:
					begin
					if(DCache_awready)
						begin
						state <= DCache_WriteBackFirst;
						DCache_wdata_fetched <= 1'b0;
						DCache_wdata_prefetch <= 32'b0;
						DCache_awvalid <= 1'b0;
						end
					else
						begin
						DCache_awvalid <= 1'b1;
						end
					end
				DCache_WriteBackFirst:
					begin
					if(DCache_wready)
						begin
						DCache_access_offset <= DCache_access_offset +  1;
						Mem_access_offset <= Mem_access_offset + 1;
						DCache_wdata_fetched <= 1'b0;
						DCache_wvalid <= 1'b0;
						state <= DCache_WriteBack;
						end
					else if(!DCache_wdata_fetched)
						begin
						DCache_wvalid <= 1'b1;
						DCache_wdata_prefetch <= LRU[cache_windex] ? CacheLines0_rdata : CacheLines1_rdata;
						DCache_wdata_fetched <= 1'b1;
						end
					else
						begin
						// do nothing
						end
					end
				DCache_WriteBack:
					begin
					if(DCache_wready)
						begin
						if(Mem_access_offset == 0)
							begin
							// finish all AXI transaction
							DCache_req <= 1'b0;
							DCache_arvalid <= 1'b0;
							DCache_rready <= 1'b0;
							DCache_awvalid <= 1'b0;
							DCache_wlast <= 1'b0;
							DCache_wvalid <= 1'b0;
							// clean up dirty
							cache_we = 1'b1;
							cache_windex <= DCache_addr_index;
							wtag <= CacheLines0_hit ? CacheLines0_tag : (CacheLines1_hit ? CacheLines1_tag : 0);
							woff <= DCache_addr_offset;
							// wdata <= DCache_cpu_wdata; 		// no need to care about this
							w_byte_enable <= 4'b0000;			// don't touch the data
							wdirty <= 1'b0;
							wvalid <= CacheLines0_hit ? CacheLines0_valid : (CacheLines1_hit ? CacheLines1_valid : 1'b0);
							state <= DCache_WaitWrFinish;
							end
						else
							begin
							if(Mem_access_offset == DCache_addr_offset_end)
								begin
								DCache_wlast <= 1'b1;
								end
							DCache_access_offset <= DCache_access_offset +  1;
							Mem_access_offset <= Mem_access_offset + 1;
							DCache_wdata_fetched <= 1'b0;
							DCache_wvalid <= 1'b0;
							end
						end
					else if(!DCache_wdata_fetched)
						begin
						DCache_wvalid <= 1'b1;
						DCache_wdata_prefetch <= LRU[cache_windex] ? CacheLines0_rdata : CacheLines1_rdata;
						DCache_wdata_fetched <= 1'b1;
						end
					end
				DCache_MemReadWait:
					begin
					/*if(DCache_grnt)
						begin
						// do nothing
						end
					else if(DCache_arready)
						begin
						state <= DCache_MemReadFirst;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b1;
						end*/
					if(DCache_grnt)
						begin
						if(DCache_arready == 1'b1)
							begin
							state <= DCache_MemReadWaitLast;
							end
						else
							begin
							state <= DCache_MemReadWaitNow;
							end
						end
					else
						begin
						// do nothing
						end
					end
				DCache_MemReadWaitLast:
					begin
					DCache_arvalid <= 1'b1;
					if(DCache_arready)// && (DCache_rid == 4'b0001))
						begin
						state <= DCache_MemReadFirst;
						// DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b1;
						end
					end
				DCache_MemReadWaitNow:
					begin
					if(DCache_arready)// && (DCache_rid == 4'b0001))
						begin
						state <= DCache_MemReadFirst;
						DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b1;
						end
					else
						begin
						DCache_arvalid <= 1'b1;
						end
					end
				DCache_MemReadFirst:
					begin
					if(DCache_rvalid && (DCache_rid == 4'b0001))
						begin
						if(DCache_rlast)
							begin
							/*cache_we = 1'b1;
							cache_replace <= 1'b1;			// replace cache block
							cache_windex <= DCache_addr_index;
							wtag <= Mem_access_tag;
							woff <= DCache_access_offset;
							wdata <= 32'b0;
							w_byte_enable <= 4'b1111;
							wdirty <= 1'b0;
							wvalid <= 1'b0;*/
							DCache_rready <= 1'b1;
							state <= DCache_MemReadExc;
							flag <= 1'b1;
							end
						else
							begin
							DCache_access_offset <= DCache_access_offset + 1;
							Mem_access_offset <= Mem_access_offset + 1;
							// write cache
							cache_we = 1'b1;
							cache_replace <= 1'b1;			// replace cache block
							cache_windex <= DCache_addr_index;
							wtag <= Mem_access_tag;
							woff <= DCache_access_offset;
							wdata <= DCache_rdata;
							w_byte_enable <= 4'b1111;
							wdirty <= 1'b0;
							wvalid <= 1'b0;
							DCache_rready <= 1'b1;
							state <= DCache_MemRead;
							end
						DCache_arvalid <= 1'b0;
						/*# 1;
						$display("wdata: 0x%8h, woff: 0x%1h, Mem_access_offset: 0x%1h", wdata, woff, Mem_access_offset);*/
						end
					else
						begin
						// do nothing
						DCache_arvalid <= 1'b0;
						end
					end
				DCache_MemRead:
					begin
					if(DCache_rvalid && (DCache_rid == 4'b0001))
						begin
						// write cache
						cache_we <= 1'b1;
						cache_replace <= 1'b1;
						cache_windex <= DCache_addr_index;
						wtag <= Mem_access_tag;
						if(flag == 1'b1)
							begin
							woff <= DCache_access_offset;
							wdata <= 32'b0;
							w_byte_enable <= 4'b1111;
							end
						else
							begin
							woff <= DCache_access_offset;
							wdata <= DCache_rdata;
							w_byte_enable <= 4'b1111;
							end
						wdirty <= 1'b0;
						if(Mem_access_offset == {OFFSET_WIDTH{1'b1}})
							begin
							// finish all AXI transaction
							// DCache_req <= 1'b0;		// release bus
							// DCache_arvalid <= 1'b0;
							DCache_rready <= 1'b1;
							// DCache_awvalid <= 1'b0;
							// DCache_wlast <= 1'b0;
							// DCache_wvalid <= 1'b0;
							// set valid
							wvalid <= 1'b1;
							state <= DCache_WaitWrFinish;
							end
						else
							begin
							wvalid <= 1'b0;
							DCache_access_offset <= DCache_access_offset +  1;
							Mem_access_offset <= Mem_access_offset + 1;
							DCache_rready <= 1'b1;
							end
						/*# 1;
						$display("wdata: 0x%8h, woff: 0x%1h, Mem_access_offset: 0x%1h", wdata, woff, Mem_access_offset);*/
						end
					else
						begin
						// no write cache
						cache_we <= 1'b0;
						cache_replace <= 1'b0;
						DCache_rready <= 1'b0;
						end
					end
				DCache_WaitWrFinish:
					begin
					DCache_access_offset <= 0;
					state <= DCache_IDLE;
					cache_we <= 1'b0;
					wtag <= 0;
					woff <= 0;
					wdata <= 32'b0;
					w_byte_enable <= 4'b0000;
					wdirty <= 1'b0;
					wvalid <= 1'b0;
					cache_windex <= 0;
					cache_replace <= 1'b0;
					Mem_access_tag <= 0;
					Mem_access_offset <= 0;
					DCache_req <= 1'b0;
					DCache_arvalid <= 1'b0;
					DCache_rready <= 1'b1;
					DCache_write_req <= 1'b0;
					DCache_awvalid <= 1'b0;
					DCache_wlast <= 1'b0;
					DCache_wvalid <= 1'b0;
					DCache_wdata_prefetch <= 32'b0;
					DCache_wdata_fetched <= 1'b0;
					end
				DCache_MemReadExc:
					begin
					if(DCache_access_offset == {OFFSET_WIDTH{1'b1}})
						begin
						// finish all AXI transaction
						// DCache_req <= 1'b0;		// release bus
						// DCache_arvalid <= 1'b0;
						DCache_rready <= 1'b1;
						// DCache_awvalid <= 1'b0;
						// DCache_wlast <= 1'b0;
						// DCache_wvalid <= 1'b0;
						// set valid
						wvalid <= 1'b1;
						state <= DCache_WaitWrFinish;
						end
					else
						begin
						wvalid <= 1'b0;
						DCache_access_offset <= DCache_access_offset +  1;
						DCache_rready <= 1'b1;
						end
					cache_we = 1'b1;
					cache_replace <= 1'b1;			// replace cache block
					cache_windex <= DCache_addr_index;
					wtag <= Mem_access_tag;
					woff <= DCache_access_offset;
					wdata <= 32'b0;
					w_byte_enable <= 4'b1111;
					wdirty <= 1'b0;
					/*# 1;
					$display("wdata: 0x%8h, woff: 0x%1h, Mem_access_offset: 0x%1h", wdata, woff, Mem_access_offset);*/
					end
				default:
					begin
					DCache_access_offset <= 0;
					state <= DCache_IDLE;
					cache_we <= 1'b0;
					wtag <= 0;
					woff <= 0;
					wdata <= 32'b0;
					w_byte_enable <= 4'b0000;
					wdirty <= 1'b0;
					wvalid <= 1'b0;
					cache_windex <= 0;
					cache_replace <= 1'b0;
					Mem_access_tag <= 0;
					Mem_access_offset <= 0;
					DCache_req <= 1'b0;
					DCache_arvalid <= 1'b0;
					DCache_rready <= 1'b0;
					DCache_write_req <= 1'b0;
					DCache_awvalid <= 1'b0;
					DCache_wlast <= 1'b0;
					DCache_wvalid <= 1'b0;
					DCache_wdata_prefetch <= 32'b0;
					DCache_wdata_fetched <= 1'b0;
					end
			endcase
			end
		end
endmodule