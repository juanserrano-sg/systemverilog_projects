
/******************************************************************
* Description
*
* JTAG BOUNDARY
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module E16_JTAG_BOUNDARY(input clkDR, 
					     input mode,
						 input updateDR,
					     input shiftDR,
						 input shiftIN,
					     output logic shiftOUT,
						 input parallelIN,
						 output logic parallelOUT);

	logic OUT0, OUT1;
	
	FFD     D0(clkDR,OUT0,shiftOUT);
	FFD     D1(updateDR,shiftOUT,OUT1);
	MUX2TO1 D2(parallelIN,shiftIN,shiftDR,OUT0);
	MUX2TO1 D3(parallelIN,OUT1,mode,parallelOUT);

endmodule 


module FFD(input clk_FFD,input D,output logic Q);
	always @ (posedge clk_FFD) begin
		Q <= D;
	end
endmodule 

module MUX2TO1(input A,input B,input S,output logic OUT);
	assign OUT = S? B : A;
endmodule 