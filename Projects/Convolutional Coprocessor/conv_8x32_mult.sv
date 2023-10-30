
/******************************************************************
* Description
*
* MULTIPLIER
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module conv_8x32_mult #(
	parameter DATA_WIDTH = 8
	
)(
	input  logic [DATA_WIDTH-1:0] a_in, 
	input  logic [DATA_WIDTH-1:0] b_in, 
	output logic [(2*DATA_WIDTH)-1:0] d_out
);

assign d_out = a_in * b_in;

endmodule
