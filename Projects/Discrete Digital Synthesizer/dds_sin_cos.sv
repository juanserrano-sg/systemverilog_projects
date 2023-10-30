
/******************************************************************
* Description
*
* DDS 
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/



module dds_sin_cos (
	input clk, 
	input rst,
	input en,
	input load,
	
	input logic signed [2:-5] amp_sin,
	input logic signed [2:-5] amp_cos,
	
	input logic [7:0] phase_sin,
	input logic [7:0] phase_cos,
	
	input logic [5:0] freq_sen, 
	input logic [5:0] freq_cos, 
	
	output logic signed [2:-13] cosine_out,
	output logic signed [2:-13] sine_out
		
	);
	

//********************************
// REGISTERS
//********************************

wire signed [0:-7] sin_mem_out;
wire signed [0:-7] cos_mem_out;

wire signed [2:-13] reg_cos_out;
wire signed [2:-13] reg_sin_out;


wire [7:0] acc_sin_reg_out;
wire [7:0] acc_cos_reg_out;


wire [7:0] reg_sin_freq_out;
wire [7:0] reg_cos_freq_out;

wire [7:0] ph_sin_out;
wire [7:0] ph_sum_cos_out;
wire [7:0] ph_cos_out;



wire freq_clr_wire;
wire freq_load_wire;	
wire out_load_wire;
wire out_clr_wire;


//********************************
// FSM
//********************************	
	
dds_sin_cos_fsm fsm_module(
	.clk(clk),
	.rst(rst),
	.en_i(en),
	.load_i(load),
	.freq_clr(freq_clr_wire),
	.freq_load(freq_load_wire), 
	.out_load(out_load_wire),
	.out_clr(out_clr_wire)
	
		
);	
	
//********************************
// REGISTERS
//********************************

dds_reg  #(
	.DATA_WIDTH(8)
	
) reg_freq_sin (
	.clk(clk),
	.rstn(rst),
	.clrh(freq_clr_wire),
	.enh(freq_load_wire),
	.d_in(acc_sin_reg_out), 
	.d_out(reg_sin_freq_out)
);

dds_reg  #(
	.DATA_WIDTH(8)
	
) reg_freq_cos (
	.clk(clk),
	.rstn(rst),
	.clrh(freq_clr_wire),
	.enh(freq_load_wire),
	.d_in(acc_cos_reg_out), 
	.d_out(reg_cos_freq_out)
);

dds_reg  #(
	.DATA_WIDTH(16)
	
) reg_out_sin (
	.clk(clk),
	.rstn(rst),
	.clrh(out_clr_wire),
	.enh(out_load_wire),
	.d_in(reg_sin_out), 
	.d_out(sine_out)
);

dds_reg  #(
	.DATA_WIDTH(16)
	
) reg_out_cos (
	.clk(clk),
	.rstn(rst),
	.clrh(out_clr_wire),
	.enh(out_load_wire),
	.d_in(reg_cos_out), 
	.d_out(cosine_out)
);


//********************************
// ADDER
//********************************

adder #(
	.DATA_WIDTH(8)
	
) acc_sin_freq (
	.a_in({2'b00, freq_sen}), 
	.b_in(reg_sin_freq_out), 
	.d_out(acc_sin_reg_out)
);


adder #(
	.DATA_WIDTH(8)
	
) phase_sin_addr (
	.a_in(reg_sin_freq_out), 
	.b_in(phase_sin), 
	.d_out(ph_sin_out)
);


adder #(
	.DATA_WIDTH(8)
	
) acc_cos_freq (
	.a_in({2'b00,freq_cos}), 
	.b_in(reg_cos_freq_out), 
	.d_out(acc_cos_reg_out)
);

adder #(
	.DATA_WIDTH(8)
	
) phase_cos_addr (
	.a_in(reg_cos_freq_out), 
	.b_in(phase_cos), 
	.d_out(ph_sum_cos_out)
);

adder #(
	.DATA_WIDTH(8)
	
) phase_cos_sum_addr (
	.a_in(ph_sum_cos_out), 
	.b_in(8'd63), 
	.d_out(ph_cos_out)
);

//********************************
// MULTIPLIER
//********************************

fp_multiplier #(
	.WORD_LENGTH(8),
	.A_QI(3),
	.B_QI(1),
	.O_QI(3)
) mult_sin(
	.a_in(amp_sin), 
	.b_in(sin_mem_out), 
	.d_out(reg_sin_out)
	
);

fp_multiplier #(
	.WORD_LENGTH(8),
	.A_QI(3),
	.B_QI(1),
	.O_QI(3)
) mult_cos(
	.a_in(amp_cos), 
	.b_in(cos_mem_out), 
	.d_out(reg_cos_out)
	
);

//********************************
// MEMORIES
//********************************

simple_dual_port_ram_single_clk_sv #(
		.DATA_WIDTH(8),
		.ADDR_WIDTH (8),
		.TXT_FILE("C:/juanquart/conv_proy/mem_X.txt")
) LUT (
		.clk         (clk),		
		.write_en_i  (1'd0),
		.write_addr_i(8'd0),				
		.write_data_i(8'd0),
		
		.read_addr_i1(ph_sin_out),
		.read_addr_i2(ph_cos_out),
		
		.read_data_o1 (sin_mem_out),		
		.read_data_o2 (cos_mem_out)
	   
);


endmodule
