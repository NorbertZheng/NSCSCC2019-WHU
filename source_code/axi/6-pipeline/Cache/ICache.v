module ICache(
	input				clk						,
	input				rst_n					,
	
	// AXI read channel signals
	input				ICache_grnt				,
	output	reg			ICache_req				,
	// read address channel signals
	output		[3 :0]	ICache_arid				,
	output		[31:0]	ICache_araddr			,
	output		[3 :0]	ICache_arlen			,
	output		[2 :0]	ICache_arsize			,
	output		[1 :0]	ICache_arburst			,
	output		[1 :0]	ICache_arlock			,
	output		[3 :0]	ICache_arcache			,
	output		[2 :0]	ICache_arprot 			,
	output	reg			ICache_arvalid 			,
	input				ICache_arready			,
	// read data channel signals           
	input 		[3 :0]	ICache_rid				,
	input 		[31:0] 	ICache_rdata			,
	input 		[1 :0]	ICache_rresp			,
	input				ICache_rlast			,
	input 				ICache_rvalid 			,
	output	reg			ICache_rready			,
	
	// CPU read 
	input				ICache_cpu_re			,
	input		[31:0]	ICache_cpu_addr			,
	output		[31:0]	ICache_cpu_rdata		,
	output				ICache_cpu_Stall		,
	output				ICache_IF_ID_Stall		,
	output	reg			ICache_IF_Clr			
);
	parameter	CACHE_LINE_WIDTH		=	6,
				TAG_WIDTH				=	20,
				INDEX_WIDTH				=	32 - CACHE_LINE_WIDTH - TAG_WIDTH,
				NUM_CACHE_LINES			=	2 ** INDEX_WIDTH,
				OFFSET_WIDTH			=	CACHE_LINE_WIDTH - 2;
	parameter	ICache_IDLE				=	4'd0,
				ICache_CheckDirty		=	4'd1,
				ICache_MemReadWait		=	4'd2,
				ICache_MemReadWaitLast	=	4'd3,
				ICache_MemReadWaitNow	=	4'd4,
				ICache_MemReadFirst		=	4'd5,
				ICache_MemRead			=	4'd6,
				ICache_WriteBackWait	=	4'd7,
				ICache_WriteBackFirst	=	4'd8,
				ICache_WriteBack		=	4'd9,
				ICache_WaitWrFinish		=	4'd10,
				ICache_Delay			=	4'd11;

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
	reg [NUM_CACHE_LINES - 1:0]LRU;		// record recent access which way 0 / 1
	genvar i;
	generate
	// CacheLines0
	for(i = 0;i < NUM_CACHE_LINES;i = i + 1)
		begin
		CacheLine #(
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
		CacheLine #(
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
	wire [TAG_WIDTH - 1:0] ICache_addr_tag;
	wire [INDEX_WIDTH - 1:0] ICache_addr_index;
	wire [OFFSET_WIDTH - 1:0] ICache_addr_offset;
	wire [1:0] ICache_addr_byteoffset;
	assign {ICache_addr_tag, ICache_addr_index, ICache_addr_offset, ICache_addr_byteoffset} = ICache_cpu_addr;
	reg [31:0] ICache_cpu_addr_pre;
	wire [TAG_WIDTH - 1:0] ICache_addr_pre_tag;
	wire [INDEX_WIDTH - 1:0] ICache_addr_pre_index;
	wire [OFFSET_WIDTH - 1:0] ICache_addr_pre_offset;
	wire [1:0] ICache_addr_pre_byteoffset;
	assign {ICache_addr_pre_tag, ICache_addr_pre_index, ICache_addr_pre_offset, ICache_addr_pre_byteoffset} = ICache_cpu_addr_pre;
	
	// MEM / DCacheLine Traverse offset
	reg [TAG_WIDTH - 1:0] Mem_access_tag;
	reg [OFFSET_WIDTH - 1:0] Mem_access_offset;
	reg [OFFSET_WIDTH - 1:0] ICache_access_offset;
	
	// for ICache_access_offset, next period will get the rdata
	assign roff = (state == ICache_IDLE) ? ICache_addr_offset : ICache_access_offset;
	wire [OFFSET_WIDTH - 1:0] ICache_addr_offset_end = 0 - 1;
	
	// Status
	wire CacheLines0_valid = rvalid0[ICache_addr_index];
	wire CacheLines0_dirty = rdirty0[ICache_addr_index];
	wire [TAG_WIDTH-1:0] CacheLines0_tag = rtag0[ICache_addr_index];
	wire CacheLines0_hit = (CacheLines0_tag == ICache_addr_tag);
	reg CacheLines0_hit_pre;
	/*reg CacheLines0_hit;
	always@(negedge clk)
		begin
		if(!rst_n)
			begin
			CacheLines0_hit <= 1'b0;
			end
		else
			begin
			CacheLines0_hit <= (CacheLines0_tag == ICache_addr_tag);
			end
		end*/
	wire [31:0] CacheLines0_rdata = rdata0[ICache_addr_pre_index];
	wire CacheLines1_valid = rvalid1[ICache_addr_index];
	wire CacheLines1_dirty = rdirty1[ICache_addr_index];
	wire [TAG_WIDTH-1:0] CacheLines1_tag = rtag1[ICache_addr_index];
	wire CacheLines1_hit = (CacheLines1_tag == ICache_addr_tag);
	reg CacheLines1_hit_pre;
	/*reg CacheLines1_hit;
	always@(negedge clk)
		begin
		if(!rst_n)
			begin
			CacheLines1_hit <= 1'b0;
			end
		else
			begin
			CacheLines1_hit <= (CacheLines1_tag == ICache_addr_tag);
			end
		end*/
	wire [31:0] CacheLines1_rdata = rdata1[ICache_addr_pre_index];		// get last period roff read data
	
	// cache write control signals
	reg cache_we;
	reg cache_replace;
	reg [INDEX_WIDTH - 1:0] cache_windex;
	generate
	for(i = 0; i < NUM_CACHE_LINES; i = i + 1)
		begin
		// 						   (replace block	0 - old	   old && on replacing		)	(not replace block, check hit && refresh)
		assign we0[i] = cache_we ? (cache_replace ? (LRU[i] ? (i == cache_windex) : 1'b0) : (i == ICache_addr_index && CacheLines0_hit)) : 1'b0;
		// 						   (replace block	1 - old	   old && on replacing		)	(not replace block, check hit && refresh)
		assign we1[i] = cache_we ? (cache_replace ? (~LRU[i] ? (i == cache_windex) : 1'b0) : (i == ICache_addr_index && CacheLines1_hit)) : 1'b0;
		// we set Cache's clk is ~CPU'clk, so once we find Hit then we can write cache or read cache before the pipeline reg move
		// additionally, when we read / write cache(Hit first), we will stall the pipeline reg before EXE_MEM(including) and flush
		// MEM_WB pipeline reg for 1 cycle!
		end
	endgenerate
	
	// AXI static signals
	assign ICache_arid = 4'b0000;
	assign ICache_araddr = {Mem_access_tag, ICache_addr_index, Mem_access_offset, 2'b00};
	assign ICache_arlen = 4'b1111;
	assign ICache_arsize = 3'b010;
	assign ICache_arburst = 2'b01;		// ?
	assign ICache_arlock = 2'b00;		// single CPU, no need for lock
	assign ICache_arcache = 4'b0000;
	assign ICache_arprot = 3'b000;
	
	wire need_memread = (
		(ICache_cpu_re && (~CacheLines0_hit || ~CacheLines0_valid) && (~CacheLines1_hit || ~CacheLines1_valid))		// read
	);
	assign ICache_cpu_Stall = ~(											// Here is a ~
		// (state == ICache_Hit) ||											// Hit! read / write data
		// (state == ICache_IDLE && ~(need_memread) && (pre_state == ICache_IDLE || pre_state == ICache_Hit))		// IDLE! and will not change into other state soon
		(state == ICache_IDLE) && ~(need_memread)
		// (state == ICache_Delay)
	);
	assign ICache_IF_ID_Stall = ~(
		(state == ICache_IDLE)
	);
	// already wait for 1 cycle
	// assign ICache_cpu_rdata = CacheLines0_hit ? CacheLines0_rdata : (CacheLines1_hit ? CacheLines1_rdata : 32'b0);
	assign ICache_cpu_rdata = CacheLines0_hit_pre ? CacheLines0_rdata : (CacheLines1_hit_pre ? CacheLines1_rdata : 32'b0);
	always@(*)
		begin
		$display("CacheLines0_rdata: 0x%8h, CacheLines1_rdata: 0x%8h"
				, CacheLines0_rdata, CacheLines1_rdata);
		end
	always@(*)
		begin
		$display("ICache_cpu_rdata: 0x%8h, ICache_cpu_Stall: 0b%1b", ICache_cpu_rdata, ICache_cpu_Stall);
		end
		
	always@(posedge clk)
		begin
		# 1;
		$display("ICache state: 0x%1h, ICache_cpu_Stall: 0b%1b, ICache_IF_ID_Stall: 0b%1b", state, ICache_cpu_Stall, ICache_IF_ID_Stall);
		end
	
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
			ICache_cpu_addr_pre <= 32'b0;
			// mem access
			Mem_access_tag <= 0;
			Mem_access_offset <= 0;
			// cache access
			ICache_access_offset <= 0;
			// state
			state <= ICache_IDLE;
			// write cache data
			wtag <= 0;
			woff <= 0;
			wdata <= 32'b0;
			w_byte_enable <= 4'b0;
			wdirty <= 1'b0;
			wvalid <= 1'b0;
			// outputs
			ICache_req <= 1'b0;
			ICache_arvalid <= 1'b0;
			ICache_rready <= 1'b0;
			ICache_IF_Clr <= 1'b0;
			// hit signals
			CacheLines0_hit_pre <= 1'b0;
			CacheLines1_hit_pre <= 1'b0;
			end
		else
			begin
			CacheLines0_hit_pre <= CacheLines0_hit;
			CacheLines1_hit_pre <= CacheLines1_hit;
			pre_state <= state;
			ICache_cpu_addr_pre <= ICache_cpu_addr;
			case(state)
				ICache_IDLE:
					begin
					if(need_memread)
						begin
						state <= ICache_MemReadWait;
						ICache_access_offset <= 0;
						Mem_access_tag <= ICache_addr_tag;
						Mem_access_offset <= 0;
						ICache_req <= 1'b1;
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
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b0;
						ICache_IF_Clr <= 1'b1;
						end
					else if(ICache_cpu_re)
						begin
						ICache_access_offset <= ICache_addr_offset;
						state <= ICache_IDLE;		// state <= ICache_Hit;
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
						ICache_req <= 1'b0;
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b0;
						ICache_IF_Clr <= 1'b0;
						end
					else
						begin
						ICache_access_offset <= 0;
						state <= ICache_IDLE;
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
						ICache_req <= 1'b0;
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b0;
						ICache_IF_Clr <= 1'b0;
						end
					end
				/*ICache_Hit:
					begin
					ICache_access_offset <= 0;
					state <= ICache_IDLE;
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
					ICache_req <= 1'b0;
					ICache_arvalid <= 1'b0;
					ICache_rready <= 1'b0;
					end*/
				ICache_MemReadWait:
					begin
					if(ICache_grnt)
						begin
						if(ICache_arready == 1'b1)
							begin
							state <= ICache_MemReadWaitLast;
							end
						else
							begin
							state <= ICache_MemReadWaitNow;
							end
						end
					else
						begin
						// do nothing
						end
					end
				ICache_MemReadWaitLast:
					begin
					ICache_arvalid <= 1'b1;
					if(ICache_arready && (ICache_rid == 4'b0000))
						begin
						state <= ICache_MemReadFirst;
						// ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b1;
						end
					/*if(ICache_arready == 1'b0)
						begin
						state <= ICache_MemReadWaitNow;
						end
					else
						begin
						// do nothing
						end*/
					end
				ICache_MemReadWaitNow:
					begin
					ICache_arvalid <= 1'b1;
					if(ICache_arready && (ICache_rid == 4'b0000))
						begin
						state <= ICache_MemReadFirst;
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b1;
						end
					end
				ICache_MemReadFirst:
					begin
					if(ICache_rvalid && (ICache_rid == 4'b0000))
						begin
						ICache_access_offset <= ICache_access_offset +  1;
						Mem_access_offset <= Mem_access_offset + 1;
						// write cache
						cache_we = 1'b1;
						cache_replace <= 1'b1;			// replace cache block
						cache_windex <= ICache_addr_index;
						wtag <= Mem_access_tag;
						woff <= ICache_access_offset;
						wdata <= ICache_rdata;
						w_byte_enable <= 4'b1111;
						wdirty <= 1'b0;
						wvalid <= 1'b0;
						ICache_rready <= 1'b1;
						// ICache_arvalid <= 1'b0;
						state <= ICache_MemRead;
						# 1;
						$display("wdata: 0x%8h, woff: 0x%1h, Mem_access_offset: 0x%1h", wdata, woff, Mem_access_offset);
						end
					else
						begin
						// do nothing
						ICache_arvalid <= 1'b0;
						end
					end
				ICache_MemRead:
					begin
					if(ICache_rvalid && (ICache_rid == 4'b0000))
						begin
						// write cache
						cache_we = 1'b1;
						cache_replace <= 1'b1;
						cache_windex <= ICache_addr_index;
						wtag <= Mem_access_tag;
						woff <= ICache_access_offset;
						wdata <= ICache_rdata;
						w_byte_enable <= 4'b1111;
						wdirty <= 1'b0;
						if(Mem_access_offset == {OFFSET_WIDTH{1'b1}})
							begin
							// finish all AXI transaction
							// ICache_req <= 1'b0;		// release bus
							// ICache_arvalid <= 1'b0;
							ICache_rready <= 1'b1;
							// set valid
							wvalid <= 1'b1;
							state <= ICache_WaitWrFinish;
							end
						else
							begin
							wvalid <= 1'b0;
							ICache_access_offset <= ICache_access_offset +  1;
							Mem_access_offset <= Mem_access_offset + 1;
							ICache_rready <= 1'b1;
							// ICache_arvalid <= 1'b0;
							end
						# 1;
						$display("wdata: 0x%8h, woff: 0x%1h, Mem_access_offset: 0x%1h, {OFFSET_WIDTH{1'b1}}: 0x%2h"
								, wdata, woff, Mem_access_offset, {OFFSET_WIDTH{1'b1}});
						end
					else
						begin
						// no write cache
						cache_we = 1'b0;
						cache_replace <= 1'b0;
						ICache_rready <= 1'b0;
						end
					end
				ICache_WaitWrFinish:
					begin
					/*if(ICache_cpu_re)
						begin
						ICache_access_offset <= ICache_addr_offset;
						state <= ICache_IDLE;		// state <= ICache_Hit;
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
						ICache_req <= 1'b0;
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b1;
						end
					else
						begin
						ICache_access_offset <= 0;
						state <= ICache_IDLE;
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
						ICache_req <= 1'b0;
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b1;
						end*/
					ICache_access_offset <= 0;
					state <= ICache_IDLE;		// state <= ICache_Delay;
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
					ICache_req <= 1'b0;
					ICache_arvalid <= 1'b0;
					ICache_rready <= 1'b1;
					end
				/*ICache_Delay:			// for cu_exc_type RI
					begin
					if(ICache_cpu_re)
						begin
						ICache_access_offset <= ICache_addr_offset;
						state <= ICache_IDLE;		// state <= ICache_Hit;
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
						ICache_req <= 1'b0;
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b0;
						end
					else
						begin
						ICache_access_offset <= 0;
						state <= ICache_IDLE;
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
						ICache_req <= 1'b0;
						ICache_arvalid <= 1'b0;
						ICache_rready <= 1'b0;
						end
					end*/
				default:
					begin
					ICache_access_offset <= 0;
					state <= ICache_IDLE;
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
					ICache_req <= 1'b0;
					ICache_arvalid <= 1'b0;
					ICache_rready <= 1'b0;
					end
			endcase
			end
		end
endmodule