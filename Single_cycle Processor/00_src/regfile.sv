//-----------------------------------------------------------------------------
// File          : regfile.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 24/10/2025
//
// Description   : 32x32-bit Register File module with synchronous write and asynchronous read.
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

  // Output read ports (Hardwired x0 to 0)
  assign o_rs1_data = (i_rs1_addr == 5'b0) ? 32'b0 : register_rf[i_rs1_addr];
  assign o_rs2_data = (i_rs2_addr == 5'b0) ? 32'b0 : register_rf[i_rs2_addr];

  // Write & Synchronous Reset
  always_ff @(posedge i_clk) begin
    if (!i_reset) begin
      // Reset all registers to 0
      for (int i = 0; i < 32; i++) begin
        register_rf[i] <= 32'b0;
      end
    end else if (i_rd_wren && (i_rd_addr != 5'b0)) begin
      // Write if not x0
      register_rf[i_rd_addr] <= i_rd_data;
    end
  end

endmodule : regfile