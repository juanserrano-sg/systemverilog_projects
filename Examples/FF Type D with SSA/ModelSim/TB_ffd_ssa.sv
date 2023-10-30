//`timescale 1ns/1ps

// Testbench ffd_ssa

module TB_ffd_ssa;
logic rst_a, rst_s, clk, d, en;
logic q;

ffd_ssa dut(.rst_a (rst_a), .rst_s (rst_s), .clk (clk), .d (d), .en (en), .q (q));


 initial begin 
    clk = 0;
    forever begin
    #50 clk = ~clk;
    end
end
	
 initial begin
	rst_a = 0;
	rst_s = 0;
	d = 1;
	en = 1;
	
	#100;
	rst_a = 1;
	rst_s = 0;
	d = 1;
	en = 1;
	
	#100;
	rst_a = 0;
	rst_s = 0;
	d = 1;
	en = 1;
	
	#100;
	rst_a = 0;
	rst_s = 1;
	d = 1;
	en = 1;

	#100;
	rst_a = 0;
	rst_s = 1;
	d = 1;
	en = 1;
	
	#100;
	rst_a = 0;
	rst_s = 0;
	d = 1;
	en = 1;


	#100;
	rst_a = 0;
	rst_s = 0;
	d = 1;
	en = 0;


end
	
	


endmodule
