module SPI_RAM (din, clk, rst_n, rx_valid, dout, tx_valid);
	
	parameter MEM_DEPTH = 256;
	localparam ADDR_SIZE = $clog2(MEM_DEPTH); //default 8 

	input [9:0] din;
	input clk, rst_n , rx_valid;
	output reg [7:0] dout;
	output reg tx_valid;

	reg [7:0] mem [255:0];	
	reg [7:0] temp_mem_reg;
    reg tx_valid_reg; 		// New register to hold tx_valid

	always @(posedge clk) begin
		if (~rst_n) begin
			dout 	     <= 0; 
			tx_valid     <= 0;
            tx_valid_reg <= 0;
			temp_mem_reg <= 0;
		end
		else begin
			if (rx_valid) begin
				case (din[9:8])
					//Write
					2'b00: temp_mem_reg   	  <= din[7:0];
					2'b01:	mem[temp_mem_reg] <= din[7:0];
					//Read
					2'b10:	temp_mem_reg   	  <= din[7:0];
					2'b11: begin
							dout 	     <= mem[temp_mem_reg];
							tx_valid_reg <= 1;
						end
					default: begin
									dout 	     <= 0; 
									tx_valid     <= 0;
                                    tx_valid_reg <= 0;
									temp_mem_reg <= 0;
							end
				endcase
			end
            // Keep tx_valid high for one more cycle to ensure data capture
            if (tx_valid_reg) begin
                tx_valid <= 1;
                tx_valid_reg <= 0;
            end else begin
                tx_valid <= 0;
            end
		end 
	end
endmodule
