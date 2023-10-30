
/******************************************************************
* Description
*
* cCnverter
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module converter(mode, cntHr, cntSec, d_Hr,u_Hr, d_s, u_s);
	parameter width_Hr=1;
	parameter WIDTH_SEC=1;
	
	input mode;
	input [width_Hr-1:0] cntHr;
	input [WIDTH_SEC-1:0] cntSec;
	
	output [3:0] d_s;
	output [3:0] u_s;
	
	output [3:0]d_Hr;
	output [3:0]u_Hr;

	logic [3:0]uniHoras = 0;
	logic [1:0]decHoras = 0;

	integer i ;

//formato 23hrs
always @(mode) begin

	if(mode) begin
		uniHoras=0;
		decHoras=0;
		for(i=0; i<=23; i++) begin
			if(cntHr == i) begin
				u_Hr = uniHoras;
				d_Hr = decHoras;
			end
			
			if(uniHoras==9) begin
				uniHoras = 0;
				decHoras++;
			end
			
			else 
			uniHoras++;

		end
	end
	
	 	else begin 
		uniHoras=0;
		decHoras=0;
		for(i=0; i<=23; i++) begin
			if(cntHr == i) begin
				u_Hr = uniHoras;
				d_Hr = decHoras;
			end
			
			if (uniHoras == 2 && decHoras == 1) begin 
				uniHoras = 1;
				decHoras = 0;
			end
			
			else if(uniHoras == 9) begin
				uniHoras = 0;
				decHoras++;
			end
			
			else	begin
			uniHoras++;
			end
		end
	end
end



always_comb begin
	d_s= cntSec / 10;
	u_s= cntSec % 10;
end

endmodule