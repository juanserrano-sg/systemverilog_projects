
/******************************************************************
* Description
*
* Top Level
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/

module conv_8x32 (
	input clk, rst, start_i,
	input [4:0] sizeX, sizeY,
	input [7:0] dataX, dataY, 
	output logic writeZ, busy, done,
	output logic [4:0] memX_addr, memY_addr,
	output logic [5:0] memZ_addr,
	output logic [15:0] dataZ

);


//********************************
// WIRES
//********************************

wire nd_flag;
wire memS_cond;
wire memZ_cond;
	
wire memS_en;
wire memZ_en;

wire k_load_wire;
wire n_load_wire;
wire k_clr_wire;
wire n_clr_wire;

wire d_get_wire;
wire ini_state_wire;

wire regz_load_wire;
wire z_load_wire;
wire regz_clr_wire;
wire z_clr_wire;

wire comp_eq_y_o;
wire comp_eq_x_o;	

wire [4:0] s_x;
wire [4:0] s_y;

wire [4:0] inc_k_o;
wire [4:0] inc_n_o;

wire [4:0] k_reg_o;
wire [4:0] n_reg_o;
wire [5:0] sizeZ_P1;
wire [4:0] sizeZ_o;

wire [4:0] sub_nk_o;
wire [4:0] sub_sym1_o;

wire [15:0] data_mult_o;
wire [15:0] regz_add_out;
wire [15:0] d_z;


//********************************
// FSM INSTANCE
//********************************

conv_8x32_fsm FSM (
	.clk(clk),
	.rst(rst),
	.init_i(start_i),
	.done_i(nd_flag),
	.memS_cond(memS_cond),
	.memZ_cond(memZ_cond),
	
	.memS_en_o(memS_en),
	.memZ_en_o(memZ_en),
	
	.k_load_o(k_load_wire),
	.n_load_o(n_load_wire),
	.k_clr_o(k_clr_wire),
	.n_clr_o(n_clr_wire),
	
	.d_get_o(d_get_wire),
	.d_state_o(done),
	.ini_state_o(ini_state_wire),
	
	.regz_load_o(regz_load_wire),
	.z_load_o(z_load_wire),
	.regz_clr_o(regz_clr_wire),
	.z_clr_o(z_clr_wire), 
	.wr_z_o(writeZ), 
	.busy_state_o(busy)
	
);


//********************************
// REGISTERS
//********************************
// DATA REGISTERS
conv_8x32_reg  #(
	.DATA_WIDTH(16)
	
) reg_z (
	.clk(clk),
	.rstn(rst),
	.clrh(regz_clr_wire),
	.enh(regz_load_wire),
	.d_in(regz_add_out), 
	.d_out(d_z)
);

conv_8x32_reg  #(
	.DATA_WIDTH(16)
	
) reg_buffer_z (
	.clk(clk),
	.rstn(rst),
	.clrh(z_clr_wire),
	.enh(z_load_wire),
	.d_in(d_z), 
	.d_out(dataZ)
);


// Size Registers
conv_8x32_reg  #(
	.DATA_WIDTH(5)
	
) reg_sizex (
	.clk(clk),
	.rstn(rst),
	.clrh(1'b0),
	.enh(1'b1),
	.d_in(sizeX), 
	.d_out(s_x)
);

conv_8x32_reg  #(
	.DATA_WIDTH(5)
	
) reg_sizey (
	.clk(clk),
	.rstn(rst),
	.clrh(1'b0),
	.enh(1'b1),
	.d_in(sizeY), 
	.d_out(s_y)
);

// N & K Registers
conv_8x32_reg  #(
	.DATA_WIDTH(5)
	
) reg_k (
	.clk(clk),
	.rstn(rst),
	.clrh(k_clr_wire),
	.enh(k_load_wire),
	.d_in(inc_k_o), 
	.d_out(k_reg_o)
);

conv_8x32_reg  #(
	.DATA_WIDTH(5)
	
) reg_n (
	.clk(clk),
	.rstn(rst),
	.clrh(n_clr_wire),
	.enh(n_load_wire),
	.d_in(inc_n_o), 
	.d_out(n_reg_o)
);

// MEM_ADRR_x_y_z
conv_8x32_reg  #(
	.DATA_WIDTH(5)
	
) reg_mem_x (
	.clk(clk),
	.rstn(rst),
	.clrh(k_clr_wire),
	.enh(memS_en),
	.d_in(k_reg_o), 
	.d_out(memX_addr)
);

conv_8x32_reg  #(
	.DATA_WIDTH(5)
	
) reg_mem_y (
	.clk(clk),
	.rstn(rst),
	.clrh(ini_state_wire),
	.enh(memS_en),
	.d_in(sub_nk_o), 
	.d_out(memY_addr)
);

conv_8x32_reg  #(
	.DATA_WIDTH(5)
	
) reg_mem_z (
	.clk(clk),
	.rstn(rst),
	.clrh(ini_state_wire),
	.enh(memZ_en),
	.d_in(n_reg_o), 
	.d_out(memZ_addr)
);


//********************************
// OPERATIONS
//********************************

//MULTIPLICATION BLOCK
conv_8x32_mult #(
	.DATA_WIDTH(8)
	
) data_mult(
	.a_in(dataX), 
	.b_in(dataY), 
	.d_out(data_mult_o)
);


//ADDER BLOCKS
conv_8x32_adder #(
	.DATA_WIDTH(16)
	
) adder_regz (
	.a_in(data_mult_o), 
	.b_in(d_z), 
	.d_out(regz_add_out)
);


conv_8x32_adder #(
	.DATA_WIDTH(5)
	
) adder_inc_k (
	.a_in(5'b00001), 
	.b_in(k_reg_o), 
	.d_out(inc_k_o)
);


conv_8x32_adder #(
	.DATA_WIDTH(5)
	
) adder_inc_n (
	.a_in(5'b00001), 
	.b_in(n_reg_o), 
	.d_out(inc_n_o)
);


conv_8x32_adder #(
	.DATA_WIDTH(5)
	
) adder_x_m_y_S (
	.a_in(sizeX), 
	.b_in(sizeY), 
	.d_out(sizeZ_P1)
);


//SUBT BLOCKS
conv_8x32_subt #(
	.DATA_WIDTH(5)
	
) sub_nk(
	.a_in(n_reg_o), 
	.b_in(k_reg_o), 
	.d_out(sub_nk_o)
);

conv_8x32_subt #(
	.DATA_WIDTH(5)
	
) sub_sym1(
	.a_in(sizeY), 
	.b_in(5'b00001), 
	.d_out(sub_sym1_o)
);

conv_8x32_subt #(
	.DATA_WIDTH(5)
	
) sub_zsize_m1(
	.a_in(sizeZ_P1), 
	.b_in(5'b00001), 
	.d_out(sizeZ_o)
);


//COMPARATORS
 conv_8x32_comp_less_or_eq #(
	.DATA_WIDTH(5)
) comp_l_eq_y(
	.a_in(sub_nk_o), 
	.b_in(sub_sym1_o), 
	.d_out(comp_eq_y_o)
);

conv_8x32_comp_less #(
	.DATA_WIDTH(5)
) comp_less_x(
	.a_in(k_reg_o), 
	.b_in(sizeX), 
	.d_out(comp_eq_x_o)
);

conv_8x32_AND #(
	.DATA_WIDTH(1)
) and_cond(
	.a_in(comp_eq_y_o), 
	.b_in(comp_eq_x_o), 
	.d_out(memS_cond)
);

conv_8x32_comp_less_or_eq #(
	.DATA_WIDTH(5)
	
) comp_nk(
	.a_in(k_reg_o), 
	.b_in(n_reg_o), 
	.d_out(memZ_cond)
);

conv_8x32_comp_less #(
	.DATA_WIDTH(5)
	
) comp_regz_n(
	.a_in(n_reg_o), 
	.b_in(sizeZ_o), 
	.d_out(nd_flag)
);




endmodule
