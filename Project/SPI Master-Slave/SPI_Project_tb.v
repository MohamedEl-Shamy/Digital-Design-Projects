module SPI_tb ();

	reg  clk, rst_n, SS_n, MOSI;
	wire MISO;

	Wrapper I1 (clk, rst_n, SS_n, MOSI, MISO);

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    //Initialize the memory to zeros:
    integer i;
    initial begin
    	for(i = 0; i < 256; i = i + 1)
    		I1.SPI_RAM_inst.mem[i] = 0;
    end

    initial begin
    	//RESET:
		rst_n = 0;
		MOSI  = 0;
		SS_n  = 1;
		@(negedge clk);

		rst_n = 1;
		SS_n  = 0;
		@(negedge clk);

		//Test Writing (Saving the address):
		MOSI = 0;
		@(negedge clk);
		MOSI = 0;
		@(negedge clk);
		MOSI = 0;
		@(negedge clk);
		repeat(8) begin
			MOSI = 1;
			@(negedge clk); //Save the address 1111_1111
		end

		@(negedge clk);

		//Close Communication:
		SS_n  = 1;
		@(negedge clk);

		//Start Communication:
		SS_n  = 0;
		@(negedge clk);

		//Test Writing (Writing in the Adress):
		MOSI = 0;
		@(negedge clk);
		MOSI = 0;
		@(negedge clk);
		MOSI = 1;
		@(negedge clk);
		repeat(8) begin
			MOSI = 1;
			@(negedge clk); //Save this data: 1111_1111 in the previous stored address
		end

		@(negedge clk);

		//Close Communication:
		SS_n  = 1;
		@(negedge clk);

		//Start Communication:
		SS_n  = 0;
		@(negedge clk);

		//Test Reading (Saving the adress):
		MOSI = 1;
		@(negedge clk);
		MOSI = 1;
		@(negedge clk);
		MOSI = 0;
		@(negedge clk);
		repeat(8) begin
			MOSI = 1;
			@(negedge clk); //Save the address 1111_1111
		end

		@(negedge clk);

 		//Close Communication:
		SS_n  = 1;
		@(negedge clk);

		//Start Communication:
		SS_n  = 0;
		@(negedge clk);

		//Test Reading (Reading content inside the Adress):
		MOSI = 1;
		@(negedge clk);
		MOSI = 1;
		@(negedge clk);
		MOSI = 1;
		@(negedge clk);
		repeat(10) begin
			MOSI = 1;
			@(negedge clk); //Get the data 1111_1111 Stored in the previous address
		end
		
		//Reading the output serial
		repeat(10) begin
			@(negedge clk); //MISO output serially
		end
		$stop;
    end
endmodule