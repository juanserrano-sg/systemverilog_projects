/******************************************************************
* Description
*
* Control
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/


module control(clk, rst, set, hora, min, carry_sec, carry_dMin,  enable_uMin,   enable_hr);
	input clk, rst, set, hora, min, carry_sec, carry_dMin;

	output enable_uMin, enable_hr;

	logic hr_flag;
	logic min_flag;
	logic q_hr;
	logic q_min;
	
	always@(negedge rst, posedge clk) begin
		if(!rst) q_hr <= 1'b1;
			else q_hr <= hora;
	end
	
	assign hr_flag = ~hora & q_hr;
	
	always@(negedge rst, posedge clk) begin
		if(!rst) q_min <= 1'b1;
		else q_min <= min;
	end
	
	assign min_flag = ~min & q_min;

	always_comb begin
		if(!set && hr_flag) enable_hr = 1'b1;
		else enable_hr = carry_dMin;
	end

	always_comb begin
		if(!set && min_flag) enable_uMin = 1'b1;
		else enable_uMin = carry_sec;
	end
endmodule
