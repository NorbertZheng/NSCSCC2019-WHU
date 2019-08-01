module mycpu_top(
	input		[5 :0]	int					,		// high active
	
	input				aclk				,
	input				aresetn				,		// low active
	
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
	
	// Mips
	Mips m_Mips(
		.int_i				(int				),		// high active

		.clk				(aclk				),
		.rst_n				(aresetn			),		// low active

		.arid				(arid				),
		.araddr				(araddr				),
		.arlen				(arlen				),
		.arsize				(arsize				),
		.arburst			(arburst			),
		.arlock				(arlock				),
		.arcache			(arcache			),
		.arprot				(arprot				),
		.arvalid			(arvalid			),
		.arready			(arready			),
		
		.rid				(rid				),
		.rdata				(rdata				),
		.rresp				(rresp				),
		.rlast				(rlast				),
		.rvalid				(rvalid				),
		.rready				(rready				),
		
		.awid				(awid				),
		.awaddr				(awaddr				),
		.awlen				(awlen				),
		.awsize				(awsize				),
		.awburst			(awburst			),
		.awlock				(awlock				),
		.awcache			(awcache			),
		.awprot				(awprot				),
		.awvalid			(awvalid			),
		.awready			(awready			),
		
		.wid				(wid				),
		.wdata				(wdata				),
		.wstrb				(wstrb				),
		.wlast				(wlast				),
		.wvalid				(wvalid				),
		.wready				(wready				),
		
		.bid				(bid				),
		.bresp				(bresp				),
		.bvalid				(bvalid				),
		.bready				(bready				),

		//debug interface
		.debug_wb_pc		(debug_wb_pc		),
		.debug_wb_rf_wen	(debug_wb_rf_wen	),
		.debug_wb_rf_wnum	(debug_wb_rf_wnum	),
		.debug_wb_rf_wdata	(debug_wb_rf_wdata	)
	);
	/*assign arid = 4'b0001;
	assign araddr = 32'h1faff000;
	assign arlen = 4'b0000;
	assign arsize = 3'b010;
	assign arburst = 2'b00;		// ?
	assign arlock = 2'b00;		// single CPU, no need for lock
	assign arcache = 4'b0000;
	assign arprot = 3'b000;
	assign arvalid = 1'b1;
	assign rready = 1'b1;*/
endmodule