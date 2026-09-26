//-----------------------------------------------------------------------------
// File          : alu.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-24
//
// Description   : 32-bit Arithmetic Logic Unit (ALU) supporting arithmetic,
//                 logical, comparison, and bit-shift instructions.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module alu (
    input  logic [31:0] i_op_a,
    input  logic [31:0] i_op_b,
    input  logic [3:0]  i_alu_op,
    output logic [31:0] o_alu_data
);

    // Local opcode definitions
    localparam [3:0]
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_SLT  = 4'b0010,
        ALU_SLTU = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_OR   = 4'b0101,
        ALU_AND  = 4'b0110,
        ALU_SLL  = 4'b0111,
        ALU_SRL  = 4'b1000,
        ALU_SRA  = 4'b1001,
        ALU_LUI  = 4'b1010;

    // Intermediate results
    logic [31:0] and_kq;
    logic [31:0] or_kq;
    logic [31:0] xor_kq;
    logic        sel_sub;
    assign sel_sub = &(i_alu_op ^~ ALU_SUB);

    logic        sel_srl;
    assign sel_srl = &(i_alu_op ^~ ALU_SRL);

    logic        sel_sra;
    assign sel_sra = &(i_alu_op ^~ ALU_SRA);

    logic        shf_right;
    logic        shf_arith;
    assign shf_arith = sel_sra;
    assign shf_right = sel_srl | sel_sra;

    logic [31:0] shft_o;
    logic        less_s;
    logic        less_u;
    logic [31:0] adder_sum;
    logic        adder_cout;
    logic        adder_v;
    logic [31:0] slt_kq;
    logic [31:0] sltu_kq;

    // AND Module Instantiation
    And_module u_and (
        .i_a    (i_op_a),
        .i_b    (i_op_b),
        .o_data (and_kq)
    );

    // OR Module Instantiation
    Or_module u_or (
        .i_a    (i_op_a),
        .i_b    (i_op_b),
        .o_data (or_kq)
    );

    // XOR Module Instantiation
    Xor_module u_xor (
        .i_a    (i_op_a),
        .i_b    (i_op_b),
        .o_data (xor_kq)
    );

    // Operand A Selection (LUI zeroes op_a)
    logic [31:0] op_a;
    always_comb begin
        case (i_alu_op)
            ALU_LUI: op_a = 32'b0;
            default: op_a = i_op_a;
        endcase
    end

    logic [31:0] op_b_adder;
    assign op_b_adder = i_op_b ^ {32{sel_sub}};

    adder_32bit u_adder_32bit (
        .a    (op_a),
        .b    (op_b_adder),
        .cin  (sel_sub),
        .sum  (adder_sum),
        .cout (adder_cout),
        .v    (adder_v)
    );

    // Comparator for SLT/SLTU
    comparator u_comparator (
        .i_a      (i_op_a),
        .i_b      (i_op_b),
        .o_less_s (less_s),
        .o_less_u (less_u)
    );

    assign slt_kq  = {31'b0, less_s};
    assign sltu_kq = {31'b0, less_u};

    // Barrel Shifter
    barrel_shifter u_barrel_shifter (
        .in    (i_op_a),
        .shamt (i_op_b[4:0]),
        .dir   (shf_right),
        .arith (shf_arith),
        .out   (shft_o)
    );

    // Result Multiplexer
    always_comb begin
        case (i_alu_op)
            ALU_ADD : o_alu_data = adder_sum;
            ALU_SUB : o_alu_data = adder_sum;
            ALU_SLT : o_alu_data = slt_kq;
            ALU_SLTU: o_alu_data = sltu_kq;
            ALU_XOR : o_alu_data = xor_kq;
            ALU_OR  : o_alu_data = or_kq;
            ALU_AND : o_alu_data = and_kq;
            ALU_SLL : o_alu_data = shft_o;
            ALU_SRL : o_alu_data = shft_o;
            ALU_SRA : o_alu_data = shft_o;
            ALU_LUI : o_alu_data = adder_sum;
            default : o_alu_data = 32'b0;
        endcase
    end

endmodule : alu
