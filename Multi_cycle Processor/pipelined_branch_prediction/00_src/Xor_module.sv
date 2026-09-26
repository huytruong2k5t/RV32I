//-----------------------------------------------------------------------------
// File          : Xor_module.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-21
//
// Description   : 32-bit bitwise XOR operation module for the ALU.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module Xor_module (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    output logic [31:0] o_data
);

    assign o_data = i_a ^ i_b;

endmodule : Xor_module