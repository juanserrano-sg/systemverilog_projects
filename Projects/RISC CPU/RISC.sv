
/******************************************************************
* Description
*
* RISC
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module RISC(input logic clk,
			input logic reset,
			output logic [31:0] dataMemory_out);
	
	logic [31:0] data, PC, address, Inst_in_1, Inst_out_1, Inst_out_2, Inst_out_3, Inst_out_4, rd1_alu, rd2_alu, rd2, A_out, B_out, rd, Y_out, MD1_out, MD2_out,Register_Data_out;
	
	RISC_ProgramCounter 		ProgramCounter(.data(3'h4),.clk(clk),.reset(reset),.PC(PC));
	
	
	
	RISC_InstructionMemory 	InstructionMemory(.address(PC[31:2]),.data_out(Inst_in_1));
	
	RISC_32bitsReg				InstructionRegister_1(.clk(clk),.data(Inst_in_1),.data_out(Inst_out_1));
	
	
	
	RISC_InstructionDecoder 	InstructionDecoder(.clk(clk),.reset(reset),.Instruction(Inst_out_1),.wa(Inst_out_4[11:7]),.wd(Register_Data_out),.rd1_alu(rd1_alu),.rd2_alu(rd2_alu),.rd2(rd2));
	
	RISC_32bitsReg				A_Register(.clk(clk),.data(rd1_alu),.data_out(A_out));
	
	RISC_32bitsReg				B_Register(.clk(clk),.data(rd2_alu),.data_out(B_out));
	
	RISC_32bitsReg				InstructionRegister_2(.clk(clk),.data(Inst_out_1),.data_out(Inst_out_2));
	
	RISC_32bitsReg				MD1_Register(.clk(clk),.data(rd2),.data_out(MD1_out));
	
	
		
	RISC_ALU				    ALU(.instruction(Inst_out_2), .instruction_Y(Inst_out_3),.instruction_R(Inst_out_4), .rd_alu_Y(Y_out), .rd_alu_R(Register_Data_out), .rd1_alu_A(A_out), .rd2_alu_B(B_out), .PC(32'b0), .rd(rd));
	
	RISC_32bitsReg				Y_Register(.clk(clk),.data(rd),.data_out(Y_out));
	
	RISC_32bitsReg				MD2_Register(.clk(clk),.data(MD1_out),.data_out(MD2_out));
	
	RISC_32bitsReg				InstructionRegister_3(.clk(clk),.data(Inst_out_2),.data_out(Inst_out_3));
	
	
	
	RISC_DataMemory				DataMemory(.clk(clk),.reset(reset),.Instruction({Inst_out_3[13:12],Inst_out_3[6:0]}),.address(Y_out),.wdata(MD2_out),.Data_out(dataMemory_out));
	
	RISC_32bitsReg				Register(.clk(clk),.data(dataMemory_out),.data_out(Register_Data_out));
	
	RISC_32bitsReg				InstructionRegister_4(.clk(clk),.data(Inst_out_3),.data_out(Inst_out_4));
	
endmodule 