
/******************************************************************
* Description
*
* Data Memory
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module RISC_DataMemory(input  logic clk,
						   input  logic reset,
						   input  logic [8:0]  instruction,
					       input  logic [31:0] address,
						   input  logic [31:0] wdata,
						   output logic [31:0] data_out);

	localparam LB    = 10'b000_0000011;
	localparam LH    = 10'b001_0000011;
	localparam LW    = 10'b010_0000011;
	localparam LBU   = 10'b100_0000011;
	localparam LHU   = 10'b101_0000011;
	
	localparam SB    = 10'b000_0100011;
	localparam SH    = 10'b001_0100011;
	localparam SW    = 10'b010_0100011;
	
	
	logic [31:0] DM [15:0];
	logic [31:0] rdata;
	
	logic MemWrite;
	logic WBSel;
	
	assign MemWrite = (instruction == SB || instruction == SH || instruction == SW);
	assign WBSel    = (instruction == LB || instruction == LH || instruction == LW || instruction == LBU || instruction == LHU);
	

	always @ (negedge reset, posedge clk) begin
		if(!reset) begin
			for (integer i = 0; i < 16; i++) begin
				DM[i] <= i;
			end
			
		end
		
		else if(MemWrite) begin
			
			case(instruction)	
				SB: DM[address] <= {24'd0,wdata[7:0]}; 
				SH: DM[address] <= {16'd0,wdata[15:0]};
				SW: DM[address] <= wdata[31:0];
				default: DM[address] <= wdata[31:0];
			endcase
		end
	end
	
	assign rdata = DM[address];
	assign data_out = WBSel ? rdata : address;
	
endmodule
