//-----------------------------------------------------------------------------
// File          : control_unit.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-27
//
// Description   : Main control unit decoding RISC-V RV32I instructions and
//                 generating datapath control signals for all pipeline stages.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module control_unit (
    input  logic [31:0] i_instr,
    output logic        o_rd_wren,
    output logic        o_opa_sel,     // 0: rs1, 1: PC
    output logic        o_opb_sel,     // 0: rs2, 1: Imm
    output logic [3:0]  o_alu_op,
    output logic        o_mem_wren,
    output logic [1:0]  o_wb_sel,      // 00: PC+4, 01: ALU, 10: MEM
    output logic        o_br_un,       // 0: Unsigned Compare, 1: Signed
    output logic        o_is_branch,
    output logic        o_is_jal,
    output logic        o_is_jalr,
    output logic        o_valid_instr,
    output logic [4:0]  o_rs1_addr,
    output logic [4:0]  o_rs2_addr,
    output logic [4:0]  o_rd_addr,
    output logic [2:0]  o_funct3,
    output logic        o_rs1_used,
    output logic        o_rs2_used,
    output logic        o_is_load
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = i_instr[6:0];
    assign funct3 = i_instr[14:12];
    assign funct7 = i_instr[31:25];

    assign o_rs1_addr = i_instr[19:15];
    assign o_rs2_addr = i_instr[24:20];
    assign o_rd_addr  = i_instr[11:7];
    assign o_funct3   = i_instr[14:12];

    assign o_rs1_used = (opcode != 7'b0110111) && (opcode != 7'b0010111) && (opcode != 7'b1101111);
    assign o_rs2_used = (opcode == 7'b0110011) || (opcode == 7'b0100011) || (opcode == 7'b1100011);
    assign o_is_load  = (opcode == 7'b0000011);

    // ALU Operation Codes
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

    always_comb begin
        // Default Values
        o_rd_wren     = 1'b0;
        o_mem_wren    = 1'b0;
        o_opa_sel     = 1'b0; // Default: Rs1
        o_opb_sel     = 1'b0; // Default: Rs2
        o_alu_op      = ALU_ADD;
        o_wb_sel      = 2'b00;
        o_br_un       = 1'b0;
        o_is_branch   = 1'b0;
        o_is_jal      = 1'b0;
        o_is_jalr     = 1'b0;
        o_valid_instr = 1'b0;

        case (opcode)
            //====== R-TYPE (add, sub, sll, ...) ========
            7'b0110011: begin
                o_rd_wren     = 1'b1;
                o_opa_sel     = 1'b0; // Rs1
                o_opb_sel     = 1'b0; // Rs2
                o_wb_sel      = 2'b01; // ALU result
                o_valid_instr = 1'b1;

                case (funct3)
                    3'b000:  o_alu_op = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                    3'b001:  o_alu_op = ALU_SLL;
                    3'b010:  o_alu_op = ALU_SLT;
                    3'b011:  o_alu_op = ALU_SLTU;
                    3'b100:  o_alu_op = ALU_XOR;
                    3'b101:  o_alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    3'b110:  o_alu_op = ALU_OR;
                    3'b111:  o_alu_op = ALU_AND;
                    default: o_valid_instr = 1'b0;
                endcase
            end

            //======= I-TYPE (addi, slti, ...) ===========
            7'b0010011: begin
                o_rd_wren     = 1'b1;
                o_opa_sel     = 1'b0; // Rs1
                o_opb_sel     = 1'b1; // Imm
                o_wb_sel      = 2'b01; // ALU result
                o_valid_instr = 1'b1;

                case (funct3)
                    3'b000:  o_alu_op = ALU_ADD;
                    3'b010:  o_alu_op = ALU_SLT;
                    3'b011:  o_alu_op = ALU_SLTU;
                    3'b100:  o_alu_op = ALU_XOR;
                    3'b110:  o_alu_op = ALU_OR;
                    3'b111:  o_alu_op = ALU_AND;
                    3'b001:  o_alu_op = (funct7 == 7'b0) ? ALU_SLL : ALU_ADD;
                    3'b101:  o_alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    default: o_valid_instr = 1'b0;
                endcase
            end

            //====== LOAD (lb, lh, lw, ...) ==========
            7'b0000011: begin
                o_rd_wren     = 1'b1;
                o_opa_sel     = 1'b0; // Rs1
                o_opb_sel     = 1'b1; // Imm
                o_alu_op      = ALU_ADD; // Address: Rs1 + Imm
                o_mem_wren    = 1'b0;
                o_wb_sel      = 2'b10; // Load Data from Memory
                o_valid_instr = 1'b1;
            end

            //========== STORE (sb, sh, sw) ==========
            7'b0100011: begin
                o_rd_wren     = 1'b0;
                o_opa_sel     = 1'b0; // Rs1
                o_opb_sel     = 1'b1; // Imm
                o_alu_op      = ALU_ADD; // Address: Rs1 + Imm
                o_mem_wren    = 1'b1;
                o_valid_instr = 1'b1;
            end

            //========= BRANCH (beq, bne, ...) ==============
            7'b1100011: begin
                o_rd_wren     = 1'b0;
                o_mem_wren    = 1'b0;
                o_opa_sel     = 1'b1; // PC
                o_opb_sel     = 1'b1; // Imm
                o_is_branch   = 1'b1;
                o_valid_instr = 1'b1;

                // Signed/Unsigned comparison flag for BRC
                if (funct3 == 3'b110 || funct3 == 3'b111) begin
                    o_br_un = 1'b0; // BLTU, BGEU (Unsigned)
                end else begin
                    o_br_un = 1'b1; // BEQ, BNE, BLT, BGE (Signed)
                end
            end

            //========= JAL ===========
            7'b1101111: begin
                o_rd_wren     = 1'b1;
                o_opa_sel     = 1'b1; // PC
                o_opb_sel     = 1'b1; // Imm
                o_wb_sel      = 2'b00; // PC + 4
                o_is_jal      = 1'b1;
                o_valid_instr = 1'b1;
            end

            //========= JALR ===========
            7'b1100111: begin
                o_rd_wren     = 1'b1;
                o_opa_sel     = 1'b0; // Rs1
                o_opb_sel     = 1'b1; // Imm
                o_alu_op      = ALU_ADD; // Rs1 + Imm
                o_wb_sel      = 2'b00; // PC + 4
                o_is_jalr     = 1'b1;
                o_valid_instr = 1'b1;
            end

            //========== LUI (U-TYPE) ==========
            7'b0110111: begin
                o_rd_wren     = 1'b1;
                o_opa_sel     = 1'b0;
                o_opb_sel     = 1'b1; // Imm
                o_alu_op      = ALU_LUI;
                o_wb_sel      = 2'b01; // ALU Result
                o_valid_instr = 1'b1;
            end

            //========= AUIPC ===========
            7'b0010111: begin
                o_rd_wren     = 1'b1;
                o_opa_sel     = 1'b1; // PC
                o_opb_sel     = 1'b1; // Imm
                o_alu_op      = ALU_ADD; // PC + Imm
                o_wb_sel      = 2'b01; // ALU Result
                o_valid_instr = 1'b1;
            end

            default: begin
                o_valid_instr = 1'b0;
            end
        endcase
    end

endmodule : control_unit