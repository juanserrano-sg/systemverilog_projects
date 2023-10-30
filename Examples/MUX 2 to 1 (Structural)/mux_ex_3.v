
module mux_ex_3 (a,sel,y);
	input sel;
	input [1:0] a;
	output y;
	wire [1:0] b,s;
	assign s = {sel,~sel};
	assign {b,y} = {a&s,|b};
endmodule
	