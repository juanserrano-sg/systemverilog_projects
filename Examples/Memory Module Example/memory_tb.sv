`timescale 1ns/100ps
module memory_tb();
	logic rst, clk, wr_en;
	logic[3:0] addr_o,addr_i;
	logic[1:0] data;

	memory dut(.rst(rst), .clk(clk), .wr_en(wr_en), .addr(addr_o), .data(data));
	generator generator(.addr_i(addr_i), .rst(rst), .clk(clk), .addr_o(addr_o), .data(data), .wr_en(wr_en));
	analyzer analyzer(.clk(clk), .data(data), .addr(addr_i));
	'include "testcase.sv";
endmodule
