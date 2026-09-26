//-----------------------------------------------------------------------------
// File          : adder_32bit.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 22/10/2025
//
// Description   : 32-bit ripple-carry adder with carry-out and overflow detection.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module adder_32bit (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic        cout,
    output logic        v
);
    logic [32:0] Carry;
    assign Carry[0] = cin;

    // 32 full adders connected in cascade
    full_adder fa0  (.a(a[0]),  .b(b[0]),  .cin(Carry[0]),  .sum(sum[0]),  .cout(Carry[1]));
    full_adder fa1  (.a(a[1]),  .b(b[1]),  .cin(Carry[1]),  .sum(sum[1]),  .cout(Carry[2]));
    full_adder fa2  (.a(a[2]),  .b(b[2]),  .cin(Carry[2]),  .sum(sum[2]),  .cout(Carry[3]));
    full_adder fa3  (.a(a[3]),  .b(b[3]),  .cin(Carry[3]),  .sum(sum[3]),  .cout(Carry[4]));
    full_adder fa4  (.a(a[4]),  .b(b[4]),  .cin(Carry[4]),  .sum(sum[4]),  .cout(Carry[5]));
    full_adder fa5  (.a(a[5]),  .b(b[5]),  .cin(Carry[5]),  .sum(sum[5]),  .cout(Carry[6]));
    full_adder fa6  (.a(a[6]),  .b(b[6]),  .cin(Carry[6]),  .sum(sum[6]),  .cout(Carry[7]));
    full_adder fa7  (.a(a[7]),  .b(b[7]),  .cin(Carry[7]),  .sum(sum[7]),  .cout(Carry[8]));
    full_adder fa8  (.a(a[8]),  .b(b[8]),  .cin(Carry[8]),  .sum(sum[8]),  .cout(Carry[9]));
    full_adder fa9  (.a(a[9]),  .b(b[9]),  .cin(Carry[9]),  .sum(sum[9]),  .cout(Carry[10]));
    full_adder fa10 (.a(a[10]), .b(b[10]), .cin(Carry[10]), .sum(sum[10]), .cout(Carry[11]));
    full_adder fa11 (.a(a[11]), .b(b[11]), .cin(Carry[11]), .sum(sum[11]), .cout(Carry[12]));
    full_adder fa12 (.a(a[12]), .b(b[12]), .cin(Carry[12]), .sum(sum[12]), .cout(Carry[13]));
    full_adder fa13 (.a(a[13]), .b(b[13]), .cin(Carry[13]), .sum(sum[13]), .cout(Carry[14]));
    full_adder fa14 (.a(a[14]), .b(b[14]), .cin(Carry[14]), .sum(sum[14]), .cout(Carry[15]));
    full_adder fa15 (.a(a[15]), .b(b[15]), .cin(Carry[15]), .sum(sum[15]), .cout(Carry[16]));
    full_adder fa16 (.a(a[16]), .b(b[16]), .cin(Carry[16]), .sum(sum[16]), .cout(Carry[17]));
    full_adder fa17 (.a(a[17]), .b(b[17]), .cin(Carry[17]), .sum(sum[17]), .cout(Carry[18]));
    full_adder fa18 (.a(a[18]), .b(b[18]), .cin(Carry[18]), .sum(sum[18]), .cout(Carry[19]));
    full_adder fa19 (.a(a[19]), .b(b[19]), .cin(Carry[19]), .sum(sum[19]), .cout(Carry[20]));
    full_adder fa20 (.a(a[20]), .b(b[20]), .cin(Carry[20]), .sum(sum[20]), .cout(Carry[21]));
    full_adder fa21 (.a(a[21]), .b(b[21]), .cin(Carry[21]), .sum(sum[21]), .cout(Carry[22]));
    full_adder fa22 (.a(a[22]), .b(b[22]), .cin(Carry[22]), .sum(sum[22]), .cout(Carry[23]));
    full_adder fa23 (.a(a[23]), .b(b[23]), .cin(Carry[23]), .sum(sum[23]), .cout(Carry[24]));
    full_adder fa24 (.a(a[24]), .b(b[24]), .cin(Carry[24]), .sum(sum[24]), .cout(Carry[25]));
    full_adder fa25 (.a(a[25]), .b(b[25]), .cin(Carry[25]), .sum(sum[25]), .cout(Carry[26]));
    full_adder fa26 (.a(a[26]), .b(b[26]), .cin(Carry[26]), .sum(sum[26]), .cout(Carry[27]));
    full_adder fa27 (.a(a[27]), .b(b[27]), .cin(Carry[27]), .sum(sum[27]), .cout(Carry[28]));
    full_adder fa28 (.a(a[28]), .b(b[28]), .cin(Carry[28]), .sum(sum[28]), .cout(Carry[29]));
    full_adder fa29 (.a(a[29]), .b(b[29]), .cin(Carry[29]), .sum(sum[29]), .cout(Carry[30]));
    full_adder fa30 (.a(a[30]), .b(b[30]), .cin(Carry[30]), .sum(sum[30]), .cout(Carry[31]));
    full_adder fa31 (.a(a[31]), .b(b[31]), .cin(Carry[31]), .sum(sum[31]), .cout(Carry[32]));

    assign cout = Carry[32];
    assign v = Carry[31] ^ Carry[32]; // overflow
endmodule