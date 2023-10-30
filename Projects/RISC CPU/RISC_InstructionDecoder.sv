
/******************************************************************
* Description
*
* Instruction Decoder
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module RISC_InstructionDecoder(input logic clk,
								   input logic reset,
								   input logic [31:0] instruction,
								   input logic [4:0] wa,
								   input logic [31:0] wd,
								   output logic [31:0] rd1_alu,
								   output logic [31:0] rd2_alu,
								   output logic [31:0] rd2);

	localparam LUI   = 10'bxxx_0110111;
	localparam AUIPC = 10'bxxx_0010111;
	localparam ADD   = 10'b000_0110011;
	localparam SUB   = 10'b000_0110011;
	localparam ADDI  = 10'b000_0010011;
	
	localparam SLL   = 10'b001_0110011;
	localparam SRL   = 10'b101_0110011;
	localparam SRA   = 10'b101_0110011;
	localparam SLLI  = 10'b001_0010011;
	localparam SRLI  = 10'b101_0010011;
	localparam SRAI  = 10'b101_0010011;
	
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
	
	localparam BEQ   = 10'b000_1100011;
	localparam BNE   = 10'b001_1100011;
	localparam BLT   = 10'b100_1100011;
	localparam BGE   = 10'b101_1100011;
	localparam BLTU  = 10'b110_1100011;
	localparam BGEU  = 10'b111_1100011;
	
	localparam JAL   = 10'bXXX_1101111;
	localparam JALR  = 10'b000_1100111;
	
	localparam LB    = 10'b000_0000011;
	localparam LH    = 10'b001_0000011;
	localparam LW    = 10'b010_0000011;
	localparam LBU   = 10'b100_0000011;
	localparam LHU   = 10'b101_0000011;
	
	localparam SB    = 10'b000_0100011;
	localparam SH    = 10'b001_0100011;
	localparam SW    = 10'b010_0100011;
	
	
	

	logic alu_select;
	logic [3:0] we_out;
	logic [9:0] op_code;
	logic [11:0] imm_select;
	logic [4:0] rs2, rs1;
	logic [31:0] operation_reg [31:0];
	
	assign op_code = {instruction[14:12], instruction[6:0]};
	assign alu_select = (op_code == ADDI || op_code == XORI || op_code == ORI || op_code == ANDI || op_code == SLTI || op_code == SLTIU || 
								op_code == LB || op_code == LH || op_code == LW || op_code == LBU || op_code == LHU || 
								op_code == SB || op_code == SH || op_code == SW);

	assign imm_select = (op_code == SB || op_code == SH || op_code == SW)? {instruction[31:25], instruction[11:7]} : instruction[31:20];
	
	assign we_out[0] = !(op_code[6:0] == BEQ[6:0] || op_code[6:0] == SB[6:0]);
	
	assign rs1 = instruction[19:15];
	assign rd1_alu = operation_reg[rs1];
	assign rs2 = instruction[24:20];
	
	assign rd2_alu = (alu_select)? {20'b0, imm_select} : operation_reg[rs2];
	
	assign rd2 = operation_reg[rs2];
	
	
	
	always @ (posedge clk) begin
		
		we_out[3:1] <= we_out[2:0];
		
	end
	
	always @ (negedge reset, posedge clk) begin
		
		if(!reset) operation_reg <= '{default:32'd0};
				
		else if(wa != 0 && we_out[3]) operation_reg[wa] <= wd;
		
	end

endmodule 