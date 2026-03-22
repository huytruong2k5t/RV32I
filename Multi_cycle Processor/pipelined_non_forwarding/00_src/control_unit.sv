module control_unit (
    input  logic [31:0] i_instr,
    input  logic        i_br_less,     
    input  logic        i_br_equal,    
    
    output logic        o_pc_sel,      // 1: Jump/Branch Taken, 0: PC+4
    output logic        o_rd_wren,
    output logic        o_opa_sel,     // 0: rs1, 1: PC 
    output logic        o_opb_sel,     // 0: rs2, 1: Imm
    output logic [3:0]  o_alu_op,
    output logic        o_mem_wren,
    output logic [1:0]  o_wb_sel,      // 00: PC+4, 01: ALU, 10: MEM, 11: ...
    output logic        o_br_un,       // 0: Unsigned Compare, 1: Signed
    output logic        o_valid_instr
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = i_instr[6:0];
    assign funct3 = i_instr[14:12];
    assign funct7 = i_instr[31:25];

    //========= ALU OP CODES ===============
    parameter 
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
        // --- Default Values  ---
        o_rd_wren     = 1'b0;
        o_mem_wren    = 1'b0;
        o_opa_sel     = 1'b0; // Mặc định chọn Rs1
        o_opb_sel     = 1'b0; // Mặc định chọn Rs2
        o_alu_op      = ALU_ADD;
        o_wb_sel      = 2'b00;
        o_br_un       = 1'b0;
        o_pc_sel      = 1'b0; // Mặc định PC+4
        o_valid_instr = 1'b0;

        case (opcode)
            //====== R-TYPE (add, sub, sll, ...) ========        
            7'b0110011: begin
                o_rd_wren = 1'b1;   
                o_opa_sel = 1'b0; // Chọn Rs1
                o_opb_sel = 1'b0; // Chọn Rs2
                o_wb_sel  = 2'b01; // Chọn kết quả ALU ghi về 
                o_valid_instr = 1'b1;
                
                case (funct3)
                    3'b000: o_alu_op = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                    3'b001: o_alu_op = ALU_SLL;
                    3'b010: o_alu_op = ALU_SLT;
                    3'b011: o_alu_op = ALU_SLTU;
                    3'b100: o_alu_op = ALU_XOR;
                    3'b101: o_alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    3'b110: o_alu_op = ALU_OR;
                    3'b111: o_alu_op = ALU_AND;
                    default: o_valid_instr = 0;
                endcase
            end

            //======= I-TYPE (addi, slti, ...) ===========        
            7'b0010011: begin
                o_rd_wren = 1'b1;
                o_opa_sel = 1'b0; // Chọn Rs1 
                o_opb_sel = 1'b1; // Chọn Imm
                o_wb_sel  = 2'b01; // Chọn ALU
                o_valid_instr = 1'b1;

                case (funct3)
                    3'b000: o_alu_op = ALU_ADD;
                    3'b010: o_alu_op = ALU_SLT;
                    3'b011: o_alu_op = ALU_SLTU;
                    3'b100: o_alu_op = ALU_XOR;
                    3'b110: o_alu_op = ALU_OR;
                    3'b111: o_alu_op = ALU_AND;
                    3'b001: o_alu_op = (funct7 == 0) ? ALU_SLL : ALU_ADD; // Check logic shift
                    3'b101: o_alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    default: o_valid_instr = 0;
                endcase
            end

            //====== LOAD (lb, lh, lw, ...) ==========
            7'b0000011: begin
                o_rd_wren  = 1'b1;   
                o_opa_sel  = 1'b0; // Rs1
                o_opb_sel  = 1'b1; // Imm
                o_alu_op   = ALU_ADD; // Tính địa chỉ: Rs1 + Imm
                o_mem_wren = 1'b0;   
                o_wb_sel   = 2'b10; // Chọn Load Data (Logic cũ: 2->Mem)
                o_valid_instr = 1'b1;
            end

            //========== S-TYPE (sb, sh, sw) ==========          
            7'b0100011: begin
                o_rd_wren  = 1'b0;   
                o_opa_sel  = 1'b0; // Rs1   
                o_opb_sel  = 1'b1; // Imm   
                o_alu_op   = ALU_ADD; // Tính địa chỉ
                o_mem_wren = 1'b1;   
                o_valid_instr = 1'b1;
            end

            //========= B-TYPE (beq, bne, ...) ==============  
            // QUAN TRỌNG: Logic xác định PC_SEL nằm ngay tại đây
            7'b1100011: begin
                o_rd_wren  = 1'b0;
                o_mem_wren = 1'b0;
                o_opa_sel  = 1'b1; // Chọn PC 
                o_opb_sel  = 1'b1; // Chọn Imm
                o_valid_instr = 1'b1;

                // 1. Xác định Signed/Unsigned comparison
                if (funct3 == 3'b110 || funct3 == 3'b111) 
                    o_br_un = 1'b0; // BLTU, BGEU
                else 
                    o_br_un = 1'b1;

                // 2. Xác định có Branch hay không (PC_SEL)
                case (funct3)
                    3'b000: o_pc_sel = i_br_equal;       // BEQ
                    3'b001: o_pc_sel = ~i_br_equal;      // BNE
                    3'b100: o_pc_sel = i_br_less;        // BLT
                    3'b101: o_pc_sel = ~i_br_less;       // BGE
                    3'b110: o_pc_sel = i_br_less;        // BLTU
                    3'b111: o_pc_sel = ~i_br_less;       // BGEU
                    default: o_pc_sel = 1'b0;
                endcase
            end

            //========= JAL ===========
            7'b1101111: begin
                o_rd_wren  = 1'b1;   
                o_opa_sel  = 1'b1; // PC (để lưu PC+4 hoặc tính toán)
                o_opb_sel  = 1'b1; // Imm   
                o_wb_sel   = 2'b00; // Chọn PC+4 ghi vào Rd (Logic cũ: 0->PC+4)
                o_pc_sel   = 1'b1; // Luôn nhảy
                o_valid_instr = 1'b1;
            end

            //========= JALR ===========
            7'b1100111: begin
                o_rd_wren  = 1'b1;   
                o_opa_sel  = 1'b0; // Rs1 (Target = Rs1 + Imm)
                o_opb_sel  = 1'b1; // Imm   
                o_wb_sel   = 2'b00; // Chọn PC+4 ghi vào Rd
                o_pc_sel   = 1'b1; // Luôn nhảy
                o_valid_instr = 1'b1;
            end

            //========== LUI (U-TYPE) ==========
            7'b0110111: begin
                o_rd_wren  = 1'b1;
                o_opa_sel  = 1'b0; // Don't care (ALU LUI chỉ lấy B)
                o_opb_sel  = 1'b1; // Imm
                o_alu_op   = ALU_LUI;
                o_wb_sel   = 2'b01; // ALU Result
                o_valid_instr = 1'b1;
            end

            //========= AUIPC ===========
            7'b0010111: begin
                o_rd_wren  = 1'b1;
                o_opa_sel  = 1'b1; // PC
                o_opb_sel  = 1'b1; // Imm
                o_alu_op   = ALU_ADD; // PC + Imm
                o_wb_sel   = 2'b01; // ALU Result
                o_valid_instr = 1'b1;
            end

            default: begin
                o_valid_instr = 1'b0;
            end
        endcase
    end
endmodule