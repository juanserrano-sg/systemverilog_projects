/******************************************************************
* Description
*
* Top Level
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module dds_sin_cos_fsm (
	input logic clk,
	input logic rst,
	
	input logic en_i,
	input logic load_i,
	
	output logic freq_clr,
	output logic freq_load,
	output logic out_load, 
	output logic out_clr
	
		
);


typedef enum logic [1:0] {IDLE=2'b00, LOAD=2'b01, INC=2'b10, XX='x} state_t; //For FSM states

 //typedef definitions
 state_t state;
 state_t next;

 //(1)State register
 always_ff@(posedge clk or negedge rst)
     if(!rst) state <= IDLE;                                            
     else      state <= next;

 //(2)Combinational next state logic
 always_comb begin
     next = XX;
     unique case(state)
         IDLE: 		if(en_i) begin 
								if (load_i) next = LOAD;
								else next = INC;
							end
							else    next = IDLE;  
					  
         LOAD:      	if(en_i) begin 
								if (load_i) next = LOAD;
								else next = INC;
							end
							else    next = IDLE;
		
			INC:		if(en_i) begin 
								if (load_i) next = LOAD;
								else next = INC;
							end
							else    next = IDLE;
							
         default:        next = XX;
     endcase
 end
 
 
 //(3)Registered output logic (Moore outputs)
 always_ff @(posedge clk or negedge rst) begin
     if(!rst) begin
         freq_clr <= 1'b1;
			freq_load <= 1'b0;
			out_clr <= 1'b1;
			out_load <= 1'b0;
     end
     else begin
         freq_clr <= 1'b0;
			freq_load <= 1'b0;
			out_clr <= 1'b0;
			out_load <= 1'b0;
			
             unique case(next)
                 IDLE: begin				  
						  freq_clr <= 1'b1;
						  out_clr <= 1'b1;
    				  end
					  
					  LOAD: ;
					  
                 INC: begin
						  freq_load <= 1'b1;
						  out_load <= 1'b1;
					  end
					  
             endcase
     end
 end
 

endmodule