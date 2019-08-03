`include "../../Define/LS_Define.v"
module modifyStoreData(mem_wdata_i, store_type, byte_valid, mem_wdata_o);
	/*********************
	 *	Store Data Modifier
	 *input:
	 *	mem_wdata_i[31:0]		: mem write data
	 *	store_type[3:0]			: store type
	 *	byte_valid[3:0]			: identity which byte in word is valid
	 *output:
	 *	mem_wdata_o[31:0]		: mem write data modified
	 *********************/
	input [3:0] store_type, byte_valid;
	input [31:0] mem_wdata_i;
	output reg [31:0] mem_wdata_o;
	
	always@(*)
		begin
		mem_wdata_o = mem_wdata_i;
		case(store_type)
			`STORE_SB:
				begin
				case(byte_valid)
					4'b0001:
						begin
						mem_wdata_o = {8'b0, 8'b0, 8'b0, mem_wdata_i[7:0]};
						end
					4'b0010:
						begin
						mem_wdata_o = {8'b0, 8'b0, mem_wdata_i[7:0], 8'b0};
						end
					4'b0100:
						begin
						mem_wdata_o = {8'b0, mem_wdata_i[7:0], 8'b0, 8'b0};
						end
					default:
						begin
						mem_wdata_o = {mem_wdata_i[7:0], 8'b0, 8'b0, 8'b0};
						end
				endcase
				end
			`STORE_SH:
				begin
				mem_wdata_o = (byte_valid == 4'b0011) ? {8'b0, 8'b0, mem_wdata_i[15:8], mem_wdata_i[7:0]} : {mem_wdata_i[15:8], mem_wdata_i[7:0], 8'b0, 8'b0};
				end
			`STORE_SC,
			`STORE_SW:
				begin
				;
				end
			`STORE_SWL:
				begin
				case(byte_valid)
					4'b0001:
						begin
						mem_wdata_o = {24'b0, mem_wdata_i[31:24]};
						end
					4'b0011:
						begin
						mem_wdata_o = {16'b0, mem_wdata_i[31:16]};
						end
					4'b0111:
						begin
						mem_wdata_o = {8'b0, mem_wdata_i[31:8]};
						end
					default:
						begin
						mem_wdata_o = mem_wdata_i;
						end
				endcase
				end
			`STORE_SWR:
				begin
				case(byte_valid)
					4'b1000:
						begin
						mem_wdata_o = {mem_wdata_i[7:0], 24'b0};
						end
					4'b1100:
						begin
						mem_wdata_o = {mem_wdata_i[15:0], 16'b0};
						end
					4'b1110:
						begin
						mem_wdata_o = {mem_wdata_i[23:0], 8'b0};
						end
					default:
						begin
						mem_wdata_o = mem_wdata_i;
						end
				endcase
				end
		endcase
		end
endmodule