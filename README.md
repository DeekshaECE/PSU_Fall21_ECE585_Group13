# PSU_Fall21_ECE585_Group13
Simulation of a Memory Controller

# Procedure to execute from terminal:

1. Copy mem_controller.sv and mem_cont_defs.sv files into a directory

2. Add queuedHere.txt file with trace input file contents (from tracefiles_and_results folder - tx.trace) - {format - [clock time][mode of operation][hexadecimal address]}

3. cd directory_name

#Source

4. vlib work

#Compile mem_controller.sv and mem_cont_defs.sv 

5. vlog -sv mem_controller.sv mem_cont_defs.sv

#Simulate INPUT_FILE input_file.trace

6. vsim +access +r +INPUT_FILE=input_file.trace +OUTPUT_FILE=output_file.txt work.mem_controller -c -do "run -all; exit"

7. Check output file output_file.txt
