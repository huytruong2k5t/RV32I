//-----------------------------------------------------------------------------
// File          : single_cycle.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 28/10/2025
//
// Description   : Top-level RISC-V 32I single-cycle processor datapath and control.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module single_cycle(
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_io_sw,
    output logic [31:0] o_pc_debug,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [31:0] o_io_lcd,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic        o_insn_vld
    );
    //assign instruction = instr;
logic [31:0] pc_q, pc_plus, pc_next;
logic [31:0] rs1_data, rs2_data;
logic [31:0] instr;
logic [31:0] rd_data;
logic [4:0] rs1_addr, rs2_addr, rd_addr;      
assign rs1_addr = instr[19:15];
assign rs2_addr = instr[24:20];
assign rd_addr  = instr[11:7];
logic        pc_sel, opa_sel, opb_sel, mem_wren, valid_instr;
logic [3:0]  alu_op;
logic [1:0]  wb_sel;
logic [6:0] opcode;
logic [2:0] fuct3;
assign opcode = instr[6:0];
assign fuct3 = instr[14:12];
logic [31:0] imm;
logic br_un, br_less, br_equal;
logic [31:0] op_a, op_b, alu_data, ld_data;
logic not_rst;
assign not_rst = i_reset;
// ================= Control Unit =================
  control_unit Control_unit(
    .i_instr       (instr),
    .i_br_less     (br_less),
    .i_br_equal    (br_equal),
    .o_pc_sel      (pc_sel),
    .o_rd_wren     (rd_wren),
    .o_opa_sel     (opa_sel),
    .o_opb_sel     (opb_sel),
    .o_alu_op      (alu_op),
    .o_mem_wren    (mem_wren),
    .o_wb_sel      (wb_sel),
    .o_br_un       (br_un),
    .o_valid_instr (valid_instr)
  );
//============ PC next ===============
  mux2 #(32) PC_NEXT (
    .a  (alu_data),
    .b  (pc_plus),
    .sel(pc_sel),
    .y  (pc_next)
  );
 
//==== PC MODULE ====
PC pc (
  .i_clk (i_clk),
  .i_reset(i_reset),
  .i_next(pc_next),
  .o_pc  (pc_q)
);

  assign o_pc_debug = pc_q;

//======= PC+4 MODULE ==========
pc_plus_four pc_4 (
  .i_pc  (pc_q),
  .o_pc_plus_four (pc_plus)
);

//======= INSTRUCTION MEMORY (I$) ==========
Imem I$ (
  .i_clk   (i_clk),
  .i_reset (i_reset),          
  .pc  (pc_q),          
  .Rom_mem (instr)          
);

//========== Regfile ===========
regfile Regfile (
  .i_clk(i_clk),
  .i_reset (not_rst),
  .i_rs1_addr(rs1_addr), 
  .i_rs2_addr(rs2_addr),
  .o_rs1_data(rs1_data), 
  .o_rs2_data(rs2_data),
  .i_rd_addr(rd_addr),   
  .i_rd_data(rd_data),
  .i_rd_wren(rd_wren)
);

//==== ImmGen ====
immgen Immgen (.i_instr(instr), .o_imm(imm));

//==== BRC ====
brc Brc (
  .i_rs1_data (rs1_data),
  .i_rs2_data (rs2_data),
  .i_br_un    (br_un),
  .o_br_less  (br_less),
  .o_br_equal (br_equal)
);
  
  assign o_insn_vld = valid_instr; 
  
//========== OPERAND SELECTION MUXES ==============
  mux2 #(32) MUX_OPA (.a(pc_q), .b(rs1_data),  .sel(opa_sel), .y(op_a));
  // 0->rs2, 1->imm
  mux2 #(32) MUX_OPB (.a(rs2_data), .b(imm),   .sel(opb_sel), .y(op_b));

//========== ALU ===========
  alu Alu (
    .i_op_a    (op_a),
    .i_op_b    (op_b),
    .i_alu_op  (alu_op),
    .o_alu_data(alu_data)
  );

//============ LSU + I/O =============
  lsu Lsu (
    .i_clk       (i_clk),
    .i_reset     (i_reset),
    .i_lsu_addr  (alu_data),
    .i_st_data   (rs2_data),
    .i_lsu_wren  (mem_wren),
    .o_ld_data   (ld_data),
     .i_funct3 (fuct3),
    .i_opcode (opcode),
    .o_io_ledr   (o_io_ledr),
    .o_io_ledg   (o_io_ledg),
    .o_io_hex0   (o_io_hex0), .o_io_hex1(o_io_hex1), .o_io_hex2(o_io_hex2),
    .o_io_hex3   (o_io_hex3), .o_io_hex4(o_io_hex4), .o_io_hex5(o_io_hex5),
    .o_io_hex6   (o_io_hex6), .o_io_hex7(o_io_hex7),
    .o_io_lcd    (o_io_lcd),
    .i_io_sw     (i_io_sw)
  );

 //========= WB mux (SELECT PC+4/ALU/LOAD/0) ===============
  mux4 #(32) MUX_WB (
    .d0 (pc_plus),
    .d1 (alu_data),
    .d2 (ld_data),
    .d3 (32'b0),
    .sel(wb_sel),
    .y  (rd_data)
  );

endmodule
