

/******************************************************************
* Description
*
* 32bit Register
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module RISC_32bitsReg(input logic 		  clk,
					  input logic  [31:0] data,
					  output logic [31:0] data_out);
	always @ (posedge clk) begin
		data_out <= data;
	end
endmodule 