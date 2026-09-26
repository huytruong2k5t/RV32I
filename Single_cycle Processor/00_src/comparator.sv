//-----------------------------------------------------------------------------
// File          : comparator.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 22/10/2025
//
// Description   : 32-bit signed and unsigned comparator module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module comparator (
    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic        less_s,
    output logic        less_u
);
    logic [31:0] b_complement;
     assign b_complement = ~B;  // 1's complement, +1 via cin
     logic [31:0] diff;    
     logic        carry_out,v_out;

        adder_32bit adder_instruction (
             .a    (A),
             .b    (b_complement),
             .cin  (1'b1),          // +1 to form 2's complement (rs1 - rs2)
             .sum  (diff),
             .cout (carry_out),
             .v      (v_out)
        );
   assign less_u = ~carry_out;
    assign less_s = diff[31] ^ v_out;
endmodule 