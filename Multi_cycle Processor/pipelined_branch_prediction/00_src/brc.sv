//-----------------------------------------------------------------------------
// File          : brc.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-24
//
// Description   : Branch comparator evaluating branch conditions (less than,
//                 equality) for both signed and unsigned comparisons.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module brc (
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_rs2_data,
    input  logic        i_br_un,
    output logic        o_br_less,
    output logic        o_br_equal
);

    // Equality comparison
    assign o_br_equal = ~|(i_rs1_data ^ i_rs2_data);

    logic [31:0] b_complement;
    logic [31:0] diff;
    logic        carry_out;
    logic        v_out;

    assign b_complement = ~i_rs2_data; // Bù 1, +1 qua cin

    adder_32bit u_adder_brc (
        .a    (i_rs1_data),
        .b    (b_complement),
        .cin  (1'b1), // +1 để tạo số bù 2 (rs1 - rs2)
        .sum  (diff),
        .cout (carry_out),
        .v    (v_out)
    );

    always_comb begin
        if (~i_br_un) begin
            o_br_less = ~carry_out; // Unsigned comparison
        end else begin
            o_br_less = diff[31] ^ v_out; // Signed comparison
        end
    end

endmodule : brc