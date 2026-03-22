module hazard_forwarding(
    // Inputs Addresses
    input  logic [4:0] i_rs1_addr_id, i_rs2_addr_id,
    input  logic [4:0] i_rs1_addr_ex, i_rs2_addr_ex,
    input  logic [4:0] i_rd_addr_ex,  i_rd_addr_dm, i_rd_addr_wb,
    
    // Control Signals
    input  logic i_reg_wr_ex, i_reg_wr_dm, i_reg_wr_wb,
    input  logic i_is_load_ex,       // Lệnh ở EX là Load?
    input  logic i_opcode_is_branch, // Lệnh ở ID là Branch?
    input  logic i_opcode_is_jalr,   // Lệnh ở ID là JALR?
    input  logic i_branch_taken,     // Branch/Jump thực sự xảy ra?
    
    // Outputs
    output logic o_stall_pc_if,
    output logic o_stall_if_id,
    output logic o_clear_if_id,
    output logic o_clear_id_ex,
    output logic [1:0] o_rs1_sel, o_rs2_sel
);

    logic load_stall, branch_stall, jalr_stall, total_stall;

    // --- 1. Forwarding Unit (Cho tầng EX - ALU Operands) ---
    // Ưu tiên: MEM (mới nhất) -> WB (cũ hơn) -> Register File
    always_comb begin
        o_rs1_sel = 2'b00; // 00: ID/EX register (Mặc định)
        if ((i_rs1_addr_ex != 0) && (i_rs1_addr_ex == i_rd_addr_dm) && i_reg_wr_dm) 
            o_rs1_sel = 2'b01; // Forward từ MEM (ALU result hoặc Load result từ chu kỳ trước)
        else if ((i_rs1_addr_ex != 0) && (i_rs1_addr_ex == i_rd_addr_wb) && i_reg_wr_wb) 
            o_rs1_sel = 2'b10; // Forward từ WB
            
        o_rs2_sel = 2'b00;
        if ((i_rs2_addr_ex != 0) && (i_rs2_addr_ex == i_rd_addr_dm) && i_reg_wr_dm) 
            o_rs2_sel = 2'b01;
        else if ((i_rs2_addr_ex != 0) && (i_rs2_addr_ex == i_rd_addr_wb) && i_reg_wr_wb) 
            o_rs2_sel = 2'b10;
    end

    // --- 2. Hazard Detection (Stall Logic) ---
    always_comb begin
        load_stall = 1'b0; branch_stall = 1'b0; jalr_stall = 1'b0;

        // A. Load-Use Hazard: 
        // Lệnh ở EX là Load, lệnh ở ID muốn dùng kết quả đó -> Phải Stall 1 nhịp.
        // Sau 1 nhịp, Load sẽ sang MEM, lúc đó Forwarding unit (ở trên) sẽ lấy được từ MEM/WB.
        if (i_is_load_ex && ((i_rs1_addr_id == i_rd_addr_ex) || (i_rs2_addr_id == i_rd_addr_ex)) && (i_rd_addr_ex != 0)) 
            load_stall = 1'b1;

        // B. Branch Data Hazard (Resolved by Stalling):
        // Vì bộ so sánh Branch (brc) nằm ở ID, nó cần dữ liệu ngay lập tức.
        // Nếu dữ liệu nguồn (rs1, rs2) đang được tính toán ở EX hoặc MEM -> Stall đợi nó về WB.
        if (i_opcode_is_branch) begin
            if ((i_reg_wr_ex && (i_rd_addr_ex != 0) && ((i_rd_addr_ex == i_rs1_addr_id) || (i_rd_addr_ex == i_rs2_addr_id))) ||
                (i_reg_wr_dm && (i_rd_addr_dm != 0) && ((i_rd_addr_dm == i_rs1_addr_id) || (i_rd_addr_dm == i_rs2_addr_id))))
                branch_stall = 1'b1;
        end

        // C. JALR Hazard: Tương tự Branch, JALR cần rs1 ở ID để tính Target.
        if (i_opcode_is_jalr) begin
            if ((i_reg_wr_ex && (i_rd_addr_ex != 0) && (i_rd_addr_ex == i_rs1_addr_id)) ||
                (i_reg_wr_dm && (i_rd_addr_dm != 0) && (i_rd_addr_dm == i_rs1_addr_id)))
                jalr_stall = 1'b1;
        end
    end

    assign total_stall = load_stall | branch_stall | jalr_stall;

    // --- 3. Control Outputs ---
    // Khi Stall: Giữ nguyên PC và IF/ID.
    assign o_stall_pc_if  = total_stall;
    assign o_stall_if_id  = total_stall;
    
    // Clear IF/ID (Flush lệnh kế tiếp) khi:
    // 1. Branch/Jump thực sự xảy ra (Taken).
    // 2. VÀ chúng ta KHÔNG bị stall (nếu stall thì chưa quyết định nhảy được).
    assign o_clear_if_id  = i_branch_taken && !total_stall; 
    
    // Clear ID/EX (Chèn bong bóng vào EX) khi:
    // 1. Xảy ra Stall (ID bị giữ lại, cần đẩy bong bóng sang EX).
    // LƯU Ý QUAN TRỌNG: KHÔNG flush khi i_branch_taken. Lệnh Branch phải đi tiếp để được retire.
    assign o_clear_id_ex  = total_stall;

endmodule