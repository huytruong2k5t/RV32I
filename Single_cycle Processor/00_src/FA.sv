//-----------------------------------------------------------------------------
// File          : FA.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 21/10/2025
//
// Description   : 1-bit Full Adder primitive module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module FA(
    input  logic FA_a,
    input  logic FA_b,
    input  logic C_i,
    output logic FA_S,
    output logic C_o
);
    assign FA_S= FA_a ^ FA_b ^ C_i;
     assign C_o = (FA_a & FA_b) | (FA_a & C_i) | (FA_b & C_i);
endmodule

