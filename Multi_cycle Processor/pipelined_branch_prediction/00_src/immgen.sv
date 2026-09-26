//-----------------------------------------------------------------------------
// File          : immgen.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-24
//
// Description   : Immediate generator unit decoding 32-bit instruction immediates
//                 for I, S, B, U, and J instruction formats.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module immgen (
    input  logic [31:0] i_instr,
    output logic [31:0] o_imm
);

    logic [6:0] opcode;
    assign opcode = i_instr[6:0];

    logic [11:0] imm_i;
    logic [11:0] imm_s;
    logic [12:0] imm_b;
    logic [19:0] imm_u;
    logic [20:0] imm_j;

    assign imm_i = i_instr[31:20];
    assign imm_s = { i_instr[31:25], i_instr[11:7] };
    assign imm_b = { i_instr[31], i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0 };
    assign imm_u = i_instr[31:12];
    assign imm_j = { i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0 };

    logic [31:0] imm_i_sext;
    logic [31:0] imm_s_sext;
    logic [31:0] imm_b_sext;
    logic [31:0] imm_j_sext;
    logic [31:0] imm_u_type;

    assign imm_i_sext = { {20{imm_i[11]}}, imm_i };
    assign imm_s_sext = { {20{imm_s[11]}}, imm_s };
    assign imm_b_sext = { {19{imm_b[12]}}, imm_b };
    assign imm_j_sext = { {11{imm_j[20]}}, imm_j };
    assign imm_u_type = { imm_u, 12'b0 };

    always_comb begin
        case (opcode)
            7'b0000011: o_imm = imm_i_sext; // LOAD
            7'b0010011: o_imm = imm_i_sext; // OP-IMM
            7'b1100111: o_imm = imm_i_sext; // JALR
            7'b0100011: o_imm = imm_s_sext; // STORE
            7'b1100011: o_imm = imm_b_sext; // BRANCH
            7'b0110111: o_imm = imm_u_type; // LUI
            7'b0010111: o_imm = imm_u_type; // AUIPC
            7'b1101111: o_imm = imm_j_sext; // JAL
            default:    o_imm = 32'b0;
        endcase
    end

endmodule : immgen