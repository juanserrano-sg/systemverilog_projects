
/******************************************************************
* Description
*
* I2C Slave PCA9536 Module
*
* Author: Juan Antonio Serrano Gomez
* email : antonio.serrano@cinvestav.mx
* Date  :	09/06/2023
******************************************************************/


module PCA9536(
	input rst, 
	input SCL,
	inout SDA,
	inout [3:0] P);
	

	parameter [2:0] STATE_IDLE      = 3'h0,// Espera
						 STATE_DEV_ADDR  = 3'h1,// La direccion es correcta
						 STATE_READ      = 3'h2,// Operacion READ 
						 STATE_IDX_PTR   = 3'h3,// Obtener bits de registro
						 STATE_WRITE     = 3'h4;// Escribir en registro
	logic [2:0]	state; // Estado
						 
	parameter [6:0] device_address = 7'h41; // Direccion del dispositivo
	
//************* Variables del contador ***********************************
	logic [3:0] bit_counter; // Contador de los bits de palabra
	logic [7:0]	input_shift; // Logic para palabra	
	
//******** Detectores de flanco de INICIO y STOP *************************
	logic	start_detect;
	logic	start_resetter;
	logic	stop_detect;
	logic	stop_resetter;
	logic	master_ack;

// Apuntador para los registros 
	logic [7:0]	index_pointer;	
	
// Control de salida SDA	
	logic	output_control;
	
// Registros
	logic [7:0]	reg_00,reg_01,reg_02,reg_03;

// Logic para el corrimiento de la salida para lectura
	logic [7:0]	output_shift;
	
