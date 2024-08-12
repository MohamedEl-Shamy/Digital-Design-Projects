vlib work
vlog DSP_Mux.v DSP_RegMux_Module.v DSP_Project.v DSP_Project_tb.v
vsim -voptargs=+acc work.Spartan6_DSP48A1_tb
add wave *
run -all
#quit -sim

