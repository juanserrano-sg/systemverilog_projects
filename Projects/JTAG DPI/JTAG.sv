
/******************************************************************
* Description
*
* JTAG
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module JTAG(input TMS,
			input TDI,
			input TCK,
			input TRST,
			input reset,
			input clk,
			input load,
			input shift_r_l,
			input [2:0] sh,
			input [7:0] d_in,
			output logic [6:0] y1,
			output logic [6:0] y2,
			output logic TDO);

	logic [7:0] d_out;  
	logic TDO_1;
	logic TDO_2; 	
   
	logic [3:0] a1; //Conectar a d_out[3:0]
  	logic [3:0] a2; //Conectar a d_out[7:4]
   
 	E16_JTAG_Register8bits E16_JTAG_Register8bits_1(.TDI(TDI),.TMS(TMS),.TCK(TCK),.TRST(TRST),.reset(reset),.clk(clk),.load(load),.shift_r_l(shift_r_l),.sh(sh),.d_in(d_in),.d_out({a2,a1}),.TDO(TDO_1));
	
	E16_JTAG_Decoder7segs E16_JTAG_Decoder7segs_1(.TDI(TDO_1),.TMS(TMS),.TCK(TCK),.TRST(TRST),.a(a1),.y(y1),.TDO(TDO_2));
	E16_JTAG_Decoder7segs E16_JTAG_Decoder7segs_2(.TDI(TDO_2),.TMS(TMS),.TCK(TCK),.TRST(TRST),.a(a2),.y(y2),.TDO(TDO));
	
 endmodule 