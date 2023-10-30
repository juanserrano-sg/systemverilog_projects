//Demultiplexor 1 a 4
module mux2to1 (a,b,sel,y);
	input a,b,sel;
	output reg y;
	
	always @* begin
		if(sel) begin
			y = a;
		end
		else begin
			y = b;
		end
	end 
endmodule
	