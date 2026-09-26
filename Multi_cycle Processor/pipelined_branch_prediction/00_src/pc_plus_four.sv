//-----------------------------------------------------------------------------
// File          : pc_plus_four.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-22
//
// Description   : PC incrementer module that computes PC + 4 for the next
//                 sequential instruction address.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module pc_plus_four (
    input  logic [31:0] i_pc,
    output logic [31:0] o_pc_plus_four
);

    assign o_pc_plus_four = i_pc + 32'd4;

endmodule : pc_plus_four