module bus_arbiter(clk, rst_n, busy, m0_req, m0_grnt, m1_req, m1_grnt, m2_req, m2_grnt);
	/*********************
	 *		Bus Arbiter
	 *input:
	 *	clk							: clock
	 *	rst_n						: negetive reset signal
	 *	m0_req						: master0 req signal
	 *	m1_req						: master1 req signal
	 *	m2_req						: master2 req signal
	 *output:
	 *	m0_grnt						: master0 grnt signal
	 *	m1_grnt						: master1 grnt signal
	 *	m2_grnt						: master2 grnt signal
	 *********************/
	input clk, rst_n;
	input m0_req, m1_req, m2_req;
	output busy;
	output reg m0_grnt, m1_grnt, m2_grnt;
	
	reg [1:0] owner;
	assign busy = 	((owner == 2'b00 && m0_req == 1'b1) ||
					 (owner == 2'b01 && m1_req == 1'b1) ||
					 (owner == 2'b10 && m2_req == 1'b1));
	
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			owner <= 2'b0;
			end
		else
			begin
			if(m0_req == 1'b1 && ~(owner == 2'b01 && m1_req == 1'b1) && ~(owner == 2'b10 && m2_req == 1'b1))		// prefer m0(data req)
				begin
				owner <= 2'b00;
				end
			else if(m1_req == 1'b1 && ~(owner == 2'b00 && m0_req == 1'b1) && ~(owner == 2'b10 && m2_req == 1'b1))
				begin
				owner <= 2'b01;
				end
			else if(m2_req == 1'b1 && ~(owner == 2'b01 && m1_req == 1'b1) && ~(owner == 2'b00 && m0_req == 1'b1))
				begin
				owner <= 2'b10;
				end
			end
		end
	
	always@(*)
		begin
		m0_grnt = 1'b0;
		m1_grnt = 1'b0;
		m2_grnt = 1'b0;
		case(owner)
			2'b00:
				begin
				m0_grnt = 1'b1;
				end
			2'b01:
				begin
				m1_grnt = 1'b1;
				end
			2'b10:
				begin
				m2_grnt = 1'b1;
				end
			default:
				begin
				// do nothing
				end
		endcase
		end
endmodule