onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {CLOCK & RESET}
add wave -noupdate -radix binary /tbench/i_clk
add wave -noupdate -radix binary /tbench/i_reset

add wave -noupdate -divider {PROGRAM COUNTER & INSTR}
add wave -noupdate -radix hexadecimal /tbench/o_pc_debug
add wave -noupdate -radix hexadecimal /tbench/dut/pc_next
add wave -noupdate -radix hexadecimal /tbench/dut/instr
add wave -noupdate -radix binary      /tbench/o_insn_vld

add wave -noupdate -divider {CONTROL SIGNALS}
add wave -noupdate -radix binary      /tbench/dut/pc_sel
add wave -noupdate -radix binary      /tbench/dut/Control_unit/o_rd_wren
add wave -noupdate -radix binary      /tbench/dut/opa_sel
add wave -noupdate -radix binary      /tbench/dut/opb_sel
add wave -noupdate -radix binary      /tbench/dut/alu_op
add wave -noupdate -radix binary      /tbench/dut/mem_wren
add wave -noupdate -radix binary      /tbench/dut/wb_sel

add wave -noupdate -divider {REGISTER FILE}
add wave -noupdate -radix unsigned    /tbench/dut/rs1_addr
add wave -noupdate -radix hexadecimal /tbench/dut/rs1_data
add wave -noupdate -radix unsigned    /tbench/dut/rs2_addr
add wave -noupdate -radix hexadecimal /tbench/dut/rs2_data
add wave -noupdate -radix unsigned    /tbench/dut/rd_addr
add wave -noupdate -radix hexadecimal /tbench/dut/rd_data

add wave -noupdate -divider {ALU & BRANCH}
add wave -noupdate -radix hexadecimal /tbench/dut/op_a
add wave -noupdate -radix hexadecimal /tbench/dut/op_b
add wave -noupdate -radix hexadecimal /tbench/dut/imm
add wave -noupdate -radix hexadecimal /tbench/dut/alu_data
add wave -noupdate -radix binary      /tbench/dut/br_less
add wave -noupdate -radix binary      /tbench/dut/br_equal

add wave -noupdate -divider {LSU & DATA MEMORY}
add wave -noupdate -radix hexadecimal /tbench/dut/Lsu/i_lsu_addr
add wave -noupdate -radix hexadecimal /tbench/dut/Lsu/i_st_data
add wave -noupdate -radix hexadecimal /tbench/dut/ld_data

add wave -noupdate -divider {PERIPHERAL I/O}
add wave -noupdate -radix hexadecimal /tbench/i_io_sw
add wave -noupdate -radix hexadecimal /tbench/o_io_ledr
add wave -noupdate -radix hexadecimal /tbench/o_io_ledg
add wave -noupdate -radix hexadecimal /tbench/o_io_hex0
add wave -noupdate -radix hexadecimal /tbench/o_io_hex1
add wave -noupdate -radix hexadecimal /tbench/o_io_hex2
add wave -noupdate -radix hexadecimal /tbench/o_io_hex3

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 220
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {20000 ps}
