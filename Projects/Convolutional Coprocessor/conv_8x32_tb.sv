/******************************************************************
* Description
*
* TB Module 
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/


`timescale 1ns/100ps 

module conv_8x32_tb ();

localparam DATAWIDTH_IN 			 = 8,
			  DATAWIDTH_OUT 			 = 16,
			  
//Colocar tamaño de los vectores
			  X_SIZE				       = 5'b0_0101,
			  Y_SIZE      				 = 5'b0_1010,
			  
           RAM_IN_ADDR_WIDTH      = 5,			  
			  RAM_OUT_ADDR_WIDTH     = 6;
			  

logic clk;
logic rstn;

logic       init_i;

logic [7:0] dato_X;
logic [7:0] dato_Y;
logic [15:0] dato_Z;

logic [4:0] memX_addr;
logic [4:0] memY_addr;
logic [5:0] memZ_addr;

logic [15:0] z_Wire;

logic       done, busy, writeZ;

integer mem_out_file;


//Top Level
 conv_8x32 dut(
	.clk(clk), 
	.rst(rstn), 
	.start_i(init_i),
	.sizeX(X_SIZE), 
	.sizeY(Y_SIZE),
	.dataX(dato_X), 
	.dataY(dato_Y), 
	.writeZ(writeZ), 
	.busy(busy), 
	.done(done),
	.memX_addr(memX_addr), 
	.memY_addr(memY_addr),
	.memZ_addr(memZ_addr),
	.dataZ(dato_Z)

);


//***************** ROM **********************
simple_rom_sv #(
		.DATA_WIDTH(DATAWIDTH_IN),
		.ADDR_WIDTH(RAM_IN_ADDR_WIDTH),
		.TXT_FILE("C:/juanquart/conv_proy/mem_X.txt")
) ROM_X(
		.clk(clk),		
		.read_addr_i(memX_addr),
		.read_data_o(dato_X)	   
);

simple_rom_sv #(
		.DATA_WIDTH(DATAWIDTH_IN),
		.ADDR_WIDTH(RAM_IN_ADDR_WIDTH),
		.TXT_FILE("C:/juanquart/conv_proy/mem_Y.txt")
) ROM_Y(
		.clk(clk),		
		.read_addr_i(memY_addr),
		.read_data_o(dato_Y)	   
);


//************** RAM OUT ************************	

simple_dual_port_ram_single_clk_sv #(
		.DATA_WIDTH(DATAWIDTH_OUT),
		.ADDR_WIDTH (RAM_OUT_ADDR_WIDTH),
		.TXT_FILE   ("C:/juanquart/conv_proy/mem_Z.txt")
) RAM_Z(
		.clk         (clk),		
		.write_en_i  (writeZ),
		.write_addr_i(memZ_addr),				
		.read_addr_i (6'd0),
		.write_data_i(dato_Z),
		.read_data_o (z_Wire)
	   
);

//clock source
 initial begin 
    clk = 0;
    forever begin
    #50 clk = ~clk;
    end
end

initial begin
   mem_out_file=$fopen("C:/juanquart/conv_proy/mem__Z_out.txt","w");
	rstn      = 1'b0; 
	init_i    = 1'b0;
	
	#70
	rstn = 1'b1;
	init_i = 1'b1;
	
   for(int i=0; i < (X_SIZE + Y_SIZE - 1); i++) begin
      @(posedge writeZ)
      $fdisplay(mem_out_file, "%d", dato_Z); 
   end	
	
	$fclose(mem_out_file);
	#20_000
	$stop;
end

endmodule
