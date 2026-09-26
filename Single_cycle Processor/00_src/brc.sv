//-----------------------------------------------------------------------------
// File          : brc.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 23/10/2025
//
// Description   : Branch Condition (BRC) comparator unit evaluating branch conditions.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module brc(
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_rs2_data,
    input  logic        i_br_un,
    output logic        o_br_less,
    output logic        o_br_equal
);
    // Equality comparison
    assign o_br_equal = ~|(i_rs1_data ^ i_rs2_data);
     
     logic [31:0] b_complement;
     assign b_complement = ~i_rs2_data;  // 1's complement, +1 via cin
     logic [31:0] diff;
     logic        carry_out,v_out;

        adder_32bit adder_inst (
             .a    (i_rs1_data),
             .b    (b_complement),
             .cin  (1'b1),          // +1 to form 2's complement (rs1 - rs2)
             .sum  (diff),
             .cout (carry_out),
             .v      (v_out)
        );

    always_comb begin
    if (~i_br_un) begin
        o_br_less = ~carry_out;                 // unsigned
    end else begin
        o_br_less = diff[31] ^ v_out;         
    end
    end
endmodule 