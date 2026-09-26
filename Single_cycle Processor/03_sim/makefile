# Author: Hai Cao (Updated for COAD Project)
# RISC-V Single Cycle Processor Simulation Makefile
# Supported Simulators: Cadence Xcelium & Mentor ModelSim

.PHONY: all
all: sim

# ==============================================================================
# CADENCE XCELIUM (Linux Server / Lab HCMUT)
# ==============================================================================
.PHONY: sim
sim:
	@xrun -access +rwc -f ./flist

.PHONY: wave
wave:
	@(simvision wave.shm &)

.PHONY: gui
gui:
	@xrun -gui -access +rwc -f ./flist -input restore.tcl

.PHONY: create_filelist
create_filelist:
	@rm -f flist
	@echo "-sv" > flist
	@echo "-timescale 1ns/100ps" >> flist
	@echo "" >> flist
	@echo "# TESTBENCH FILES" >> flist
	@find ./../01_bench \( -name "*.sv" -o -name "*.v" -o -name "*.svh" -o -name "*.vh" \) >> flist
	@echo "" >> flist
	@echo "# SOURCE CODE FILES" >> flist
	@find ./../00_src \( -name "*.sv" -o -name "*.v" -o -name "*.svh" -o -name "*.vh" \) >> flist

# ==============================================================================
# MENTOR MODELSIM / QUESTA (CLI & GUI)
# ==============================================================================
.PHONY: modelsim
modelsim:
	@if [ ! -d "work" ]; then vlib work; fi
	@vlog -sv ../00_src/*.sv
	@vlog -sv -mfcu ../01_bench/tlib.svh ../01_bench/driver.sv ../01_bench/scoreboard.sv ../01_bench/tbench.sv
	@vsim -c -do "run -all; quit" tbench

.PHONY: modelsim_gui
modelsim_gui:
	@if [ ! -d "work" ]; then vlib work; fi
	@vlog -sv ../00_src/*.sv
	@vlog -sv -mfcu ../01_bench/tlib.svh ../01_bench/driver.sv ../01_bench/scoreboard.sv ../01_bench/tbench.sv
	@vsim -gui -do "do wave.do; run -all;" tbench

# ==============================================================================
# CLEANUP
# ==============================================================================
.PHONY: clean
clean:
	@echo "-> CLEANING SIMULATION ARTIFACTS"
	@rm -rf x* *.vcd *.shm *.log work transcript vsim.wlf .simvision waves.shm
