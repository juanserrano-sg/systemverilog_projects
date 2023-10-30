
/******************************************************************
* Description
*
* Configurable Digital Clock
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/




module rel_t(clk, rst, set, hora, min, mode, uSec, dSec, uMin, dMin, uHr, dHr);
	input clk;
	input rst;
	input set;	// Push button
	input hora;	// Push button
	input min;	// Push button 
	input mode;	// switch = 0 (12h) / switch = 1 (24h)
	
	output [6:0] uSec;
	output [6:0] dSec;
	output [6:0] uMin;
	output [6:0] dMin;
	output [6:0] uHr;
	output [6:0] dHr;
	
	localparam WIDTH_TIC = 26;
	localparam WIDTH_SEC = 6;
	localparam WIDTH_UMIN = 4;
	localparam WIDTH_DMIN = 4;
	localparam width_Hr = 5;
	
	localparam MAX_CNT_TIC = 50_000_000;
	localparam MAX_CNT_SEC = 59;
	localparam MAX_CNT_UMIN = 9;
	localparam MAX_CNT_DMIN = 5;
	localparam MAX_CNT_HR = 23;
	
	localparam RST_VAL = 0;
	localparam RST_VAL_HR = 0;
	
	logic enable_Sec;
	logic enable_uMin;
	logic enable_hr;
	logic carry_Tic;
	logic carry_Sec;
	logic carry_uMin;
	logic carry_dMin;
	logic carry_hr;
	
	logic [3:0] d_Hr;
	logic [3:0] u_Hr;
	logic [3:0] d_s;
	logic [3:0] u_s;
	
	logic [WIDTH_TIC-1:0] cnt_Tic;
	logic [WIDTH_SEC-1:0] cnt_Sec;
	logic [WIDTH_UMIN-1:0] cnt_uMin;
	logic [WIDTH_DMIN-1:0] cnt_dMin;
	logic [width_Hr-1:0] cnt_Hr;
	
	// CONTADORES
	counter #(.WIDTH(WIDTH_TIC), .MAX_CNT(MAX_CNT_TIC), .RST_VAL(RST_VAL)) ticCnt (.clk(clk), .rst(rst), .en(1'b1), .carry_out(carry_Tic), .cnt(cnt_Tic));
	counter #(.WIDTH(WIDTH_SEC), .MAX_CNT(MAX_CNT_SEC), .RST_VAL(RST_VAL)) secCnt (.clk(clk), .rst(rst), .en(carry_Tic), .carry_out(carry_Sec), .cnt(cnt_Sec));
	counter #(.WIDTH(WIDTH_UMIN), .MAX_CNT(MAX_CNT_UMIN), .RST_VAL(RST_VAL)) uMinCnt (.clk(clk), .rst(rst), .en(enable_uMin), .carry_out(carry_uMin), .cnt(cnt_uMin));
	counter #(.WIDTH(WIDTH_DMIN), .MAX_CNT(MAX_CNT_DMIN), .RST_VAL(RST_VAL)) dMinCnt (.clk(clk), .rst(rst), .en(carry_uMin), .carry_out(carry_dMin), .cnt(cnt_dMin));
	counter #(.WIDTH(width_Hr), .MAX_CNT(MAX_CNT_HR), .RST_VAL(RST_VAL_HR)) hrCnt (.clk(clk), .rst(rst), .en(enable_hr), .carry_out(carry_hr), .cnt(cnt_Hr));
	
	// BLOQUE DE CONTROL
	control control(.clk(clk), .rst(rst), .set(set), .hora(hora), .min(min), .carry_sec(carry_Sec), .carry_dMin(carry_dMin), .enable_uMin(enable_uMin),  .enable_hr(enable_hr));

	//CONVERSION 12-24
	converter #(.width_Hr(width_Hr), .WIDTH_SEC(WIDTH_SEC)) conv(.mode(mode), .cntHr(cnt_Hr), .cntSec(cnt_Sec),  .d_Hr(d_Hr), .u_Hr(u_Hr), .d_s(d_s), .u_s(u_s));
	
	deco_bcd_7seg deco1(.in_a(u_s), .y(uSec));
	deco_bcd_7seg deco2(.in_a(d_s), .y(dSec));
	deco_bcd_7seg deco3(.in_a(cnt_uMin), .y(uMin));
	deco_bcd_7seg deco4(.in_a(cnt_dMin), .y(dMin));
	deco_bcd_7seg deco5(.in_a(u_Hr), .y(uHr));
	deco_bcd_7seg deco6(.in_a(d_Hr), .y(dHr));

endmodule



