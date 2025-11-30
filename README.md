# AES-128 Encryption Core

This project implements an AES-128 encryption core in SystemVerilog.

## Features
- Fully pipelined design.
- Ready for synthesis in Xilinx 7-series FPGAs.
- Compatible for Xilinx Vivado 2025.1+ (probably will work in older versions too).

## Usage
1. Open vivado console in project directory:
``` 
vivado -mode tcl 
```
2. Source the sim.tcl file in scripts/
```
source scripts/sim.tcl
```
3. Run Simulation:
```
run_sim %Project_Name% %Top_Module% %Testbench_Module% 
```
4. (Optional) Launch gui for waveform viewer:
```
start_gui 
```
5. (Optional) Running sim may polute the directory. Run this to clean unwanted files.
```
source clear_dir.tcl 
```

## TO-DO:
- Implement the design.
- Verify the design using XSI (currently on SystemVerilog tb).
- Run Static Timing Analysis.
- Create an AXI-Stream interface.
- Package the design into an IP.

