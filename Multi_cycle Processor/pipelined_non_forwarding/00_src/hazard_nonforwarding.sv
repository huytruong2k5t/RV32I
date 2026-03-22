module hazard_nonforwarding(
    input  logic [4:0] i_rs1_addr_id, i_rs2_addr_id,
    input  logic [4:0] i_rd_addr_ex,  i_rd_addr_dm, i_rd_addr_wb,
    
    input  logic i_reg_wr_ex, i_reg_wr_dm, i_reg_wr_wb,
    input  logic i_opcode_is_branch,
    input  logic i_opcode_is_jalr,  
    input  logic i_branch_taken,    
    
    output logic o_stall_pc_if,
    output logic o_stall_if_id,
    output logic o_clear_if_id,
    output logic o_clear_id_ex,
    output logic [1:0] o_rs1_sel, o_rs2_sel
);

    logic data_hazard_stall;
    logic total_stall;

    assign o_rs1_sel = 2'b00; 
    assign o_rs2_sel = 2'b00;

    always_comb begin
        data_hazard_stall = 1'b0;
        
        // RS1 Check
        if (i_rs1_addr_id != 0) begin
            if ((i_rs1_addr_id == i_rd_addr_ex) && i_reg_wr_ex) data_hazard_stall = 1'b1;
            else if ((i_rs1_addr_id == i_rd_addr_dm) && i_reg_wr_dm) data_hazard_stall = 1'b1;
            // ĐÃ XÓA: Kiểm tra WB (Vì Regfile đã tự xử lý được)
        end

        // RS2 Check
        if (i_rs2_addr_id != 0) begin
            if ((i_rs2_addr_id == i_rd_addr_ex) && i_reg_wr_ex) data_hazard_stall = 1'b1;
            else if ((i_rs2_addr_id == i_rd_addr_dm) && i_reg_wr_dm) data_hazard_stall = 1'b1;
            // ĐÃ XÓA: Kiểm tra WB
        end
    end
    
    assign total_stall = data_hazard_stall;

    assign o_stall_pc_if  = total_stall;
    assign o_stall_if_id  = total_stall;
    
    // Clear IF/ID khi Branch taken VÀ không bị stall (để tránh mất dấu Branch)
    assign o_clear_if_id  = i_branch_taken && !total_stall; 
    
    // Clear ID/EX khi Stall (chèn bong bóng)
    assign o_clear_id_ex  = total_stall;

endmodule