module Spartan6_DSP48A1_tb ();

	//Attributes:
	parameter A0REG = 0, A1REG = 1, B0REG = 0, B1REG = 1;
	parameter CREG = 1, DREG = 1, MREG = 1, PREG = 1, CARRYINREG = 1;
	parameter CARRYOUTREG = 1, OPMODEREG = 1;
	parameter CARRYINSEL = "OPMODE5";			//OR CARRYIN
	parameter B_INPUT = "DIRECT";				//OR CASCADE
	parameter RSTTYPE = "SYNC"; 				//OR ASYNC

	//Data Ports:
	reg  [17:0] A, B, D;
	reg  [47:0] C;
	reg  CARRYIN;
	wire  [35:0] M;
	wire [47:0] P;
	wire CARRYOUT, CARRYOUTF;

	//Control Input Ports:
	reg CLK;
	reg [7:0] OPMODE;

	//Clock Enable Input Ports:
	reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, CECARRYOUT;

	//Reset Input Ports:
	reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYOUT;

	//Cascade Ports:
	reg  [17:0] BCIN;
	reg  [47:0] PCIN;
	wire [17:0] BCOUT;
	wire [47:0] PCOUT;

	Spartan6_DSP48A1 I1 (A, B, C, D, CARRYIN, M, P, CARRYOUT, CARRYOUTF, CLK, OPMODE, 
						 CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, CECARRYOUT, RSTA, RSTB, 
						 RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYOUT, BCOUT, PCIN, PCOUT, BCIN);

	initial begin
		CLK = 0;
		forever #5 CLK = ~CLK;
    end

    initial begin

    // Reset Test:
    	RSTA = 1'b1;
    	RSTB = 1'b1;
    	RSTC = 1'b1;
    	RSTCARRYIN = 1'b1;
    	RSTD = 1'b1;
    	RSTM = 1'b1;
    	RSTOPMODE = 1'b1;
    	RSTP = 1'b1;
    	RSTCARRYOUT = 1'b1;
    	repeat (4) @(negedge CLK);
    	// Check output

		// Initialize inputs
	    A = 18'h00000;
	    B = 18'h00000;
	    C = 48'h000000000000;
	    D = 18'h00000;
	    CARRYIN = 1'b0;
	    CLK = 1'b0;
	    OPMODE = 8'h00;
	    CEA = 1'b0;
	    CEB = 1'b0;
	    CEC = 1'b0;
	    CECARRYIN = 1'b0;
	    CED = 1'b0;
	    CEM = 1'b0;
	    CEOPMODE = 1'b0;
	    CEP = 1'b0;
	    CECARRYOUT = 1'b0;
	    RSTA = 1'b0;
	    RSTB = 1'b0;
	    RSTC = 1'b0;
	    RSTCARRYIN = 1'b0;
	    RSTD = 1'b0;
	    RSTM = 1'b0;
	    RSTOPMODE = 1'b0;
	    RSTP = 1'b0;
	    RSTCARRYOUT = 1'b0;
	    BCIN = 18'h00000;
	    PCIN = 48'h000000000000;

	    // Case 1: addition
	    #10;
	    A = 18'd02; 
	    B = 18'd02;
	    D = 18'd03;
	    C = 48'd01;
	    OPMODE[5]   = 0;
		OPMODE[6]   = 0;
		OPMODE[4]   = 1; //Use pre adder.
		OPMODE[1:0] = 0; //Neglect multiplier
		OPMODE[3:2] = 3;
		OPMODE [7]	= 0;
	    CEA = 1'b1;
	    CEB = 1'b1;
	    CEC = 1'b1;
	    CED = 1'b1;
	    CEM = 1'b1;
	    CEOPMODE = 1'b1;
	    CEP = 1'b1;
	    CECARRYOUT = 1'b1;
	    RSTA = 1'b0;
	    RSTB = 1'b0;
	    RSTC = 1'b0;
	    RSTCARRYIN = 1'b0;
	    RSTD = 1'b0;
	    RSTM = 1'b0;
	    RSTOPMODE = 1'b0;
	    RSTP = 1'b0;
	    RSTCARRYOUT = 1'b0;

	    repeat (4) @(negedge CLK);
	    // Check output

	    // Case 2: Subtraction and multiply
	    #10;
	    A = 18'd02; 
	    B = 18'd05;
	    D = 18'd010;
	    C = 48'd22;
	    OPMODE[5]   = 0;
		OPMODE[6]   = 1; //Minus
		OPMODE[4]   = 1; //use pre adder.
		OPMODE[1:0] = 0; //neglect multiplier out (pad zeros)
		OPMODE[3:2] = 2'b01; //Use C(2'b11), PCIN (2'b01)
		OPMODE [7]	= 0;
	    CEA = 1'b1;
	    CEB = 1'b1;
	    CEC = 1'b1;
	    CED = 1'b1;
	    CEM = 1'b1;
	    CEOPMODE = 1'b1;
	    CEP = 1'b1;
	    CECARRYOUT = 1'b1;
	    RSTA = 1'b0;
	    RSTB = 1'b0;
	    RSTC = 1'b0;
	    RSTCARRYIN = 1'b0;
	    RSTD = 1'b0;
	    RSTM = 1'b0;
	    RSTOPMODE = 1'b0;
	    RSTP = 1'b0;
	    RSTCARRYOUT = 1'b0;

	    repeat (4) @(negedge CLK);
	    // Check output

	    // Case 3: Use PCIN
	    #10;
	    PCIN = 48'h000000000005;
	    A = 18'd02; 
	    B = 18'd05;
	    D = 18'd010;
	    C = 48'd22;
	    OPMODE[5]   = 0;
		OPMODE[6]   = 0; //Add
		OPMODE[4]   = 1; //use pre adder.
		OPMODE[1:0] = 1; //neglect multiplier out (pad zeros)
		OPMODE[3:2] = 2'b01; //Use C(2'b11), PCIN (2'b01)
		OPMODE [7]	= 0;
	    CEA = 1'b1;
	    CEB = 1'b1;
	    CEC = 1'b1;
	    CED = 1'b1;
	    CEM = 1'b1;
	    CEOPMODE = 1'b1;
	    CEP = 1'b1;
	    CECARRYOUT = 1'b1;
	    RSTA = 1'b0;
	    RSTB = 1'b0;
	    RSTC = 1'b0;
	    RSTCARRYIN = 1'b0;
	    RSTD = 1'b0;
	    RSTM = 1'b0;
	    RSTOPMODE = 1'b0;
	    RSTP = 1'b0;
	    RSTCARRYOUT = 1'b0;

	    repeat (4) @(negedge CLK);
	    // Check output

	    // Case 4: Accumalte the output. (last value of P = 5)
	    #10;
	   	A = 18'd02; 
	    B = 18'd05;
	    D = 18'd010;
	    C = 48'd22;
	    OPMODE[5]   = 0;
		OPMODE[6]   = 0; //Add
		OPMODE[4]   = 1; //use pre adder.
		OPMODE[1:0] = 2; //Feedback of the output
		OPMODE[3:2] = 2'b01; //Use C(2'b11), PCIN (2'b01), PCIN = 5 too
		OPMODE [7]	= 0;
	    CEA = 1'b1;
	    CEB = 1'b1;
	    CEC = 1'b1;
	    CED = 1'b1;
	    CEM = 1'b1;
	    CEOPMODE = 1'b1;
	    CEP = 1'b1;
	    CECARRYOUT = 1'b1;
	    RSTA = 1'b0;
	    RSTB = 1'b0;
	    RSTC = 1'b0;
	    RSTCARRYIN = 1'b1;
	    RSTD = 1'b0;
	    RSTM = 1'b0;
	    RSTOPMODE = 1'b0;
	    RSTP = 1'b0;
	    RSTCARRYOUT = 1'b0;
		repeat (4) @(negedge CLK);
	    $stop;
    end
endmodule