//-----------------------------------------------------------------------------
// File          : And_module.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 21/10/2025
//
// Description   : 32-bit bitwise AND logic module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module And_module(
    input  logic [31:0] And_A,
    input  logic [31:0] And_B,
    output logic [31:0] And_kq
);

assign And_kq = And_A & And_B; 
endmodule 