
/******************************************************************
* Description
*
* ALU
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module RISC_ALU(input logic [31:0] instruction,
						  input logic [31:0] instruction_Y,
						  input logic [31:0] instruction_R,
						  input logic signed [31:0] rd_alu_Y,
						  input logic signed [31:0] rd_alu_R,
						  input logic signed [31:0] rd1_alu_A,
						  input logic signed [31:0] rd2_alu_B,
						  input logic [31:0] PC,
						  output logic [31:0] rd);

	localparam LUI    = 7'b0110111;
	localparam AUIPC  = 7'b0010111;
	localparam IMM_OP = 7'b0010011;
	localparam BRANCH = 7'b1100011;
	localparam LOAD   = 7'b0000011;
	localparam STORE  = 7'b0100011;
	
	localparam ADD   = 1'b0;
	localparam SUB   = 1'b1;
	localparam ADDI  = 10'b000_0010011;
	
	localparam SLL   = 10'b001_0110011;
	localparam SRL   = 1'b0; 
	localparam SRA   = 1'b1; 
	localparam SLLI  = 10'b001_0010011;
	localparam SRLI  = 1'b0; 
	localparam SRAI  = 1'b1; 
	
	localparam XOR   = 10'b100_0110011;
	localparam OR    = 10'b110_0110011;
	localparam AND   = 10'b111_0110011;
	localparam XORI  = 10'b100_0010011;
	localparam ORI   = 10'b110_0010011;
	localparam ANDI  = 10'b111_0010011;
	
	localparam SLT   = 10'b010_0110011;
	localparam SLTU  = 10'b011_0110011;
	localparam SLTI  = 10'b010_0010011;
	localparam SLTIU = 10'b011_0010011;
	
	localparam LB    = 10'b000_0000011;
	localparam LH    = 10'b001_0000011;
	localparam LW    = 10'b010_0000011;
	localparam LBU   = 10'b100_0000011;
	localparam LHU   = 10'b101_0000011;
	
	localparam SB    = 10'b000_0100011;
	localparam SH    = 10'b001_0100011;
	localparam SW    = 10'b010_0100011;
	
	localparam ADD_SUB   = 10'b000_0110011;
	localparam SRL_SRA   = 10'b101_0110011;
	localparam SRLI_SRAI = 10'b101_0010011;
	
	logic [4:0] shamt;
	logic [9:0] op_code;
	logic signed [31:0] rd1_alu;
	logic signed [31:0] rd2_alu;

	assign op_code = {instruction[14:12], instruction[6:0]};
	assign shamt = instruction[24:20];
		
	always_comb begin
		if((instruction[6:0] != BRANCH) && (Instruction[6:0] != STORE) && (Instruction_Y[11:7] == Instruction[19:15]))
		rd1_alu = rd_alu_Y;
		
		else if((instruction[6:0] != BRANCH) && (instruction[6:0] != STORE) && (i[11:7] == instruction[19:15]))	
		rd1_alu = rd_alu_R;
		
		else rd1_alu = rd1_alu_A;
		
		if((instruction[6:0] != LUI) && (instruction[6:0] != AUIPC) && (instruction[6:0] != IMM_OP) && (instruction[6:0] != LOAD) && (instruction_Y[11:7] == instruction[24:20])) 	
		rd2_alu = rd_alu_Y;
		
		else if((instruction[6:0] != LUI) && (instruction[6:0] != AUIPC) && (instruction[6:0] != IMM_OP) && (instruction[6:0] != LOAD) && (i[11:7] == instruction[24:20]))	
				rd2_alu = rd_alu_R;
		else	rd2_alu = rd2_alu_B;

	end
	
	always_comb begin
		case(op_code)
			ADD_SUB: if(instruction[30] == ADD) rd = rd1_alu + rd2_alu; 
					 else rd = rd1_alu - rd2_alu; 

			ADDI: 	rd = rd1_alu + {{20{rd2_alu[11]}}, rd2_alu[11:0]};
			
			SLL: 		rd = rd1_alu << rd2_alu[4:0]; 	
			
			SRL_SRA: if(instruction[30] == SRL) rd = rd1_alu >> rd2_alu[4:0];
						else begin
							rd = rd1_alu >> rd2_alu[4:0];
							rd[31] = rd1_alu[31];
						end
			
			SLLI: 	rd = rd1_alu << shamt; 
			
			SRLI_SRAI:	if(instruction[30] == SRLI) rd = rd1_alu >> shamt; 
							else begin
								rd = rd1_alu >> shamt;
								rd[31] = rd1_alu[31];
							end 
			
			XOR: 		rd = rd1_alu ^ rd2_alu;
			
			OR: 		rd = rd1_alu | rd2_alu; 
			
			AND: 		rd = rd1_alu & rd2_alu;  
			
			XORI: 	rd = rd1_alu ^ {{20{rd2_alu[11]}}, rd2_alu[11:0]};
			
			ORI: 		rd = rd1_alu | {{20{rd2_alu[11]}}, rd2_alu[11:0]};
			
			ANDI: 	rd = rd1_alu & {{20{rd2_alu[11]}}, rd2_alu[11:0]}; 
			
			SLT: 		if(rd1_alu < rd2_alu) rd = 1;
						else rd = 0;
			
			SLTU:		if(rd1_alu[31] == rd2_alu[31]) begin
							if(rd1_alu < rd2_alu) rd = 1;
							else rd = 0;
						end
						else if (rd1_alu[31] == 1'b1) rd = 1;
						else rd = 0;
			
			SLTI:		if (rd1_alu < {{20{rd2_alu[11]}}, rd2_alu[11:0]}) begin
							rd = 1;
						end
						else rd = 0;
			
			SLTIU:	if(rd1_alu[31] == rd2_alu[31]) begin
							if(rd1_alu < {{20{rd2_alu[11]}}, rd2_alu[11:0]}) begin
								rd = 1;
							end
							else rd = 0;
						end
						
						else if(rd1_alu[31] == 1'b1) begin
							rd = 1;
						end
						
						else rd = 0;	

			default: begin
							if(op_code[6:0] == LUI) rd = {instruction[31:12],12'b0}; 
							else rd = 0;
						end
		endcase
	end
endmodule 