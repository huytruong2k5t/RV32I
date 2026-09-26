//-----------------------------------------------------------------------------
// File          : PC.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-23
//
// Description   : Program Counter (PC) register with enable and asynchronous reset.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module PC (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic        i_en,
    input  logic [31:0] i_next,
    output logic [31:0] o_pc
);

    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            o_pc <= 32'b0;
        end else if (i_en) begin
            o_pc <= i_next;
        end
    end

endmodule : PC