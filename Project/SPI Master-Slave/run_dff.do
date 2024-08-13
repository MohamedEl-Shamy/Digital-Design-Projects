vlib work
vlog SPI_RAM_File.v SPI_Slave_File.v SPI_Wrapper.v SPI_Project_tb.v
vsim -voptargs=+acc work.SPI_tb

# Add waves for all signals in the top-level module (if needed)
add wave /SPI_tb/I1/*

# Add only the specified signals from SPI_Slave_inst
add wave /SPI_tb/I1/SPI_Slave_inst/tx_valid
add wave /SPI_tb/I1/SPI_Slave_inst/tx_data
add wave /SPI_tb/I1/SPI_Slave_inst/rx_valid
add wave /SPI_tb/I1/SPI_Slave_inst/rx_data
add wave /SPI_tb/I1/SPI_Slave_inst/ns
add wave /SPI_tb/I1/SPI_Slave_inst/cs
add wave /SPI_tb/I1/SPI_Slave_inst/counter_reg
add wave /SPI_tb/I1/SPI_Slave_inst/temp_reg
add wave /SPI_tb/I1/SPI_Slave_inst/temp_reg_10
add wave /SPI_tb/I1/SPI_Slave_inst/Add_Exist_Flag

# Add only the specified signals from SPI_RAM_inst
add wave /SPI_tb/I1/SPI_RAM_inst/din
add wave /SPI_tb/I1/SPI_RAM_inst/dout
add wave /SPI_tb/I1/SPI_RAM_inst/mem
add wave /SPI_tb/I1/SPI_RAM_inst/temp_mem_reg
add wave /SPI_tb/I1/SPI_RAM_inst/tx_valid_reg

run -all
#quit -sim
