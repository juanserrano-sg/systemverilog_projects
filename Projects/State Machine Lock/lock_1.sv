
/******************************************************************
* Description
*
* Lock
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module lock_1(
	input clk,
	input rst,
	input [3:0] k,
	input sw0_in,
	
	output [9:0] indicator,
	output [6:0] out_seg0,
	output [6:0] out_seg1,
	output [6:0] out_seg2,
	output [6:0] out_seg3);

	logic [1:0] pass [0:9];
	logic [3:0] digit;

	logic [3:0] cnt;
	logic [25:0] cnt1s;
	logic [2:0] cnt3s;

	logic ChkFlg;	
	logic enable1s;
	logic enable3s;
	logic rstsyn3s;
	
	logic [3:0] edgek;
	logic [3:0] edgek_flag;
	
	logic [6:0] seg_out [3:0];
	
	logic sw0;
	

	typedef enum {Start, Display, Ok, Wait, Open, Chg, Error, Chk, Last} states;
		
	states currState;
	states nextState;

	localparam Maxcnt = 49_999_999;

											// _
	localparam _0 = 7'b1000000;	//| |
											//|_|
	localparam _1 = 7'b1111001;	//   |
											// _ |
	localparam _2 = 7'b0100100;	// _|
											//|_  _
	localparam _3 = 7'b0110000;	//    _|
											//    _|
	localparam _4 = 7'b0011001;	//|_|
											//  | _
	localparam _5 = 7'b0010010;	//   |_
											//    _|
	localparam _6 = 7'b0000010;	//|_
											//|_| _
	localparam _7 = 7'b1111000;	//    _|
											// _   |
	localparam _8 = 7'b0000000;	//|_|
											//|_| _
	localparam _9 = 7'b0011000;	//   |_|
											//     |
											
											 // _											
	localparam _C = 7'b1000110; 	 //|
											 //|_	 _
	localparam _O = 7'b1000000; 	 //   | |
											 //   |_|
	localparam _L = 7'b1000111; 	 //|
											 //|_
	localparam _n = 7'b0101011; 	 //	 _
											 // _ | |
	localparam _E = 7'b0000110; 	 //|_
											 //|_  _
	localparam _P = 7'b0001100; 	 //   |_|
											 //	|
	localparam _H = 7'b0001011;    //|_
											 //| | _
	localparam _g = 7'b0010000;    //	|_|
											 //	 _|
	localparam _d = 7'b0100001;    // _|
											 //|_|
	localparam _guion = 7'b0111111;//	 _	
											 //	 
	localparam OFF = 7'd127;		//
	
//******** Memoria de Display a salida ********
	assign out_seg0 = seg_out[0];
	assign out_seg1 = seg_out[1];
	assign out_seg2 = seg_out[2];
	assign out_seg3 = seg_out[3];

//******** Antirebote para el SW0 ********
	debouncer(.pb_1(sw0_in), .clk(clk), .pb_out(sw0));
	
//******** Letras y Numeros para Displays ********
	always_comb begin
		if ((currState == Start) || (currState == Error) || (currState == Ok) || (currState == Wait)) begin
			seg_out[3] = _L;
			seg_out[2] = _O;
			seg_out[1] = _C;
			seg_out[0] = OFF;
		end
		else if (currState == Open) begin
			seg_out[3] = _O;
			seg_out[2] = _P;
			seg_out[1] = _E;
			seg_out[0] = _n;
		end
		else if ((currState == Chg) || (currState == Chk)) begin
			seg_out[3] = _C;
			seg_out[2] = _H;
			seg_out[1] = _g;
			case (cnt)
				0:	seg_out[0] = _0;
				1:	seg_out[0] = _1;
				2:	seg_out[0] = _2;
				3:	seg_out[0] = _3;
				4:	seg_out[0] = _4;
				5:	seg_out[0] = _5;
				6:	seg_out[0] = _6;
				7:	seg_out[0] = _7;
				8:	seg_out[0] = _8;
				9:	seg_out[0] = _9;
				default: seg_out[0] = _guion;
			endcase
		end
		else if (currState == Display) begin
			seg_out[3] = _d;
			seg_out[2] = _O;
			seg_out[1] = _n;
			seg_out[0] = _E;
		end
		else begin
			seg_out[3] = _guion;
			seg_out[2] = _guion;
			seg_out[1] = _guion;
			seg_out[0] = _guion;
		end
	end
	
//******** Maq. De Estados ********
	always_comb begin
		nextState = currState;
		case (currState)
			Start:	if (sw0) nextState = Error;
						else if (|edgek_flag) begin
									if ((edgek_flag == 4'b0001 && pass[cnt] == 0) || (edgek_flag == 4'b0010 && pass[cnt] == 1) ||
										 (edgek_flag == 4'b0100 && pass[cnt] == 2) || (edgek_flag == 4'b1000 && pass[cnt] == 3))	
										  nextState = Ok;
									else nextState = Error;
						end

			Ok:		if (cnt < digit) nextState = Start;
						else nextState = Wait;

			Wait:		if (|edgek_flag) nextState = Error;
						else if (sw0) nextState = Open;
						
			Error: 	if (!sw0) nextState = Start;

			Open: 	if (!sw0) nextState = Start;
						else if (edgek_flag[0]) nextState = Chg;

			Chg:		if (!sw0 && ChkFlg) nextState = Display;
						else if (!sw0) nextState = Start;
						else if (|edgek_flag) nextState = Chk;
						
			Chk:		if (cnt == 9)	nextState = Display;
						else nextState = Chg;

			Display:	if(cnt3s == 3) nextState = Last;
			
			Last: if(sw0) nextState = Open;
						else nextState = Start;
			
		endcase
	end

	//******** Config. de Contrasena ********
	always@(posedge rst, posedge clk) begin
		if (rst) begin
			pass[0] <= 0;
			pass[1] <= 1;
			pass[2] <= 2;
			pass[3] <= 3;
		end
		else if (currState == Chk) begin
			if (!k[0]) 		pass[cnt] <= 0;
			else if (!k[1]) pass[cnt] <= 1;
			else if (!k[2]) pass[cnt] <= 2;
			else if (!k[3]) pass[cnt] <= 3;
		end
	end
	
	//******** Digit ********
	always@ (posedge rst, posedge clk) begin
		if (rst) currState <= Start;
		else currState <= nextState;
	end
	
		//******** Digit ********
	always@ (posedge rst, posedge clk) begin
		if (rst) digit <= 3;
		else if (currState == Chk) digit <= cnt;
	end
	
	//******** Enable  ********
	always @ (posedge rst, posedge clk) begin
		if (rst) cnt <= 0;
		else begin
			if (rst_sy) cnt <= 0;
			else if (enable) cnt <= cnt + 1'b1;
			else cnt <= cnt;
		end
	end

	//******** Enable y Reset Sincrono ********	
	assign rst_sy = (currState == Open || currState == Error || currState == Last) ? 1'b1:1'b0;
	assign enable = (currState == Ok || currState == Chk) ? 1'b1:1'b0;
	
	//******** 1 Segundo ********	
	always @ (posedge rst, posedge clk)	begin
		if (rst) cnt1s <= 0;
		else begin
			if (Maxcnt == cnt1s)	cnt1s <= 0;
			else if (enable1s)	cnt1s <= cnt1s + 1'b1;
			else	cnt1s <= 0;
		end
	end
	
	assign enable1s = currState == Display;

	//******** Bandera de Check ********
	always @ (posedge rst, posedge clk) begin
		if (rst) ChkFlg <= 0;
		else if (currState == Chk) ChkFlg <= 1;
		else if (currState == Start) ChkFlg <= 0;
	end
	
	always @ (posedge rst, posedge clk) begin
		if(rst) indicator = 9'd0;
		else if(|(~k)) indicator[cnt-1] = 1'b1;
		else if(rst_sy) indicator = 9'd0;
	end

	//******** 3 Segundos ********
	always @ (posedge rst, posedge clk) begin
		if (rst) cnt3s <= 0;
		else begin
			if (enable3s) cnt3s <= cnt3s + 1'b1;
			else if (rstsyn3s) cnt3s <= 0;
			else cnt3s <= cnt3s;
		end
	end

	assign enable3s = (Maxcnt == cnt1s);
	assign rstsyn3s = currState == Start;
	
	//******** Detector de flanco de K ********
	always @ (posedge rst, posedge clk)	begin
		if (rst) edgek <= 4'b1111;
		else edgek <= ~k;
	end
	
	assign edgek_flag = ~k & ~edgek;
	
endmodule
