//-----------------------------------------------------------------------------
// File          : PC.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 23/10/2025
//
// Description   : Program Counter register module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module PC (    
    input  logic        i_clk,
    input  logic        i_reset,    // active-low reset: 0 => reset PC=0
    input  logic [31:0] i_next,
    output logic [31:0] o_pc
);

//==== INITIAL PC IS ALWAYS 0 ========
  always_ff @(posedge i_clk) begin
    if (~i_reset) o_pc <= 32'h0000_0000;
    else         o_pc <= i_next;
  end
  
endmodule 