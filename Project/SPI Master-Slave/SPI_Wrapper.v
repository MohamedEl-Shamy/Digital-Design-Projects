module Wrapper (clk, rst_n, SS_n, MOSI, MISO);

	input clk, rst_n, SS_n, MOSI;
	output MISO;

	wire [9:0] rx_data; // Internal wire to connect SPI_Slave and SPI_RAM
    wire rx_valid;      // Internal wire for rx_valid
    wire [7:0] tx_data; // Internal wire for tx_data
    wire tx_valid;      // Internal wire for tx_valid


	SPI_Slave SPI_Slave_inst (
        .clk(clk),
        .rst_n(rst_n),
        .MOSI(MOSI),
        .SS_n(SS_n),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .MISO(MISO),
        .rx_valid(rx_valid),
        .rx_data(rx_data)
    );

    SPI_RAM SPI_RAM_inst (
        .din(rx_data),
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid),
        .dout(tx_data),
        .tx_valid(tx_valid)
    );
endmodule