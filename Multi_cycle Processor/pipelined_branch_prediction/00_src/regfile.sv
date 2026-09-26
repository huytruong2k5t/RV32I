//-----------------------------------------------------------------------------
// File          : regfile.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-25
//
// Description   : 32x32-bit dual-read single-write register file with x0 hardwired
//                 to zero and negative-edge synchronous write update.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module regfile (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [4:0]  i_rs1_addr,
    input  logic [4:0]  i_rs2_addr,
    input  logic [4:0]  i_rd_addr,
    input  logic [31:0] i_rd_data,
    input  logic        i_rd_wren,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data
);

    logic [31:0] register_rf [31:0];
    integer i;

    always_comb begin
        if (i_rs1_addr == 5'b0) begin
            o_rs1_data = 32'b0;
        end else begin
            o_rs1_data = register_rf[i_rs1_addr];
        end

        if (i_rs2_addr == 5'b0) begin
            o_rs2_data = 32'b0;
        end else begin
            o_rs2_data = register_rf[i_rs2_addr];
        end
    end

    always_ff @(negedge i_clk) begin
        if (i_reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                register_rf[i] <= 32'b0;
            end
        end else if (i_rd_wren && (i_rd_addr != 5'b0)) begin
            register_rf[i_rd_addr] <= i_rd_data;
        end
    end

endmodule : regfile