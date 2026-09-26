//-----------------------------------------------------------------------------
// File          : hazard_forwarding.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-28
//
// Description   : Hazard detection and data forwarding unit for resolving
//                 RAW data hazards, load-use stalls, and branch/jump flushes.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module hazard_forwarding (
    // Inputs Addresses
    input  logic [4:0]  i_rs1_addr_id,
    input  logic [4:0]  i_rs2_addr_id,
    input  logic [4:0]  i_rs1_addr_ex,
    input  logic [4:0]  i_rs2_addr_ex,
    input  logic [4:0]  i_rd_addr_ex,
    input  logic [4:0]  i_rd_addr_dm,
    input  logic [4:0]  i_rd_addr_wb,

    // Control Signals
    input  logic        i_reg_wr_dm,
    input  logic        i_reg_wr_wb,
    input  logic        i_is_load_ex,       // Load instruction in EX
    input  logic        i_pc_sel_ex,        // Branch/Jump taken at EX
    input  logic        i_rs1_used_id,      // ID stage instruction reads rs1
    input  logic        i_rs2_used_id,      // ID stage instruction reads rs2

    // Outputs
    output logic        o_pc_en,
    output logic        o_stall_pc_if,
    output logic        o_stall_if_id,
    output logic        o_clear_if_id,
    output logic        o_clear_id_ex,
    output logic [1:0]  o_rs1_sel,
    output logic [1:0]  o_rs2_sel
);

    // --- 1. Forwarding Unit (EX Stage - ALU & BRC Operands) ---
    // Priority: MEM (most recent) -> WB (older) -> Register File (default)
    always_comb begin
        o_rs1_sel = 2'b00; // 00: ID/EX register (Default)
        if ((i_rs1_addr_ex != 5'd0) && (i_rs1_addr_ex == i_rd_addr_dm) && i_reg_wr_dm) begin
            o_rs1_sel = 2'b01; // Forward from MEM
        end else if ((i_rs1_addr_ex != 5'd0) && (i_rs1_addr_ex == i_rd_addr_wb) && i_reg_wr_wb) begin
            o_rs1_sel = 2'b10; // Forward from WB
        end

        o_rs2_sel = 2'b00;
        if ((i_rs2_addr_ex != 5'd0) && (i_rs2_addr_ex == i_rd_addr_dm) && i_reg_wr_dm) begin
            o_rs2_sel = 2'b01; // Forward from MEM
        end else if ((i_rs2_addr_ex != 5'd0) && (i_rs2_addr_ex == i_rd_addr_wb) && i_reg_wr_wb) begin
            o_rs2_sel = 2'b10; // Forward from WB
        end
    end

    // --- 2. Load-Use Hazard Detection (1-cycle stall) ---
    logic load_stall;
    always_comb begin
        load_stall = 1'b0;
        if (i_is_load_ex && (i_rd_addr_ex != 5'd0)) begin
            if ((i_rs1_used_id && (i_rs1_addr_id == i_rd_addr_ex)) ||
                (i_rs2_used_id && (i_rs2_addr_id == i_rd_addr_ex))) begin
                load_stall = 1'b1;
            end
        end
    end

    // --- 3. Pipeline Control Outputs ---
    // EX stage branch redirection (i_pc_sel_ex == 1) flushes wrong-path instructions.
    assign o_stall_pc_if = load_stall && !i_pc_sel_ex;
    assign o_pc_en       = ~o_stall_pc_if;
    assign o_stall_if_id = load_stall && !i_pc_sel_ex;

    assign o_clear_if_id = i_pc_sel_ex;
    assign o_clear_id_ex = i_pc_sel_ex || load_stall;

endmodule : hazard_forwarding