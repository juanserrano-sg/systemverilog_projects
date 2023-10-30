

/******************************************************************
* Description
*
* Counter
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/



module counter(clk, rst, en, carry_out, cnt);
	parameter WIDTH = 4;
	parameter MAX_CNT = 9;
	parameter [WIDTH-1:0] RST_VAL = 0;
	
	input clk;
	input rst;
	input en;
	
	output carry_out;
	output logic [WIDTH-1:0] cnt;
	
	assign carry_out = (cnt == MAX_CNT && en);
	
	always_ff @(negedge rst, posedge clk)	begin
	if (!rst) cnt <= RST_VAL;
		else if (carry_out) cnt <= RST_VAL;
		else if (en) cnt <= cnt + 1'b1;
		else cnt <= cnt;
	end
endmodule
