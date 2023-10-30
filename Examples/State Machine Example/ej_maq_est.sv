
//Maquina de Estados
module ej_maq_est (sen, rst, clk, curr_st, Av, St);

input sen, clk, rst;

//Semaforos con vectores   G Y R
output [2:0] Av; // MSB	  	0 0 0		 LSB -> Semaforo de Avenida
output [2:0] St;//  MSB	   0 0 0		 LSB -> Semaforo de Calle

//Estados presente y futuro
output logic [2:0] curr_st;
logic [2:0] nxt_st;

//Cuentas para 0.5, 1 y 3 seg
logic [25:0] cnt1;
logic [27:0] cnt3;
logic [24:0] cnt0_5;

//Carrys
logic c1, c0_5, c3;

//Estados
parameter the_initial = 3'd0;
parameter av_green = 3'd1;
parameter av_yellow = 3'd2;
parameter av_red 	=  3'd3;
parameter st_yellow = 3'd4;

//Ciclos de una frec de 50MHz para 3, 1 y 0.5 s
parameter cnt_s3 = 150000000;
parameter cnt_s1 =  50000000;
parameter cnt_0s5 = 25000000;

// Parametros para testbench
//parameter cnt_s3 = 15;
//parameter cnt_s1 =  5;
//parameter cnt_0s5 = 2;


// 150,000,000 ciclos de 20 ns = 3 s
always @ (posedge rst, posedge clk) begin
	if (rst) cnt3 <= 0;
	else if (c3) cnt3 <= 0;
	else if (curr_st == av_green) cnt3 <= cnt3 + 1'b1;
end

assign c3 = (cnt3 == cnt_s3) ? 1'b1 : 1'b0;

// 50,000,000 ciclos de 20 ns = 1 s
always @ (posedge rst, posedge clk) begin
	if (rst) cnt1 <= 0;
	else if (c1) cnt1 <= 0;
	else if (curr_st == av_yellow || curr_st == av_red) cnt1 <= cnt1 + 1'b1;
end

assign c1 = (cnt1 == cnt_s1) ? 1'b1 : 1'b0;

// 25,000,000 ciclos de 20 ns = 0.5 s
always @ (posedge rst, posedge clk) begin
	if (rst) cnt0_5 <= 0;
	else if (c0_5) cnt0_5 <= 0;
	else if (curr_st == st_yellow) cnt0_5 <= cnt0_5 + 1'b1;
end

assign c0_5 = (cnt0_5 == cnt_0s5) ? 1'b1 : 1'b0;

//Maquina de Estados
always @*
	case (curr_st)
	the_initial: if (sen) nxt_st = av_green;     else nxt_st = curr_st; 
	av_green: 	 if (c3) nxt_st = av_yellow;     else nxt_st = curr_st;
	av_yellow: 	 if (c1) nxt_st = av_red;        else nxt_st = curr_st;
	av_red: 		 if (c1) nxt_st = st_yellow;     else nxt_st = curr_st;
	st_yellow: 	 if (c0_5) nxt_st = the_initial; else nxt_st = curr_st;
	default: nxt_st = curr_st;
endcase

// Salidas del FSM
assign Av = (curr_st == 3'd0 || curr_st == 3'd1 ) ? 3'b100 : (curr_st == 3'd3 || curr_st == 3'd4) ? 3'b001 : (curr_st == 3'd2) ? 3'b010 : 3'b000;
assign St = (curr_st == 3'd0 || curr_st == 3'd1 || curr_st == 3'd2) ? 3'b001 : (curr_st == 3'd3) ? 3'b100 : (curr_st == 3'd4) ? 3'b010 : 3'b000;

//FF de progreso de estados
always @(posedge rst or posedge clk)
	if(rst) curr_st <= 0;
	else curr_st <= nxt_st;
	
endmodule
