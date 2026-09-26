//-----------------------------------------------------------------------------
// File          : FA32.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 22/10/2025
//
// Description   : 32-bit ripple-carry adder/subtractor built with 32 1-bit full adders.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module FA32 (
    input  logic [31:0] FA32_A,
    input  logic [31:0] FA32_B,
    input  logic        FA32_T,
    output logic [31:0] FA32_S,
    output logic        FA32_C_o
);
  wire [31:0] Bx = FA32_B ^ {32{FA32_T}};
  wire [32:0] c;
  assign c[0] = FA32_T;
  
  FA fa0  (.FA_a(FA32_A[0 ]), .FA_b(Bx[0 ]), .C_i(c[0 ]), .FA_S(FA32_S[0 ]), .C_o(c[1 ]));
  FA fa1  (.FA_a(FA32_A[1 ]), .FA_b(Bx[1 ]), .C_i(c[1 ]), .FA_S(FA32_S[1 ]), .C_o(c[2 ]));
  FA fa2  (.FA_a(FA32_A[2 ]), .FA_b(Bx[2 ]), .C_i(c[2 ]), .FA_S(FA32_S[2 ]), .C_o(c[3 ]));
  FA fa3  (.FA_a(FA32_A[3 ]), .FA_b(Bx[3 ]), .C_i(c[3 ]), .FA_S(FA32_S[3 ]), .C_o(c[4 ]));
  FA fa4  (.FA_a(FA32_A[4 ]), .FA_b(Bx[4 ]), .C_i(c[4 ]), .FA_S(FA32_S[4 ]), .C_o(c[5 ]));
  FA fa5  (.FA_a(FA32_A[5 ]), .FA_b(Bx[5 ]), .C_i(c[5 ]), .FA_S(FA32_S[5 ]), .C_o(c[6 ]));
  FA fa6  (.FA_a(FA32_A[6 ]), .FA_b(Bx[6 ]), .C_i(c[6 ]), .FA_S(FA32_S[6 ]), .C_o(c[7 ]));
  FA fa7  (.FA_a(FA32_A[7 ]), .FA_b(Bx[7 ]), .C_i(c[7 ]), .FA_S(FA32_S[7 ]), .C_o(c[8 ]));
  FA fa8  (.FA_a(FA32_A[8 ]), .FA_b(Bx[8 ]), .C_i(c[8 ]), .FA_S(FA32_S[8 ]), .C_o(c[9 ]));
  FA fa9  (.FA_a(FA32_A[9 ]), .FA_b(Bx[9 ]), .C_i(c[9 ]), .FA_S(FA32_S[9 ]), .C_o(c[10]));
  FA fa10 (.FA_a(FA32_A[10]), .FA_b(Bx[10]), .C_i(c[10]), .FA_S(FA32_S[10]), .C_o(c[11]));
  FA fa11 (.FA_a(FA32_A[11]), .FA_b(Bx[11]), .C_i(c[11]), .FA_S(FA32_S[11]), .C_o(c[12]));
  FA fa12 (.FA_a(FA32_A[12]), .FA_b(Bx[12]), .C_i(c[12]), .FA_S(FA32_S[12]), .C_o(c[13]));
  FA fa13 (.FA_a(FA32_A[13]), .FA_b(Bx[13]), .C_i(c[13]), .FA_S(FA32_S[13]), .C_o(c[14]));
  FA fa14 (.FA_a(FA32_A[14]), .FA_b(Bx[14]), .C_i(c[14]), .FA_S(FA32_S[14]), .C_o(c[15]));
  FA fa15 (.FA_a(FA32_A[15]), .FA_b(Bx[15]), .C_i(c[15]), .FA_S(FA32_S[15]), .C_o(c[16]));
  FA fa16 (.FA_a(FA32_A[16]), .FA_b(Bx[16]), .C_i(c[16]), .FA_S(FA32_S[16]), .C_o(c[17]));
  FA fa17 (.FA_a(FA32_A[17]), .FA_b(Bx[17]), .C_i(c[17]), .FA_S(FA32_S[17]), .C_o(c[18]));
  FA fa18 (.FA_a(FA32_A[18]), .FA_b(Bx[18]), .C_i(c[18]), .FA_S(FA32_S[18]), .C_o(c[19]));
  FA fa19 (.FA_a(FA32_A[19]), .FA_b(Bx[19]), .C_i(c[19]), .FA_S(FA32_S[19]), .C_o(c[20]));
  FA fa20 (.FA_a(FA32_A[20]), .FA_b(Bx[20]), .C_i(c[20]), .FA_S(FA32_S[20]), .C_o(c[21]));
  FA fa21 (.FA_a(FA32_A[21]), .FA_b(Bx[21]), .C_i(c[21]), .FA_S(FA32_S[21]), .C_o(c[22]));
  FA fa22 (.FA_a(FA32_A[22]), .FA_b(Bx[22]), .C_i(c[22]), .FA_S(FA32_S[22]), .C_o(c[23]));
  FA fa23 (.FA_a(FA32_A[23]), .FA_b(Bx[23]), .C_i(c[23]), .FA_S(FA32_S[23]), .C_o(c[24]));
  FA fa24 (.FA_a(FA32_A[24]), .FA_b(Bx[24]), .C_i(c[24]), .FA_S(FA32_S[24]), .C_o(c[25]));
  FA fa25 (.FA_a(FA32_A[25]), .FA_b(Bx[25]), .C_i(c[25]), .FA_S(FA32_S[25]), .C_o(c[26]));
  FA fa26 (.FA_a(FA32_A[26]), .FA_b(Bx[26]), .C_i(c[26]), .FA_S(FA32_S[26]), .C_o(c[27]));
  FA fa27 (.FA_a(FA32_A[27]), .FA_b(Bx[27]), .C_i(c[27]), .FA_S(FA32_S[27]), .C_o(c[28]));
  FA fa28 (.FA_a(FA32_A[28]), .FA_b(Bx[28]), .C_i(c[28]), .FA_S(FA32_S[28]), .C_o(c[29]));
  FA fa29 (.FA_a(FA32_A[29]), .FA_b(Bx[29]), .C_i(c[29]), .FA_S(FA32_S[29]), .C_o(c[30]));
  FA fa30 (.FA_a(FA32_A[30]), .FA_b(Bx[30]), .C_i(c[30]), .FA_S(FA32_S[30]), .C_o(c[31]));
  FA fa31 (.FA_a(FA32_A[31]), .FA_b(Bx[31]), .C_i(c[31]), .FA_S(FA32_S[31]), .C_o(c[32]));

  assign FA32_C_o = c[32];
endmodule