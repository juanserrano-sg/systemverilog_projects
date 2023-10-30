
/******************************************************************
* Description
*
* REGISTER
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module dds_reg #(
	parameter DATA_WIDTH = 8
	
)(
	input  logic clk,
	input  logic rstn,
	input  logic clrh,
	input  logic enh,
	input  logic [DATA_WIDTH-1:0] d_in, 
	output logic [DATA_WIDTH-1:0] d_out
);

always_ff @(posedge clk, negedge rstn) begin 
	if(!rstn)
		d_out <= {DATA_WIDTH{1'b0}};
	else if(enh)
		d_out <= d_in;
	else if(clrh)
		d_out <= {DATA_WIDTH{1'b0}};
	else
	d_out <= d_out;
end

endmodule
