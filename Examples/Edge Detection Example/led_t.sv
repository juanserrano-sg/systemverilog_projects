
module led_t (clk, rst, l_out, Edge);
input clk, rst, Edge;
output logic l_out;

logic edge_flag;
logic q1;

always @(negedge rst, posedge clk)
if(!rst) q1 <= 1'b0;
else q1 <= ~Edge;

assign edge_flag = ~Edge & ~q1;

always @(negedge rst, posedge clk)
if(!rst) l_out <= 1'b0;
else if (edge_flag) l_out = ~ l_out;
endmodule
