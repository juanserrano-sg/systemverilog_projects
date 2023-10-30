initial
	begin #100
		generator.write(10,2);
		generator.write(5,3);
		analyzer.read(10,2);
		analyzer.read(5,0);
		#(1000 * 1);     // This avoids the Modelsimmessage: Break in Module memory_tbat testcase.vline 9 
		$stop;
end 