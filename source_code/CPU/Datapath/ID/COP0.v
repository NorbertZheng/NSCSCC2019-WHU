`include "../../Define/COP0_Define.v"
`include "../../Define/TLB_Define.v"
module COP0(clk, rst_n, wcp0, waddr, raddr, wdata, tlbp_we, tlbr_we, tlbr_result, exc_type, int_i, victim_inst_addr, is_delayslot, badvaddr, COP0_data, exc_en, PC_exc, kseg0_uncached, tlb_addr, tlb_wdata, asid, user_mode);
	/*********************
	 *		CoProcessor 0
	 *input:
	 *	clk						: clock
	 *	rst_n					: negetive reset signal
	 *	wcp0					: write COP0
	 *	waddr[4:0]				: write address
	 *	raddr[4:0]				: read address
	 *	wdata[31:0]				: data to write into COP0
	 *	tlbp_we					: tlbp instruction write enable
	 *	tlbr_we					: tlbr instruction write enable
	 *	exc_type[7:0]			: exc type
	 *	int_i[4:0]				: outside int * 5
	 *	victim_inst_addr[31:0]	: victim instruction PC address
	 *	is_delayslot			: whether victim instruction is in delayslot
	 *	badvaddr[31:0]			: bad instruction Virtual address
	 *output:
	 *	COP0_data[31:0]			: 32-bit COP0 dout
	 *	exc_en					: identity whether exc is happening
	 *	PC_exc[31:0]			: PC exc address
	 *	kseg0_uncached			: through COP0_Config identity whether kseg0 is uncached(default)
	 *	tlb_addr[4:0]			: TLB access address
	 *	tlb_wdata[89:0]			: TLB write data
	 *	asid[7:0]				: asid
	 *	user_mode				: user mode
	 *********************/
	input clk, rst_n;
	input wcp0, tlbp_we, tlbr_we, is_delayslot;
	input [4:0] waddr, raddr, int_i;
	input [7:0] exc_type;
	input [31:0] wdata, victim_inst_addr, badvaddr;
	input [89:0] tlbr_result;
	output reg [31:0] COP0_data;
	// 组合逻辑输出
	output reg exc_en, kseg0_uncached;
	output user_mode;
	output reg [4:0] tlb_addr;
	output reg [7:0] asid;
	output reg [31:0] PC_exc;
	output reg [89:0] tlb_wdata;
	
	reg [31:0] COP0_Index, COP0_EntryLo0, COP0_EntryLo1;
	reg [31:0] COP0_PageMask;
	reg [31:0] COP0_Badvaddr, COP0_Count, COP0_EntryHi, COP0_Compare, COP0_Status, COP0_Cause, COP0_EPC, COP0_Prid, COP0_Config;
	reg timer_int;
	reg [31:0] tempEPC;
	// COP0_Status[15:10]: 指示硬件中断是否被允许， 0 - 屏蔽， 1 - 允许； COP0_Status[9:8]: 指示软件中断是否被允许, 0 - 屏蔽， 1 - 允许
	wire [5:0] hardware_irq = COP0_Status[1] ? 6'b000000 : {int_i, timer_int} & COP0_Status[15:10];		//屏蔽EXL=1时的外部中断
	wire [1:0] software_irq = COP0_Status[1] ? 2'b00 : COP0_Cause[9:8] & COP0_Status[9:8];				//屏蔽EXL=1时的软中断
	wire [4:0] cause = exc_type[6] ? 5'd4 : exc_type[7] ? 5'd5 : exc_type[1] ? 5'd8 : exc_type[0] ? 5'd9 : exc_type[2] ? 5'd10 : exc_type[3] ? 5'd12 : exc_type[4] ? 5'd13 : exc_type[5] ? 5'd31 : ((hardware_irq != 6'b0) || (software_irq != 2'b0)) ? 5'd0 : 5'd30;

	// user_mode
	assign user_mode = 1'b0;
	
	// kseg0_uncached
	always@(*)
		begin
		if(!rst_n)
			begin
			kseg0_uncached = 1'b1;
			end
		else
			begin
			kseg0_uncached = 1'b1;
			if(wcp0)
				begin
				if(waddr == `CP0_CONFIG)
					begin
					kseg0_uncached = (wdata[2:0] == 3'b010);
					end
				end
			else
				begin
				kseg0_uncached = (COP0_Config[2:0] == 3'b010);
				end
			end
		end
		
	// tlb_addr
	always@(*)
		begin
		if(!rst_n)
			begin
			tlb_addr = 5'b0;
			end
		else
			begin
			tlb_addr = 5'b0;
			if(wcp0)
				begin
				if(waddr == `CP0_INDEX)
					begin
					tlb_addr = wdata[`CP0_INDEX_INDEX];
					end
				end
			else if(tlbp_we)
				begin
				tlb_addr = wdata[`CP0_INDEX_INDEX];
				end
			else
				begin
				tlb_addr = COP0_Index[`CP0_INDEX_INDEX];
				end
			end
		end
	
	// asid
	always@(*)
		begin
		if(!rst_n)
			begin
			asid = 8'b0;
			end
		else
			begin
			asid = 8'b0;
			if(wcp0)
				begin
				if(waddr == `CP0_ENTRYHI)
					begin
					asid = wdata[`CP0_ENTRYHI_ASID];
					end
				end
			else if(tlbr_we)
				begin
				asid = tlbr_result[`TLB_ASID];
				end
			else
				begin
				asid = COP0_EntryHi[`CP0_ENTRYHI_ASID];
				end
			end
		end
		
	// tlb_wdata
	always@(*)
		begin
		if(!rst_n)
			begin
			tlb_wdata = 90'b0;
			end
		else
			begin
			tlb_wdata = 90'b0;
			if(wcp0)
				begin
				case(waddr)
					`CP0_ENTRYLO0:
						begin
						tlb_wdata = {COP0_EntryHi[`CP0_ENTRYHI_VPN2], COP0_EntryHi[`CP0_ENTRYHI_ASID], 
							COP0_PageMask[`CP0_PAGEMASK_MASK], tlbr_result[`TLB_G] & COP0_EntryLo1[`CP0_ENTRYLO_G],
							tlbr_result[`TLB_ENTRYLO0], 
							COP0_EntryLo1[`CP0_ENTRYLO_PFN], COP0_EntryLo1[`CP0_ENTRYLO_C], COP0_EntryLo1[`CP0_ENTRYLO_D], COP0_EntryLo1[`CP0_ENTRYLO_V]};
						end
					`CP0_ENTRYLO1:
						begin
						tlb_wdata = {COP0_EntryHi[`CP0_ENTRYHI_VPN2], COP0_EntryHi[`CP0_ENTRYHI_ASID], 
							COP0_PageMask[`CP0_PAGEMASK_MASK], COP0_EntryLo0[`CP0_ENTRYLO_G] & tlbr_result[`TLB_G],
							COP0_EntryLo0[`CP0_ENTRYLO_PFN], COP0_EntryLo0[`CP0_ENTRYLO_C], COP0_EntryLo0[`CP0_ENTRYLO_D], COP0_EntryLo0[`CP0_ENTRYLO_V], 
							tlbr_result[`TLB_ENTRYLO1]};
						end
					`CP0_PAGEMASK:
						begin
						tlb_wdata = {COP0_EntryHi[`CP0_ENTRYHI_VPN2], COP0_EntryHi[`CP0_ENTRYHI_ASID], 
							tlbr_result[`TLB_PAGEMASK], COP0_EntryLo0[`CP0_ENTRYLO_G] & COP0_EntryLo1[`CP0_ENTRYLO_G],
							COP0_EntryLo0[`CP0_ENTRYLO_PFN], COP0_EntryLo0[`CP0_ENTRYLO_C], COP0_EntryLo0[`CP0_ENTRYLO_D], COP0_EntryLo0[`CP0_ENTRYLO_V], 
							COP0_EntryLo1[`CP0_ENTRYLO_PFN], COP0_EntryLo1[`CP0_ENTRYLO_C], COP0_EntryLo1[`CP0_ENTRYLO_D], COP0_EntryLo1[`CP0_ENTRYLO_V]};
						end
					`CP0_ENTRYHI:
						begin
						tlb_wdata = {tlbr_result[`TLB_ENTRYHI], 
							COP0_PageMask[`CP0_PAGEMASK_MASK], COP0_EntryLo0[`CP0_ENTRYLO_G] & COP0_EntryLo1[`CP0_ENTRYLO_G],
							COP0_EntryLo0[`CP0_ENTRYLO_PFN], COP0_EntryLo0[`CP0_ENTRYLO_C], COP0_EntryLo0[`CP0_ENTRYLO_D], COP0_EntryLo0[`CP0_ENTRYLO_V], 
							COP0_EntryLo1[`CP0_ENTRYLO_PFN], COP0_EntryLo1[`CP0_ENTRYLO_C], COP0_EntryLo1[`CP0_ENTRYLO_D], COP0_EntryLo1[`CP0_ENTRYLO_V]};
						end
				endcase
				end
			else if(tlbr_we)
				begin
				tlb_wdata = tlbr_result;
				end
			else
				begin
				tlb_wdata = {COP0_EntryHi[`CP0_ENTRYHI_VPN2], COP0_EntryHi[`CP0_ENTRYHI_ASID], 
							COP0_PageMask[`CP0_PAGEMASK_MASK], COP0_EntryLo0[`CP0_ENTRYLO_G] & COP0_EntryLo1[`CP0_ENTRYLO_G],
							COP0_EntryLo0[`CP0_ENTRYLO_PFN], COP0_EntryLo0[`CP0_ENTRYLO_C], COP0_EntryLo0[`CP0_ENTRYLO_D], COP0_EntryLo0[`CP0_ENTRYLO_V], 
							COP0_EntryLo1[`CP0_ENTRYLO_PFN], COP0_EntryLo1[`CP0_ENTRYLO_C], COP0_EntryLo1[`CP0_ENTRYLO_D], COP0_EntryLo1[`CP0_ENTRYLO_V]};
				end
			end
		end
				

	always@(posedge clk or negedge rst_n)
		begin
		if(!rst_n)
			begin
			timer_int <= 1'b0;
			COP0_Index <= {1'b0, 26'b0, 5'b0};
			COP0_EntryLo0 <= 32'b0;
			COP0_EntryLo1 <= 32'b0;
			COP0_PageMask <= 32'b0;
			COP0_Badvaddr <= 32'b0;
			COP0_Count <= 32'b0;
			COP0_EntryHi <= 32'b0;
			COP0_Compare <= 32'b0;
			COP0_Status <= 32'b00010000000000000000000000000000;
			COP0_Cause <= 32'b0;
			COP0_EPC <= 32'b0;
			COP0_Prid <= {8'b0, 8'b1, 16'h8000}; 					//MIPS32 4Kc		// {8'b0, 8'h57, 10'h4, 6'h2};
			COP0_Config <= {1'b1, 21'b0, 3'b001, 4'b0, 3'b010}; 	//Release 1;
			end
		else
			begin
			COP0_Prid <= {8'b0, 8'h57, 10'h4, 6'h2};
			COP0_Count <= COP0_Count + 1'b1;
			/**********************************/
			/*      比较计时是否结束          */
			/**********************************/
			if((COP0_Count == COP0_Compare) && (COP0_Count != 32'b0))
				begin
				timer_int <= 1'b1;		// 下一个周期会引起 timer interrupt, 因为cause是同步判断的
				end
			/**********************************/
			/*     处理exc、hw_irq、sw_irq    */
			/**********************************/
			if(exc_type != 8'b0)		// 说明外部有异常, 而且我们认为异常的优先级高于中断，所以先用if语句判断。
				begin					// 由于cause使用了组合逻辑，所以可以在这里直接使用cause，而不像 timer_int 使用了同步逻辑而必须等一周期
				if(cause == 5'd31)
					begin
					COP0_Status[1] <= 1'b0;		// 开异常中断
					end
				else if(!COP0_Status[1])		// 异常中断被允许
					begin
					if (cause == 5'd4)			// instruction fetch & ram_data load 同属于 exc_type[6]
						begin
						if(victim_inst_addr[1:0] != 2'b00)		// 优先考虑victim_inst_addr, 毕竟是 instruction 来自
							begin
							COP0_Badvaddr <= victim_inst_addr;
							end
						else
							begin
							COP0_Badvaddr <= badvaddr;
							end
						end
					else if(cause == 5'd5)		// ram_data store 属于 exc_type[7]
						begin
						COP0_Badvaddr <= badvaddr;
						end
					// 根据是否为 delayslot 判断 EPC 写入什么
					if(is_delayslot)
						begin
						COP0_EPC <= victim_inst_addr - 32'h4;
						COP0_Cause[31] <= 1'b1;
						end
					else
						begin
						COP0_EPC <= victim_inst_addr;
						COP0_Cause[31] <= 1'b0;
						end
					COP0_Status[1] <= 1'b1;		// 正在处理异常中断，屏蔽其他异常中断，不允许中断嵌套
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end
				else							// 如果没有允许异常中断，就简单记录
					begin
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end
					/*begin
					if (cause == 5'd4)			// instruction fetch & ram_data load 同属于 exc_type[6]
						begin
						if(victim_inst_addr[1:0] != 2'b00)		// 优先考虑victim_inst_addr, 毕竟是 instruction 来自
							begin
							COP0_Badvaddr <= victim_inst_addr;
							end
						else
							begin
							COP0_Badvaddr <= badvaddr;
							end
						end
					else if(cause == 5'd5)		// ram_data store 属于 exc_type[7]
						begin
						COP0_Badvaddr <= badvaddr;
						end
					// 根据是否为 delayslot 判断 EPC 写入什么
					if(is_delayslot)
						begin
						COP0_EPC <= victim_inst_addr - 32'h4;
						COP0_Cause[31] <= 1'b1;
						end
					else
						begin
						COP0_EPC <= victim_inst_addr;
						COP0_Cause[31] <= 1'b0;
						end
					COP0_Status[1] <= 1'b1;		// 正在处理异常中断，屏蔽其他异常中断，不允许中断嵌套
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end*/
				end
			else if((hardware_irq != 6'd0) && COP0_Status[0])	//中断发生（EXL=1时的外部中断自动屏蔽了）, 说明 exc_type == 8'b0, 没有异常，但是有第二优先级的 hardware_irq
				begin
				if(!COP0_Status[1])				// 允许中断异常
					begin
					if(is_delayslot)
						begin
						COP0_EPC <= victim_inst_addr - 32'h4;
						COP0_Cause[31] <= 1'b1;
						end
					else
						begin
						COP0_EPC <= victim_inst_addr;
						COP0_Cause[31] <= 1'b0;
						end
					COP0_Status[1] <= 1'b1;		// 正在处理异常中断，屏蔽其他异常中断，不允许中断嵌套
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end
				else
					begin
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end
					/*begin
					if(is_delayslot)
						begin
						COP0_EPC <= victim_inst_addr - 32'h4;
						COP0_Cause[31] <= 1'b1;
						end
					else
						begin
						COP0_EPC <= victim_inst_addr;
						COP0_Cause[31] <= 1'b0;
						end
					COP0_Status[1] <= 1'b1;		// 正在处理异常中断，屏蔽其他异常中断，不允许中断嵌套
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end*/
				end
			else if((software_irq != 2'b0) && COP0_Status[0])	//软中断发生（EXL=1时的中断自动屏蔽了）, 第三优先级的 software_irq, 内部不会记录 software_irq 的信息
				begin
				if(!COP0_Status[1])				// 允许中断异常
					begin
					if(is_delayslot)
						begin
						COP0_EPC <= victim_inst_addr - 32'h4;
						COP0_Cause[31] <= 1'b1;
						end
					else
						begin
						COP0_EPC <= victim_inst_addr;
						COP0_Cause[31] <= 1'b0;
						end
					COP0_Status[1] <= 1'b1;		// 正在处理异常中断，屏蔽其他异常中断，不允许中断嵌套
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end
				else
					begin
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end
					/*begin
					if(is_delayslot)
						begin
						COP0_EPC <= victim_inst_addr - 32'h4;
						COP0_Cause[31] <= 1'b1;
						end
					else
						begin
						COP0_EPC <= victim_inst_addr;
						COP0_Cause[31] <= 1'b0;
						end
					COP0_Status[1] <= 1'b1;		// 正在处理异常中断，屏蔽其他异常中断，不允许中断嵌套
					COP0_Cause[6:2] <= cause;	// 写入 Exc_Codes
					COP0_Cause[15:10] <= hardware_irq;
					end*/
				end
			/**********************************/
			/*      write COP0 Regs           */
			/**********************************/
			else if(wcp0)
				begin
				case(waddr)
					`CP0_INDEX:
						begin
						COP0_Index[`CP0_INDEX_INDEX] <= wdata[`CP0_INDEX_INDEX];
						end
					`CP0_ENTRYLO0:
						begin
						COP0_EntryLo0[`CP0_ENTRYLO_PFN] <= wdata[`CP0_ENTRYLO_PFN];
						COP0_EntryLo0[`CP0_ENTRYLO_FLAG] <= wdata[`CP0_ENTRYLO_FLAG];
						end
					`CP0_ENTRYLO1:
						begin
						COP0_EntryLo1[`CP0_ENTRYLO_PFN] <= wdata[`CP0_ENTRYLO_PFN];
						COP0_EntryLo1[`CP0_ENTRYLO_FLAG] <= wdata[`CP0_ENTRYLO_FLAG];
						end
					`CP0_PAGEMASK:
						begin
						COP0_PageMask[`CP0_PAGEMASK_MASK] <= wdata[`CP0_PAGEMASK_MASK];
						end
					`CP0_COUNT:
						begin
						COP0_Count <= wdata;
						end
					`CP0_ENTRYHI:
						begin
						COP0_EntryHi[`CP0_ENTRYHI_VPN2] <= wdata[`CP0_ENTRYHI_VPN2];
						COP0_EntryHi[`CP0_ENTRYHI_ASID] <= wdata[`CP0_ENTRYHI_ASID];
						end
					`CP0_COMPARE:
						begin
						COP0_Compare <= wdata;
						timer_int <= 1'b0;
						end
					`CP0_STATUS:
						begin
						COP0_Status <= wdata;		// 难道不会冲突？ 2 个操作 COP0_Status 的地方
						end
					`CP0_CAUSE:
						begin
						COP0_Cause[9:8] <= wdata[9:8];
						COP0_Cause[23] <= wdata[23];
						COP0_Cause[22] <= wdata[22];
						end
					`CP0_EPC:
						begin
						COP0_EPC <= wdata;
						end
					`CP0_CONFIG:
						begin
						COP0_Config[2:0] <= wdata[2:0];
						end
				endcase
				end
			/**********************************/
			/*    hardware write COP0_Index   */
			/**********************************/
			else if(tlbp_we)
				begin
				COP0_Index[`CP0_INDEX_P] <= wdata[`CP0_INDEX_P];
				COP0_Index[`CP0_INDEX_INDEX] <= wdata[`CP0_INDEX_INDEX];
				end
			else if(tlbr_we)
				begin
				// COP0_EntryLo0
				COP0_EntryLo0[`CP0_ENTRYLO_PFN] <= tlbr_result[`TLB_ENTRYLO0_PFN0];
				COP0_EntryLo0[`CP0_ENTRYLO_G] <= tlbr_result[`TLB_G];
				COP0_EntryLo0[`CP0_ENTRYLO_C] <= tlbr_result[`TLB_ENTRYLO0_C];
				COP0_EntryLo0[`CP0_ENTRYLO_D] <= tlbr_result[`TLB_ENTRYLO0_D];
				COP0_EntryLo0[`CP0_ENTRYLO_V] <= tlbr_result[`TLB_ENTRYLO0_V];
				// COP0_EntryLo1
				COP0_EntryLo1[`CP0_ENTRYLO_PFN] <= tlbr_result[`TLB_ENTRYLO1_PFN1];
				COP0_EntryLo1[`CP0_ENTRYLO_G] <= tlbr_result[`TLB_G];
				COP0_EntryLo1[`CP0_ENTRYLO_C] <= tlbr_result[`TLB_ENTRYLO1_C];
				COP0_EntryLo1[`CP0_ENTRYLO_D] <= tlbr_result[`TLB_ENTRYLO1_D];
				COP0_EntryLo1[`CP0_ENTRYLO_V] <= tlbr_result[`TLB_ENTRYLO1_V];
				// COP0_PageMask
				COP0_PageMask[`CP0_PAGEMASK_MASK] <= tlbr_result[`TLB_PAGEMASK];
				// COP0_EntryHi
				COP0_EntryHi[`CP0_ENTRYHI_VPN2] <= tlbr_result[`TLB_VPN2];
				COP0_EntryHi[`CP0_ENTRYHI_ASID] <= tlbr_result[`TLB_ASID];
				end
			end
		end
		
	// 权宜之计, posedge clk 才写入COP0_EPC，导致慢了一个周期才能提供 EPC 地址，这个仅仅是一个补救措施
	always@(*)
		begin
		if(wcp0)
			begin
			tempEPC = COP0_EPC;
			case(waddr)
				`CP0_EPC:
					begin
					tempEPC = wdata;
					end
			endcase
			end
		else
			begin
			tempEPC = COP0_EPC;
			end
		end
		
	// 送出COP0_data
	always@(*)
		begin
		if(!rst_n)
			begin
			COP0_data = 32'b0;
			end
		else if(wcp0 && (waddr == raddr))
			begin
			COP0_data = wdata;
			end
		else
			begin
			case(raddr)
				`CP0_BADVADDR:		
					begin
					COP0_data = COP0_Badvaddr;
					end
				`CP0_COUNT:		
					begin
					COP0_data = COP0_Count;
					end
				`CP0_COMPARE:	
					begin
					COP0_data = COP0_Compare;
					end
				`CP0_STATUS:	
					begin
					COP0_data = COP0_Status;
					end
				`CP0_CAUSE:	
					begin
					COP0_data = {COP0_Cause[31:16], {int_i, timer_int}, COP0_Cause[9:0]};
					end
				`CP0_EPC:	
					begin
					COP0_data = COP0_EPC;
					end
				`CP0_PRID:	
					begin
					COP0_data = COP0_Prid;
					end
				`CP0_CONFIG:	
					begin
					COP0_data = COP0_Config;
					end	
				default:
					begin
					COP0_data = 32'b0;
					end
			endcase
			end
		end
		
	// 送出 PC_exc
	always@(*)
		begin
		if(!rst_n)
			begin
			PC_exc = 32'b0;
			exc_en = 1'b0;
			end
		else if(exc_type != 8'b0)	//中断发生（EXL=1时的外部中断自动屏蔽了）
			begin
			exc_en = 1'b1;
			case(cause)
				5'd4:				//加载或取值地址不对齐
					begin
					PC_exc = 32'hbfc00380;
					end
				5'd5:				//存储地址不对齐
					begin
					PC_exc = 32'hbfc00380;
					end
				5'd8:				//syscall
					begin
					PC_exc = 32'hbfc00380;
					end
				5'd9:				//break
					begin
					PC_exc = 32'hbfc00380;
					end
				5'd10:				//unused inst
					begin
					PC_exc = 32'hbfc00380;
					end
				5'd12:				//overflow
					begin
					PC_exc = 32'hbfc00380;
					end
				5'd13:				//自陷
					PC_exc = 32'hbfc00380;
				5'd31:				//eret 考虑特殊情况：前条指令在W级写回epc，eret指令在M级将得到旧值
					begin
					PC_exc = tempEPC;
					end
				default:
					begin
					exc_en = 1'b0;
					PC_exc = 32'b0;
					end
			endcase
			end
		else if((hardware_irq != 6'b0) && COP0_Status[0])	//中断发生（EXL=1时的外部中断自动屏蔽了）
			begin
			exc_en = 1'b1;
			//中断向量
			if(cause == 5'd0)
				begin
				PC_exc = 32'hbfc00380;			// PC_exc = 32'h30;
				end
			else
				begin
				exc_en = 1'b0;
				PC_exc = 32'b0;
				end
			end
		else if((software_irq != 2'b0) && COP0_Status[0])	//中断发生（EXL=1时的外部中断自动屏蔽了）
			begin
			exc_en = 1'b1;
			//中断向量
			if(cause == 5'd0)
				begin
				PC_exc = 32'hbfc00380;			// PC_exc = 32'h30;
				end
			else
				begin
				exc_en = 1'b0;
				PC_exc = 32'b0;
				end
			end
		else
			begin
			exc_en = 1'b0;
			PC_exc = 32'b0;
			end
		end
endmodule