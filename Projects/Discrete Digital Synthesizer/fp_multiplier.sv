
/******************************************************************
* Description
*
* MULTIPLIER
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  : 18/06/2023
******************************************************************/

module fp_multiplier #(
	parameter WORD_LENGTH = 8,
	parameter A_QI = 2,
	parameter B_QI = 2,
	parameter O_QI = 4
)(
	input  logic signed [A_QI-1:-(WORD_LENGTH-A_QI)] a_in, 
	input  logic signed [B_QI-1:-(WORD_LENGTH-B_QI)] b_in, 
	
//	output logic signed [O_QI-1:-((2*WORD_LENGTH)-O_QI)] d_out
	
	output logic signed [O_QI-1:-((2*WORD_LENGTH)-O_QI)] d_out 
);

wire signed [O_QI-1:-((2*WORD_LENGTH)-O_QI)] d_out_reg;

assign d_out_reg = a_in * b_in;

assign d_out = {d_out_reg[O_QI-1], d_out_reg[O_QI-3:-((2*WORD_LENGTH)-O_QI)], 1'b0};
//assign d_out_trunc = {d_out[O_QI], d_out[1:-(WORD_LENGTH-A_QI-1)]}

endmodule 

