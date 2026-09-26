//-----------------------------------------------------------------------------
// File          : Or_module.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 21/10/2025
//
// Description   : 32-bit bitwise OR logic module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module Or_module(
    input  logic [31:0] Or_A,
    input  logic [31:0] Or_B,
    output logic [31:0] Or_kq
);

assign Or_kq = Or_A | Or_B; 
endmodule 