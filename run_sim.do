vlog -reportprogress 300 -work work sp_bl.sv
vlog -reportprogress 300 -work work FIR_filter_DA.sv
vlog -reportprogress 300 -work work tb.sv
vsim -gui work.tb
run -all