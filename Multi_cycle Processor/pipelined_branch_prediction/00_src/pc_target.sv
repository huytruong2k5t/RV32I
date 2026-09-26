//-----------------------------------------------------------------------------
// File          : pc_target.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-23
//
// Description   : Next PC multiplexer selecting between sequential PC+4,
//                 predicted branch target, and EX-stage redirect target.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module pc_target (
    input  logic [31:0] i_pc_plus4_if,
    input  logic [31:0] i_pred_target_if,
    input  logic        i_pred_taken_if,
    input  logic [31:0] i_redirect_target_ex,
    input  logic        i_redirect_ex,
    output logic [31:0] o_pc_next
);

    always_comb begin
        if (i_redirect_ex) begin
            // Highest priority: Correct misprediction or jump from EX
            o_pc_next = i_redirect_target_ex;
        end else if (i_pred_taken_if) begin
            // Taken branch predicted by Branch Predictor (0-cycle penalty)
            o_pc_next = i_pred_target_if;
        end else begin
            // Default sequential PC + 4
            o_pc_next = i_pc_plus4_if;
        end
    end

endmodule : pc_target