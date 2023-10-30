
/******************************************************************
* Description
*
* Program Counter
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module RISC_ProgramCounter(input logic [2:0] data,
						   input logic clk,
						   input logic reset,
						   output logic [31:0] PC);

	always @ (negedge reset, posedge clk) begin
		if(!reset) PC <= 0;
		else PC <= PC + data;
	end
	
endmodule 