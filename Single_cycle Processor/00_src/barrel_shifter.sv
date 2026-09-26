//-----------------------------------------------------------------------------
// File          : barrel_shifter.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 22/10/2025
//
// Description   : 32-bit logarithmic barrel shifter supporting SLL, SRL, and SRA.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module barrel_shifter (
    input  wire [31:0] in,
    input  wire [4:0]  shamt,
    input  wire        dir,
    input  wire        arith,
    output wire [31:0] out
);
    wire [31:0] s0, s1, s2, s3, s4;

    // Stage 0
    assign s0 = (!dir) ? (shamt[0] ? {in[30:0], 1'b0} : in) :
                (arith ? (shamt[0] ? {in[31], in[31:1]} : in)
                       : (shamt[0] ? {1'b0 , in[31:1]} : in));

    // Stage 1
    assign s1 = (!dir) ? (shamt[1] ? {s0[29:0], 2'b00} : s0) :
                (arith ? (shamt[1] ? {{2{s0[31]}}, s0[31:2]} : s0)
                       : (shamt[1] ? {2'b00        , s0[31:2]} : s0));

    // Stage 2
    assign s2 = (!dir) ? (shamt[2] ? {s1[27:0], 4'b0000} : s1) :
                (arith ? (shamt[2] ? {{4{s1[31]}}, s1[31:4]} : s1)
                       : (shamt[2] ? {4'b0000      , s1[31:4]} : s1));

    // Stage 3
    assign s3 = (!dir) ? (shamt[3] ? {s2[23:0], 8'h00} : s2) :
                (arith ? (shamt[3] ? {{8{s2[31]}}, s2[31:8]} : s2)
                       : (shamt[3] ? {8'h00        , s2[31:8]} : s2));

    // Stage 4
    assign s4 = (!dir) ? (shamt[4] ? {s3[15:0], 16'h0000} : s3) :
                (arith ? (shamt[4] ? {{16{s3[31]}}, s3[31:16]} : s3)
                       : (shamt[4] ? {16'h0000       , s3[31:16]} : s3));

    assign out = s4;
endmodule