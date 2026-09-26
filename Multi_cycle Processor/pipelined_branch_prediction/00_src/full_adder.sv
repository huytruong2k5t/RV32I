//-----------------------------------------------------------------------------
// File          : full_adder.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-20
//
// Description   : 1-bit full adder module calculating sum and carry output.
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

endmodule : full_adder