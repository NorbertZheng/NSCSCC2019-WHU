module bus_store_master_mux(
	// AXI write signals
	// write address channel signals
	output	reg	[3 :0]	awid				,
	output	reg	[31:0]	awaddr				,
	output	reg	[3 :0]	awlen				,
	output	reg	[2 :0]	awsize				,
	output	reg	[1 :0]	awburst				,
	output	reg	[1 :0]	awlock				,
	output	reg	[3 :0]	awcache				,
	output	reg	[2 :0]	awprot				,
	output	reg			awvalid				,
	input				awready				,
	// write data channel signals
	output	reg	[3 :0]	wid					,
	output	reg	[31:0]	wdata				,
	output	reg	[3 :0]	wstrb				,
	output	reg			wlast				,
	output	reg			wvalid				,
	input				wready				,
	// write response channel signals
	input		[3 :0]	bid					,
	input		[1 :0]	bresp				,
	input				bvalid				,
	output	reg			bready				,
	
	// master0
	input				m0_grnt		,
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
	output	reg			m0_awready			,
	// master0 write data channel signals
	input		[3 :0]	m0_wid				,
	input		[31:0]	m0_wdata			,
	input		[3 :0]	m0_wstrb			,
	input				m0_wlast			,
	input				m0_wvalid			,
	output	reg			m0_wready			,
	// master0 write response channel signals
	output	reg	[3 :0]	m0_bid				,
	output	reg	[1 :0]	m0_bresp			,
	output	reg			m0_bvalid			,
	input				m0_bready			,
	
	// master1
	input				m1_grnt		,
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
	output	reg			m1_awready			,
	// master1 write data channel signals
	input		[3 :0]	m1_wid				,
	input		[31:0]	m1_wdata			,
	input		[3 :0]	m1_wstrb			,
	input				m1_wlast			,
	input				m1_wvalid			,
	output	reg			m1_wready			,
	// master1 write response channel signals
	output	reg	[3 :0]	m1_bid				,
	output	reg	[1 :0]	m1_bresp			,
	output	reg			m1_bvalid			,
	input				m1_bready			
);
	always@(*)
		begin
		// write address channel signals
		awid = 4'b0;
		awaddr = 32'b0;
		awlen = 4'b0;
		awsize = 3'b0;
		awburst = 2'b0;
		awlock = 2'b0;
		awcache = 4'b0;
		awprot = 3'b0;
		awvalid = 1'b0;
		// write data channel signals
		wid = 4'b0;
		wdata = 32'b0;
		wstrb = 4'b0;
		wlast = 1'b0;
		wvalid = 1'b0;
		// write response channel signals
		bready = 1'b0;
		// master0
		m0_awready = 1'b0;
		m0_wready = 1'b0;
		m0_bid = 4'b0;
		m0_bresp = 2'b0;
		m0_bvalid = 1'b0;
		// master1
		m1_awready = 1'b0;
		m1_wready = 1'b0;
		m1_bid = 4'b0;
		m1_bresp = 2'b0;
		m1_bvalid = 1'b0;
		if(m0_grnt == 1'b1)
			begin
			// master0_i
			m0_awready = awready;
			m0_wready = wready;
			m0_bid = bid;
			m0_bresp = bresp;
			m0_bvalid = bvalid;
			// master0_o
			awid = m0_awid;
			awaddr = m0_awaddr;
			awlen = m0_awlen;
			awsize = m0_awsize;
			awburst = m0_awburst;
			awlock = m0_awlock;
			awcache = m0_awcache;
			awprot = m0_awprot;
			awvalid = m0_awvalid;
			wid = m0_wid;
			wdata = m0_wdata;
			wstrb = m0_wstrb;
			wlast = m0_wlast;
			wvalid = m0_wvalid;
			bready = m0_bready;
			end
		else if(m1_grnt == 1'b1)
			begin
			// master1_i
			m1_awready = awready;
			m1_wready = wready;
			m1_bid = bid;
			m1_bresp = bresp;
			m1_bvalid = bvalid;
			// master1_o
			awid = m1_awid;
			awaddr = m1_awaddr;
			awlen = m1_awlen;
			awsize = m1_awsize;
			awburst = m1_awburst;
			awlock = m1_awlock;
			awcache = m1_awcache;
			awprot = m1_awprot;
			awvalid = m1_awvalid;
			wid = m1_wid;
			wdata = m1_wdata;
			wstrb = m1_wstrb;
			wlast = m1_wlast;
			wvalid = m1_wvalid;
			bready = m0_bready;
			end
		else
			begin
			// do nothing
			end
		end
endmodule