module RegMux_pair (Output, Input, clk, PLEnable, Reset, Enable);
	parameter WIDTH = 18; 			//Default
	parameter RSTTYPE = "SYNC";		//OR ASYNC

	input  [WIDTH-1:0] Input;
	input  PLEnable, clk, Reset, Enable;
	output [WIDTH-1:0] Output;
	
	reg [WIDTH-1:0] Input_reg;
    
    assign Output = PLEnable ? Input_reg : Input;

    generate
        if (RSTTYPE == "ASYNC") begin
            always @(posedge clk or posedge Reset) begin
                if (Reset) begin
                    Input_reg <= 0;
                end
                else if (Enable) begin
                    Input_reg <= Input;    
                end            
            end
        end else if (RSTTYPE == "SYNC") begin
            always @(posedge clk) begin
                if (Reset) begin
                    Input_reg <= 0;
                end
                else if (Enable) begin
                    Input_reg <= Input;    
                end            
            end
        end
    endgenerate
endmodule

