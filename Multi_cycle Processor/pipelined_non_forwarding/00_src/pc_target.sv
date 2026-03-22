module pc_target (
    input  logic [31:0] i_pc_id,        
    input  logic [31:0] i_pc_plus4_if,  
    input  logic [31:0] i_rs1_data,     
    input  logic [31:0] i_imm,          
    input  logic [6:0]  i_opcode,       
    input  logic        i_br_taken,     
    output logic [31:0] o_pc_next       
);

    logic        is_jalr;
    logic [31:0] pc_target_val;

    // Nhận diện JALR (Opcode: 1100111)
    assign is_jalr = (i_opcode == 7'b1100111);
	 
    // Nếu là JALR: PC_next = RS1 + Imm
    // Nếu là Branch/JAL: PC_next = PC_current + Imm
    assign pc_target_val = (is_jalr) ? (i_rs1_data + i_imm) : (i_pc_id + i_imm);

    // MUX chọn PC tiếp theo:
    assign o_pc_next = (i_br_taken) ? pc_target_val : i_pc_plus4_if;

endmodule