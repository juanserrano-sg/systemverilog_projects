
/******************************************************************
* Description
*
* I2C Slave PCA9536 Module Testbench
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/


module TB_I2C;


	localparam [7:0] SLV_ADDR_RD = 8'h83;
	localparam [7:0] SLV_ADDR_WR = 8'h82;
	localparam NACK = 1'b1;
	localparam ACK = 1'b0;
	
	localparam IN_REG = 8'h00;
	localparam OUT_REG = 8'h01;
	localparam POL_REG = 8'h02;
	localparam CONF_REG3 = 8'h03;
	localparam CONF_REG2 = 8'h02;
	localparam CONF_REG1 = 8'h01;
	localparam CONF_REG0 = 8'h00;
	
	logic clk = 0;
	logic rst = 1'b0;
	wire SDA;
	logic  SCL;
	logic [3:0] p1;
	wire [3:0] Port = p1;
	pullup(SDA);
	

	I2C_GEN I2C_GEN(.clk(clk), .SDA(SDA), .SCL(SCL));
	
	PCA9536 DUT( .rst(rst), .SDA(SDA), .SCL(SCL), .P(Port));
	
	always clk = #5 ~clk;
	
	initial begin
		#10;
		rst = 1'b1;
		#10;
		rst = 1'b0;
		#10;
		rst = 1'b1;
		
		p1= 4'b0010;
		
		//Leemos el R0, ya que lo tenemos indexado de cajon
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_RD);   	// Slave Address (R/~W=1)
		I2C_GEN.rxData(8'hF2);   		// RX Data & ACK 
		I2C_GEN.stop;
		
		//Invertimos los bits del R0 poniendo en 1 los bits del R2
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_WR);   	// Slave Address (R/~W=0)
		I2C_GEN.txData(CONF_REG2);		// Command
		I2C_GEN.txData(8'hFF);          // TX Data
		I2C_GEN.stop;					// Stop pulse	
		
		//Nos posicionamos en el R0
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_WR);   	// Slave Address (R/~W=0)
		I2C_GEN.txData(CONF_REG0);		// Command
		I2C_GEN.stop;	
		
		//Leemos el registro 0 para ver los bits invertidos
		I2C_GEN.start;			
		I2C_GEN.txData(SLV_ADDR_RD);   	// Slave Address (R/~W=1)
		I2C_GEN.rxData(8'hFD);   		// RX Data & ACK 
		I2C_GEN.stop;					// Stop pulse
		
		//Invertimos los bits del R0 poniendo en 1 los bits del R2
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_WR);   	// Slave Address (R/~W=0)
		I2C_GEN.txData(CONF_REG2);		// Command
		I2C_GEN.txData(8'hF0);          // TX Data
		I2C_GEN.stop;					// Stop pulse	
		
		//Configuramos los bits del puerto como para poder mandar una salida
		p1= 4'b0zzz;	
		
		//Cambiamos los ultimos tres bits a salidas
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_WR);   	// Slave Address (R/~W=0)
		I2C_GEN.txData(CONF_REG3);		// Command
		I2C_GEN.txData(8'hF8);          // TX Data
		I2C_GEN.stop;	
		
		
		//Direccionamos el indice al R0
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_WR);   	// Slave Address (R/~W=0)
		I2C_GEN.txData(CONF_REG0);		// Command
		I2C_GEN.stop;	
		
		//Leemos el R0
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_RD);   	// Slave Address (R/~W=1)
		I2C_GEN.rxData(8'hF7);   		// RX Data & ACK 
		I2C_GEN.stop;					// Stop pulse
		
		//Cambiamos los bits del R de salidas a 0, haciendo que los ultimos 3 bits tambien vayan a 0
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_WR);   	// Slave Address (R/~W=0)
		I2C_GEN.txData(CONF_REG1);		// Command
		I2C_GEN.txData(8'hF0);          // TX Data
		I2C_GEN.stop;	
		
		//Direccionamos el indice al R0
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_WR);   	// Slave Address (R/~W=0)
		I2C_GEN.txData(CONF_REG0);		// Command
		I2C_GEN.stop;
		
		//Leemos el R0
		I2C_GEN.start;					// Start pulse
		I2C_GEN.txData(SLV_ADDR_RD);   	// Slave Address (R/~W=1)
		I2C_GEN.rxData(8'hF0);   		// RX Data & ACK 
		I2C_GEN.stop;					// Stop pulse
		
		
	end
	
	
endmodule