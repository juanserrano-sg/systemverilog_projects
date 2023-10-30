
/******************************************************************
* Description
*
* 7 Segment Decoder
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module Decoder7segs(input [3:0] a,
						output logic [6:0] o1);
	
	//									// _
	localparam _0 = 7'b0111111; 	//| |
											//|_|
	localparam _1 = 7'b0000110; 	//   |
											// _ |
	localparam _2 = 7'b1011011; 	// _|
											//|_  _
	localparam _3 = 7'b1001111; 	//    _|
											//    _|
	localparam _4 = 7'b1100110; 	//|_|
											//  | _
	localparam _5 = 7'b1101101; 	//   |_
											// _  _|
	localparam _6 = 7'b1111101; 	//|_
											//|_| _
	localparam _7 = 7'b0000111; 	//     |
											// _   | 
	localparam _8 = 7'b1111111; 	//|_|
											//|_| _
	localparam _9 = 7'b1100111; 	//   |_|
											//     |
								 
	always_comb begin
		case(a) 
			0: o1 = _0;
			1: o1 = _1;
			2: o1 = _2;
			3: o1 = _3;
			4: o1 = _4;
			5: o1 = _5;
			6: o1 = _6;
			7: o1 = _7;
			8: o1 = _8;
			9: o1 = _9;
			default: y = _0;
		endcase
	end
endmodule 