//-----------------------------------------------------------------------------
// File          : branch_eval.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-28
//
// Description   : Branch condition evaluation, target computation, misprediction
//                 detection, and RAS call/return detection unit for EX stage.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module branch_eval (
    input  logic [31:0] i_pc_curr,
    input  logic [31:0] i_pc_plus4,
    input  logic [31:0] i_imm,
    input  logic [31:0] i_alu_result,
    input  logic [2:0]  i_funct3,
    input  logic [4:0]  i_rd_addr,
    input  logic [4:0]  i_rs1_addr,
    input  logic        i_is_branch,
    input  logic        i_is_jal,
    input  logic        i_is_jalr,
    input  logic        i_valid_instr,
    input  logic        i_br_less,
    input  logic        i_br_equal,
    input  logic        i_pred_taken,
    input  logic [31:0] i_pred_target,
    output logic        o_actual_taken,
    output logic [31:0] o_branch_target,
    output logic        o_redirect,
    output logic [31:0] o_redirect_target,
    output logic        o_is_call,
    output logic        o_is_ret,
    output logic        o_ctrl,
    output logic        o_mispred
);

    logic br_cond;

    // Evaluate branch conditions
    always_comb begin
        case (i_funct3)
            3'b000:  br_cond = i_br_equal;        // BEQ
            3'b001:  br_cond = ~i_br_equal;       // BNE
            3'b100:  br_cond = i_br_less;         // BLT
            3'b101:  br_cond = ~i_br_less;        // BGE
            3'b110:  br_cond = i_br_less;         // BLTU
            3'b111:  br_cond = ~i_br_less;        // BGEU
            default: br_cond = 1'b0;
        endcase
    end

    assign o_actual_taken  = i_is_branch & br_cond;
    assign o_branch_target = i_pc_curr + i_imm;

    logic is_mispred_branch;
    logic is_mispred_jalr;
    logic is_mispred_jal;

    assign is_mispred_branch = i_is_branch && (
        (i_pred_taken != o_actual_taken) ||
        (o_actual_taken && (i_pred_target != o_branch_target))
    );

    assign is_mispred_jalr = i_is_jalr && (
        !i_pred_taken ||
        (i_pred_target != (i_alu_result & ~32'b1))
    );

    assign is_mispred_jal = i_is_jal && (
        !i_pred_taken ||
        (i_pred_target != o_branch_target)
    );

    assign o_redirect = is_mispred_jalr | is_mispred_jal | is_mispred_branch;

    always_comb begin
        if (is_mispred_jalr) begin
            o_redirect_target = i_alu_result & ~32'b1;
        end else if (is_mispred_jal) begin
            o_redirect_target = o_branch_target;
        end else if (i_is_branch && is_mispred_branch) begin
            o_redirect_target = (o_actual_taken) ? o_branch_target : i_pc_plus4;
        end else begin
            o_redirect_target = i_pc_plus4;
        end
    end

    // Call / Return detection for Return Address Stack (RAS)
    assign o_is_call = (i_is_jal || i_is_jalr) && (i_rd_addr == 5'd1 || i_rd_addr == 5'd5);
    assign o_is_ret  = i_is_jalr && (i_rd_addr == 5'd0) && (i_rs1_addr == 5'd1 || i_rs1_addr == 5'd5);

    // Debug control signals
    assign o_ctrl    = i_valid_instr & (i_is_branch | i_is_jal | i_is_jalr);
    assign o_mispred = i_valid_instr & o_redirect;

endmodule : branch_eval
