

/******************************************************************
* Description
*
* Instruction Memory
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module RISC_InstructionMemory(input logic [29:0]  address,
								  output logic [31:0] data_out);

	logic [31:0] IM [15:0];
	
	assign IM[0] = {12'h008,5'b00000,3'b000,5'b00001,7'b0010011}; //ADDI rd, rs1, imm -> 1,0,8  -> operation_reg[1] = rs1 + 8
	//assign IM[1] = {12'h010,5'b00000,3'b000,5'b00010,7'b0010011}; //ADDI rd, rs1, imm -> 2,0,16 -> operation_reg[2] = rs1 + 16
	assign IM[1] = {7'd0,5'd1,5'd1,3'b000,5'd2,7'b0110011}; 		  //ADD rd, rs1, rs2 -> 2,8,8 -> operation_reg[2] = rs1 + rs2 //8+8
	//assign IM[2] = {12'h020,5'b00000,3'b000,5'b00011,7'b0010011}; //ADDI rd, rs1, imm -> 3,0,32 -> operation_reg[3] = rs1 + 32
	assign IM[2] = {7'd0,5'd1,5'd1,3'b000,5'd3,7'b0110011}; 		  //ADD rd, rs1, rs2 -> 3,8,8 -> operation_reg[3] = rs1 + rs2 //8+8
	assign IM[3] = {12'h040,5'b00000,3'b000,5'b00100,7'b0010011}; //ADDI rd, rs1, imm -> 4,0,64 -> operation_reg[4] = rs1 + 64
	assign IM[4] = {12'h080,5'b00000,3'b000,5'b00101,7'b0010011}; //ADDI rd, rs1, imm -> 5,0,128-> operation_reg[5] = rs1 + 128
	assign IM[5] = {7'd0,5'd2,5'd1,3'b010,5'd4,7'b0100011};       //SW   rs1,rs2, imm -> 1,2,4-> 
	assign IM[6] = 32'h00000000;
	assign IM[7] = 32'h00000000;
	assign IM[8] = 32'h00000000;
	assign IM[9] = 32'h00000000;
	assign IM[10] = 32'h00000000;
	assign IM[11] = 32'h00000000;
	assign IM[12] = 32'h00000000;
	assign IM[13] = 32'h00000000;
	assign IM[14] = 32'h00000000;
	assign IM[15] = 32'h00000000;
	
	assign data_out = IM[address[3:0]];

endmodule
