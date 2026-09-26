//-----------------------------------------------------------------------------
// File          : Xor_module.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 21/10/2025
//
// Description   : 32-bit bitwise XOR logic module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module Xor_module(
    input  logic [31:0] Xor_A,
    input  logic [31:0] Xor_B,
    output logic [31:0] Xor_kq
);

assign Xor_kq = Xor_A ^ Xor_B; 
endmodule 