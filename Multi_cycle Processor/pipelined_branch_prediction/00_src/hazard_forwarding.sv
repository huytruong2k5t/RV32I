module hazard_forwarding(
    // Inputs Addresses
    input  logic [4:0] i_rs1_addr_id, i_rs2_addr_id,
    input  logic [4:0] i_rs1_addr_ex, i_rs2_addr_ex,
    input  logic [4:0] i_rd_addr_ex,  i_rd_addr_dm, i_rd_addr_wb,
    
    // Control Signals
    input  logic i_reg_wr_dm, i_reg_wr_wb,
    input  logic i_is_load_ex,       // Lệnh ở EX là Load?
    input  logic i_pc_sel_ex,        // Branch/Jump taken tại tầng EX?
    input  logic i_rs1_used_id,      // Lệnh ở ID có đọc rs1 không?
    input  logic i_rs2_used_id,      // Lệnh ở ID có đọc rs2 không?
    
    // Outputs
    output logic o_stall_pc_if,
    output logic o_stall_if_id,
    output logic o_clear_if_id,
    output logic o_clear_id_ex,
    output logic [1:0] o_rs1_sel, o_rs2_sel
);

    // --- 1. Forwarding Unit (Cho tầng EX - ALU & BRC Operands) ---
    // Ưu tiên: MEM (mới nhất) -> WB (cũ hơn) -> Register File
    always_comb begin
        o_rs1_sel = 2'b00; // 00: ID/EX register (Mặc định)
        if ((i_rs1_addr_ex != 5'd0) && (i_rs1_addr_ex == i_rd_addr_dm) && i_reg_wr_dm) 
            o_rs1_sel = 2'b01; // Forward từ MEM
        else if ((i_rs1_addr_ex != 5'd0) && (i_rs1_addr_ex == i_rd_addr_wb) && i_reg_wr_wb) 
            o_rs1_sel = 2'b10; // Forward từ WB
            
        o_rs2_sel = 2'b00;
        if ((i_rs2_addr_ex != 5'd0) && (i_rs2_addr_ex == i_rd_addr_dm) && i_reg_wr_dm) 
            o_rs2_sel = 2'b01; // Forward từ MEM
        else if ((i_rs2_addr_ex != 5'd0) && (i_rs2_addr_ex == i_rd_addr_wb) && i_reg_wr_wb) 
            o_rs2_sel = 2'b10; // Forward từ WB
    end

    // --- 2. Load-Use Hazard Detection (Stall 1 nhịp) ---
    logic load_stall;
    always_comb begin
        load_stall = 1'b0;
        if (i_is_load_ex && (i_rd_addr_ex != 5'd0)) begin
            if ((i_rs1_used_id && (i_rs1_addr_id == i_rd_addr_ex)) ||
                (i_rs2_used_id && (i_rs2_addr_id == i_rd_addr_ex))) begin
                load_stall = 1'b1;
            end
        end
    end

    // --- 3. Pipeline Control Outputs ---
    // Khi rẽ nhánh tại EX (i_pc_sel_ex == 1):
    // 2 lệnh sai đường ở IF và ID bị Flush. Ưu tiên flush cao hơn stall.
    assign o_stall_pc_if = load_stall && !i_pc_sel_ex;
    assign o_stall_if_id = load_stall && !i_pc_sel_ex;

    assign o_clear_if_id = i_pc_sel_ex;
    assign o_clear_id_ex = i_pc_sel_ex || load_stall;

endmodule