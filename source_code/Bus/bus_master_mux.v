module bus_master_mux(
	// read address channel signals
	output	reg	[3 :0]	arid		,
	output	reg	[31:0]	araddr		,
	output	reg	[3 :0]	arlen		,
	output	reg	[2 :0]	arsize		,
	output	reg	[1 :0]	arburst		,
	output	reg	[1 :0]	arlock		,
	output	reg	[3 :0]	arcache		,
	output	reg	[2 :0]	arprot 		,
	output	reg			arvalid 	,
	input				arready		,
	// read data channel signals           
	input 		[3 :0]	rid			,
	input 		[31:0] 	rdata		,
	input 		[1 :0]	rresp		,
	input				rlast		,
	input 				rvalid 		,
	output	reg			rready		,
	
	// master0
	input				m0_grnt		,
	// master0 read address signals
	input		[3 :0]	m0_arid		,
	input		[31:0]	m0_araddr	,
	input		[3 :0]	m0_arlen	,
	input		[2 :0]	m0_arsize	,
	input		[1 :0]	m0_arburst	,
	input		[1 :0]	m0_arlock	,
	input		[3 :0]	m0_arcache	,
	input		[2 :0]	m0_arprot	,
	input				m0_arvalid	,
	output	reg			m0_arready	,
	// master0 read data signals
	output	reg	[3 :0]	m0_rid		,
	output	reg	[31:0]	m0_rdata	,
	output	reg	[1 :0]	m0_rresp	,
	output	reg			m0_rlast	,
	output	reg			m0_rvalid	,
	input				m0_rready	,
	
	// master1
	input				m1_grnt		,
	// master1 read address signals
	input		[3 :0]	m1_arid		,
	input		[31:0]	m1_araddr	,
	input		[3 :0]	m1_arlen	,
	input		[2 :0]	m1_arsize	,
	input		[1 :0]	m1_arburst	,
	input		[1 :0]	m1_arlock	,
	input		[3 :0]	m1_arcache	,
	input		[2 :0]	m1_arprot	,
	input				m1_arvalid	,
	output	reg			m1_arready	,
	// master1 read data signals
	output	reg	[3 :0]	m1_rid		,
	output	reg	[31:0]	m1_rdata	,
	output	reg	[1 :0]	m1_rresp	,
	output	reg			m1_rlast	,
	output	reg			m1_rvalid	,
	input				m1_rready	
);
	always@(*)
		begin
		arid = 4'b0;
		araddr = 32'b0;
		arlen = 4'b0;
		arsize = 3'b0;
		arburst = 2'b0;
		arlock = 2'b0;
		arcache = 4'b0;
		arprot = 3'b0;
		arvalid = 1'b0;
		rready = 1'b0;
		m0_arready = 1'b0;
		m0_rid = 4'b0;
		m0_rdata = 32'b0;
		m0_rresp = 2'b0;
		m0_rlast = 1'b0;
		m0_rvalid = 1'b0;
		m1_arready = 1'b0;
		m1_rid = 4'b0;
		m1_rdata = 32'b0;
		m1_rresp = 2'b0;
		m1_rlast = 1'b0;
		m1_rvalid = 1'b0;
		if(m0_grnt == 1'b1)
			begin
			// master0_i
			m0_arready = arready;
			m0_rid = rid;
			m0_rdata = rdata;
			m0_rresp = rresp;
			m0_rlast = rlast;
			m0_rvalid = rvalid;
			// master0_o
			arid = m0_arid;
			araddr = m0_araddr;
			arlen = m0_arlen;
			arsize = m0_arsize;
			arburst = m0_arburst;
			arlock = m0_arlock;
			arcache = m0_arcache;
			arprot = m0_arprot;
			arvalid = m0_arvalid;
			rready = m0_rready;
			end
		else if(m1_grnt == 1'b1)
			begin
			// master1_i
			m1_arready = arready;
			m1_rid = rid;
			m1_rdata = rdata;
			m1_rresp = rresp;
			m1_rlast = rlast;
			m1_rvalid = rvalid;
			// master1_o
			arid = m1_arid;
			araddr = m1_araddr;
			arlen = m1_arlen;
			arsize = m1_arsize;
			arburst = m1_arburst;
			arlock = m1_arlock;
			arcache = m1_arcache;
			arprot = m1_arprot;
			arvalid = m1_arvalid;
			rready = m1_rready;
			end
		else
			begin
			// do nothing
			end
		end
endmodule