//-----------------------------------------------------------------------------
// File          : adder_32bit.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-20
//
// Description   : 32-bit ripple carry adder using generate loop of full adders,
//                 providing sum, carry-out, and overflow detection.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module adder_32bit (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic        cout,
    output logic        v
);

    logic [32:0] carry;
    assign carry[0] = cin;

    genvar ix;
    generate
        for (ix = 0; ix < 32; ix = ix + 1) begin : gen_adder
            full_adder u_full_adder (
                .a   (a[ix]),
                .b   (b[ix]),
                .cin (carry[ix]),
                .sum (sum[ix]),
                .cout(carry[ix+1])
            );
        end
    endgenerate

    assign cout = carry[32];
    assign v    = carry[31] ^ carry[32]; // Overflow flag

endmodule : adder_32bit