
/******************************************************************
* Description
*
* 8 Bit Register
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module Register8bits(input reset,
					 input clk,
					 input load,   
					 input shift_r_l,
					 input [2:0] sh,
					 input [7:0] d_in,
					 output logic [7:0] d_out);
	
	integer i;
	
	always@(posedge clk) begin
		
		if(reset) d_out <= 8'd0;
		
		else if(load) d_out <= d_in;
		
		else if(shift_r_l && (sh != 0)) begin
			
			d_out <= 8'hFF;
			
			for(i=0; i<=7; i++) begin
				
				if(i >= sh)d_out[7-i] <= d_out[(7-i)+sh];
			
			end
		
		end
		
		else if(sh != 0) begin
			
			d_out <= 8'hFF;
			
			for (i=0; i<=7; i++) begin
				
				if(i>=sh) d_out[i] <= d_out[i-sh]; 
			
			end
		end		
	end
endmodule 