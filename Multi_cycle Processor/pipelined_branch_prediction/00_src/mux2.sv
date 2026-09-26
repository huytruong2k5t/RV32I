//-----------------------------------------------------------------------------
// File          : mux2.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-22
//
// Description   : Parameterized 2-to-1 multiplexer.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module mux2 #(
    parameter W = 32
)(
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic         sel,
    output logic [W-1:0] y
);

    assign y = sel ? b : a;

endmodule : mux2