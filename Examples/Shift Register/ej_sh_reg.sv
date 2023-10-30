
//Ejercicio shift register
module ej_sh_reg(
input rst, input clk, input shift_r_l, input load,input [2:0] sh, input [7:0] d_in,
output logic [7:0] d_out);

localparam logic [7:0] r1 [7:0] =
'{
8'b0000_0000, 8'b1000_0000, 8'b1100_0000, 8'b1110_0000, 8'b1111_0000, 8'b1111_1000, 8'b1111_1100, 8'b1111_1110 
};

localparam logic [7:0] l1 [7:0] =
'{
8'b0000_0000, 8'b0000_0001, 8'b0000_0011, 8'b0000_0111, 8'0000_1111, 8'b0001_1111, 8'b0011_1111, 8'b0111_1111 
};

always @(posedge clk) begin
	if (rst) begin
	d_out <= 8'b00000000;
	end
	else if (load) begin
	d_out <= d_in;
	end
	else begin
		if(shift_r_l) begin
		d_out <= d_out >> sh;
		d_out <= d_out | r1[sh];
		end
		else if(!shift_r_l) begin
		d_out <= d_out << sh;
		d_out <= d_out | l1[sh];
		end	
	end
end
endmodule

