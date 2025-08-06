vlib work
vlog pwm_timer.v pwm_timer_tb.v
vsim -voptargs=+acc work.pwm_timer_tb
add wave -noupdate -color Cyan -itemcolor Cyan /pwm_timer_tb/i_clk_tb
add wave -noupdate -color Cyan -itemcolor Cyan /pwm_timer_tb/DUT/div_clk_reg
add wave -noupdate -color Cyan -itemcolor Cyan /pwm_timer_tb/DUT/div_clk
add wave -noupdate -color Cyan -itemcolor Cyan /pwm_timer_tb/o_mc_pwm_tb
add wave -noupdate -color {Spring Green} -itemcolor {Spring Green} /pwm_timer_tb/i_rst_tb
add wave -noupdate -color {Spring Green} -itemcolor {Spring Green} /pwm_timer_tb/i_wb_cyc_tb
add wave -noupdate -color {Spring Green} -itemcolor {Spring Green} /pwm_timer_tb/i_wb_stb_tb
add wave -noupdate -color {Spring Green} -itemcolor {Spring Green} /pwm_timer_tb/i_wb_we_tb
add wave -noupdate -color {Spring Green} -itemcolor {Spring Green} /pwm_timer_tb/i_wb_adr_tb
add wave -noupdate -color {Spring Green} -itemcolor {Spring Green} /pwm_timer_tb/i_wb_data_tb
add wave -noupdate -color Cyan -itemcolor Cyan /pwm_timer_tb/o_wb_ack_tb
add wave -noupdate -color Cyan -itemcolor Cyan -radix unsigned /pwm_timer_tb/o_wb_data_tb
add wave -noupdate /pwm_timer_tb/i_extclk_tb
add wave -noupdate /pwm_timer_tb/i_DC_tb
add wave -noupdate -color Yellow -itemcolor Yellow /pwm_timer_tb/i_DC_valid_tb
add wave -noupdate -color Yellow -itemcolor Yellow /pwm_timer_tb/DUT/interrupt_clear
add wave -noupdate -color White -itemcolor White /pwm_timer_tb/DUT/DC
add wave -noupdate -color White -itemcolor White -radix unsigned /pwm_timer_tb/DUT/Ctrl
add wave -noupdate -color White -itemcolor White -radix unsigned /pwm_timer_tb/DUT/Period
add wave -noupdate -color White -itemcolor White -radix unsigned /pwm_timer_tb/DUT/counter
add wave -noupdate -color White -itemcolor White /pwm_timer_tb/DUT/Divisor