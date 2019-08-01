`define LOAD_LB				4'd1	// 必须从1开始。防冲突模块据此判断是否正在执行LOAD类指令
`define LOAD_LBU			4'd2
`define LOAD_LH				4'd3
`define LOAD_LHU			4'd4
`define LOAD_LW				4'd5
`define LOAD_LWL			4'd6
`define LOAD_LWR			4'd7
`define LOAD_LL				4'd8

`define STORE_SB			4'd1
`define STORE_SH			4'd2
`define STORE_SW			4'd3
`define STORE_SWL			4'd4
`define STORE_SWR			4'd5
`define STORE_SC			4'd6