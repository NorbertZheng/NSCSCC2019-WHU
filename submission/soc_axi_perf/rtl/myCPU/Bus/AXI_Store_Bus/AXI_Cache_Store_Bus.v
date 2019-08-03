module AXI_Cache_Store_Bus(
	input				clk					,
	input				rst_n				,
	// AXI write signals
	// write address channel signals
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
	// write data channel signals
	output		[3 :0]	wid					,
	output		[31:0]	wdata				,
	output		[3 :0]	wstrb				,
	output				wlast				,
	output				wvalid				,
	input				wready				,
	// write response channel signals
	input		[3 :0]	bid					,
	input		[1 :0]	bresp				,
	input				bvalid				,
	output				bready				,
	
	// master0
	output				m0_grnt				,
	input				m0_req				,
	// master0 write address channel signals
	input		[3 :0]	m0_awid				,
	input		[31:0]	m0_awaddr			,
	input		[3 :0]	m0_awlen			,
	input		[2 :0]	m0_awsize			,
	input		[1 :0]	m0_awburst			,
	input		[1 :0]	m0_awlock			,
	input		[3 :0]	m0_awcache			,
	input		[2 :0]	m0_awprot			,
	input				m0_awvalid			,
	output				m0_awready			,
	// master0 write data channel signals
	input		[3 :0]	m0_wid				,
	input		[31:0]	m0_wdata			,
	input		[3 :0]	m0_wstrb			,
	input				m0_wlast			,
	input				m0_wvalid			,
	output				m0_wready			,
	// master0 write response channel signals
	output		[3 :0]	m0_bid				,
	output		[1 :0]	m0_bresp			,
	output				m0_bvalid			,
	input				m0_bready			,
	
	// master1
	output				m1_grnt				,
	input				m1_req				,
	// master1 write address channel signals
	input		[3 :0]	m1_awid				,
	input		[31:0]	m1_awaddr			,
	input		[3 :0]	m1_awlen			,
	input		[2 :0]	m1_awsize			,
	input		[1 :0]	m1_awburst			,
	input		[1 :0]	m1_awlock			,
	input		[3 :0]	m1_awcache			,
	input		[2 :0]	m1_awprot			,
	input				m1_awvalid			,
	output				m1_awready			,
	// master1 write data channel signals
	input		[3 :0]	m1_wid				,
	input		[31:0]	m1_wdata			,
	input		[3 :0]	m1_wstrb			,
	input				m1_wlast			,
	input				m1_wvalid			,
	output				m1_wready			,
	// master1 write response channel signals
	output		[3 :0]	m1_bid				,
	output		[1 :0]	m1_bresp			,
	output				m1_bvalid			,
	input				m1_bready			
);
	bus_store_arbiter m_bus_store_arbiter(
		.clk(clk), 
		.rst_n(rst_n), 
		.m0_req(m0_req), 
		.m0_grnt(m0_grnt), 
		.m1_req(m1_req), 
		.m1_grnt(m1_grnt)
	);

	bus_store_master_mux m_bus_store_master_mux(
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
		.m0_grnt			(m0_grnt),
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
		.m1_grnt			(m1_grnt),
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
endmodule