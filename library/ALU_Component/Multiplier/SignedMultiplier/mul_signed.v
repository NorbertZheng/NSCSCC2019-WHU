module mul_signed(a, b, z);
	input [7:0] a, b;
	output [15:0] z;
	
	wire [7:0] ab0 = b[0] ? a : 8'h0;
	wire [7:0] ab1 = b[1] ? a : 8'h0;
	wire [7:0] ab2 = b[2] ? a : 8'h0;
	wire [7:0] ab3 = b[3] ? a : 8'h0;
	wire [7:0] ab4 = b[4] ? a : 8'h0;
	wire [7:0] ab5 = b[5] ? a : 8'h0;
	wire [7:0] ab6 = b[6] ? a : 8'h0;
	wire [7:0] ab7 = b[7] ? a : 8'h0;
	
	assign z = (({8'b1, ~ab0[7], ab0[6:0]} + {7'b0, ~ab1[7], ab1[6:0], 1'b0}) + ({6'b0, ~ab2[7], ab2[6:0], 2'b0} + {5'b0, ~ab3[7], ab3[6:0], 3'b0})) + (({4'b0, ~ab4[7], ab4[6:0], 4'b0} + {3'b0, ~ab5[7], ab5[6:0], 5'b0}) + (2'b0, ~ab6[7], ab6[6:0], 6'b0}, {1'b1, ab7[7], ~ab7[6:0], 7'b0}));
endmodule