module pc_target (
    input  logic [31:0] i_pc_ex,        
    input  logic [31:0] i_pc_plus4_if,  
    input  logic [31:0] i_alu_result,   
    input  logic [31:0] i_imm,          
    input  logic        i_is_jalr,      
    input  logic        i_pc_sel,       
    output logic [31:0] o_pc_next       
);

    logic [31:0] pc_target_val;

    // Nếu là JALR: PC_target = (RS1 + Imm) & ~1 = ALU_result & ~1 (chuẩn RISC-V xóa LSB)
    // Nếu là Branch/JAL: PC_target = PC_current + Imm
    assign pc_target_val = (i_is_jalr) ? (i_alu_result & ~32'b1) : (i_pc_ex + i_imm);

    // MUX chọn PC tiếp theo:
    assign o_pc_next = (i_pc_sel) ? pc_target_val : i_pc_plus4_if;

endmodule