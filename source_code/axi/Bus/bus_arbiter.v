module bus_arbiter(clk, rst_n, m0_req, m0_grnt, m1_req, m1_grnt);
	/*********************
	 *		Bus Arbiter
	 *input:
	 *	clk							: clock
	 *	rst_n						: negetive reset signal
	 *	m0_req						: master0 req signal
	 *	m1_req						: master1 req signal
	 *output:
	 *	m0_grnt						: master0 grnt signal
	 *	m1_grnt						: master1 grnt signal
	 *********************/
	input clk, rst_n;
	input m0_req, m1_req;
	output reg m0_grnt, m1_grnt;
	
	reg owner;
	
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			owner <= 1'b0;
			end
		else
			begin
			if(m0_req == 1'b1)		// prefer m0(data req)
				begin
				owner <= 1'b0;
				end
			else if(m1_req == 1'b1)
				begin
				owner <= 1'b1;
				end
			end
		end
	
	always@(*)
		begin
		m0_grnt = 1'b0;
		m1_grnt = 1'b0;
		case(owner)
			1'b0:
				begin
				m0_grnt = 1'b1;
				end
			1'b1:
				begin
				m1_grnt = 1'b1;
				end
		endcase
		end
endmodule