//-----------------------------------------------------------------------------
// File          : mux4.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-22
//
// Description   : Parameterized 4-to-1 multiplexer.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module mux4 #(
    parameter W = 32
)(
    input  logic [W-1:0] d0,
    input  logic [W-1:0] d1,
    input  logic [W-1:0] d2,
    input  logic [W-1:0] d3,
    input  logic [1:0]   sel,
    output logic [W-1:0] y
);

    always_comb begin
        unique case (sel)
            2'b00:   y = d0;
            2'b01:   y = d1;
            2'b10:   y = d2;
            default: y = d3;
        endcase
    end

endmodule : mux4
