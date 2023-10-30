/******************************************************************
* Description
*
* DUAL PORT RAM
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module simple_dual_port_ram_single_clk_sv #(
		parameter DATA_WIDTH= 8,
		parameter ADDR_WIDTH= 8,
		parameter TXT_FILE= "C:/juanquart/conv_proy/mem_X.txt"
)(
		input  logic                  clk,		
		input  logic                  write_en_i,
		input  logic [ADDR_WIDTH-1:0] write_addr_i,
		input  logic [DATA_WIDTH-1:0] write_data_i,
		
		input  logic [ADDR_WIDTH-1:0] read_addr_i1,
		input  logic [ADDR_WIDTH-1:0] read_addr_i2,

		output logic [DATA_WIDTH-1:0] read_data_o1,
	   output logic [DATA_WIDTH-1:0] read_data_o2
	   
);

// signal declaration
logic [DATA_WIDTH-1:0] RAM_structure [2**ADDR_WIDTH-1:0]; 

initial begin  //load hexadecimal data in txt
		$readmemh(TXT_FILE, RAM_structure);		
end

//write and read operations
always_ff @ (posedge clk) begin
		if(write_en_i)
				RAM_structure[write_addr_i] <= write_data_i;
		read_data_o1 <= RAM_structure[read_addr_i1];
		read_data_o2 <= RAM_structure[read_addr_i2];		
end

endmodule
