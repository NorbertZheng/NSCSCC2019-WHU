module mul_signed_v2(a, b, z);
	input [7:0] a, b;
	output [15:0] z;
	
	reg [7:0] a_bi[7:0];
	always@(*)
		begin
		integer i, j;
		for(i = 0;i < 7;i = i + 1)
			begin
			for(j = 0;j < 7;j = j + 1)
				begin
				a_bi[i][j] = a[i] & b[j];
				end
			end
		for(i = 0;i < 7;i = i + 1)
			begin
			a_bi[i][7] = ~(a[i] & b[7]);
			end
		for(j = 0;j < 7;j = j + 1)
			begin
			a_bi[7][j] = ~(a[7] & b[j]);
			end
		a_bi[7][7] = a[7] & b[7];
		end
	
	assign z = (({8'b1, a_bi[0][7], a_bi[0][6:0]} + {7'b0, a_bi[1][7], a_bi[0][6:0], 1'b0}) + ({6'b0, a_bi[2][7], a_bi[2][6:0], 2'b0} + {5'b0, a_bi[3][7], a_bi[3][6:0], 3'b0})) + (({4'b0, a_bi[4][7], a_bi[4][6:0], 4'b0} + {3'b0, a_bi[5][7], a_bi[5][6:0], 5'b0}) + (2'b0, a_bi[6][7], a_bi[6][6:0], 6'b0}, {1'b1, a_bi[7][7], a_bi[7][6:0], 7'b0}));
endmodule