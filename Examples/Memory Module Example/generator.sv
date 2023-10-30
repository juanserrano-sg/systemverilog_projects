//'timescale 1ns/100ps
// Generador - JUAN ANTONIO SERRANO GOMEZ
module generator (addr_i, rst, clk, addr_o, data, wr_en);
	input [3:0] addr_i;
	output logic rst = 1'b0;
	output logic clk = 1'b0;
	output logic [3:0] addr_o = 4'h0;
	output logic [1:0] data = 2'bzz;
	output logic wr_en = 1'b0;
	logic [3:0] addr;
	
	initial #100 rst = 1'b0;
	always clk = #50 ~clk;
	always @* addr_o = wr_en ? add : addr_i;
	
	task write; input [3:0] addr_value; input [1:0] d_in_value;
	begin
		@(negedge clk);
		addr = addr_value;
		data = d_in_value;
		wr_en = 1'b1;
		@(posedge clk);
		#10 
		addr=0;data= 2'bzz; wr_en= 1'b0;
		end
	endtask 
endmodule
