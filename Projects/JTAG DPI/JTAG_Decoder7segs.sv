
/******************************************************************
* Description
*
* JTAG 7 Segment Decoder 
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module JTAG_Decoder7segs(input TDI,
							 input TMS,
						     input TCK,
							 input TRST,
							 input [3:0] a,
							 output logic [6:0] y,
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
	
	logic [4:0] a_IN;
	//logic [3:0] a_IN;
	logic [3:0] a_JTAG;
	logic [7:0] y_IN;
	//logic [6:0] y_IN;
	logic [6:0] y_JTAG;
	
	logic [3:0] shiftOUT_1;
	logic [6:0] shiftOUT_2;
	
	logic [1:0] InstrReg;
	logic [1:0] InstrRegTemp;
	logic BypassReg;
	logic [31:0] IDCODEReg;
	
	localparam [31:0] IDCODE = 32'h9A10_E702;
	
	localparam IDCODE_INS = 2'b00;
	localparam SAMPLE_PRELOAD = 2'b01;
	localparam EXTEST = 2'b10;
	localparam BYPASS = 2'b11; //Obligatorio 11...1
	

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
			
			else if((InstrReg == EXTEST) || (InstrReg == SAMPLE_PRELOAD)) TDO = shiftOUT_2[6];
			
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
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////State machine									
	
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

	E16_Decoder7segs DUT0(.a(a_JTAG),.y(y_JTAG));
	
	genvar i;
	
	assign a_IN[0] = TDI;
	generate
		
		for(i = 0; i < 4; i++) begin: JTAG_BOUNDARY_1
			
			assign a_IN[i+1] = shiftOUT_1[i];
			
			E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_1(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(a_IN[i]),.shiftOUT(shiftOUT_1[i]),.parallelIN(a[i]),.parallelOUT(a_JTAG[i]));
			
		end
	endgenerate
	
	assign y_IN[0] = shiftOUT_1[2];
	generate 
		
		for(i = 0; i < 7; i++) begin: JTAG_BOUNDARY_2
			assign y_IN[i+1] = shiftOUT_2[i];
			E16_JTAG_BOUNDARY E16_JTAG_BOUNDARY_2(.clkDR(clkDR),.mode(mode),.updateDR(updateDR),.shiftDR(shiftDR),.shiftIN(y_IN[i]),.shiftOUT(shiftOUT_2[i]),.parallelIN(y_JTAG[i]),.parallelOUT(y[i]));
		end
		
	endgenerate	
endmodule 