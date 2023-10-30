`timescale 1ns/1ps

module ej_min_seg_ds(rst, clk, stp_r, f_c, cnt_ds, cnt_s1, cnt_s2, cnt_m1, cnt_m2);

input clk;
input rst;
input stp_r;
input f_c;

output logic [3:0] cnt_ds;
output logic [3:0] cnt_s1;
output logic [2:0] cnt_s2;
output logic [3:0] cnt_m1;
output logic [2:0] cnt_m2;

logic [18:0] cnt1;
logic c1, c2, c3, c4, c5, lstop_1, lfre_2;

logic ed_f1, ed_f2;
logic s1,s2;

parameter cnt_ds_p = 5000000;
parameter cnt_dsm1 = 9;
parameter cnt2_sm2 = 6;

// Detector de flanco de stop
always @(posedge rst, posedge clk)
	if (rst) s1 <= 1'b0;
	else s1 <= stp_r;

// Detector de flanco de freeze
always @(posedge rst, posedge clk)
	if (rst) s2 <= 1'b0;
	else s2 <= f_c;

//  Comb del detector de stop	
assign ed_f1 = stp_r & ~s1;


//  Comb del detector de freeze
assign ed_f2 = f_c & ~s2;


// Memoria de Stop
always @(posedge rst, posedge clk)
	if (rst) lstop_1 <= 0;
	else if (ed_f1) lstop_1 = ~ lstop_1;

// Memoria de Freeze
always @(posedge rst, posedge clk)
	if (rst) lfre_2 <= 0;
	else if (ed_f2) lfre_2 = ~ lfre_2;

	
// 5,000,000 ciclos de 20 ns = 0.1 s
always @ (posedge rst, posedge clk) begin
	if (rst) cnt1 <= 0;
	else if (lstop_1) cnt1 <= 0; 
	else if (c1) cnt1 <= 0;
	else begin 
	if (!lfre_2) cnt1 <= cnt1 + 1'b1;
	end
end

assign c1 = (cnt1 == cnt_ds_p) ? 1'b1 : 1'b0;

// 0-9 decimas de segundo
always  @(posedge rst, posedge clk) 
	if (rst) cnt_ds <= 0;
	else if (lstop_1) cnt_ds <= 0; 
	else if (c2) cnt_ds <= 0;
	else if (c1) cnt_ds <= cnt_ds + 1'b1;

assign c2 = (cnt_ds == cnt_dsm1 && c1) ? 1'b1 : 1'b0;

// 0-9 unidades de segundo
always  @(posedge rst, posedge clk) 
	if (rst) cnt_s1 <= 0;
	else if (lstop_1) cnt_s1 <= 0; 
	else if (c3) cnt_s1 <= 0;
	else if (c2) cnt_s1 <= cnt_s1 + 1'b1;

assign c3 = (cnt_s1 == cnt_dsm1 && c2) ? 1'b1 : 1'b0;

// 0-6 decenas de segundo
always  @(posedge rst, posedge clk) 
	if (rst) cnt_s2 <= 0;
	else if (lstop_1) cnt_s2 <= 0; 
	else if (c4) cnt_s2 <= 0;
	else if (c3) cnt_s2 <= cnt_s2 + 1'b1;

assign c4 = (cnt_s2 == cnt2_sm2 && c3) ? 1'b1 : 1'b0;

// 0-9 unidades de minuto
always  @(posedge rst, posedge clk) 
	if (rst) cnt_m1 <= 0;
	else if (lstop_1) cnt_m1 <= 0; 
	else if (c5) cnt_m1 <= 0;
	else if (c4) cnt_m1 <= cnt_m1 + 1'b1;

assign c5 = (cnt_m1 == cnt_dsm1 && c4) ? 1'b1 : 1'b0;


// 0-6 decenas de minuto
always  @(posedge rst, posedge clk) 
	if (rst) cnt_m2 <= 0;
	else if (lstop_1) cnt_m2 <= 0; 
	else if (c6) cnt_m2 <= 0;
	else if (c5) cnt_m2 <= cnt_m1 + 1'b1;

assign c6 = (cnt_m2 == cnt2_sm2 && c5) ? 1'b1 : 1'b0;




	
endmodule
