//Demultiplexor 1 a 4
module mux4_1 (a,sel,y);
	input [3:0] a;
	input [1:0] sel;
	output reg y;
	
	always_comb begin
		if(sel == 2'b00) begin
		y = a[0];
		end
		else if(sel == 2'b01) begin
		y = a[1];
		end
		else if(sel == 2'b10) begin
		y = a[2];
		end
		else begin
		y = a[3];
		end
	end 
endmodule
	