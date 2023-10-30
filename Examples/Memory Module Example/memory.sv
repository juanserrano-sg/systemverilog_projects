
//Memoria - JUAN ANTONIO SERRANO GOMEZ
module memory(input rst, input clk, input wr_en, input[3:0] addr, inout[1:0] data); 
	logic[1:0] mem[15:0];  
	integer i;
	always @(posedge clk) 
		if (rst) begin 
			for(i=0; i<16;i=i+1) mem[i] <=0;
			end    
		else begin 
		if(wr_en) mem[addr] <=data;
		end  
	
	assign data= (~wr_en) ? mem[addr] : 2'b zz; 
endmodule
