module AXI_Cache_Load_Bus(
	input			clk			,
	input			rst_n		,
	output			busy		,
	// AXI read channel signals
	// read address channel signals
	output	[3 :0]	arid		,
	output	[31:0]	araddr		,
	output	[3 :0]	arlen		,
	output	[2 :0]	arsize		,
	output	[1 :0]	arburst		,
	output	[1 :0]	arlock		,
	output	[3 :0]	arcache		,
	output	[2 :0]	arprot 		,
	output			arvalid 	,
	input			arready		,
	// read data channel signals           
	input 	[3 :0]	rid			,
	input 	[31:0] 	rdata		,
	input 	[1 :0]	rresp		,
	input			rlast		,
	input 			rvalid 		,
	output			rready		,
	
	// master0
	input			m0_req		,
	output			m0_grnt		,
	// master0 read address signals
	input	[3 :0]	m0_arid		,
	input	[31:0]	m0_araddr	,
	input	[3 :0]	m0_arlen	,
	input	[2 :0]	m0_arsize	,
	input	[1 :0]	m0_arburst	,
	input	[1 :0]	m0_arlock	,
	input	[3 :0]	m0_arcache	,
	input	[2 :0]	m0_arprot	,
	input			m0_arvalid	,
	output			m0_arready	,
	// master0 read data signals
	output	[3 :0]	m0_rid		,
	output	[31:0]	m0_rdata	,
	output	[1 :0]	m0_rresp	,
	output			m0_rlast	,
	output			m0_rvalid	,
	input			m0_rready	,
	
	// master1
	input			m1_req		,
	output			m1_grnt		,
	// master1 read address signals
	input	[3 :0]	m1_arid		,
	input	[31:0]	m1_araddr	,
	input	[3 :0]	m1_arlen	,
	input	[2 :0]	m1_arsize	,
	input	[1 :0]	m1_arburst	,
	input	[1 :0]	m1_arlock	,
	input	[3 :0]	m1_arcache	,
	input	[2 :0]	m1_arprot	,
	input			m1_arvalid	,
	output			m1_arready	,
	// master1 read data signals
	output	[3 :0]	m1_rid		,
	output	[31:0]	m1_rdata	,
	output	[1 :0]	m1_rresp	,
	output			m1_rlast	,
	output			m1_rvalid	,
	input			m1_rready	,
	
	// master2
	input			m2_req		,
	output			m2_grnt		,
	// master1 read address signals
	input	[3 :0]	m2_arid		,
	input	[31:0]	m2_araddr	,
	input	[3 :0]	m2_arlen	,
	input	[2 :0]	m2_arsize	,
	input	[1 :0]	m2_arburst	,
	input	[1 :0]	m2_arlock	,
	input	[3 :0]	m2_arcache	,
	input	[2 :0]	m2_arprot	,
	input			m2_arvalid	,
	output			m2_arready	,
	// master1 read data signals
	output	[3 :0]	m2_rid		,
	output	[31:0]	m2_rdata	,
	output	[1 :0]	m2_rresp	,
	output			m2_rlast	,
	output			m2_rvalid	,
	input			m2_rready	
);
	bus_arbiter m_bus_arbiter(
		.clk(clk), 
		.rst_n(rst_n), 
		.busy(busy), 
		.m0_req(m0_req), 
		.m0_grnt(m0_grnt), 
		.m1_req(m1_req), 
		.m1_grnt(m1_grnt),
		.m2_req(m2_req), 
		.m2_grnt(m2_grnt)
	);

	bus_master_mux m_bus_master_mux(
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
		.rid(rid),
		.rdata(rdata),
		.rresp(rresp),
		.rlast(rlast),
		.rvalid(rvalid),
		.rready(rready),
		// master0
		.m0_grnt(m0_grnt),
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
		.m0_rid(m0_rid),
		.m0_rdata(m0_rdata),
		.m0_rresp(m0_rresp),
		.m0_rlast(m0_rlast),
		.m0_rvalid(m0_rvalid),
		.m0_rready(m0_rready),
		// master1
		.m1_grnt(m1_grnt),
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
		.m1_rid(m1_rid),
		.m1_rdata(m1_rdata),
		.m1_rresp(m1_rresp),
		.m1_rlast(m1_rlast),
		.m1_rvalid(m1_rvalid),
		.m1_rready(m1_rready),
		// master2
		.m2_grnt(m2_grnt),
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
		.m2_rid(m2_rid),
		.m2_rdata(m2_rdata),
		.m2_rresp(m2_rresp),
		.m2_rlast(m2_rlast),
		.m2_rvalid(m2_rvalid),
		.m2_rready(m2_rready)
	);
endmodule