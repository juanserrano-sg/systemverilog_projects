module TB_Mux4_1;
	reg [3:0]a;
	reg [1:0]sel;
	wire y;
	mux2to1 dut(.a (a),.sel(sel),.y(y));  //Instanciando nuestro diseño para prueba
	initial begin
		sel = 2'b00;
		a = 4'b1010;
		#100;
		sel = 2'b01;
		#100;
		sel = 2'b10;
		#100;
		sel = 2'b11;
	end
endmodule
