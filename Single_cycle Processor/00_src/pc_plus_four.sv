//-----------------------------------------------------------------------------
// File          : pc_plus_four.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 22/10/2025
//
// Description   : PC increment module computing PC + 4.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module pc_plus_four (

    input  logic [31:0] i_pc,

    output logic [31:0] o_pc_plus_four

);

    assign o_pc_plus_four = i_pc + 32'd4;

endmodule: pc_plus_four