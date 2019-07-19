`include "../../Define/LS_Define.v"
module modifyLoaddata(mem_rdata_i, rf_rdata_i, load_type, byte_valid, mem_rdata_o);
	/*********************
	 *	Load Data Modifier
	 *input:
	 *	mem_rdata_i[31:0]		: mem read data
	 *	rf_rdata_i[31:0]		: rf read data
	 *	load_type[3:0]			: load type
	 *	byte_valid[3:0]			: identity which byte in word is valid
	 *output:
	 *	mem_rdata_o[31:0]		: mem read data modified
	 *********************/
	input [3:0] load_type, byte_valid;
	input [31:0] mem_rdata_i, rf_rdata_i;
	output reg [31:0] mem_rdata_o;
	
	// 为字节指令设计
	wire[7:0] byte_data = (byte_valid == 4'b0001) ? mem_rdata_i[7:0] : (byte_valid == 4'b0010) ? mem_rdata_i[15:8] : (byte_valid == 4'b0100) ? mem_rdata_i[23:16] : mem_rdata_i[31:24];
	// 为半字指令设计
	wire[15:0] hb_data = (byte_valid == 4'b0011) ? mem_rdata_i[15:0] : mem_rdata_i[31:16];
	
	always @(*)
		begin
		mem_rdata_o = mem_rdata_i;
		case (load_type)
			`LOAD_LB:
				begin
				mem_rdata_o = {{24{byte_data[7]}}, byte_data};
				end
			`LOAD_LBU:
				begin
				mem_rdata_o = {24'b0, byte_data};
				end
			`LOAD_LH:
				begin
				mem_rdata_o = {{16{hb_data[15]}}, hb_data[15:0]};
				end
			`LOAD_LHU:
				begin
				mem_rdata_o = {16'b0, hb_data[15:0]};
				end
			`LOAD_LW,
			`LOAD_LL:
				begin
				mem_rdata_o = mem_rdata_i;
				end
			`LOAD_LWL:
				begin
				case(byte_valid)
					4'b0001:
						begin
						mem_rdata_o = {mem_rdata_i[7:0], rf_rdata_i[23:0]};
						end
					4'b0011:
						begin
						mem_rdata_o = {mem_rdata_i[15:0], rf_rdata_i[15:0]};
						end
					4'b0111:
						begin
						mem_rdata_o = {mem_rdata_i[23:0], rf_rdata_i[7:0]};
						end
					default:
						begin
						mem_rdata_o = mem_rdata_i;
						end
				endcase
				end
			`LOAD_LWR:
				begin
				case(byte_valid)
					4'b1111:
						begin
						mem_rdata_o = mem_rdata_i;
						end
					4'b1110:
						begin
						mem_rdata_o = {rf_rdata_i[31:24], mem_rdata_i[31:8]};
						end
					4'b1100:
						begin
						mem_rdata_o = {rf_rdata_i[31:16], mem_rdata_i[31:16]};
						end
					default:
						begin
						mem_rdata_o = {rf_rdata_i[31:8], mem_rdata_i[31:24]};
						end
				endcase
				end
		endcase
		end
endmodule