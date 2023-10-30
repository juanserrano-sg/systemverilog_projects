//`timescale 1ns/1ps

// Ejercicio Secuenciales - Flip Flop Tipo D con resets sincronos y asincronos, enable sincrono 
// JASG

module ffd_ssa(rst_a, rst_s, clk, en, d, q);
input rst_a, rst_s, clk, en, d; 
output logic q; 

always @ (posedge clk, posedge rst_a)
if (rst_a) q <= 0;
else if (rst_s) q <= 0;
else if (en) q<= d;

endmodule
