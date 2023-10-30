`timescale 1ns/100ps

module analyzer(
	input clk, 
	input[1:0] data, 
	output logic[3:0] addr= 4'h0);
	integer file;   
	initial file = $fopen("test_output.dat");

	task read; 
	input[3:0] addr_value; input[1:0] data_exp;
		begin
		@(negedge clk); addr= addr_value;  
		#10  if(data!=data_exp) begin 
					$display("ERROR at time %g: Expected data (%h) does not match Read data (%h)", $time, data_exp,data);
					$fwrite(file, "ERROR at time %g: Expected data (%h) does not match Read data (%h)", $time,data_exp, data);
					end
				else $display("Read operation was successful");
		end  
	endtask  
endmodule
