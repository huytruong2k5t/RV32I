//-----------------------------------------------------------------------------
// File          : mux2.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 21/10/2025
//
// Description   : 2-to-1 parameterized multiplexer module.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module mux2 #(parameter W=32)(
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic         sel,
    output logic [W-1:0] y
); 
assign y = sel ? b : a; 
endmodule