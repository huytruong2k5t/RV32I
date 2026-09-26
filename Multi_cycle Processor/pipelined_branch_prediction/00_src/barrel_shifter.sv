//-----------------------------------------------------------------------------
// File          : barrel_shifter.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-22
//
// Description   : 32-bit logarithmic barrel shifter supporting logical left,
//                 logical right, and arithmetic right bit shifts.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module barrel_shifter (
    input  logic [31:0] in,
    input  logic [4:0]  shamt,
    input  logic        dir,
    input  logic        arith,
    output logic [31:0] out
);

    logic [31:0] s0;
    logic [31:0] s1;
    logic [31:0] s2;
    logic [31:0] s3;
    logic [31:0] s4;

    // Tang 0 (Shift 1 bit)
    assign s0 = (!dir) ? (shamt[0] ? {in[30:0], 1'b0} : in) :
                (arith ? (shamt[0] ? {in[31], in[31:1]} : in)
                       : (shamt[0] ? {1'b0 , in[31:1]} : in));

    // Tang 1 (Shift 2 bits)
    assign s1 = (!dir) ? (shamt[1] ? {s0[29:0], 2'b00} : s0) :
                (arith ? (shamt[1] ? {{2{s0[31]}}, s0[31:2]} : s0)
                       : (shamt[1] ? {2'b00        , s0[31:2]} : s0));

    // Tang 2 (Shift 4 bits)
    assign s2 = (!dir) ? (shamt[2] ? {s1[27:0], 4'b0000} : s1) :
                (arith ? (shamt[2] ? {{4{s1[31]}}, s1[31:4]} : s1)
                       : (shamt[2] ? {4'b0000      , s1[31:4]} : s1));

    // Tang 3 (Shift 8 bits)
    assign s3 = (!dir) ? (shamt[3] ? {s2[23:0], 8'h00} : s2) :
                (arith ? (shamt[3] ? {{8{s2[31]}}, s2[31:8]} : s2)
                       : (shamt[3] ? {8'h00        , s2[31:8]} : s2));

    // Tang 4 (Shift 16 bits)
    assign s4 = (!dir) ? (shamt[4] ? {s3[15:0], 16'h0000} : s3) :
                (arith ? (shamt[4] ? {{16{s3[31]}}, s3[31:16]} : s3)
                       : (shamt[4] ? {16'h0000       , s3[31:16]} : s3));

    assign out = s4;

endmodule : barrel_shifter