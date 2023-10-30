module TB_Mux2to1;
	reg a,b,sel;
	wire y;
	mux2to1 dut(.a (a),.b(b),.sel(sel),.y(y));  //Instanciando nuestro diseño para prueba
	initial begin
		sel =1;
		a = 0;
		b = 0;
		#100;
		a = 1;
		#100;
		sel = 0;
		#100;
		b = 1;
	end
endmodule
