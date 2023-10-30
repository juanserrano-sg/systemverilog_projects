
/******************************************************************
* Description
*
* JTAG 8 Bit Register
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module JTAG_Register8bits(input TDI,
										input TMS,
										input TCK,
										input TRST,
										input reset,
										input clk,
										input load,   
										input shift_r_l,
										input [2:0] sh,
										input [7:0] d_in,
										output logic [7:0] d_out,
										output logic TDO);
	
	typedef enum{Test_Logic_Reset,
					 Run_Test_Idle,
					 Select_DR_Scan,
					 Select_IR_Scan,
					 Capture_DR,
					 Shift_DR,
					 Exit1_DR,
					 Pause_DR,
					 Exit2_DR,
					 Update_DR,
					 Capture_IR,
					 Shift_IR,
					 Exit1_IR,
					 Pause_IR,
					 Exit2_IR,
					 Update_IR} states;
	
	states currentState;
	states nextState;
	
	logic clkDR;
	logic updateDR;
	logic mode;
	logic shiftDR;
	
	logic resetJTAG,clkJTAG,loadJTAG,shift_r_lJTAG;
	logic [3:0] sh_IN;
	logic [2:0] sh_JTAG;
	logic [8:0] d_in_IN;
	logic [7:0] d_in_JTAG;
	logic [8:0] d_out_IN;
	logic [7:0] d_out_JTAG;
	
	logic shiftOUT_1;
	logic shiftOUT_2;
	logic shiftOUT_3;
	logic shiftOUT_4;
	logic [2:0] shiftOUT_5;
	logic [7:0] shiftOUT_6;
	logic [7:0] shiftOUT_7;
	
	logic [1:0] InstrReg;
	logic [1:0] InstrRegTemp;
	logic BypassReg;
	logic [31:0] IDCODEReg;
	
	localparam IDCODE = 32'h5802_FE0A;
	
	localparam IDCODE_INS = 2'b00;
	localparam SAMPLE_PRELOAD = 2'b01;
	localparam EXTEST = 2'b10;
	localparam BYPASS = 2'b11;

	always @ (posedge TCK) begin 
		
		if(currentState == Shift_IR) begin
		
			InstrRegTemp[0] <= TDI;
			InstrRegTemp[1] <= InstrRegTemp[0];
		
		end
	end
	
	always @ (negedge TRST, posedge TCK) begin 
		
		if(!TRST) InstrReg <= BYPASS;
		
		else if(currentState == Update_IR) begin
		
			InstrReg <= InstrRegTemp;
		
		end
	end
	
	always @ (posedge TCK) begin
		
		if((InstrReg == BYPASS) && (currentState == Shift_DR)) BypassReg <= TDI;
		
	end
	
	always @ (posedge TCK) begin 
		
		if(currentState == Shift_DR)  begin 
													IDCODEReg[0] <= IDCODEReg[31];
													IDCODEReg[31:1] <= IDCODEReg[30:0];
												end
		
		else IDCODEReg <= IDCODE;
		
	end
	
	always_comb begin
	
		if(currentState == Shift_IR) TDO = InstrRegTemp[1];
		
		else if(currentState == Shift_DR) begin
			
			if(InstrReg == BYPASS) TDO = BypassReg;
			
			else if((InstrReg == EXTEST) || (InstrReg == SAMPLE_PRELOAD)) TDO = shiftOUT_7[7];
			
			else TDO = IDCODEReg[31];
		end
		
		else TDO = 1'b0;
		
	end
	
	always_comb begin
		
		if(InstrReg != SAMPLE_PRELOAD) mode = 0;
		
		else mode = 1;
		
	end
	
	always_comb begin 
		
		if((currentState == Capture_DR) && (InstrReg == SAMPLE_PRELOAD)) shiftDR = 1'b0;
		
		else if(((currentState == Update_DR) || (currentState == Shift_DR)) && ((InstrReg == EXTEST) || (InstrReg == SAMPLE_PRELOAD))) shiftDR = 1'b1;
		
		else shiftDR = 1'b0;
		
	end
	
	always_comb begin 
		
		if(((currentState == Capture_DR) || (currentState == Shift_DR)) && ((InstrReg == EXTEST) || (InstrReg == SAMPLE_PRELOAD))) clkDR = TCK;
		
		else clkDR = 1'b0; 
		
	end
	
	always_comb begin
		if((currentState == Update_DR) && ((InstrReg == EXTEST) || (InstrReg == SAMPLE_PRELOAD))) updateDR = ~TCK;
		else updateDR = 1'b1; 
		
	end
			
			
	always @ (negedge TRST, posedge TCK) begin 
		if(!TRST) currentState <= Test_Logic_Reset;
		else currentState <= nextState;
	end
	
	always_comb begin
		nextState = currentState;
		
		case(currentState)
			Test_Logic_Reset: begin
										if(!TMS) nextState = Run_Test_Idle;
									end
			
			Run_Test_Idle: 	begin
										if(TMS) nextState = Select_DR_Scan;
									end
			
			Select_DR_Scan: 	begin
										if(TMS) nextState = Select_IR_Scan;
										else nextState = Capture_DR;
									end
			
			Select_IR_Scan: 	begin
										if(TMS) nextState = Test_Logic_Reset;
										else nextState = Capture_IR;
									end
			
			Capture_DR: 		begin
										if(TMS) nextState = Exit1_DR;
										else nextState = Shift_DR;
									end
			
			Shift_DR: 			begin
										if(TMS) nextState = Exit1_DR;
									end
			
			Exit1_DR: 			begin
										if(TMS) nextState = Update_DR;
										else nextState = Pause_DR;
									end
			
			Pause_DR: 			begin
										if(TMS) nextState = Exit2_DR;
									end
			
			Exit2_DR: 			begin
										if(TMS) nextState = Update_DR;
										else nextState = Shift_DR;
									end
			
			Update_DR: 			begin
										if(TMS) nextState = Select_DR_Scan;
										else nextState = Run_Test_Idle;
									end
			
			Capture_IR: 		begin
										if(TMS) nextState = Exit1_IR;
										else nextState = Shift_IR;
									end
			
			Shift_IR:			begin
										if(TMS) nextState = Exit1_IR;
									end
			
			Exit1_IR:			begin
										if(TMS) nextState = Update_IR;
										else nextState = Pause_IR;
									end
			
			Pause_IR:			begin
										if(TMS) nextState = Exit2_IR;
									end
			
			Exit2_IR:			begin
										if(TMS) nextState = Update_IR;
										else nextState = Shift_IR;
									end
			
			Update_IR:			begin
										if(TMS) nextState = Select_DR_Scan;
										else nextState = Run_Test_Idle;
									end
			
		endcase
	end
	
	E16_Register8bits DUT0(.reset(resetJTAG),.clk(clkJTAG),.load(loadJTAG),.shift_r_l(shift_r_lJTAG),.sh(sh_JTAG),.d_in(d_in_JTAG),.d_out(d_out_JTAG));
	
	E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_1(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(TDI),.shiftOUT(shiftOUT_1),.parallelIN(reset),.parallelOUT(resetJTAG));
	E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_2(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(shiftOUT_1),.shiftOUT(shiftOUT_2),.parallelIN(clk),.parallelOUT(clkJTAG));
	E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_3(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(shiftOUT_2),.shiftOUT(shiftOUT_3),.parallelIN(load),.parallelOUT(loadJTAG));
	E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_4(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(shiftOUT_3),.shiftOUT(shiftOUT_4),.parallelIN(shift_r_l),.parallelOUT(shift_r_lJTAG));
	
	genvar i;
	
	assign sh_IN[0] = shiftOUT_4;
	generate
		
		for(i = 0; i < 3; i++) begin: JTAG_BOUNDARY_5 
			
			assign sh_IN[i+1] = shiftOUT_5[i];
			//assign sh_IN[2:1] = shiftOUT_5[1:0];
			
			E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_5(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(sh_IN[i]),.shiftOUT(shiftOUT_5[i]),.parallelIN(sh[i]),.parallelOUT(sh_JTAG[i]));
			
		end
	endgenerate
	
	assign d_in_IN[0] = shiftOUT_5[2];
	generate
		
		for(i = 0; i < 8; i++) begin: JTAG_BOUNDARY_6
			
			assign d_in_IN[i+1] = shiftOUT_6[i];
			//assign d_in_IN[7:1] = shiftOUT_6[6:0];
			
			E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_6(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(d_in_IN[i]),.shiftOUT(shiftOUT_6[i]),.parallelIN(d_in[i]),.parallelOUT(d_in_JTAG[i]));
			
		end
	endgenerate
	
	assign d_out_IN[0] = shiftOUT_6[7];
	generate 
		
		for(i = 0; i < 8; i++) begin: JTAG_BOUNDARY_7
			
			assign d_out_IN[i+1] = shiftOUT_7[i];
			//assign d_out_IN[7:1] = shiftOUT_7[6:0];
			
			E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_7(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(d_out_IN[i]),.shiftOUT(shiftOUT_7[i]),.parallelIN(d_out_JTAG[i]),.parallelOUT(d_out[i]));
			
		end
		
	endgenerate	
endmodule 