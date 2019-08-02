`include "Define/LS_Define.v"
module Mips(
	input		[5 :0]	int_i				,		// high active
	
	input				clk					,
	input				rst_n				,		// low active
	
	output		[3 :0]	arid				,
	output		[31:0]	araddr				,
	output		[3 :0]	arlen				,
	output		[2 :0]	arsize				,
	output		[1 :0]	arburst				,
	output		[1 :0]	arlock				,
	output		[3 :0]	arcache				,
	output		[2 :0]	arprot				,
	output				arvalid				,
	input				arready				,
	
	input		[3 :0]	rid					,
	input		[31:0]	rdata				,
	input		[1 :0]	rresp				,
	input				rlast				,
	input				rvalid				,
	output				rready				,

	output		[3 :0]	awid				,
	output		[31:0]	awaddr				,
	output		[3 :0]	awlen				,
	output		[2 :0]	awsize				,
	output		[1 :0]	awburst				,
	output		[1 :0]	awlock				,
	output		[3 :0]	awcache				,
	output		[2 :0]	awprot				,
	output				awvalid				,
	input				awready				,

	output		[3 :0]	wid					,
	output		[31:0]	wdata				,
	output		[3 :0]	wstrb				,
	output				wlast				,
	output				wvalid				,
	input				wready				,

	input		[3 :0]	bid					,
	input		[1 :0]	bresp				,
	input				bvalid				,
	output				bready				,

	//debug interface
	output		[31:0]	debug_wb_pc			,
	output		[3 :0]	debug_wb_rf_wen		,
	output		[4 :0]	debug_wb_rf_wnum	,
	output		[31:0]	debug_wb_rf_wdata	
);
	always@(posedge clk)
		begin
		$display();
		$display("arid: 0x%1h, araddr: 0x%8h, arlen: 0x%1h, arsize: 0x%1h, arburst: 0x%1h, arvalid: 0b%1b, arready: 0b%1b"
				, arid, araddr, arlen, arsize, arburst, arvalid, arready);
		$display("rid: 0x%1h, rdata: 0x%8h, rresp: 0b%2b, rlast: 0b%1b, rvalid: 0b%1b, rready: 0b%1b"
				, rid, rdata, rresp, rlast, rvalid, rready);
		$display("awid: 0x%1h, awaddr: 0x%8h, awlen: 0x%1h, awsize: 0x%1h, awburst: 0x%1h, awvalid: 0b%1b, awready: 0b%1b"
				, awid, awaddr, awlen, awsize, awburst, awvalid, awready);
		$display("wid: 0x%1h, wdata: 0x%8h, wstrb: 0b%2b, wlast: 0b%1b, wvalid: 0b%1b, wready: 0b%1b"
				, wid, wdata, wstrb, wlast, wvalid, wready);
		$display("bid: 0x%1h, bresp: 0b%2b, bvalid: 0b%1b, bready: 0b%1b"
				, bid, bresp, bvalid, bready);
		$display();
		end
	// AXI_Cache_Store_Bus
	wire m0_write_req, m0_write_grnt, m1_write_req, m1_write_grnt;
	wire m0_awvalid, m0_awready, m0_wlast, m0_wvalid, m0_wready, m0_bvalid, m0_bready;
	wire m1_awvalid, m1_awready, m1_wlast, m1_wvalid, m1_wready, m1_bvalid, m1_bready;
	wire [1 :0] m0_awburst, m0_awlock, m0_bresp, m1_awburst, m1_awlock, m1_bresp;
	wire [2 :0] m0_awsize, m0_awprot, m1_awsize, m1_awprot;
	wire [3 :0] m0_awid, m0_awlen, m0_awcache, m0_wid, m0_wstrb, m0_bid;
	wire [3 :0] m1_awid, m1_awlen, m1_awcache, m1_wid, m1_wstrb, m1_bid;
	wire [31:0] m0_awaddr, m0_wdata, m1_awaddr, m1_wdata;
	AXI_Cache_Store_Bus AXI_Cache_Store_Bus(
		.clk				(clk),
		.rst_n				(rst_n),
		// write address channel signals
		.awid				(awid),
		.awaddr				(awaddr),
		.awlen				(awlen),
		.awsize				(awsize),
		.awburst			(awburst),
		.awlock				(awlock),
		.awcache			(awcache),
		.awprot				(awprot),
		.awvalid			(awvalid),
		.awready			(awready),
		// write data channel signals
		.wid				(wid),
		.wdata				(wdata),
		.wstrb				(wstrb),
		.wlast				(wlast),
		.wvalid				(wvalid),
		.wready				(wready),
		// write response channel signals
		.bid				(bid),
		.bresp				(bresp),
		.bvalid				(bvalid),
		.bready				(bready),
		
		// master0
		.m0_req				(m0_write_req),
		.m0_grnt			(m0_write_grnt),
		.m0_awid			(m0_awid),
		.m0_awaddr			(m0_awaddr),
		.m0_awlen			(m0_awlen),
		.m0_awsize			(m0_awsize),
		.m0_awburst			(m0_awburst),
		.m0_awlock			(m0_awlock),
		.m0_awcache			(m0_awcache),
		.m0_awprot			(m0_awprot),
		.m0_awvalid			(m0_awvalid),
		.m0_awready			(m0_awready),
		.m0_wid				(m0_wid),
		.m0_wdata			(m0_wdata),
		.m0_wstrb			(m0_wstrb),
		.m0_wlast			(m0_wlast),
		.m0_wvalid			(m0_wvalid),
		.m0_wready			(m0_wready),
		.m0_bid				(m0_bid),
		.m0_bresp			(m0_bresp),
		.m0_bvalid			(m0_bvalid),
		.m0_bready			(m0_bready),
		
		// master1
		.m1_req				(m1_write_req),
		.m1_grnt			(m1_write_grnt),
		.m1_awid			(m1_awid),
		.m1_awaddr			(m1_awaddr),
		.m1_awlen			(m1_awlen),
		.m1_awsize			(m1_awsize),
		.m1_awburst			(m1_awburst),
		.m1_awlock			(m1_awlock),
		.m1_awcache			(m1_awcache),
		.m1_awprot			(m1_awprot),
		.m1_awvalid			(m1_awvalid),
		.m1_awready			(m1_awready),
		.m1_wid				(m1_wid),
		.m1_wdata			(m1_wdata),
		.m1_wstrb			(m1_wstrb),
		.m1_wlast			(m1_wlast),
		.m1_wvalid			(m1_wvalid),
		.m1_wready			(m1_wready),
		.m1_bid				(m1_bid),
		.m1_bresp			(m1_bresp),
		.m1_bvalid			(m1_bvalid),
		.m1_bready			(m1_bready)
	);
	
	// AXI_Cache_Load_Bus
	wire m0_req, m0_grnt, m0_arvalid, m0_arready, m0_rlast, m0_rvalid, m0_rready, m1_req, m1_grnt, m1_arvalid, m1_arready, m1_rlast, m1_rvalid, m1_rready;
	wire m2_req, m2_grnt, m2_arvalid, m2_arready, m2_rlast, m2_rvalid, m2_rready;
	wire [1 :0] m0_arburst, m0_arlock, m0_rresp, m1_arburst, m1_arlock, m1_rresp;
	wire [1 :0] m2_arburst, m2_arlock, m2_rresp;
	wire [2 :0] m0_arsize, m0_arprot, m1_arsize, m1_arprot;
	wire [2 :0] m2_arsize, m2_arprot;
	wire [3 :0] m0_arid, m0_arlen, m0_arcache, m0_rid, m1_arid, m1_arlen, m1_arcache, m1_rid;
	wire [3 :0] m2_arid, m2_arlen, m2_arcache, m2_rid;
	wire [31:0] m0_araddr, m0_rdata, m1_araddr, m1_rdata;
	wire [31:0] m2_araddr, m2_rdata;
	AXI_Cache_Load_Bus m_AXI_Cache_Load_Bus(
		.clk(clk),
		.rst_n(rst_n),
		// AXI read channel signals
		// read address channel signals
		.arid(arid),
		.araddr(araddr),
		.arlen(arlen),
		.arsize(arsize),
		.arburst(arburst),
		.arlock(arlock),
		.arcache(arcache),
		.arprot(arprot),
		.arvalid(arvalid),
		.arready(arready),
		// read data channel signals           
		.rid(rid),
		.rdata(rdata),
		.rresp(rresp),
		.rlast(rlast),
		.rvalid(rvalid),
		.rready(rready),
	
		// master0
		.m0_req(m0_req),
		.m0_grnt(m0_grnt),
		// master0 read address signals
		.m0_arid(m0_arid),
		.m0_araddr(m0_araddr),
		.m0_arlen(m0_arlen),
		.m0_arsize(m0_arsize),
		.m0_arburst(m0_arburst),
		.m0_arlock(m0_arlock),
		.m0_arcache(m0_arcache),
		.m0_arprot(m0_arprot),
		.m0_arvalid(m0_arvalid),
		.m0_arready(m0_arready),
		// master0 read data signals
		.m0_rid(m0_rid),
		.m0_rdata(m0_rdata),
		.m0_rresp(m0_rresp),
		.m0_rlast(m0_rlast),
		.m0_rvalid(m0_rvalid),
		.m0_rready(m0_rready),
	
		// master1
		.m1_req(m1_req),
		.m1_grnt(m1_grnt),
		// master1 read address signals
		.m1_arid(m1_arid),
		.m1_araddr(m1_araddr),
		.m1_arlen(m1_arlen),
		.m1_arsize(m1_arsize),
		.m1_arburst(m1_arburst),
		.m1_arlock(m1_arlock),
		.m1_arcache(m1_arcache),
		.m1_arprot(m1_arprot),
		.m1_arvalid(m1_arvalid),
		.m1_arready(m1_arready),
		// master1 read data signals
		.m1_rid(m1_rid),
		.m1_rdata(m1_rdata),
		.m1_rresp(m1_rresp),
		.m1_rlast(m1_rlast),
		.m1_rvalid(m1_rvalid),
		.m1_rready(m1_rready),
		
		// master2
		.m2_req(m2_req),
		.m2_grnt(m2_grnt),
		// master1 read address signals
		.m2_arid(m2_arid),
		.m2_araddr(m2_araddr),
		.m2_arlen(m2_arlen),
		.m2_arsize(m2_arsize),
		.m2_arburst(m2_arburst),
		.m2_arlock(m2_arlock),
		.m2_arcache(m2_arcache),
		.m2_arprot(m2_arprot),
		.m2_arvalid(m2_arvalid),
		.m2_arready(m2_arready),
		// master1 read data signals
		.m2_rid(m2_rid),
		.m2_rdata(m2_rdata),
		.m2_rresp(m2_rresp),
		.m2_rlast(m2_rlast),
		.m2_rvalid(m2_rvalid),
		.m2_rready(m2_rready)
	);
	
	wire [31:0] mem_rdata;
	/**************************/
	/*           IPF          */
	/**************************/
	// PC
	wire ICache_IF_Clr;
	wire PC_target_sel, exc_en, stcl_lw, stcl_jmp, stcl_f, stcl_ram_cache, stcl_div, stcl_ICache, stcl_DCache;
	wire uncachedLoader_cpu_Stall, uncachedStorer_cpu_Stall, uncachedLoader_cpu_PC_Stall, uncachedStorer_cpu_PC_Stall;
	assign stcl_f = 1'b0;			// temp for test
	assign stcl_ram_cache = 1'b0;	// temp for test
	wire [31:0] if_fetch_exc_type, PC_branch, PC_exc, PC_o, PC_plus4;
	reg stcl_DCache_delay;			// for 1-cycle stcl_DCache delay
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			stcl_DCache_delay <= 1'b0;
			end
		else
			begin
			stcl_DCache_delay <= stcl_DCache;
			end
		end
	reg uncachedStorer_cpu_Stall_delay;		// for 1-cycle delay of uncachedStorer_cpu_Stall
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			uncachedStorer_cpu_Stall_delay <= 1'b0;
			end
		else
			begin
			uncachedStorer_cpu_Stall_delay <= uncachedStorer_cpu_Stall;
			end
		end
	reg uncachedLoader_cpu_Stall_delay;		// for 1-cycle delay of uncachedLoader_cpu_Stall
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			uncachedLoader_cpu_Stall_delay <= 1'b0;
			end
		else
			begin
			uncachedLoader_cpu_Stall_delay <= uncachedLoader_cpu_Stall;
			end
		end
	PC m_PC(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_lw), 
		.stall1(stcl_jmp), 
		.stall2(stcl_f | (stcl_ICache && ~PC_target_sel)), 
		.stall3(stcl_ram_cache | stcl_div | stcl_DCache | (uncachedLoader_cpu_PC_Stall | uncachedStorer_cpu_PC_Stall)),// (uncachedLoader_cpu_Stall | uncachedStorer_cpu_Stall)), 
		// .minus4((uncachedLoader_cpu_Stall && ~uncachedLoader_cpu_Stall_delay) | (uncachedStorer_cpu_Stall && ~uncachedStorer_cpu_Stall_delay)),
		.PC_exc_i(PC_exc), 
		.PC_target_i(PC_branch), 
		.PC_exc_sel(exc_en), 
		.PC_target_sel(PC_target_sel), 
		.PC_o(PC_o), 
		.PC_plus4(PC_plus4), 
		.if_fetch_exc_type(if_fetch_exc_type)
	);
	/*always@(*)
		begin
		$display("stcl_ICache: 0b%1b, exc_en: 0b%1b, PC_o: 0x%8h"
				, stcl_ICache, exc_en, PC_o);
		end*/
	reg PC_target_sel_delay;		// for 1-cycle delay of PC_target_sel signal to flush IF/ID instruction
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			PC_target_sel_delay <= 1'b0;
			end
		else
			begin
			PC_target_sel_delay <= PC_target_sel;
			end
		end
		
	// IPF_IF_REG_PACKED
	wire DCache_IF_Stall;
	wire is_delayslot, IPF_IF_is_delayslot_data, instMiss, IPF_IF_instMiss_data, instValid, IPF_IF_instValid_data;
	wire [7:0] asid, IPF_IF_asid_data;
	wire [31:0] IPF_IF_if_fetch_exc_type_data, IPF_IF_PC_plus4_data, IPF_IF_Instruction_data;
	IPF_IF_REG_PACKED m_IPF_IF_REG_PACKED(
		.clk							(clk															), 
		.rst_n							(rst_n															), 
		// control signals
		.stall0							(stcl_lw														), 
		.stall1							(stcl_jmp														), 
		.stall2							(stcl_f | (stcl_ICache)	| ((uncachedLoader_cpu_Stall) | (uncachedStorer_cpu_Stall))				), 
		.stall3							(stcl_ram_cache | stcl_div | DCache_IF_Stall					), //(stcl_DCache)						), 
		.irq							(exc_en															), 
		.clr0							(PC_target_sel													), 
		// data
		.PC_plus4						(PC_plus4														), 
		.IPF_IF_PC_plus4_data			(IPF_IF_PC_plus4_data											),
		.is_delayslot					(is_delayslot													), 
		.IPF_IF_is_delayslot_data		(IPF_IF_is_delayslot_data										), 
		.if_fetch_exc_type				(if_fetch_exc_type												), 
		.IPF_IF_if_fetch_exc_type_data	(IPF_IF_if_fetch_exc_type_data									), 
		.asid							(asid															), 
		.IPF_IF_asid_data				(IPF_IF_asid_data												), 
		.instMiss						(instMiss														), 
		.IPF_IF_instMiss_data			(IPF_IF_instMiss_data											), 
		.instValid						(instValid														), 
		.IPF_IF_instValid_data			(IPF_IF_instValid_data											)
	);
	
	// ICache
	wire ICache_IF_ID_Stall;
	wire ICache_grnt, ICache_req, ICache_arvalid, ICache_arready, ICache_rlast, ICache_rvalid, ICache_rready;
	wire [1:0] ICache_arburst, ICache_arlock, ICache_rresp;
	wire [2:0] ICache_arsize, ICache_arprot;
	wire [3:0] ICache_arid, ICache_arlen, ICache_arcache, ICache_rid;
	wire [31:0] ICache_araddr, ICache_rdata, inst_data;
	wire [31:0] physical_inst_addr;
	ICache m_ICache(
		.clk(clk),
		.rst_n(rst_n),
		.ICache_grnt(ICache_grnt),
		.ICache_req(ICache_req),
		.ICache_arid(ICache_arid),
		.ICache_araddr(ICache_araddr),
		.ICache_arlen(ICache_arlen),
		.ICache_arsize(ICache_arsize),
		.ICache_arburst(ICache_arburst),
		.ICache_arlock(ICache_arlock),
		.ICache_arcache(ICache_arcache),
		.ICache_arprot(ICache_arprot),
		.ICache_arvalid(ICache_arvalid),
		.ICache_arready(ICache_arready),
		.ICache_rid(ICache_rid),
		.ICache_rdata(ICache_rdata),
		.ICache_rresp(ICache_rresp),
		.ICache_rlast(ICache_rlast),
		.ICache_rvalid(ICache_rvalid),
		.ICache_rready(ICache_rready),
		.ICache_cpu_re(1'b1),
		.ICache_cpu_addr(physical_inst_addr),
		.ICache_cpu_rdata(inst_data),
		.ICache_cpu_Stall(stcl_ICache),
		.ICache_IF_Clr(ICache_IF_Clr),
		.ICache_IF_ID_Stall(ICache_IF_ID_Stall)
	);
	assign ICache_grnt = m2_grnt;
	assign m2_req = ICache_req;
	assign m2_arid = ICache_arid;
	assign m2_araddr = ICache_araddr;
	assign m2_arlen = ICache_arlen;
	assign m2_arsize = ICache_arsize;
	assign m2_arburst = ICache_arburst;
	assign m2_arlock = ICache_arlock;
	assign m2_arcache = ICache_arcache;
	assign m2_arprot = ICache_arprot;
	assign m2_arvalid = ICache_arvalid;
	assign ICache_arready = m2_arready;
	assign ICache_rid = m2_rid;
	assign ICache_rdata = m2_rdata;
	assign ICache_rresp = m2_rresp;
	assign ICache_rlast = m2_rlast;
	assign ICache_rvalid = m2_rvalid;
	assign m2_rready = ICache_rready;
	always@(*)
		begin
		$display("ICache_req: 0b%1b, ICache_grnt: 0b%1b", ICache_req, ICache_grnt);
		$display("ICache_arid: 0x%1h, ICache_araddr: 0x%8h, ICache_arlen: 0x%1h, ICache_arsize: 0x%1h, ICache_arburst: 0x%1h"
				, ICache_arid, ICache_araddr, ICache_arlen, ICache_arsize, ICache_arburst);
		$display("ICache_arlock: 0x%1h, ICache_arcache: 0x%1h, ICache_arprot: 0x%1h, ICache_arvalid: 0b%1b, ICache_arready: 0b%1b"
				, ICache_arlock, ICache_arcache, ICache_arprot, ICache_arvalid, ICache_arready);
		$display("ICache_rid: 0x%1h, ICache_rdata: 0x%8h, ICache_rvalid: 0b%1b, ICache_rready: 0b%1b"
				, ICache_rid, ICache_rdata, ICache_rvalid, ICache_rready);
		end
	
	// IF_ID_REG_PACKED
	wire DCache_State_Hit;
	wire IF_ID_is_delayslot_data, IF_ID_instMiss_data, IF_ID_instValid_data;
	wire [7:0] IF_ID_asid_data;
	wire [31:0] IF_ID_if_fetch_exc_type_data, IF_ID_PC_plus4_data, IF_ID_Instruction_data;
	IF_ID_REG_PACKED m_IF_ID_REG_PACKED(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_lw), 
		.stall1(stcl_jmp), 
		.stall2(stcl_f), 
		.stall3(stcl_ram_cache | stcl_div | DCache_IF_Stall | ((uncachedLoader_cpu_Stall) | (uncachedStorer_cpu_Stall))), // (stcl_DCache)), 
		.irq(exc_en), 
		.clr0(ICache_IF_ID_Stall | ICache_IF_Clr | PC_target_sel_delay | DCache_State_Hit),		// .clr0(stcl_ICache | ICache_IF_Clr),
		.PC_plus4(IPF_IF_PC_plus4_data), 
		.IF_ID_PC_plus4_data(IF_ID_PC_plus4_data), 
		.Instruction(inst_data), 
		.IF_ID_Instruction_data(IF_ID_Instruction_data), 
		.is_delayslot(IPF_IF_is_delayslot_data), 
		.IF_ID_is_delayslot_data(IF_ID_is_delayslot_data), 
		.if_fetch_exc_type(IPF_IF_if_fetch_exc_type_data), 
		.IF_ID_if_fetch_exc_type_data(IF_ID_if_fetch_exc_type_data),
		.asid(IPF_IF_asid_data),
		.IF_ID_asid_data(IF_ID_asid_data),
		.instMiss(IPF_IF_instMiss_data),
		.IF_ID_instMiss_data(IF_ID_instMiss_data),
		.instValid(IPF_IF_instValid_data),
		.IF_ID_instValid_data(IF_ID_instValid_data)
	);
	always@(*)
		begin
		$display("IF_ID_Instruction_data: 0x%8h, IF_ID_PC_plus4_data: 0x%8h, IPF_IF_PC_plus4_data: 0x%8h"
				, IF_ID_Instruction_data, IF_ID_PC_plus4_data, IPF_IF_PC_plus4_data);
		end
	/*always@(*)
		begin
		$display("IF_ID->stcl_lw: 0b%1b, stcl_jmp: 0b%1b, stcl_f: 0b%1b, stcl_ram_cache: 0b%1b, stcl_div: 0b%1b, stcl_DCache: 0b%1b"
				, stcl_lw, stcl_jmp, stcl_f, stcl_ram_cache, stcl_div, stcl_DCache);
		end*/

	/**************************/
	/*           ID           */
	/**************************/
	// rf_jdata0_fw_mux
	wire [1:0] rf_jdata0_fw_sel;
	wire [31:0] rf_rdata0, EXE_MEM_ALU_result_data, WB_result_data, rf_jdata0_fw_mux_data;
	Mux3T1 m_rf_jdata0_fw_mux(
		.s(rf_jdata0_fw_sel), 
		.y(rf_jdata0_fw_mux_data), 
		.d0(rf_rdata0), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// rf_jdata1_fw_mux
	wire [1:0] rf_jdata1_fw_sel;
	wire [31:0] rf_rdata1, rf_jdata1_fw_mux_data;
	Mux3T1 m_rf_jdata1_fw_mux(
		.s(rf_jdata1_fw_sel), 
		.y(rf_jdata1_fw_mux_data), 
		.d0(rf_rdata1), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// Control_Unit
	wire eret, is_div, is_sign_div, is_delayslot_o, wcp0, hi_i_sel, lo_i_sel, whi, wlo, wreg, wmem, sign, alusrc0_sel, i_b, tlbr, tlbp, wtlb;
	wire [1:0] result_sel, alusrc1_sel, regdst;
	wire [3:0] store_type, load_type;
	wire [7:0] aluop;
	wire [31:0] cu_inst_exc_type;
	Control_Unit m_Control_Unit(
		.rst_n(rst_n), 
		.inst(IF_ID_Instruction_data), 
		.rf_read_data0(rf_jdata0_fw_mux_data), 
		.rf_read_data1(rf_jdata1_fw_mux_data), 
		.PC_plus4(IF_ID_PC_plus4_data), 
		.is_delayslot_i(IF_ID_is_delayslot_data), 
		.eret(eret),
		.is_div(is_div), 
		.is_sign_div(is_sign_div), 
		.cu_inst_exc_type(cu_inst_exc_type), 
		.is_delayslot_o(is_delayslot_o), 
		.wcp0(wcp0), 
		.store_type(store_type), 
		.load_type(load_type), 
		.hi_i_sel(hi_i_sel), 
		.lo_i_sel(lo_i_sel), 
		.whi(whi), 
		.wlo(wlo), 
		.wreg(wreg), 
		.result_sel(result_sel), 
		.wmem(wmem), 
		.sign(sign), 
		.aluop(aluop), 
		.alusrc0_sel(alusrc0_sel), 
		.alusrc1_sel(alusrc1_sel), 
		.regdst(regdst), 
		.i_bj(is_delayslot), 
		.i_b(i_b), 
		.PC_target_sel(PC_target_sel), 
		.PC_branch(PC_branch),
		.tlbr(tlbr),
		.tlbp(tlbp),
		.wtlb(wtlb)
	);
	/*always@(*)
		begin
		$display("IF_ID_Instruction_data: 0x%8h, cu_inst_exc_type: 0x%8h"
				, IF_ID_Instruction_data, cu_inst_exc_type);
		end*/

	// Registers
	wire MEM_WB_wreg_data;
	wire [4:0] MEM_WB_regdst_data;
	Registers #(32, 5, 32) m_Registers(
		.clk(clk), 
		.rst_n(rst_n), 
		.RegWrite(MEM_WB_wreg_data), 
		.Read_register1(IF_ID_Instruction_data[25:21]), 
		.Read_register2(IF_ID_Instruction_data[20:16]), 
		.Write_register(MEM_WB_regdst_data), 
		.Write_data(WB_result_data), 
		.Read_data1(rf_rdata0), 
		.Read_data2(rf_rdata1)
	);
	
	// hi_lo_reg
	wire MEM_WB_whi_data, MEM_WB_wlo_data;
	wire [31:0] WB_hi_data, WB_lo_data, hi_o, lo_o;
	hi_lo_reg m_hi_lo_reg(
		.clk(clk), 
		.rst_n(rst_n), 
		.whi(MEM_WB_whi_data), 
		.wlo(MEM_WB_wlo_data), 
		.hi_i(WB_hi_data), 
		.lo_i(WB_lo_data), 
		.hi_o(hi_o), 
		.lo_o(lo_o)
	);
	
	// COP0 
	wire [31:0] physical_data_addr;
	wire EXE_MEM_instMiss_data, dataMiss, EXE_MEM_instValid_data, dataValid, EXE_MEM_eret_data;
	wire [3:0] EXE_MEM_load_type_data, EXE_MEM_store_type_data;
	wire MEM_load_exc = ((EXE_MEM_load_type_data == `LOAD_LH || EXE_MEM_load_type_data == `LOAD_LHU) && physical_data_addr[0])||
						((EXE_MEM_load_type_data == `LOAD_LL || EXE_MEM_load_type_data == `LOAD_LW) && physical_data_addr[1:0] != 2'b00);
	wire MEM_store_exc = (EXE_MEM_store_type_data == `STORE_SH && physical_data_addr[0])||
						((EXE_MEM_store_type_data == `STORE_SW || EXE_MEM_store_type_data == `STORE_SC) && physical_data_addr[1:0] != 2'b00);
	wire MEM_WB_wcp0_data, vic_is_delayslot, kseg0_uncached, MEM_WB_tlbp_data, MEM_WB_tlbr_data, user_mode;
	wire [4:0] tlb_addr;
	wire [5:0] EXE_MEM_int_i_data;
	wire [7:0] exp_asid; 
	wire [31:0] vic_inst_addr, COP0_data, MEM_WB_Instruction_data, EXE_MEM_exc_type_data, MEM_tlb_exc_type;
	wire [89:0] tlb_wdata, MEM_WB_tlbr_result_data;
	wire [2:0] MEM_WB_wsel_data = MEM_WB_Instruction_data[2:0];
	COP0 m_COP0(
		.clk(clk), 
		.rst_n(rst_n), 
		.wcp0(MEM_WB_wcp0_data), 
		.waddr(MEM_WB_regdst_data), 
		.wsel(MEM_WB_wsel_data),
		.raddr(IF_ID_Instruction_data[15:11]),
		.rsel(IF_ID_Instruction_data[2:0]),
		.wdata(WB_result_data), 
		.eret(EXE_MEM_eret_data),
		.tlbp_we(MEM_WB_tlbp_data),
		.tlbr_we(MEM_WB_tlbr_data),
		.tlbr_result(MEM_WB_tlbr_result_data),
		.exc_type(EXE_MEM_exc_type_data | {26'b0, MEM_store_exc, MEM_load_exc, 4'b0}), // | MEM_tlb_exc_type), 
		.int_i(EXE_MEM_int_i_data), 
		.instMiss(EXE_MEM_instMiss_data),
		.dataMiss(dataMiss),
		.instValid(EXE_MEM_instValid_data),
		.dataValid(dataValid),
		.exp_asid(exp_asid),
		.victim_inst_addr(vic_inst_addr), 
		.is_delayslot(vic_is_delayslot), 
		.badvaddr(EXE_MEM_ALU_result_data), 
		.COP0_data(COP0_data), 
		.exc_en(exc_en), 
		.PC_exc(PC_exc),
		.kseg0_uncached(kseg0_uncached),
		.tlb_addr(tlb_addr),
		.tlb_wdata(tlb_wdata),
		.asid(asid),
		.user_mode(user_mode)
	);
	
	// EXT
	wire [31:0] Imm32;
	EXT m_EXT(
		.EXTOp(sign), 
		.Imm16(IF_ID_Instruction_data[15:0]), 
		.Imm32(Imm32)
	);
	
	// victimInstDetector
	wire ID_EXE_is_delayslot_data, EXE_MEM_is_delayslot_data;
	wire [7:0] ID_EXE_asid_data, EXE_MEM_asid_data;
	wire [31:0] ID_EXE_PC_plus4_data, EXE_MEM_PC_plus4_data;
	victimInstDetector m_victimInstDetector(
		.PC_o(PC_o), 
		.asid(asid),
		.IF_ID_is_delayslot_data(IF_ID_is_delayslot_data), 
		.IF_ID_asid_data(IF_ID_asid_data),
		.IF_ID_PC_plus4_data(IF_ID_PC_plus4_data), 
		.ID_EXE_is_delayslot_data(ID_EXE_is_delayslot_data), 
		.ID_EXE_asid_data(ID_EXE_asid_data),
		.ID_EXE_PC_plus4_data(ID_EXE_PC_plus4_data), 
		.EXE_MEM_is_delayslot_data(EXE_MEM_is_delayslot_data), 
		.EXE_MEM_asid_data(EXE_MEM_asid_data),
		.EXE_MEM_PC_plus4_data(EXE_MEM_PC_plus4_data), 
		.vic_is_delayslot(vic_is_delayslot), 
		.vic_inst_addr(vic_inst_addr),
		.exp_asid(exp_asid)
	);
	/*always@(*)
		begin
		$display("COP0_EPC: 0x%8h, EXE_MEM_PC_data: 0x%8h, ID_EXE_PC_data: 0x%8h, IF_ID_PC_data: 0x%8h, vic_inst_addr: 0x%8h"
				, COP0_EPC, EXE_MEM_PC_plus4_data - 32'h4, ID_EXE_PC_plus4_data - 32'h4, IF_ID_PC_plus4_data - 32'h4, vic_inst_addr);
		end*/
	
	// Hazard_Detection_Unit
	wire ID_EXE_wreg_data;
	wire [3:0] ID_EXE_load_type_data, ID_EXE_store_type_data;
	wire [4:0] EXE_regdst_data, EXE_MEM_regdst_data;
	Hazard_Detection_Unit m_Hazard_Detection_Unit(
		.rst_n(rst_n), 
		.EXE_regdst_data(EXE_regdst_data), 
		.IF_ID_rs_data(IF_ID_Instruction_data[25:21]), 
		.IF_ID_rt_data(IF_ID_Instruction_data[20:16]), 
		.ID_EXE_load_type_data(ID_EXE_load_type_data), 
		.ID_EXE_store_type_data(ID_EXE_store_type_data), 
		.stcl_lw(stcl_lw), 
		.ID_i_b(i_b), 
		.ID_EXE_wreg_data(ID_EXE_wreg_data), 
		.EXE_MEM_load_type_data(EXE_MEM_load_type_data), 
		.EXE_MEM_store_type_data(EXE_MEM_store_type_data), 
		.EXE_MEM_regdst_data(EXE_MEM_regdst_data),
		.stcl_jmp(stcl_jmp)
	);
	
	// ID_EXE_REG_PACKED
	wire ID_EXE_is_div_data, ID_EXE_is_sign_div_data, ID_EXE_wcp0_data, ID_EXE_hi_i_sel_data, ID_EXE_lo_i_sel_data, ID_EXE_whi_data, ID_EXE_wlo_data;
	wire ID_EXE_wmem_data, ID_EXE_alusrc0_sel_data, ID_EXE_tlbr_data, ID_EXE_tlbp_data, ID_EXE_wtlb_data, ID_EXE_eret_data, ID_EXE_instMiss_data;
	wire ID_EXE_instValid_data;
	wire [1:0] ID_EXE_result_sel_data, ID_EXE_alusrc1_sel_data, ID_EXE_regdst_data;
	wire [4:0] ID_EXE_rs_data, ID_EXE_rt_data, ID_EXE_rd_data, ID_EXE_tlb_addr_data;
	wire [7:0] ID_EXE_aluop_data;
	wire [31:0] ID_EXE_rf_rdata0_data, ID_EXE_rf_rdata1_data, ID_EXE_hi_data, ID_EXE_lo_data, ID_EXE_COP0_data_data, ID_EXE_Imm32_data, ID_EXE_Instruction_data;
	wire [31:0] ID_EXE_cu_inst_exc_type_data, ID_EXE_if_fetch_exc_type_data;
	wire [89:0] ID_EXE_tlb_wdata_data;
	ID_EXE_REG_PACKED m_ID_EXE_REG_PACKED(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_ram_cache | stcl_div | stcl_DCache | (uncachedLoader_cpu_Stall | uncachedStorer_cpu_Stall)), 
		.irq(exc_en), 
		.clr0(stcl_lw), 
		.clr1(stcl_jmp), 
		.clr2(stcl_f), 
		.is_div(is_div), 
		.ID_EXE_is_div_data(ID_EXE_is_div_data), 
		.is_sign_div(is_sign_div), 
		.ID_EXE_is_sign_div_data(ID_EXE_is_sign_div_data), 
		.cu_inst_exc_type(cu_inst_exc_type), 
		.ID_EXE_cu_inst_exc_type_data(ID_EXE_cu_inst_exc_type_data), 
		.is_delayslot(is_delayslot_o), 
		.ID_EXE_is_delayslot_data(ID_EXE_is_delayslot_data), 
		.wcp0(wcp0), 
		.ID_EXE_wcp0_data(ID_EXE_wcp0_data), 
		.store_type(store_type), 
		.ID_EXE_store_type_data(ID_EXE_store_type_data), 
		.load_type(load_type), 
		.ID_EXE_load_type_data(ID_EXE_load_type_data), 
		.hi_i_sel(hi_i_sel), 
		.ID_EXE_hi_i_sel_data(ID_EXE_hi_i_sel_data), 
		.lo_i_sel(lo_i_sel), 
		.ID_EXE_lo_i_sel_data(ID_EXE_lo_i_sel_data),
		.whi(whi), 
		.ID_EXE_whi_data(ID_EXE_whi_data), 
		.wlo(wlo), 
		.ID_EXE_wlo_data(ID_EXE_wlo_data), 
		.wreg(wreg), 
		.ID_EXE_wreg_data(ID_EXE_wreg_data), 
		.result_sel(result_sel), 
		.ID_EXE_result_sel_data(ID_EXE_result_sel_data), 
		.wmem(wmem), 
		.ID_EXE_wmem_data(ID_EXE_wmem_data), 
		.aluop(aluop), 
		.ID_EXE_aluop_data(ID_EXE_aluop_data), 
		.alusrc0_sel(alusrc0_sel), 
		.ID_EXE_alusrc0_sel_data(ID_EXE_alusrc0_sel_data), 
		.alusrc1_sel(alusrc1_sel), 
		.ID_EXE_alusrc1_sel_data(ID_EXE_alusrc1_sel_data), 
		.regdst(regdst), 
		.ID_EXE_regdst_data(ID_EXE_regdst_data), 
		.rf_rdata0(rf_rdata0), 
		.ID_EXE_rf_rdata0_data(ID_EXE_rf_rdata0_data), 
		.rf_rdata1(rf_rdata1), 
		.ID_EXE_rf_rdata1_data(ID_EXE_rf_rdata1_data), 
		.hi(hi_o), 
		.ID_EXE_hi_data(ID_EXE_hi_data), 
		.lo(lo_o), 
		.ID_EXE_lo_data(ID_EXE_lo_data), 
		.COP0_data(COP0_data), 
		.ID_EXE_COP0_data_data(ID_EXE_COP0_data_data), 
		.rs(IF_ID_Instruction_data[25:21]), 
		.ID_EXE_rs_data(ID_EXE_rs_data), 
		.rt(IF_ID_Instruction_data[20:16]), 
		.ID_EXE_rt_data(ID_EXE_rt_data), 
		.rd(IF_ID_Instruction_data[15:11]), 
		.ID_EXE_rd_data(ID_EXE_rd_data), 
		.Imm32(Imm32), 
		.ID_EXE_Imm32_data(ID_EXE_Imm32_data), 
		.PC_plus4(IF_ID_PC_plus4_data), 
		.ID_EXE_PC_plus4_data(ID_EXE_PC_plus4_data), 
		.if_fetch_exc_type(IF_ID_if_fetch_exc_type_data), 
		.ID_EXE_if_fetch_exc_type_data(ID_EXE_if_fetch_exc_type_data),
		.instruction(IF_ID_Instruction_data),
		.ID_EXE_Instruction_data(ID_EXE_Instruction_data),
		.tlb_addr(tlb_addr), 
		.ID_EXE_tlb_addr_data(ID_EXE_tlb_addr_data), 
		.tlb_wdata(tlb_wdata), 
		.ID_EXE_tlb_wdata_data(ID_EXE_tlb_wdata_data), 
		.tlbr(tlbr), 
		.ID_EXE_tlbr_data(ID_EXE_tlbr_data), 
		.tlbp(tlbp), 
		.ID_EXE_tlbp_data(ID_EXE_tlbp_data),
		.wtlb(wtlb),
		.ID_EXE_wtlb_data(ID_EXE_wtlb_data),
		.asid(IF_ID_asid_data),
		.ID_EXE_asid_data(ID_EXE_asid_data),
		.eret(eret), 
		.ID_EXE_eret_data(ID_EXE_eret_data), 
		.instMiss(IF_ID_instMiss_data), 
		.ID_EXE_instMiss_data(ID_EXE_instMiss_data), 
		.instValid(IF_ID_instValid_data), 
		.ID_EXE_instValid_data(ID_EXE_instValid_data)
	);
	/*always@(*)
		begin
		$display("ID_EXE_load_type_data: 0d%2d, IF_ID_rs_data: 0x%2h, IF_ID_rt_data: 0x%2h, EXE_regdst_data: 0x%2h, ID_EXE_Instruction_data: 0x%8h"
				, ID_EXE_load_type_data, IF_ID_Instruction_data[25:21], IF_ID_Instruction_data[20:16], EXE_regdst_data, ID_EXE_Instruction_data);
		end*/

	/**************************/
	/*          EXE           */
	/**************************/
	// rf_rdata0_fw_mux
	wire [1:0] rf_rdata0_fw_sel;
	wire [31:0] rf_rdata0_fw_mux_data;
	Mux3T1 m_rf_rdata0_fw_mux(
		.s(rf_rdata0_fw_sel), 
		.y(rf_rdata0_fw_mux_data), 
		.d0(ID_EXE_rf_rdata0_data), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// rf_rdata1_fw_mux
	wire [1:0] rf_rdata1_fw_sel;
	wire [31:0] rf_rdata1_fw_mux_data;
	Mux3T1 m_rf_rdata1_fw_mux(
		.s(rf_rdata1_fw_sel), 
		.y(rf_rdata1_fw_mux_data), 
		.d0(ID_EXE_rf_rdata1_data), 
		.d1(EXE_MEM_ALU_result_data), 
		.d2(WB_result_data)
	);
	
	// hi_fw_mux
	wire [1:0] hi_fw_sel;
	wire [31:0] hi_fw_mux_data, MEM_hi_data;
	Mux3T1 m_hi_fw_mux(
		.s(hi_fw_sel), 
		.y(hi_fw_mux_data), 
		.d0(ID_EXE_hi_data), 
		.d1(MEM_hi_data), 
		.d2(WB_hi_data)
	);
	
	// lo_fw_mux
	wire [1:0] lo_fw_sel;
	wire [31:0] lo_fw_mux_data, MEM_lo_data;
	Mux3T1 m_lo_fw_mux(
		.s(lo_fw_sel), 
		.y(lo_fw_mux_data), 
		.d0(ID_EXE_lo_data), 
		.d1(MEM_lo_data), 
		.d2(WB_lo_data)
	);
	
	// ALU_src0_mux
	wire [31:0] src0;
	Mux2T1 m_ALU_src0_mux(
		.s(ID_EXE_alusrc0_sel_data), 
		.y(src0), 
		.d0(rf_rdata0_fw_mux_data), 
		.d1(ID_EXE_Imm32_data)
	); 
	
	// ALU_src1_mux
	wire [31:0] src1;
	Mux4T1 m_ALU_src1_mux(
		.s(ID_EXE_alusrc1_sel_data), 
		.y(src1), 
		.d0(rf_rdata1_fw_mux_data), 
		.d1(hi_fw_mux_data), 
		.d2(lo_fw_mux_data), 
		.d3(ID_EXE_Imm32_data)
	);
	
	// ll_bit_fw_mux
	wire ll_bit_fw_mux_data, ll_bit_o;
	wire MEM_ll_bit_data = (EXE_MEM_load_type_data == `LOAD_LL);
	Mux2T1 #(1) m_ll_bit_fw_mux(
		.s(MEM_ll_bit_data), 
		.y(ll_bit_fw_mux_data), 
		.d0(ll_bit_o), 
		.d1(MEM_ll_bit_data)
	);
	
	// EXE_MEM_modify_tlbr_result
	wire [89:0] EXE_MEM_tlbr_result_data;
	wire [31:0] MEM_modified_tlbr_result_data;
	modify_tlbr_result m_EXE_MEM_modify_tlbr_result(
		.tlbr_result(EXE_MEM_tlbr_result_data), 
		.ID_EXE_rd_data(ID_EXE_rd_data), 
		.modified_tlbr_result(MEM_modified_tlbr_result_data)
	);
	
	// MEM_WB_modify_tlbr_result
	wire [31:0] WB_modified_tlbr_result_data;
	modify_tlbr_result m_MEM_WB_modify_tlbr_result(
		.tlbr_result(MEM_WB_tlbr_result_data), 
		.ID_EXE_rd_data(ID_EXE_rd_data), 
		.modified_tlbr_result(WB_modified_tlbr_result_data)
	);
	
	// COP0_data_fw_mux
	wire [2:0] COP0_rdata_fw_sel;
	wire [31:0] COP0_data_fw_mux_data;
	Mux5T1 m_COP0_data_fw_mux(
		.s(COP0_rdata_fw_sel), 
		.y(COP0_data_fw_mux_data), 
		.d0(ID_EXE_COP0_data_data), 
		.d1(EXE_MEM_ALU_result_data),
		.d2(WB_result_data),
		.d3(MEM_modified_tlbr_result_data),
		.d4(WB_modified_tlbr_result_data)
	);
	
	// MMU
	wire inst_uncached, data_uncached, dataDirty;
	wire [31:0] tlbp_result;
	wire [89:0] tlbr_result;
	MMU m_MMU(
		.clk(clk), 
		.rst_n(rst_n), 
		.wtlb(ID_EXE_wtlb_data),
		.user_mode(user_mode),
		.tlb_addr(ID_EXE_tlb_addr_data), 
		.tlb_wdata(ID_EXE_tlb_wdata_data), 
		.inst_enable(1'b1), 
		.data_enable((EXE_MEM_load_type_data != 4'd0) || (EXE_MEM_store_type_data != 4'd0)), 
		.inst_addr_i(PC_o), 
		.data_addr_i(EXE_MEM_ALU_result_data), 
		.asid(asid), 
		.kseg0_uncached(kseg0_uncached), 
		.inst_addr_o(physical_inst_addr), 
		.data_addr_o(physical_data_addr), 
		.inst_uncached(inst_uncached), 
		.data_uncached(data_uncached), 
		.tlbp_result(tlbp_result), 
		.tlbr_result(tlbr_result),
		.dataMiss(dataMiss), 
		.instMiss(instMiss), 
		.dataDirty(dataDirty), 
		.dataValid(dataValid), 
		.instValid(instValid)
	);
	
	// ALU
	wire ALU_we, ALU_mwe;
	wire [3:0] byte_valid;
	wire [31:0] ALU_exc_type, temp_ALU_result;
	wire [63:0] Mul_result;
	ALU m_ALU(
		.aluop(ID_EXE_aluop_data), 
		.src0(src0), 
		.src1(src1), 
		.ll_bit_o(ll_bit_fw_mux_data), 
		.hilo_o({hi_fw_mux_data, lo_fw_mux_data}), 
		.EXE_PC_plus8(ID_EXE_PC_plus4_data + 32'h4), 
		.COP0_rdata(COP0_data_fw_mux_data), 
		.ALU_result(temp_ALU_result), 
		.ALU_we(ALU_we), 
		.ALU_mwe(ALU_mwe), 
		.Mul_result(Mul_result), 
		.byte_valid(byte_valid), 
		.ALU_exc_type(ALU_exc_type)
	);
	
	// ALU_result_mux
	wire [31:0] ALU_result;
	Mux2T1 m_ALU_result_mux(
		.s(ID_EXE_tlbp_data), 
		.y(ALU_result), 
		.d0(temp_ALU_result), 
		.d1(tlbp_result)
	);
	
	// Divider
	wire [63:0] Div_result;
	Divider m_Divider(
		.clk(clk), 
		.rst_n(rst_n), 
		.a(src0), 
		.b(src1), 
		.start(ID_EXE_is_div_data), 
		.clr(1'b0), 
		.is_sign_div(ID_EXE_is_sign_div_data), 
		.result(Div_result), 
		.busy(stcl_div)
	);
	/*always@(*)
		begin
		$display("src0: 0x%8h, src1: 0x%8h, COP0_data_fw_mux_data: 0x%8h", src0, src1, COP0_data_fw_mux_data);
		end*/
	
	// regdst_mux		decoder
	Mux3T1 #(5) m_regdst_mux(
		.s(ID_EXE_regdst_data), 
		.y(EXE_regdst_data), 
		.d0(ID_EXE_rt_data), 
		.d1(ID_EXE_rd_data),
		.d2(5'd31)
	);
	
	// Forwawrding_Unit
	wire EXE_MEM_wreg_data, EXE_MEM_whi_data, EXE_MEM_wlo_data, EXE_MEM_wcp0_data, EXE_MEM_tlbp_data, EXE_MEM_tlbr_data;
	Forwarding_Unit m_Forwawrding_Unit(
		.rst_n(rst_n), 
		.IF_ID_rs_data(IF_ID_Instruction_data[25:21]), 
		.IF_ID_rt_data(IF_ID_Instruction_data[20:16]), 
		.ID_EXE_rs_data(ID_EXE_rs_data), 
		.ID_EXE_rt_data(ID_EXE_rt_data), 
		.EXE_MEM_wreg_data(EXE_MEM_wreg_data), 
		.EXE_MEM_regdst_data(EXE_MEM_regdst_data), 
		.MEM_WB_wreg_data(MEM_WB_wreg_data), 
		.MEM_WB_regdst_data(MEM_WB_regdst_data), 
		.rf_rdata0_fw_sel(rf_rdata0_fw_sel), 
		.rf_rdata1_fw_sel(rf_rdata1_fw_sel), 
		.rf_jdata0_fw_sel(rf_jdata0_fw_sel), 
		.rf_jdata1_fw_sel(rf_jdata1_fw_sel), 
		.EXE_MEM_whi_data(EXE_MEM_whi_data), 
		.EXE_MEM_wlo_data(EXE_MEM_wlo_data), 
		.MEM_WB_whi_data(MEM_WB_whi_data), 
		.MEM_WB_wlo_data(MEM_WB_wlo_data), 
		.hi_fw_sel(hi_fw_sel), 
		.lo_fw_sel(lo_fw_sel), 
		.ID_EXE_rd_data(ID_EXE_rd_data), 
		.EXE_MEM_wcp0_data(EXE_MEM_wcp0_data),
		.EXE_MEM_tlbp_data(EXE_MEM_tlbp_data),
		.EXE_MEM_tlbr_data(EXE_MEM_tlbr_data),
		.MEM_WB_tlbp_data(MEM_WB_tlbp_data),
		.MEM_WB_tlbr_data(MEM_WB_tlbr_data),
		.MEM_WB_wcp0_data(MEM_WB_wcp0_data), 
		.COP0_rdata_fw_sel(COP0_rdata_fw_sel)
	);

	// ll_bit
	wire [3:0] MEM_WB_load_type_data;
	wire WB_ll_bit_data = (MEM_WB_load_type_data == `LOAD_LL);
	ll_bit m_ll_bit(
		.clk(clk), 
		.rst_n(rst_n), 
		.clr(exc_en), 
		.ll_bit_i(WB_ll_bit_data), 
		.wll(WB_ll_bit_data), 
		.ll_bit_o(ll_bit_o)
	);
	
	// EXE_MEM_REG_PACKED
	wire EXE_MEM_hi_i_sel_data, EXE_MEM_lo_i_sel_data, EXE_MEM_wmem_data, EXE_MEM_SC_result_sel_data;
	wire [1:0] EXE_MEM_result_sel_data;
	wire [3:0] EXE_MEM_byte_valid_data;
	wire [31:0] EXE_MEM_rf_rdata0_fw_data, EXE_MEM_rf_rdata1_fw_data, EXE_MEM_Instruction_data;
	wire [63:0] EXE_MEM_MulDiv_result_data;
	always@(*)
		begin
		$display("stcl_DCache ^ (EXE_MEM_load_type_data != 4'b0): 0b%1b, EXE_MEM_load_type_data: 0x%1h"
				, (stcl_DCache ^ (EXE_MEM_load_type_data != 4'b0)), EXE_MEM_load_type_data);
		end
	EXE_MEM_REG_PACKED m_EXE_MEM_REG_PACKED(
		.clk(~clk), 
		.rst_n(rst_n), 
		.stall0(1'b0), 
		.stall1(stcl_ram_cache | (stcl_DCache) | (uncachedLoader_cpu_Stall | uncachedStorer_cpu_Stall)), 
		.irq(exc_en), 
		.clr(stcl_div), 
		.exc_type(ID_EXE_cu_inst_exc_type_data | ID_EXE_if_fetch_exc_type_data | ALU_exc_type), 
		.EXE_MEM_exc_type_data(EXE_MEM_exc_type_data), 
		.is_delayslot(ID_EXE_is_delayslot_data), 
		.EXE_MEM_is_delayslot_data(EXE_MEM_is_delayslot_data), 
		.int_i(int_i), 
		.EXE_MEM_int_i_data(EXE_MEM_int_i_data), 
		.wcp0(ID_EXE_wcp0_data), 
		.EXE_MEM_wcp0_data(EXE_MEM_wcp0_data), 
		.store_type(ID_EXE_store_type_data), 
		.EXE_MEM_store_type_data(EXE_MEM_store_type_data), 
		.load_type(ID_EXE_load_type_data), 
		.EXE_MEM_load_type_data(EXE_MEM_load_type_data), 
		.hi_i_sel(ID_EXE_hi_i_sel_data), 
		.EXE_MEM_hi_i_sel_data(EXE_MEM_hi_i_sel_data), 
		.lo_i_sel(ID_EXE_lo_i_sel_data),
		.EXE_MEM_lo_i_sel_data(EXE_MEM_lo_i_sel_data), 
		.whi(ID_EXE_whi_data & ALU_we), 
		.EXE_MEM_whi_data(EXE_MEM_whi_data), 
		.wlo(ID_EXE_wlo_data & ALU_we), 
		.EXE_MEM_wlo_data(EXE_MEM_wlo_data), 
		.wreg(ID_EXE_wreg_data & ALU_we), 
		.EXE_MEM_wreg_data(EXE_MEM_wreg_data), 
		.result_sel(ID_EXE_result_sel_data), 
		.EXE_MEM_result_sel_data(EXE_MEM_result_sel_data), 
		.wmem(ID_EXE_wmem_data & ALU_mwe), 
		.EXE_MEM_wmem_data(EXE_MEM_wmem_data), 
		.rf_rdata0_fw(rf_rdata0_fw_mux_data), 
		.EXE_MEM_rf_rdata0_fw_data(EXE_MEM_rf_rdata0_fw_data), 
		.rf_rdata1_fw(rf_rdata1_fw_mux_data), 
		.EXE_MEM_rf_rdata1_fw_data(EXE_MEM_rf_rdata1_fw_data), 
		.ALU_result(ALU_result), 
		.EXE_MEM_ALU_result_data(EXE_MEM_ALU_result_data), 
		.SC_result_sel(ALU_mwe), 
		.EXE_MEM_SC_result_sel_data(EXE_MEM_SC_result_sel_data), 
		.byte_valid(byte_valid), 
		.EXE_MEM_byte_valid_data(EXE_MEM_byte_valid_data), 
		.MulDiv_result(ID_EXE_is_div_data ? Div_result : Mul_result), 
		.EXE_MEM_MulDiv_result_data(EXE_MEM_MulDiv_result_data), 
		.regdst(EXE_regdst_data), 
		.EXE_MEM_regdst_data(EXE_MEM_regdst_data), 
		.PC_plus4(ID_EXE_PC_plus4_data), 
		.EXE_MEM_PC_plus4_data(EXE_MEM_PC_plus4_data),
		.tlbr(ID_EXE_tlbr_data),
		.EXE_MEM_tlbr_data(EXE_MEM_tlbr_data),
		.tlbp(ID_EXE_tlbp_data),
		.EXE_MEM_tlbp_data(EXE_MEM_tlbp_data),
		.tlbr_result(tlbr_result),
		.EXE_MEM_tlbr_result_data(EXE_MEM_tlbr_result_data),
		.asid(ID_EXE_asid_data), 
		.EXE_MEM_asid_data(EXE_MEM_asid_data), 
		.eret(ID_EXE_eret_data), 
		.EXE_MEM_eret_data(EXE_MEM_eret_data), 
		.instMiss(ID_EXE_instMiss_data), 
		.EXE_MEM_instMiss_data(EXE_MEM_instMiss_data), 
		.instValid(ID_EXE_instValid_data), 
		.EXE_MEM_instValid_data(EXE_MEM_instValid_data),
		// for test only
		.instruction(ID_EXE_Instruction_data),
		.EXE_MEM_Instruction_data(EXE_MEM_Instruction_data)
	);
	/*always@(*)
		begin
		$display("rf_jdata0_fw_mux_data: 0x%8h, rf_rdata0: 0x%8h, EXE_MEM_ALU_result_data: 0x%8h, WB_result_data: 0x%8h, EXE_MEM_Instruction_data: 0x%8h, EXE_MEM_load_type_data: 0x%8h"
				, rf_jdata0_fw_mux_data, rf_rdata0, EXE_MEM_ALU_result_data, WB_result_data, EXE_MEM_Instruction_data, EXE_MEM_load_type_data);
		$display("rf_jdata1_fw_mux_data: 0x%8h, rf_rdata1: 0x%8h, EXE_MEM_ALU_result_data: 0x%8h, WB_result_data: 0x%8h"
				, rf_jdata1_fw_mux_data, rf_rdata1, EXE_MEM_ALU_result_data, WB_result_data);
		end*/

	/**************************/
	/*          MEM           */
	/**************************/
	/*always@(*)
		begin
		if(EXE_MEM_load_type_data != 4'd0)
			begin
			$display("Load data -> instruction: 0x%8h, addr: 0x%8h, destreg: 0x%2h"
					, EXE_MEM_Instruction_data, physical_sphysical_data_addr, EXE_MEM_Instruction_data[20:16]);
			$display("EXE_MEM_rf_rdata1_fw_data: 0x%8h, EXE_MEM_PC_data: 0x%8h, mem_en_M: 0b%1b, mem_wen: 0b%1b, EXE_MEM_byte_valid_data: 0b%4b"
					, EXE_MEM_rf_rdata1_fw_data, EXE_MEM_PC_plus4_data - 32'h4, (EXE_MEM_load_type_data != 4'd0) || (EXE_MEM_store_type_data != 4'd0)
					, EXE_MEM_wmem_data && !MEM_store_exc, EXE_MEM_byte_valid_data);
			$display();
			end
		else if(EXE_MEM_store_type_data != 4'd0)
			begin
			$display("Store data -> instruction: 0x%8h, addr: 0x%8h, data: 0x%8h, mem_wdata: 0x%8h"
					, EXE_MEM_Instruction_data, physical_sphysical_data_addr, EXE_MEM_rf_rdata1_fw_data, mem_wdata);
			$display("EXE_MEM_rf_rdata1_fw_data: 0x%8h, EXE_MEM_PC_data: 0x%8h, mem_en_M: 0b%1b, mem_wen: 0b%1b, EXE_MEM_byte_valid_data: 0b%4b"
					, EXE_MEM_rf_rdata1_fw_data, EXE_MEM_PC_plus4_data - 32'h4, (EXE_MEM_load_type_data != 4'd0) || (EXE_MEM_store_type_data != 4'd0)
					, EXE_MEM_wmem_data && !MEM_store_exc, EXE_MEM_byte_valid_data);
			$display();
			end
		end*/
	
	// modifyStoreData
	wire [31:0] mem_wdata;
	modifyStoreData m_modifyStoreData(
		.mem_wdata_i(EXE_MEM_rf_rdata1_fw_data), 
		.store_type(EXE_MEM_store_type_data), 
		.byte_valid(EXE_MEM_byte_valid_data), 
		.mem_wdata_o(mem_wdata)
	);
	
	// DCache
	wire DCache_grnt, DCache_req, DCache_arvalid, DCache_arready, DCache_rlast, DCache_rvalid, DCache_rready;
	wire DCache_write_grnt, DCache_write_req, DCache_awvalid, DCache_awready, DCache_wlast, DCache_wvalid, DCache_wready, DCache_bvalid, DCache_bready;
	wire [1:0] DCache_arburst, DCache_arlock, DCache_rresp, DCache_awburst, DCache_awlock, DCache_bresp;
	wire [2:0] DCache_arsize, DCache_arprot, DCache_awsize, DCache_awprot;
	wire [3:0] DCache_arid, DCache_arlen, DCache_arcache, DCache_rid, DCache_awid, DCache_awlen, DCache_awcache;
	wire [3:0] DCache_bid, DCache_wid, DCache_wstrb;
	wire [31:0] DCache_araddr, DCache_rdata, DCache_awaddr, DCache_wdata, DCache_mem_rdata;
	DCache m_DCache(
		.clk					(~clk),
		.rst_n					(rst_n),
		.DCache_grnt			(DCache_grnt),
		.DCache_req				(DCache_req),
		.DCache_arid			(DCache_arid),
		.DCache_araddr			(DCache_araddr),
		.DCache_arlen			(DCache_arlen),
		.DCache_arsize			(DCache_arsize),
		.DCache_arburst			(DCache_arburst),
		.DCache_arlock			(DCache_arlock),
		.DCache_arcache			(DCache_arcache),
		.DCache_arprot 			(DCache_arprot),
		.DCache_arvalid 		(DCache_arvalid),
		.DCache_arready			(DCache_arready),
		.DCache_rid				(DCache_rid),
		.DCache_rdata			(DCache_rdata),
		.DCache_rresp			(DCache_rresp),
		.DCache_rlast			(DCache_rlast),
		.DCache_rvalid 			(DCache_rvalid),
		.DCache_rready			(DCache_rready),
		.DCache_write_grnt		(DCache_write_grnt),
		.DCache_write_req		(DCache_write_req),
		.DCache_awid			(DCache_awid),
		.DCache_awaddr			(DCache_awaddr),
		.DCache_awlen			(DCache_awlen),
		.DCache_awsize			(DCache_awsize),
		.DCache_awburst			(DCache_awburst),
		.DCache_awlock			(DCache_awlock),
		.DCache_awcache			(DCache_awcache),
		.DCache_awprot			(DCache_awprot),
		.DCache_awvalid			(DCache_awvalid),
		.DCache_awready			(DCache_awready),
		.DCache_wid				(DCache_wid),
		.DCache_wdata			(DCache_wdata),
		.DCache_wstrb			(DCache_wstrb),
		.DCache_wlast			(DCache_wlast),
		.DCache_wvalid			(DCache_wvalid),
		.DCache_wready			(DCache_wready),
		.DCache_bid				(DCache_bid),
		.DCache_bresp			(DCache_bresp),
		.DCache_bvalid			(DCache_bvalid),
		.DCache_bready			(DCache_bready),
		.DCache_cpu_uncached	(data_uncached),
		.DCache_cpu_re			(EXE_MEM_load_type_data != 4'b0),
		.DCache_cpu_we			(EXE_MEM_store_type_data != 4'b0),
		.DCache_cpu_addr		(physical_data_addr),
		.DCache_cpu_byte_enable	(EXE_MEM_byte_valid_data),
		.DCache_cpu_wdata		(mem_wdata),
		.DCache_cpu_rdata		(DCache_mem_rdata),
		.DCache_cpu_Stall		(stcl_DCache),
		.DCache_IF_Stall		(DCache_IF_Stall),
		.DCache_State_Hit		(DCache_State_Hit)
	);
	assign DCache_grnt = m1_grnt;
	assign m1_req = DCache_req;
	assign m1_arid = DCache_arid;
	assign m1_araddr = DCache_araddr;
	assign m1_arlen = DCache_arlen;
	assign m1_arsize = DCache_arsize;
	assign m1_arburst = DCache_arburst;
	assign m1_arlock = DCache_arlock;
	assign m1_arcache = DCache_arcache;
	assign m1_arprot = DCache_arprot;
	assign m1_arvalid = DCache_arvalid;
	assign DCache_arready = m1_arready;
	assign DCache_rid = m1_rid;
	assign DCache_rdata = m1_rdata;
	assign DCache_rresp = m1_rresp;
	assign DCache_rlast = m1_rlast;
	assign DCache_rvalid = m1_rvalid;
	assign m1_rready = DCache_rready;
	
	assign DCache_write_grnt = m1_write_grnt;
	assign m1_write_req = DCache_write_req;
	assign m1_awid = DCache_awid;
	assign m1_awaddr = DCache_awaddr;
	assign m1_awlen = DCache_awlen;
	assign m1_awsize = DCache_awsize;
	assign m1_awburst = DCache_awburst;
	assign m1_awlock = DCache_awlock;
	assign m1_awcache = DCache_awcache;
	assign m1_awprot = DCache_awprot;
	assign m1_awvalid = DCache_awvalid;
	assign DCache_awready = m1_awready;
	assign m1_wid = DCache_wid;
	assign m1_wdata = DCache_wdata;
	assign m1_wstrb = DCache_wstrb;
	assign m1_wlast = DCache_wlast;
	assign m1_wvalid = DCache_wvalid;
	assign DCache_wready = m1_wready;
	assign DCache_bid = m1_bid;
	assign DCache_bresp = m1_bresp;
	assign DCache_bvalid = m1_bvalid;
	assign m1_bready = DCache_bready;
	always@(*)
		begin
		$display("DCache_req: 0b%1b, DCache_grnt: 0b%1b", DCache_req, DCache_grnt);
		$display("DCache_arid: 0x%1h, DCache_araddr: 0x%8h, DCache_arlen: 0x%1h, DCache_arsize: 0x%1h, DCache_arburst: 0x%1h"
				, DCache_arid, DCache_araddr, DCache_arlen, DCache_arsize, DCache_arburst);
		$display("DCache_arlock: 0x%1h, DCache_arcache: 0x%1h, DCache_arprot: 0x%1h, DCache_arvalid: 0b%1b, DCache_arready: 0b%1b"
				, DCache_arlock, DCache_arcache, DCache_arprot, DCache_arvalid, DCache_arready);
		$display("DCache_rid: 0x%1h, DCache_rdata: 0x%8h, DCache_rvalid: 0b%1b, DCache_rready: 0b%1b"
				, DCache_rid, DCache_rdata, DCache_rvalid, DCache_rready);
		end
	
	// uncachedLoader
	wire uncachedLoader_req, uncachedLoader_grnt;
	wire uncachedLoader_arvalid, uncachedLoader_arready, uncachedLoader_rlast, uncachedLoader_rvalid, uncachedLoader_rready;
	wire [1 :0] uncachedLoader_arburst, uncachedLoader_arlock, uncachedLoader_rresp;
	wire [2 :0] uncachedLoader_arsize, uncachedLoader_arprot;
	wire [3 :0] uncachedLoader_arid, uncachedLoader_arlen, uncachedLoader_arcache, uncachedLoader_rid;
	wire [31:0] uncachedLoader_araddr, uncachedLoader_rdata, uncachedLoader_mem_rdata;
	uncachedLoader m_uncachedLoader(
		.clk							(~clk							),
		.rst_n							(rst_n							),
		
		// AXI read channel signals
		.uncachedLoader_req				(uncachedLoader_req				),
		.uncachedLoader_grnt			(uncachedLoader_grnt			),
		// read address channel signals
		.uncachedLoader_arid			(uncachedLoader_arid			),
		.uncachedLoader_araddr			(uncachedLoader_araddr			),
		.uncachedLoader_arlen			(uncachedLoader_arlen			),
		.uncachedLoader_arsize			(uncachedLoader_arsize			),
		.uncachedLoader_arburst			(uncachedLoader_arburst			),
		.uncachedLoader_arlock			(uncachedLoader_arlock			),
		.uncachedLoader_arcache			(uncachedLoader_arcache			),
		.uncachedLoader_arprot 			(uncachedLoader_arprot			),
		.uncachedLoader_arvalid 		(uncachedLoader_arvalid			),
		.uncachedLoader_arready			(uncachedLoader_arready			),
		// read data channel signals           
		.uncachedLoader_rid				(uncachedLoader_rid				),
		.uncachedLoader_rdata			(uncachedLoader_rdata			),
		.uncachedLoader_rresp			(uncachedLoader_rresp			),
		.uncachedLoader_rlast			(uncachedLoader_rlast			),
		.uncachedLoader_rvalid 			(uncachedLoader_rvalid			),
		.uncachedLoader_rready			(uncachedLoader_rready			),
		
		// CPU read 
		.uncachedLoader_cpu_uncached	(data_uncached					),
		.uncachedLoader_cpu_re			(EXE_MEM_load_type_data != 4'b0	),
		.uncachedLoader_cpu_addr		(physical_data_addr				),
		.uncachedLoader_cpu_rdata		(uncachedLoader_mem_rdata		),
		.uncachedLoader_cpu_Stall		(uncachedLoader_cpu_Stall		),
		.uncachedLoader_cpu_PC_Stall	(uncachedLoader_cpu_PC_Stall	)
	);
	always@(*)
		begin
		$display("data_uncached: 0b%1b, EXE_MEM_load_type_data: 0x%1h, uncachedLoader_cpu_Stall: 0b%1b, uncachedLoader_mem_rdata: 0x%8h, DCache_mem_rdata: 0x%8h"
				, data_uncached, EXE_MEM_load_type_data, uncachedLoader_cpu_Stall, uncachedLoader_mem_rdata, DCache_mem_rdata);
		end
	assign uncachedLoader_grnt = m0_grnt;
	assign m0_req = uncachedLoader_req;
	assign m0_arid = uncachedLoader_arid;
	assign m0_araddr = uncachedLoader_araddr;
	assign m0_arlen = uncachedLoader_arlen;
	assign m0_arsize = uncachedLoader_arsize;
	assign m0_arburst = uncachedLoader_arburst;
	assign m0_arlock = uncachedLoader_arlock;
	assign m0_arcache = uncachedLoader_arcache;
	assign m0_arprot = uncachedLoader_arprot;
	assign m0_arvalid = uncachedLoader_arvalid;
	assign uncachedLoader_arready = m0_arready;
	assign uncachedLoader_rid = m0_rid;
	assign uncachedLoader_rdata = m0_rdata;
	assign uncachedLoader_rresp = m0_rresp;
	assign uncachedLoader_rlast = m0_rlast;
	assign uncachedLoader_rvalid = m0_rvalid;
	assign m0_rready = uncachedLoader_rready;
	
	// mem_rdata_mux
	Mux2T1 mem_rdata_mux(
		.s(data_uncached), 
		.y(mem_rdata), 
		.d0(DCache_mem_rdata), 
		.d1(uncachedLoader_mem_rdata)
	);
	
	// uncachedStorer
	wire uncachedStorer_grnt, uncachedStorer_req, uncachedStorer_awvalid, uncachedStorer_awready, uncachedStorer_wlast;
	wire uncachedStorer_wvalid, uncachedStorer_wready, uncachedStorer_bvalid, uncachedStorer_bready;
	wire [1:0] uncachedStorer_awburst, uncachedStorer_awlock, uncachedStorer_bresp;
	wire [2:0] uncachedStorer_awsize, uncachedStorer_awprot;
	wire [3:0] uncachedStorer_awid, uncachedStorer_awlen, uncachedStorer_awcache;
	wire [3:0] uncachedStorer_bid, uncachedStorer_wid, uncachedStorer_wstrb;
	wire [31:0] uncachedStorer_awaddr, uncachedStorer_wdata;
	uncachedStorer m_uncachedStorer(
		.clk							(~clk),
		.rst_n							(rst_n),
		
		// AXI read channel signals
		.uncachedStorer_req				(uncachedStorer_req),
		.uncachedStorer_grnt			(uncachedStorer_grnt),
		// AXI write channel signals
		// write address channel signals       
		.uncachedStorer_awid			(uncachedStorer_awid),
		.uncachedStorer_awaddr			(uncachedStorer_awaddr),
		.uncachedStorer_awlen			(uncachedStorer_awlen),
		.uncachedStorer_awsize			(uncachedStorer_awsize),
		.uncachedStorer_awburst			(uncachedStorer_awburst),
		.uncachedStorer_awlock			(uncachedStorer_awlock),
		.uncachedStorer_awcache			(uncachedStorer_awcache),
		.uncachedStorer_awprot			(uncachedStorer_awprot),
		.uncachedStorer_awvalid			(uncachedStorer_awvalid),
		.uncachedStorer_awready			(uncachedStorer_awready),
		// write data channel signals
		.uncachedStorer_wid				(uncachedStorer_wid),
		.uncachedStorer_wdata			(uncachedStorer_wdata),
		.uncachedStorer_wstrb			(uncachedStorer_wstrb),
		.uncachedStorer_wlast			(uncachedStorer_wlast),
		.uncachedStorer_wvalid			(uncachedStorer_wvalid),
		.uncachedStorer_wready			(uncachedStorer_wready),
		// write response channel signals
		.uncachedStorer_bid				(uncachedStorer_bid),
		.uncachedStorer_bresp			(uncachedStorer_bresp),
		.uncachedStorer_bvalid			(uncachedStorer_bvalid),
		.uncachedStorer_bready			(uncachedStorer_bready),
		
		// CPU read
		.uncachedStorer_cpu_uncached	(data_uncached),
		.uncachedStorer_cpu_we			(EXE_MEM_store_type_data != 4'b0),
		.uncachedStorer_cpu_addr		(physical_data_addr),
		.uncachedStorer_cpu_byte_enable	(EXE_MEM_byte_valid_data),
		.uncachedStorer_cpu_wdata		(mem_wdata),
		.uncachedStorer_cpu_Stall		(uncachedStorer_cpu_Stall),
		.uncachedStorer_cpu_PC_Stall	(uncachedStorer_cpu_PC_Stall)
	);
	assign uncachedStorer_grnt = m0_write_grnt;
	assign m0_write_req = uncachedStorer_req;
	assign m0_awid = uncachedStorer_awid;
	assign m0_awaddr = uncachedStorer_awaddr;
	assign m0_awlen = uncachedStorer_awlen;
	assign m0_awsize = uncachedStorer_awsize;
	assign m0_awburst = uncachedStorer_awburst;
	assign m0_awlock = uncachedStorer_awlock;
	assign m0_awcache = uncachedStorer_awcache;
	assign m0_awprot = uncachedStorer_awprot;
	assign m0_awvalid = uncachedStorer_awvalid;
	assign uncachedStorer_awready = m0_awready;
	assign m0_wid = uncachedStorer_wid;
	assign m0_wdata = uncachedStorer_wdata;
	assign m0_wstrb = uncachedStorer_wstrb;
	assign m0_wlast = uncachedStorer_wlast;
	assign m0_wvalid = uncachedStorer_wvalid;
	assign uncachedStorer_wready = m0_wready;
	assign uncachedStorer_bid = m0_bid;
	assign uncachedStorer_bresp = m0_bresp;
	assign uncachedStorer_bvalid = m0_bvalid;
	assign m0_bready = uncachedStorer_bready;
	
	// TLBExcDetector
	TLBExcDetector m_TLBExcDetector(
		.instMiss(EXE_MEM_instMiss_data), 
		.dataMiss(dataMiss), 
		.instValid(EXE_MEM_instValid_data), 
		.dataValid(dataValid), 
		.dataDirty(dataDirty), 
		.wmem(EXE_MEM_wmem_data), 
		.tlb_exc_type(MEM_tlb_exc_type)
	);
	
	// MEM_hi_fw_mux
	Mux2T1 m_MEM_hi_fw_mux(
		.s(EXE_MEM_hi_i_sel_data), 
		.y(MEM_hi_data), 
		.d0(EXE_MEM_ALU_result_data), 
		.d1(EXE_MEM_MulDiv_result_data[63:32])
	);
	
	// MEM_lo_fw_mux
	Mux2T1 m_MEM_lo_fw_mux(
		.s(EXE_MEM_lo_i_sel_data), 
		.y(MEM_lo_data), 
		.d0(EXE_MEM_ALU_result_data), 
		.d1(EXE_MEM_MulDiv_result_data[31:0])
	);
	
	/*// modifyLoaddata
	wire [31:0] modifiedLoadData;
	modifyLoaddata m_modifyLoaddata(
		.mem_rdata_i(mem_rdata), 
		.rf_rdata_i(EXE_MEM_rf_rdata1_fw_data), 
		.load_type(EXE_MEM_load_type_data), 
		.byte_valid(EXE_MEM_byte_valid_data), 
		.mem_rdata_o(modifiedLoadData)
	);*/
	
	// MEM_WB_REG_PACKED
	wire MEM_WB_hi_i_sel_data, MEM_WB_lo_i_sel_data, MEM_WB_SC_result_sel_data;
	wire [1:0] MEM_WB_result_sel_data;
	wire [3:0] MEM_WB_byte_valid_data;
	wire [31:0] MEM_WB_rf_rdata0_fw_data, MEM_WB_rf_rdata1_fw_data, MEM_WB_ALU_result_data, MEM_WB_mem_rdata_data, MEM_WB_PC_plus4_data;
	wire [63:0] MEM_WB_MulDiv_result_data;
	MEM_WB_REG_PACKED m_MEM_WB_REG_PACKED(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall0(stcl_ram_cache), 
		.irq(exc_en | (stcl_DCache) | (uncachedLoader_cpu_Stall | uncachedStorer_cpu_Stall)), 
		.wcp0(EXE_MEM_wcp0_data), 
		.MEM_WB_wcp0_data(MEM_WB_wcp0_data), 
		.load_type(EXE_MEM_load_type_data), 
		.MEM_WB_load_type_data(MEM_WB_load_type_data), 
		.hi_i_sel(EXE_MEM_hi_i_sel_data), 
		.MEM_WB_hi_i_sel_data(MEM_WB_hi_i_sel_data), 
		.lo_i_sel(EXE_MEM_lo_i_sel_data),
		.MEM_WB_lo_i_sel_data(MEM_WB_lo_i_sel_data), 
		.whi(EXE_MEM_whi_data), 
		.MEM_WB_whi_data(MEM_WB_whi_data), 
		.wlo(EXE_MEM_wlo_data), 
		.MEM_WB_wlo_data(MEM_WB_wlo_data), 
		.wreg(EXE_MEM_wreg_data), 
		.MEM_WB_wreg_data(MEM_WB_wreg_data), 
		.result_sel(EXE_MEM_result_sel_data), 
		.MEM_WB_result_sel_data(MEM_WB_result_sel_data),  
		.rf_rdata0_fw(EXE_MEM_rf_rdata0_fw_data), 
		.MEM_WB_rf_rdata0_fw_data(MEM_WB_rf_rdata0_fw_data), 
		.rf_rdata1_fw(EXE_MEM_rf_rdata1_fw_data), 
		.MEM_WB_rf_rdata1_fw_data(MEM_WB_rf_rdata1_fw_data), 
		.ALU_result(EXE_MEM_ALU_result_data), 
		.MEM_WB_ALU_result_data(MEM_WB_ALU_result_data), 
		.SC_result_sel(EXE_MEM_SC_result_sel_data), 
		.MEM_WB_SC_result_sel_data(MEM_WB_SC_result_sel_data), 
		.byte_valid(EXE_MEM_byte_valid_data), 
		.MEM_WB_byte_valid_data(MEM_WB_byte_valid_data), 
		.MulDiv_result(EXE_MEM_MulDiv_result_data), 
		.MEM_WB_MulDiv_result_data(MEM_WB_MulDiv_result_data), 
		.regdst(EXE_MEM_regdst_data), 
		.MEM_WB_regdst_data(MEM_WB_regdst_data), 
		.mem_rdata(mem_rdata), 		// .mem_rdata(modifiedLoadData),
		.MEM_WB_mem_rdata_data(MEM_WB_mem_rdata_data),
		.tlbr(EXE_MEM_tlbr_data),
		.MEM_WB_tlbr_data(MEM_WB_tlbr_data),
		.tlbp(EXE_MEM_tlbp_data),
		.MEM_WB_tlbp_data(MEM_WB_tlbp_data),
		.tlbr_result(EXE_MEM_tlbr_result_data),
		.MEM_WB_tlbr_result_data(MEM_WB_tlbr_result_data),
		// for test
		.PC_plus4(EXE_MEM_PC_plus4_data),
		.MEM_WB_PC_plus4_data(MEM_WB_PC_plus4_data),
		.instruction(EXE_MEM_Instruction_data),
		.MEM_WB_Instruction_data(MEM_WB_Instruction_data)
	);
	/*always@(*)
		begin
		$display("MEM_WB_mem_rdata_data: 0x%8h, MEM_WB_ALU_result_data: 0x%8h"
				, MEM_WB_mem_rdata_data, MEM_WB_ALU_result_data);
		end*/
	
	/**************************/
	/*           WB           */
	/**************************/
	// modifyLoaddata
	wire [31:0] modifiedLoadData;
	modifyLoaddata m_modifyLoaddata(
		.mem_rdata_i(MEM_WB_mem_rdata_data), 
		.rf_rdata_i(MEM_WB_rf_rdata1_fw_data), 
		.load_type(MEM_WB_load_type_data), 
		.byte_valid(MEM_WB_byte_valid_data), 
		.mem_rdata_o(modifiedLoadData)
	);
	/*always@(*)
		begin
		$display("MEM_WB_mem_rdata_data: 0x%8h, modifiedLoadData: 0x%8h, MEM_WB_load_type_data: 0d%2d"
				, MEM_WB_mem_rdata_data, modifiedLoadData, MEM_WB_load_type_data);
		end*/
	/*always@(*)
		begin
		$display("MEM_WB_mem_rdata_data: 0x%8h, MEM_WB_load_type_data: 0d%2d"
				, MEM_WB_mem_rdata_data, MEM_WB_load_type_data);
		end*/
	
	// result_mux
	wire [31:0] result_mux_data;
	Mux4T1 m_result_mux(
		.s(MEM_WB_result_sel_data), 
		.y(result_mux_data), 
		.d0(modifiedLoadData),		// .d0(MEM_WB_mem_rdata_data),
		.d1(MEM_WB_ALU_result_data), 
		.d2({31'b0, MEM_WB_SC_result_sel_data}), 
		.d3(MEM_WB_ALU_result_data)
	);
	assign WB_result_data = result_mux_data;
	/*always@(posedge clk)
		begin
		# 1;
		$display("modifiedLoadData: 0x%8h, MEM_WB_ALU_result_data: 0x%8h, EXE_MEM_ALU_result_data: 0x%8h, ALU_result: 0x%8h, src0: 0x%8h, src1: 0x%8h"
				, modifiedLoadData, MEM_WB_ALU_result_data, EXE_MEM_ALU_result_data, ALU_result, src0, src1);
		end*/
	
	// WB_hi_fw_mux
	Mux2T1 m_WB_hi_fw_mux(
		.s(MEM_WB_hi_i_sel_data), 
		.y(WB_hi_data), 
		.d0(result_mux_data), 
		.d1(MEM_WB_MulDiv_result_data[63:32])
	);
	
	// WB_lo_fw_mux
	Mux2T1 m_WB_lo_fw_mux(
		.s(MEM_WB_lo_i_sel_data), 
		.y(WB_lo_data), 
		.d0(result_mux_data), 
		.d1(MEM_WB_MulDiv_result_data[31:0])
	);
	/*always@(*)
		begin
		$display("Div_result: 0x%16h, result_mux_data: 0x%8h, MEM_WB_MulDiv_result_data: 0x%8h, WB_lo_data: 0x%8h"
				, Div_result, result_mux_data, MEM_WB_MulDiv_result_data, WB_lo_data);
		end*/
	
	// for debug
	always@(posedge clk)
		begin
		# 1;
		$display("wb_pc: 0x%8h, wb_pc_d: 0d%8d, MEM_WB_Instruction_data: 0x%8h, WB_result_data: 0x%8h, debug_wb_rf_wnum: 0x%2h, debug_wb_rf_wen: 0b%4b, IF_PC: 0x%8h"
				, debug_wb_pc, debug_wb_pc[19:2], MEM_WB_Instruction_data, WB_result_data, debug_wb_rf_wnum, debug_wb_rf_wen, physical_inst_addr);
		end
	assign debug_wb_inst = MEM_WB_Instruction_data;
	assign debug_wb_pc = MEM_WB_PC_plus4_data - 32'h4;
	assign debug_wb_rf_wdata = WB_result_data;
	assign debug_wb_rf_wen = (MEM_WB_load_type_data == 4'b0) ? {4{MEM_WB_wreg_data}} : {4{MEM_WB_wreg_data}};// MEM_WB_byte_valid_data & {4{MEM_WB_wreg_data}};
	assign debug_wb_rf_wnum = MEM_WB_regdst_data;
endmodule