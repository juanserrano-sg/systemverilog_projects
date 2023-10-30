`timescale 1ns/1ps


module TB_ej_maq_est;
logic sen, clk, rst;
logic [2:0] Av; // MSB	  	0 0 0		 LSB -> Semaforo de Avenida
logic [2:0] St;
logic [2:0] curr_st;

ej_maq_est dut(.rst (rst), .clk (clk), .sen (sen), .Av (Av), .St (St), .curr_st (curr_st));


 initial begin 
    clk = 0;
    forever begin
    #50 clk = ~clk;
    end
end
	
 initial begin
	rst = 0;
	sen = 0;
	#100
	rst = 1;
	sen = 0;
	#100
	rst = 0;
	sen = 1;	
	#3000
	rst = 0;
	sen = 0;	
	#1700
	rst = 0;
	sen = 0;	
end
	
	
endmodule
