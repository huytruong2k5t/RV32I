//-----------------------------------------------------------------------------
// File          : comparator.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-22
//
// Description   : 32-bit signed and unsigned comparator module using adder_32bit.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module comparator (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    output logic        o_less_s,
    output logic        o_less_u
);

    logic [31:0] b_complement;
    logic [31:0] diff;
    logic        carry_out;
    logic        v_out;

    assign b_complement = ~i_b; // Bù 1, +1 qua cin

    adder_32bit u_adder_comp (
        .a    (i_a),
        .b    (b_complement),
        .cin  (1'b1), // +1 để tạo số bù 2 (i_a - i_b)
        .sum  (diff),
        .cout (carry_out),
        .v    (v_out)
    );

    assign o_less_u = ~carry_out;
    assign o_less_s = diff[31] ^ v_out;

endmodule : comparator