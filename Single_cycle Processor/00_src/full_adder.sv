//-----------------------------------------------------------------------------
// File          : full_adder.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 21/10/2025
//
// Description   : 1-bit Full Adder standard module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule