# SimVision restore script for Cadence Xcelium simulation
# RISC-V Single Cycle Processor

if {[catch {database open -shm -into wave.shm wave.shm -default} err]} {
    puts "Note: $err"
}

waveform using "Waveform 1"
waveform add -signals /tbench/i_clk
waveform add -signals /tbench/i_reset
waveform add -signals /tbench/o_pc_debug
waveform add -signals /tbench/o_insn_vld
waveform add -signals /tbench/dut/instr
waveform add -signals /tbench/dut/rs1_addr
waveform add -signals /tbench/dut/rs2_addr
waveform add -signals /tbench/dut/rd_addr
waveform add -signals /tbench/dut/rs1_data
waveform add -signals /tbench/dut/rs2_data
waveform add -signals /tbench/dut/alu_data
waveform add -signals /tbench/dut/ld_data
waveform add -signals /tbench/dut/rd_data
waveform add -signals /tbench/o_io_ledr
waveform add -signals /tbench/o_io_ledg
waveform add -signals /tbench/o_io_hex0
waveform add -signals /tbench/o_io_hex1
waveform add -signals /tbench/o_io_hex2
waveform add -signals /tbench/o_io_hex3
waveform add -signals /tbench/i_io_sw

waveform xview zoom full
