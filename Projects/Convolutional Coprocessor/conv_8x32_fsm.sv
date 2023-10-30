/******************************************************************
* Description
*
* Top Level
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module conv_8x32_fsm (
	input logic clk,
	input logic rst,
	
	input logic init_i,
	input logic done_i,
	
	input logic memS_cond,
	input logic memZ_cond,
	
	output logic memS_en_o,
	output logic memZ_en_o,
	
	output logic k_load_o,
	output logic n_load_o,
	output logic k_clr_o,
	output logic n_clr_o,
	
	output logic d_get_o,
	output logic d_state_o,
	output logic ini_state_o,
	
	
	output logic regz_load_o,
	output logic z_load_o,
	output logic regz_clr_o,
	output logic z_clr_o,	
	output logic wr_z_o, 
	output logic busy_state_o
);


typedef enum logic [3:0] {IDLE=4'b0000, ZS_EVAL=4'b0001, DATA_NG=4'b0010, MUL_SUMS = 4'b0011, INC_K = 4'b0100, MEMZ_POINT = 4'b0101, INC_N = 4'b0110, Z_WRITE = 4'b0111, DONE = 4'b1000, INI = 4'b1001, MEMS_POINT = 4'b1010, MEM_WAIT = 4'b1011, D_WAIT = 4'b1100, XX='x} state_t; //For FSM states

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
         IDLE: 		if(init_i) next = INI;
							else    next = IDLE;  
					  
         INI:      	next = ZS_EVAL;
		
			ZS_EVAL:		if(~done_i) next = DONE;
							else begin 
								if(memZ_cond && memS_cond) next = MEMS_POINT;
								else    next = INC_K;
							end
							
			MEMS_POINT: next = MEM_WAIT;
			
			MEM_WAIT:	next = MUL_SUMS;
			
         MUL_SUMS: 	next = DATA_NG;
			
         INC_K: 		next = DATA_NG;
					
			DATA_NG:		if(memZ_cond) next = ZS_EVAL;
							else    next = MEMZ_POINT;
					
         MEMZ_POINT: next = Z_WRITE;   
			
         Z_WRITE: 	next = INC_N; 

			INC_N: 		next = ZS_EVAL;

         DONE: 		next = D_WAIT;
						
			D_WAIT:		if(init_i) next = D_WAIT;
							else    next = IDLE;
							
         default:        next = XX;
     endcase
 end
 
 
 //(3)Registered output logic (Moore outputs)
 always_ff @(posedge clk or negedge rst) begin
     if(!rst) begin
         k_load_o <= 1'b0;
			k_clr_o <= 1'b0;
			n_load_o <= 1'b0;
			n_clr_o <= 1'b0;
			
		   ini_state_o <= 1'b0;
			memS_en_o <= 1'b0;
			memZ_en_o <= 1'b0;
			d_get_o <= 1'b0;
			d_state_o <= 1'b0;
			
			regz_load_o <= 1'b0;
			z_load_o <= 1'b0;
			regz_clr_o <= 1'b0;
			z_clr_o <= 1'b0;	
			wr_z_o <= 1'b0;
			busy_state_o <= 1'b0;
			
			
     end
     else begin
         ini_state_o <= 1'b0;
			k_load_o <= 1'b0;
			k_clr_o <= 1'b0;
			n_load_o <= 1'b0;
			n_clr_o <= 1'b0;
			
			memS_en_o <= 1'b0;
			memZ_en_o <= 1'b0;
			d_get_o <= 1'b0;
			d_state_o <= 1'b0;
			
			regz_load_o <= 1'b0;
			z_load_o <= 1'b0;
			regz_clr_o <= 1'b0;
			z_clr_o <= 1'b0;	
			wr_z_o <= 1'b0;
			busy_state_o <= 1'b1;	
			
             unique case(next)
                 IDLE: begin				  
						  busy_state_o <= 1'b0;
					  end
					  
					  INI: begin
						  ini_state_o <= 1'b1;	
						  busy_state_o <= 1'b1;
						  k_clr_o <= 1'b1;
						  n_clr_o <= 1'b1;
						  regz_clr_o <= 1'b1;
						  z_clr_o <= 1'b1;
					  end
					  
                 ZS_EVAL: ;
					  
					  MEMS_POINT: begin
					  			memS_en_o <= 1'b1;
					  end
							
					  MEM_WAIT:;
					  
					  MUL_SUMS: begin
							d_get_o <= 1'b1;
							regz_load_o <= 1'b1;
							k_load_o <= 1'b1;
					  end
					  
					  INC_K: begin
							k_load_o <= 1'b1;
					  end
					  
					  DATA_NG: ;
					  
                 MEMZ_POINT: begin
							k_clr_o <= 1'b1;
							memZ_en_o <= 1'b1;
							z_load_o <= 1'b1; 
					  end
					  
                 Z_WRITE: begin
							wr_z_o <= 1'b1;	
							
					  end
					  
					  INC_N:  begin
							n_load_o <= 1'b1;
							k_clr_o <= 1'b1;
							regz_clr_o <= 1'b1;
					  end
					  
                 DONE: begin
							busy_state_o <= 1'b0;
							d_state_o <= 1'b1;
					  end
					  
					  D_WAIT: begin
							busy_state_o <= 1'b0;
					  end
					  
             endcase
     end
 end
 

endmodule