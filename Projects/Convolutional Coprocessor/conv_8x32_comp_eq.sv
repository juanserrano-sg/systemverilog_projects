/******************************************************************
* Description
*
* EQUAL COMP
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module conv_8x32_comp_eq #(
	parameter DATA_WIDTH = 8
	
)(
	input  logic [DATA_WIDTH-1:0] a_in, 
	input  logic [DATA_WIDTH-1:0] b_in, 
	output logic d_out
);

assign d_out = (a_in == b_in) ? 1'b1 : 1'b0;

endmodule
