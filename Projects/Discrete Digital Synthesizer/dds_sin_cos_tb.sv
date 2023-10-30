/******************************************************************
* Description
*
* TB Module 
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/


`timescale 1ns/100ps 

module dds_sin_cos_tb ();

logic clk;
logic rst;

logic en;
logic load;

logic signed [2:-5] amp_sin;
logic signed [2:-5] amp_cos;
	
logic [7:0] phase_sin;
logic [7:0] phase_cos;
	
logic [5:0] freq_sen;
logic [5:0] freq_cos; 
	
logic signed [2:-13] cosine_out;
logic signed [2:-13] sine_out;


//Top Level

dds_sin_cos  dut(
	.clk(clk), 
	.rst(rst),
	.en(en),
	.load(load),
	
	.amp_sin(amp_sin),
	.amp_cos(amp_cos),
	
	.phase_sin(phase_sin),
	.phase_cos(phase_cos),
	
	.freq_sen(freq_sen), 
	.freq_cos(freq_cos), 
	
	.cosine_out(cosine_out),
	.sine_out(sine_out)
	);



//clock source
 initial begin 
    clk = 0;
    forever begin
    #50 clk = ~clk;
    end
end

initial begin
	rst  = 1'b0; 
	load = 1'b0;
	en = 1'b0;

	amp_sin = 8'b011_11111;
	amp_cos = 8'b011_11111;
		
	phase_sin = 8'd0;
	phase_cos = 8'd0;
		
	freq_sen = 6'd1;
	freq_cos = 6'd1; 
		
	#50
	rst  = 1'b1; 
	load = 1'b0;
	en = 1'b1;

	#15000
	
	amp_sin = 8'b010_00000;
	amp_cos = 8'b010_00000;
		
	phase_sin = 8'd0;
	phase_cos = 8'd0;
		
	freq_sen = 6'd8;
	freq_cos = 6'd12; 
	
	#15000	
	
	amp_sin = 8'b000_11111;
	amp_cos = 8'b001_00000;
		
	phase_sin = 8'd90;
	phase_cos = 8'd180;
		
	freq_sen = 6'd16;
	freq_cos = 6'd4; 
	
	#21000

	$stop;
end
endmodule