//********* Banderas asincronas **********	
	wire	lsb_bit = (bit_counter == 4'h7) && !start_detect;// Cuando se termia de leer el byte, puero aun no el ac
	wire	ack_bit = (bit_counter == 4'h8) && !start_detect;// Cuando se lee el ultimo bit de la trama 
	wire	address_detect = (input_shift[7:1] == device_address);// La direccion de entrada es la del esclavo
	wire	read_write_bit = input_shift[0]; // Bit de lectura/escritura
	wire	write_strobe = (state == STATE_WRITE) && ack_bit;	// Una vez que se leyeron todos los bits a escribir 

//*************** Conexiones para los detectores *************************
	wire	start_rst = !rst | start_resetter;// Detectar el inicio, dura un ciclo
	wire	stop_rst = !rst | stop_resetter;//detect the STOP for one cycle
	

//	Configuramos los Port Pins para ser entradas o salidas, dependiendo del reg 3 (Configuration Register).
	assign P[0] = reg_03[0] ? 1'bz : reg_01 [0];
	assign P[1] = reg_03[1] ? 1'bz : reg_01 [1];
	assign P[2] = reg_03[2] ? 1'bz : reg_01 [2];
	assign P[3] = reg_03[3] ? 1'bz : reg_01 [3];
	
// Configuramos el Registro 0 (Input Register) como P o P negada, segun este el registro 2 (Registro de Inversion)
	assign reg_00[0] = reg_02[0] ? (~P[0]) : P[0];
	assign reg_00[1] = reg_02[1] ? (~P[1]) : P[1];
	assign reg_00[2] = reg_02[2] ? (~P[2]) : P[2];
	assign reg_00[3] = reg_02[3] ? (~P[3]) : P[3];
	
	assign reg_00[7:4] = 4'hF;
	assign reg_01[7:4] = 4'hF;
	assign reg_02[7:4] = 4'h0;
	assign reg_03[7:4] = 4'hF;
	
	
// Control de salida SDA
	assign	SDA = output_control ? 1'bz : 1'b0;
	
//*********************** Maquina de Estados *****************************
	always @(negedge rst or negedge SCL) begin
			  if (!rst)	state <= STATE_IDLE;
			  else if (start_detect) state <= STATE_DEV_ADDR; // Se detecta la condicion de estado		 
			  else if (ack_bit) begin //Estamos en la pos del ack bit, (ack es una bandera)
						case (state)
							STATE_IDLE:			state <= STATE_IDLE;
							 
							STATE_DEV_ADDR:	if (!address_detect) state <= STATE_IDLE; // Direccion Incorrecta
													else if (read_write_bit)	state <= STATE_READ; // OP = LEER
													else	state <= STATE_IDX_PTR; // OP = ESCRIBIR
													
							STATE_READ:			if (master_ack) state <= STATE_READ; // Si se obtuvo el ack
													else	state <= STATE_IDLE; // No se obtiene el ack

							STATE_IDX_PTR:		state <= STATE_WRITE; // Obtener indice y escribir 

							STATE_WRITE:		state <= STATE_WRITE;// Escribir
						 endcase
			  end
			  else if(stop_detect)			state <= STATE_IDLE;//Si se manda stop, se regresa a IDLE 
	end




//********************** DETECCION DE INICIO ***************************** 
// Detecta el inicio de la comunicacion, con la transicion de SDA de 1 a 0 
	always @(posedge start_rst or negedge SDA)	begin
		if (start_rst)	start_detect <= 1'b0; // Si se presiona reset o se activa start_resetter, se detecta como no iniciado
		else	start_detect <= SCL;				 // Si detecta la transicion de SDA al inicio, y SCL esta en HIGH, se detecta el inicio
	end

	always @(negedge rst or posedge SCL) begin
		if (!rst)	start_resetter <= 1'b0; // Con rst se pone en 0 el start_resetter
		else	start_resetter <= start_detect; // Se pone start_resseter en 1 un ciclo despues de que se active el start_detect, el cual se desactiva
	end
	
//********************** DETECCION DE STOP ******************************* 
// Detecta el stop con la transicion 0 a 1 en SDA mientras SCL esta activo
	always @ (posedge stop_rst or posedge SDA) begin   
		if (stop_rst)	stop_detect <= 1'b0; // Si se presiona rst o se activa el stop_resetter, se manda a 0 el stop detect
		else	stop_detect <= SCL;				// Si se detecta la transicion de SDA y SCL esta activo, se activa el stop
	end

	always @ (negedge rst or posedge SCL)	begin   
		if (!rst)		stop_resetter <= 1'b0;	// Con rst se pone en 0 el stop_resetter
		else	stop_resetter <= stop_detect;	// Se pone el stop_resetter en 1 un ciclo despues de que se active el stop_detect, el cual se desactiva
	end

//*************************** Contador *********************************** 
//Cuenta de 0 a 8 (1 byte y 1 ac), y se resetea al INICIO o cuando termino la palabra
	always @(negedge SCL)	begin
		if (ack_bit || start_detect)	bit_counter <= 4'h0;
		else bit_counter <= bit_counter + 4'h1;
	end

//****************** Corrimiento para guardar el byte ******************** 
// Mientras SCL esta activo, y no se haya llegado al ac, se le añade un bit en el lsb del input_shift 
	always @(posedge SCL) begin
		if (!ack_bit)	input_shift <= {input_shift[6:0], SDA};
	end

//******************* Flag para el master_ack **************************** 
// Si se activa el bit interno de ac, para luego mandar el 0 a SDA 
	always @(posedge SCL) begin
		if (ack_bit)	master_ack <= ~SDA;	// un SDA invertido se manda master ac
	end


	
//************** Transferencia de registros con  indice ****************** 
	always @(negedge rst or negedge SCL)	begin
		if (!rst)	index_pointer <= 8'h00; // Si esta en reset, se manda a 0
		else if (stop_detect)	index_pointer <= 8'h00; // Si detecto un stop, se manda a 0
		else if (ack_bit) begin //Si se activa el bit de ac	
			if (state == STATE_IDX_PTR) index_pointer <= input_shift; // Si estamps en el estado de index pointer, del input shift sacar el pointer para el indice
//			else index_pointer <= index_pointer + 8'h01; // Se prepara para el siguiente l/e 						
		end
	end
	


//**************************************** Escritura ****************************************** 
	always @(negedge rst or negedge SCL)	begin
		if (!rst)	begin //En reset, todos los registros estan en 0
			reg_01[3:0] <= 8'hF;
			reg_02[3:0] <= 8'h0;
			reg_03[3:0] <= 8'hF;
		end
		else if (write_strobe && (index_pointer == 8'h01))	reg_01[3:0] <= input_shift[3:0];
		else if (write_strobe && (index_pointer == 8'h02))	reg_02[3:0] <= input_shift[3:0];
		else if (write_strobe && (index_pointer == 8'h03))	reg_03[3:0]<= input_shift[3:0];
	end


//**************************************** Lectura ****************************************** 
	always @(negedge SCL)	begin   
		if (lsb_bit) begin
			case (index_pointer)
				8'h00: output_shift <= reg_00;
				8'h01: output_shift <= reg_01;
				8'h02: output_shift <= reg_02;
				8'h03: output_shift <= reg_03;
			endcase
		end
		else	output_shift <= {output_shift[6:0], 1'b0};  //Una vez que se recorrieron los 8 bits, el registro output_shift queda en 0

	end
	
//******************** Control de salida SDA del esclavo ************************************ 
	always @(negedge rst or negedge SCL)	begin
		if (!rst)	output_control <= 1'b1; // Cuando comience, queremos que este en z
		else if (start_detect)	output_control <= 1'b1; // Cuando detecte el inicio, tambien en z 
		else if (lsb_bit)	begin
			output_control <=	!(((state == STATE_DEV_ADDR) && address_detect) ||	(state == STATE_IDX_PTR) ||	(state == STATE_WRITE)); // Se manda a 0 caundo cualquiera de los 3 casos suceda, pues se requiere un ac
		end
		else if (ack_bit)	begin
			if (((state == STATE_READ) && master_ack) ||	((state == STATE_DEV_ADDR) &&	address_detect && read_write_bit))
					output_control <= output_shift[7];
			else	output_control <= 1'b1;
		end
		else if (state == STATE_READ)	output_control <= output_shift[7];
		else	output_control <= 1'b1;
	end
endmodule
