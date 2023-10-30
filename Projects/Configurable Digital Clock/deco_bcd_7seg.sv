
/******************************************************************
* Description
*
* BCD to 7 Segment Decoder
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/



module deco_bcd_7seg(
	input [3:0] in_a,
	output logic [6:0] y
	);
	
	always_comb begin
		case(in_a)
		4'b0000: begin y = 7'b1000000; end
		4'b0001: begin y = 7'b1111001; end
		4'b0010: begin y = 7'b0100100; end
		4'b0011: begin y = 7'b0110000; end
		4'b0100: begin y = 7'b0011001; end
		4'b0101: begin y = 7'b0010010; end
		4'b0110: begin y = 7'b0000010; end
		4'b0111: begin y = 7'b1111000; end
		4'b1000: begin y = 7'b0000000; end
		4'b1001: begin y = 7'b0011000; end
		4'b1010: begin y = 7'b0001000; end
		4'b1011: begin y = 7'b0000011; end
		4'b1100: begin y = 7'b1000110; end
		4'b1101: begin y = 7'b0100001; end
		4'b1110: begin y = 7'b0000110; end
		4'b1111: begin y = 7'b0001110; end
		default: y = 7'b1111111;endcase
	end 
endmodule
	