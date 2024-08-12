module Spartan6_DSP48A1 (A, B, C, D, CARRYIN, M, P, CARRYOUT, CARRYOUTF, CLK, OPMODE, 
						 CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, CECARRYOUT, RSTA, RSTB, 
						 RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYOUT, BCOUT, PCIN, PCOUT, BCIN);
	//Attributes:
	parameter A0REG = 0, A1REG = 1, B0REG = 0, B1REG = 1;
	parameter CREG = 1, DREG = 1, MREG = 1, PREG = 1, CARRYINREG = 1;
	parameter CARRYOUTREG = 1, OPMODEREG = 1;
	parameter CARRYINSEL = "OPMODE5";			//OR CARRYIN
	parameter B_INPUT = "DIRECT";				//OR CASCADE
	parameter RSTTYPE = "SYNC"; 				//OR ASYNC

	//Data Ports:
	input  [17:0] A, B, D;
	input  [47:0] C;
	input  CARRYIN;
	output  [35:0] M;
	output [47:0] P;
	output CARRYOUT, CARRYOUTF;

	//Control Input Ports:
	input CLK;
	input [7:0] OPMODE;

	//Clock Enable Input Ports:
	input CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, CECARRYOUT;

	//Reset Input Ports:
	input RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYOUT;

	//Cascade Ports:
	input  [17:0] BCIN;
	input  [47:0] PCIN;
	output [17:0] BCOUT;
	output [47:0] PCOUT;

	//Internal Wires:
	wire [17:0] B_FirstStage_in;
	wire [17:0] A_FirstStage_out, B_FirstStage_out, D_FirstStage_out;
	wire [47:0] C_FirstStage_out;
	wire [17:0] PreAdder_out, B_SecondStage_in;
	wire [17:0] A_SecondStage_out, B_SecondStage_out;
	wire [35:0] M_ThirdStage_in, M_ThirdStage_out;
	wire [7:0]	OPMODE_out;
	wire CARRYIN_in, CARRYIN_out; 
	wire [47:0] Mux_X_out, Mux_Z_out, P_FourthStage_in, P_FourthStage_out;
	wire [47:0] PostAdder_out;
	wire CARRYOUT_in;

	//Instantation of the first stage in design:
	generate
    	if (A0REG == 1) begin
    	    RegMux_pair  #(.WIDTH(18), .RSTTYPE(RSTTYPE)) A_FirstStage (.Output(A_FirstStage_out), .Input(A), .clk(CLK), .PLEnable(1'b1), .Reset(RSTA), .Enable(CEA));
    	end else begin
    	    assign A_FirstStage_out = A;
    	end
	endgenerate
	generate
    	if (B0REG == 1) begin
    	    RegMux_pair  #(.WIDTH(18), .RSTTYPE(RSTTYPE)) B_FirstStage (.Output(B_FirstStage_out), .Input(B_FirstStage_in), .clk(CLK), .PLEnable(1'b1), .Reset(RSTB), .Enable(CEB));
    	end else begin
    	    assign B_FirstStage_out = B_FirstStage_in;
    	end
	endgenerate
	generate
	    if (DREG == 1) begin
	        RegMux_pair  #(.WIDTH(18), .RSTTYPE(RSTTYPE)) D_FirstStage (.Output(D_FirstStage_out), .Input(D), .clk(CLK), .PLEnable(1'b1), .Reset(RSTD), .Enable(CED));
	    end else begin
	        assign D_FirstStage_out = D;
	    end
	endgenerate
	generate
	    if (CREG == 1) begin
	        RegMux_pair  #(.WIDTH(48), .RSTTYPE(RSTTYPE)) C_FirstStage (.Output(C_FirstStage_out), .Input(C), .clk(CLK), .PLEnable(1'b1), .Reset(RSTC), .Enable(CEC));
	    end else begin
	        assign C_FirstStage_out = C;
	    end
	endgenerate
	generate
	    if (OPMODEREG == 1) begin
	        RegMux_pair  #(.WIDTH(8), .RSTTYPE(RSTTYPE)) OPMODE_Stage (.Output(OPMODE_out), .Input(OPMODE), .clk(CLK), .PLEnable(1'b1), .Reset(RSTOPMODE), .Enable(CEOPMODE));
	    end else begin
	        assign OPMODE_out = OPMODE;
	    end
	endgenerate

	//Instantation of the second stage in design:
	generate
    	if (B1REG == 1) begin
    	    RegMux_pair  #(.WIDTH(18), .RSTTYPE(RSTTYPE)) B_SecondStage (.Output(B_SecondStage_out), .Input(B_SecondStage_in), .clk(CLK), .PLEnable(1'b1), .Reset(RSTB), .Enable(CEB));
    	end else begin
    	    assign B_SecondStage_out = B_SecondStage_in;
    	end
	endgenerate
	generate
	    if (A1REG == 1) begin
	        RegMux_pair  #(.WIDTH(18), .RSTTYPE(RSTTYPE)) A_SecondStage (.Output(A_SecondStage_out), .Input(A_FirstStage_out), .clk(CLK), .PLEnable(1'b1), .Reset(RSTA), .Enable(CEA));
	    end else begin
	        assign A_SecondStage_out = A_FirstStage_out;
	    end
	endgenerate
	//Instantation of the third stage in design:
	generate
    	if (MREG == 1) begin
    	    RegMux_pair  #(.WIDTH(36), .RSTTYPE(RSTTYPE)) M_ThirdStage (.Output(M_ThirdStage_out), .Input(M_ThirdStage_in), .clk(CLK), .PLEnable(1'b1), .Reset(RSTM), .Enable(CEM));
    	end else begin
    	    assign M_ThirdStage_out = M_ThirdStage_in;
    	end
	endgenerate
	generate
	    if (CARRYINREG == 1) begin
	        RegMux_pair  #(.WIDTH(1), .RSTTYPE(RSTTYPE)) CARRYIN_Stage (.Output(CARRYIN_out), .Input(CARRYIN_in), .clk(CLK), .PLEnable(1'b1), .Reset(RSTCARRYIN), .Enable(CECARRYIN));
	    end else begin
	        assign CARRYIN_out = CARRYIN_in;
	    end
	endgenerate

	//Instantation of the Fourth stage in design:
	generate
    	if (PREG == 1) begin
    	    RegMux_pair  #(.WIDTH(48), .RSTTYPE(RSTTYPE)) P_FourthStage (.Output(P_FourthStage_out), .Input(PostAdder_out), .clk(CLK), .PLEnable(1'b1), .Reset(RSTP), .Enable(CEP));
    	end else begin
    	    assign P_FourthStage_out = PostAdder_out;
    	end
	endgenerate
	generate
	    if (CARRYOUTREG == 1) begin
	        RegMux_pair  #(.WIDTH(1), .RSTTYPE(RSTTYPE)) CARRYOUT_Stage (.Output(CARRYOUT), .Input(CARRYOUT_in), .clk(CLK), .PLEnable(1'b1), .Reset(RSTCARRYOUT), .Enable(CECARRYOUT));
	    end else begin
	        assign CARRYOUT = CARRYOUT_in;
	    end
	endgenerate

	//Generation of B_FirstStage_in and CARRYIN_in:
	generate
        if (B_INPUT == "DIRECT") begin
            assign B_FirstStage_in = B;
        end else if (B_INPUT == "CASCADE") begin
            assign B_FirstStage_in = BCIN;
        end else begin
        	assign B_FirstStage_in = 0;
        end
    endgenerate

    generate
        if (CARRYINSEL == "OPMODE5") begin
            assign CARRYIN_in = OPMODE_out[5];
        end else if (CARRYINSEL == "CARRYIN") begin
            assign CARRYIN_in = CARRYIN;
        end else begin
        	assign CARRYIN_in = 0;
        end
    endgenerate

	assign PreAdder_out 	= (OPMODE_out[6] == 0)? (D_FirstStage_out + B_FirstStage_out): (D_FirstStage_out - B_FirstStage_out);
	assign B_SecondStage_in = (OPMODE_out[4] == 0)? B_FirstStage_out: PreAdder_out;
	assign BCOUT = B_SecondStage_out;
	assign M_ThirdStage_in = B_SecondStage_out * A_SecondStage_out;
	assign M = M_ThirdStage_out;
	assign Mux_X_out = (OPMODE_out[1:0] == 2'b00)? 0:
					   (OPMODE_out[1:0] == 2'b01)? {12'b0, M_ThirdStage_out}:
					   (OPMODE_out[1:0] == 2'b10)? P_FourthStage_out: {D_FirstStage_out[11:0], A_SecondStage_out[17:0], B_SecondStage_out[17:0]};
	assign Mux_Z_out = (OPMODE_out[3:2] == 2'b00)? 0:
					   (OPMODE_out[3:2] == 2'b01)? PCIN:
					   (OPMODE_out[3:2] == 2'b10)? P_FourthStage_out: C_FirstStage_out;
	assign {CARRYOUT_in, PostAdder_out} = (OPMODE_out[7] == 1'b0)? (Mux_Z_out + Mux_X_out + CARRYIN_out): (Mux_Z_out - (Mux_X_out + CARRYIN_out));
	assign CARRYOUTF = CARRYOUT;
	assign P 		 = P_FourthStage_out;
	assign PCOUT 	 = P_FourthStage_out;
endmodule

