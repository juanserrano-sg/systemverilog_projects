//`timescale 1ns/1ps

// Testbench ffd_ssa

module TB_ej_sh_reg;
logic rst, shift_r_l, clk, load;
logic [2:0] sh;
logic	[7:0] d_in;
logic [7:0] d_out;

localparam logic [7:0] r1 [7:0] =
'{
8'b0000_0000, 8'b1000_0000, 8'b1100_0000, 8'b1110_0000, 8'b1111_0000, 8'b1111_1000, 8'b1111_1100, 8'b1111_1110 
};

localparam logic [7:0] l1 [7:0] =
'{
8'b0000_0000, 8'b1000_0000, 8'b1100_0000, 8'b1110_0000, 8'b1111_0000, 8'b1111_1000, 8'b1111_1100, 8'b1111_1110 
};

ejmem1 dut(.rst (rst), .shift_r_l (shift_r_l), .clk (clk), .load (load), .d_in (d_in), .d_out (d_out), .sh (sh));


 initial begin 
    clk = 0;
    forever begin
    #50 clk = ~clk;
    end
end
	
 initial begin
	rst = 0;
	shift_r_l = 0;
	d_in = 8'b10101010;
	load = 0;
	sh = 2'b00;
	
	#100;
	rst = 0;
	shift_r_l = 0;
	d_in = 8'b10101010;
	load = 1;
	sh = 2'b01;
	
	#100;
	rst = 0;
	shift_r_l = 1;
	d_in = 8'b11101110;
	load = 1;
	sh = 2'b10;
	
	#100;
	rst = 0;
	shift_r_l = 1;
	d_in = 8'b10101010;
	load = 0;
	sh = 2'b10;

	#100;
	rst = 1;
	shift_r_l = 1;
	d_in = 8'b10101010;
	load = 0;
	sh = 2'b10;
	
	#100;
	rst = 0;
	shift_r_l = 1;
	d_in = 8'b10101010;
	load = 0;
	sh = 2'b10;
	
end
endmodule
