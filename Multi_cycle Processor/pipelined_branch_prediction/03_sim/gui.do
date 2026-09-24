# ===================================================
# ModelSim Waveform Configuration Script
# ===================================================
onerror {resume}
quietly WaveActivateNextPane {} 0

# --- CLOCK & RESET ---
add wave -divider "CLOCK & RESET"
add wave -format Logic /tbench/clk
add wave -format Logic /tbench/rstn

# --- IF STAGE & BRANCH PREDICTION ---
add wave -divider "IF STAGE & BRANCH PREDICTOR"
add wave -format Literal -radix hexadecimal /tbench/dut/pc_curr_if
add wave -format Literal -radix hexadecimal /tbench/dut/instr_if
add wave -format Logic /tbench/dut/pred_taken_if
add wave -format Literal -radix hexadecimal /tbench/dut/pred_target_if
add wave -format Literal -radix hexadecimal /tbench/dut/pc_next

# --- BRANCH PREDICTOR INTERNAL SIGNALS ---
add wave -divider "BRANCH PREDICTOR INTERNALS"
add wave -format Literal -radix hexadecimal /tbench/dut/bp_unit/read_idx
add wave -format Literal -radix hexadecimal /tbench/dut/bp_unit/read_tag
add wave -format Logic /tbench/dut/bp_unit/o_pred_taken
add wave -format Literal -radix hexadecimal /tbench/dut/bp_unit/o_pred_target
add wave -format Logic /tbench/dut/bp_unit/i_valid_id
add wave -format Logic /tbench/dut/bp_unit/i_is_branch
add wave -format Literal -radix hexadecimal /tbench/dut/bp_unit/i_pc_id
add wave -format Literal -radix hexadecimal /tbench/dut/bp_unit/i_target_id
add wave -format Logic /tbench/dut/bp_unit/i_actual_taken

# --- ID STAGE ---
add wave -divider "ID STAGE"
add wave -format Literal -radix hexadecimal /tbench/dut/pc_curr_id
add wave -format Literal -radix hexadecimal /tbench/dut/instr_id
add wave -format Logic /tbench/dut/is_branch_id
add wave -format Logic /tbench/dut/is_jal_id
add wave -format Logic /tbench/dut/is_jalr_id
add wave -format Logic /tbench/dut/valid_instr_id

# --- EX STAGE & MISPREDICTION LOGIC ---
add wave -divider "EX STAGE & RESOLUTION"
add wave -format Literal -radix hexadecimal /tbench/dut/pc_curr_ex
add wave -format Literal -radix hexadecimal /tbench/dut/alu_result_ex
add wave -format Logic /tbench/dut/is_branch_ex
add wave -format Logic /tbench/dut/actual_taken_branch
add wave -format Logic /tbench/dut/pred_taken_ex
add wave -format Literal -radix hexadecimal /tbench/dut/branch_target_ex
add wave -format Logic /tbench/dut/is_mispred_branch
add wave -format Logic /tbench/dut/is_mispred_jal
add wave -format Logic /tbench/dut/pc_redirect_ex
add wave -format Literal -radix hexadecimal /tbench/dut/pc_redirect_target_ex

# --- HAZARD UNIT & FLUSH SIGNALS ---
add wave -divider "HAZARD & FLUSH"
add wave -format Logic /tbench/dut/stall_pc
add wave -format Logic /tbench/dut/stall_if_id
add wave -format Logic /tbench/dut/flush_if_id
add wave -format Logic /tbench/dut/flush_id_ex

# --- SCOREBOARD & PERIPHERALS ---
add wave -divider "SCOREBOARD / OUTPUT"
add wave -format Literal -radix hexadecimal /tbench/dut/o_pc_debug
add wave -format Logic /tbench/dut/o_insn_vld
add wave -format Logic /tbench/dut/o_ctrl
add wave -format Logic /tbench/dut/o_mispred
add wave -format Literal -radix ascii /tbench/dut/o_io_ledr

# All internal DUT signals recursively
add wave -divider "ALL DUT SIGNALS"
add wave -r /tbench/dut/*

run -all
wave zoom full
