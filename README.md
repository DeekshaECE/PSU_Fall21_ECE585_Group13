# PSU_Fall21_ECE585_Group13
#Simulation of a Memory Controller

#Procedure to execute from terminal:

#Copy mem_controller.sv and mem_cont_defs.sv files into a directory

#Add queuedHere.txt file with trace input file contents (from tracefiles_and_results folder - tx.trace) - {format - [clock time][mode of operation][hexadecimal address]}

#cd <directory name>

#Source
#vlib work

#Compile mem_controller.sv and mem_cont_defs.sv
#vlog -sv mem_controller.sv mem_cont_defs.sv

#Simulate INPUT_FILE <input file>.trace
#vsim +access +r +INPUT_FILE=<input file>.trace +OUTPUT_FILE=<output file>.txt work.mem_controller -c -do "run -all; exit"

#Check output file <output file>.txt
