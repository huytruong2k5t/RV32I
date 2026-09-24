module pipelined (
    input  logic          i_clk      ,
    input  logic          i_reset    ,
    // Input peripherals
    input  logic [31:0]   i_io_sw    ,
    // Output peripherals
    output logic [31:0]   o_io_lcd   ,
    output logic [31:0]   o_io_ledr  ,
    output logic [31:0]   o_io_ledg  ,
    output logic [6:0]    o_io_hex0  ,
    output logic [6:0]    o_io_hex1  ,
    output logic [6:0]    o_io_hex2  ,
    output logic [6:0]    o_io_hex3  ,
    output logic [6:0]    o_io_hex4  ,
    output logic [6:0]    o_io_hex5  ,
    output logic [6:0]    o_io_hex6  ,
    output logic [6:0]    o_io_hex7  ,
    // Debug output
    output logic [31:0]   o_pc_debug,
    output logic          o_insn_vld,
    output logic          o_ctrl    ,
    output logic          o_mispred
);

    // ========================================================================
    // 1. INTERNAL SIGNALS
    // ========================================================================

    // --- Hazard & Control ---
    logic stall_pc, stall_if_id, flush_if_id, flush_id_ex;
    
    // --- IF Stage ---
    logic [31:0] pc_next, pc_curr_if, pc_plus4_if;
    logic [31:0] instr_if;
    logic        pred_taken_if;
    logic [31:0] pred_target_if;
    logic [2:0]  ras_ptr_if;

    // --- ID Stage ---
    logic [31:0] pc_curr_id, pc_plus4_id, instr_id;
    logic [31:0] rs1_data_id, rs2_data_id, imm_id;
    logic [4:0]  rs1_addr_id, rs2_addr_id, rd_addr_id;
    logic [6:0]  opcode_id;
    logic [2:0]  funct3_id;
    logic        pred_taken_id;
    logic [31:0] pred_target_id;
    logic [2:0]  ras_ptr_id;
    
    logic        br_un_id;
    logic        is_branch_id, is_jal_id, is_jalr_id;
    logic        rs1_used_id, rs2_used_id;
    logic        reg_wren_id, mem_wren_id, op_a_sel_id, op_b_sel_id, valid_instr_id;
    logic [1:0]  wb_sel_id;
    logic [3:0]  alu_op_id;

    // --- EX Stage ---
    logic [31:0] pc_curr_ex, pc_plus4_ex;
    logic [31:0] rs1_data_ex, rs2_data_ex, imm_ex;
    logic [4:0]  rs1_addr_ex, rs2_addr_ex, rd_addr_ex;
    logic [2:0]  funct3_ex;
    logic        reg_wren_ex, mem_wren_ex, op_a_sel_ex, op_b_sel_ex;
    logic [1:0]  wb_sel_ex;
    logic [3:0]  alu_op_ex;
    logic [1:0]  fwd_a_sel, fwd_b_sel;
    logic [31:0] fwd_a_val, fwd_b_val, alu_op_a, alu_op_b, alu_result_ex;
    logic [31:0] mem_fwd_data;
    logic        pred_taken_ex;
    logic [31:0] pred_target_ex;
    logic [2:0]  ras_ptr_ex;
    
    logic        is_branch_ex, is_jal_ex, is_jalr_ex, br_un_ex;
    logic        is_call_ex, is_ret_ex;
    logic [31:0] call_ret_pc_ex;
    logic        br_less_ex, br_equal_ex, br_cond_ex;
    logic        actual_taken_branch;
    logic [31:0] branch_target_ex;
    logic        is_mispred_branch;
    logic        pc_redirect_ex;
    logic [31:0] pc_redirect_target_ex;
    logic        ctrl_ex, mispred_ex, valid_instr_ex;

    // --- MEM Stage ---
    logic [31:0] pc_curr_mem; 
    logic [31:0] pc_plus4_mem, alu_result_mem, store_data_mem, ld_data_mem;
    logic [4:0]  rd_addr_mem;
    logic [2:0]  funct3_mem;
    logic        reg_wren_mem, mem_wren_mem;
    logic [1:0]  wb_sel_mem;

    logic ctrl_mem, mispred_mem, valid_instr_mem;

    // --- WB Stage ---
    logic [31:0] pc_curr_wb; 
    logic [31:0] pc_plus4_wb, alu_result_wb, wb_data_final;
    logic [4:0]  rd_addr_wb;
    logic        reg_wren_wb;
    logic [1:0]  wb_sel_wb;

    logic ctrl_wb, mispred_wb, valid_instr_wb;

    // ========================================================================
    // 2. HAZARD UNIT
    // ========================================================================
    hazard_forwarding hazard_unit (
        .i_rs1_addr_id  (rs1_addr_id), 
        .i_rs2_addr_id  (rs2_addr_id),
        .i_rs1_addr_ex  (rs1_addr_ex), 
        .i_rs2_addr_ex  (rs2_addr_ex),
        .i_rd_addr_ex   (rd_addr_ex),  
        .i_rd_addr_dm   (rd_addr_mem), 
        .i_rd_addr_wb   (rd_addr_wb),
        
        .i_reg_wr_dm    (reg_wren_mem), 
        .i_reg_wr_wb    (reg_wren_wb),
        .i_is_load_ex   (wb_sel_ex == 2'b10), 
        
        .i_pc_sel_ex    (pc_redirect_ex),
        .i_rs1_used_id  (rs1_used_id),
        .i_rs2_used_id  (rs2_used_id),
        
        .o_stall_pc_if  (stall_pc), 
        .o_stall_if_id  (stall_if_id),
        .o_clear_if_id  (flush_if_id), 
        .o_clear_id_ex  (flush_id_ex), 
        .o_rs1_sel      (fwd_a_sel), 
        .o_rs2_sel      (fwd_b_sel)
    );

    // ========================================================================
    // 3. STAGE 1: INSTRUCTION FETCH (IF)
    // ========================================================================
    // --- PC Next Multiplexer: EX Redirection > IF Branch Predictor > PC + 4 ---
    always_comb begin
        if (pc_redirect_ex) begin
            // Ưu tiên cao nhất: Sửa sai do Misprediction hoặc Jump từ EX
            pc_next = pc_redirect_target_ex;
        end else if (pred_taken_if) begin
            // Dự đoán Taken từ Branch Predictor (0-cycle penalty)
            pc_next = pred_target_if;
        end else begin
            // Mặc định tuần tự PC + 4
            pc_next = pc_plus4_if;
        end
    end

    PC pc_reg (
        .i_clk   (i_clk), 
        .i_reset (~i_reset), 
        .i_en    (!stall_pc), 
        .i_next  (pc_next), 
        .o_pc    (pc_curr_if)
    );

    pc_plus_four pc_adder (.i_pc(pc_curr_if), .o_pc_plus_four(pc_plus4_if));
    
    Imem imem (
        .i_clk(i_clk), 
        .i_reset(~i_reset), 
        .pc(pc_curr_if), 
        .Rom_mem(instr_if)
    );

    // ========================================================================
    // BRANCH PREDICTOR (Nằm giữa tầng IF và ID)
    // ========================================================================
    // ========================================================================
    // BRANCH PREDICTOR (Nằm giữa tầng IF và ID)
    // ========================================================================
    branch_predictor #(
        .BTB_ENTRIES (256),
        .BHT_DEPTH   (256),
        .RAS_DEPTH   (8),
        .PTR_W       (3)
    ) bp_unit (
        .i_clk          (i_clk),
        .i_reset        (i_reset),

        // --- READ PORT (Stage IF) ---
        .i_pc_if        (pc_curr_if),
        .i_instr_if     (instr_if),
        .o_pred_taken   (pred_taken_if),
        .o_pred_target  (pred_target_if),
        .o_current_ptr  (ras_ptr_if),
        .o_ghr_if       (),

        // --- UPDATE PORT (Stage EX / Execution Feedback) ---
        .i_pc_id        (pc_curr_ex),
        .i_valid_id     (valid_instr_ex),
        .i_is_branch    (is_branch_ex),
        .i_actual_taken (actual_taken_branch),
        .i_target_id    (branch_target_ex),
        .i_is_call      (is_call_ex),
        .i_is_ret       (is_ret_ex),
        .i_ra_id        (call_ret_pc_ex),

        // --- RECOVERY PORT ---
        .i_mispredict   (pc_redirect_ex),
        .i_recovery_ptr (ras_ptr_ex)
    );

    // --- PIPELINE: IF -> ID ---
    always_ff @(posedge i_clk) begin
        if (!i_reset || flush_if_id) begin 
            pc_curr_id     <= 32'b0; 
            pc_plus4_id    <= 32'b0; 
            instr_id       <= 32'b0;
            pred_taken_id  <= 1'b0;
            pred_target_id <= 32'b0;
            ras_ptr_id     <= 3'b0;
        end else if (!stall_if_id) begin
            pc_curr_id     <= pc_curr_if;
            pc_plus4_id    <= pc_plus4_if; 
            instr_id       <= instr_if;
            pred_taken_id  <= pred_taken_if;
            pred_target_id <= pred_target_if;
            ras_ptr_id     <= ras_ptr_if;
        end
    end

    // ========================================================================
    // 4. STAGE 2: INSTRUCTION DECODE (ID)
    // ========================================================================
    assign rs1_addr_id = instr_id[19:15];
    assign rs2_addr_id = instr_id[24:20];
    assign rd_addr_id  = instr_id[11:7];
    assign opcode_id   = instr_id[6:0];
    assign funct3_id   = instr_id[14:12];

    assign rs1_used_id = (opcode_id != 7'b0110111) && (opcode_id != 7'b0010111) && (opcode_id != 7'b1101111);
    assign rs2_used_id = (opcode_id == 7'b0110011) || (opcode_id == 7'b0100011) || (opcode_id == 7'b1100011);

    regfile rf (
        .i_clk(i_clk), 
        .i_reset(~i_reset), 
        .i_rs1_addr(rs1_addr_id), 
        .i_rs2_addr(rs2_addr_id),
        .o_rs1_data(rs1_data_id), 
        .o_rs2_data(rs2_data_id),
        .i_rd_addr(rd_addr_wb),   
        .i_rd_data(wb_data_final), 
        .i_rd_wren(reg_wren_wb)
    );

    immgen img (.i_instr(instr_id), .o_imm(imm_id));

    control_unit cu (
        .i_instr      (instr_id), 
        .o_rd_wren    (reg_wren_id), 
        .o_opa_sel    (op_a_sel_id), 
        .o_opb_sel    (op_b_sel_id), 
        .o_alu_op     (alu_op_id), 
        .o_mem_wren   (mem_wren_id), 
        .o_wb_sel     (wb_sel_id), 
        .o_br_un      (br_un_id), 
        .o_is_branch  (is_branch_id),
        .o_is_jal     (is_jal_id),
        .o_is_jalr    (is_jalr_id),
        .o_valid_instr(valid_instr_id)
    );

    // --- PIPELINE: ID -> EX ---
    always_ff @(posedge i_clk) begin
        if (!i_reset || flush_id_ex) begin
            reg_wren_ex    <= 1'b0; 
            mem_wren_ex    <= 1'b0; 
            wb_sel_ex      <= 2'b0;
            alu_op_ex      <= 4'b0; 
            op_a_sel_ex    <= 1'b0; 
            op_b_sel_ex    <= 1'b0;
            pc_curr_ex     <= 32'b0; 
            pc_plus4_ex    <= 32'b0;
            rs1_data_ex    <= 32'b0; 
            rs2_data_ex    <= 32'b0; 
            imm_ex         <= 32'b0;
            rs1_addr_ex    <= 5'b0; 
            rs2_addr_ex    <= 5'b0; 
            rd_addr_ex     <= 5'b0; 
            funct3_ex      <= 3'b0;
            is_branch_ex   <= 1'b0; 
            is_jal_ex      <= 1'b0; 
            is_jalr_ex     <= 1'b0; 
            br_un_ex       <= 1'b0;
            valid_instr_ex <= 1'b0;
            pred_taken_ex  <= 1'b0;
            pred_target_ex <= 32'b0;
            ras_ptr_ex     <= 3'b0;
        end else begin
            reg_wren_ex    <= reg_wren_id; 
            mem_wren_ex    <= mem_wren_id; 
            wb_sel_ex      <= wb_sel_id;
            alu_op_ex      <= alu_op_id; 
            op_a_sel_ex    <= op_a_sel_id; 
            op_b_sel_ex    <= op_b_sel_id;
            pc_curr_ex     <= pc_curr_id; 
            pc_plus4_ex    <= pc_plus4_id;
            rs1_data_ex    <= rs1_data_id; 
            rs2_data_ex    <= rs2_data_id; 
            imm_ex         <= imm_id;
            rs1_addr_ex    <= rs1_addr_id; 
            rs2_addr_ex    <= rs2_addr_id; 
            rd_addr_ex     <= rd_addr_id; 
            funct3_ex      <= funct3_id;
            is_branch_ex   <= is_branch_id; 
            is_jal_ex      <= is_jal_id; 
            is_jalr_ex     <= is_jalr_id; 
            br_un_ex       <= br_un_id;
            valid_instr_ex <= valid_instr_id;
            pred_taken_ex  <= pred_taken_id;
            pred_target_ex <= pred_target_id;
            ras_ptr_ex     <= ras_ptr_id;
        end
    end

    // ========================================================================
    // 5. STAGE 3: EXECUTE (EX)
    // ========================================================================
    assign mem_fwd_data = (wb_sel_mem == 2'b00) ? pc_plus4_mem : alu_result_mem;

    always_comb begin
        case (fwd_a_sel)
            2'b00: fwd_a_val = rs1_data_ex;
            2'b01: fwd_a_val = mem_fwd_data;
            2'b10: fwd_a_val = wb_data_final;  
            default: fwd_a_val = rs1_data_ex;
        endcase
        case (fwd_b_sel)
            2'b00: fwd_b_val = rs2_data_ex;
            2'b01: fwd_b_val = mem_fwd_data;
            2'b10: fwd_b_val = wb_data_final;
            default: fwd_b_val = rs2_data_ex;
        endcase
    end

    assign alu_op_a = (op_a_sel_ex) ? pc_curr_ex : fwd_a_val;
    assign alu_op_b = (op_b_sel_ex) ? imm_ex      : fwd_b_val;

    alu ALU (.i_op_a(alu_op_a), .i_op_b(alu_op_b), .i_alu_op(alu_op_ex), .o_alu_data(alu_result_ex));

    // --- BRC: Branch Comparator tại tầng EX (Dùng trực tiếp giá trị Forwarded) ---
    brc branch_comp (
        .i_rs1_data(fwd_a_val), 
        .i_rs2_data(fwd_b_val), 
        .i_br_un   (br_un_ex), 
        .o_br_less (br_less_ex), 
        .o_br_equal(br_equal_ex)
    );

    // --- Đánh giá điều kiện rẽ nhánh ---
    always_comb begin
        case (funct3_ex)
            3'b000: br_cond_ex = br_equal_ex;       // BEQ
            3'b001: br_cond_ex = ~br_equal_ex;      // BNE
            3'b100: br_cond_ex = br_less_ex;        // BLT
            3'b101: br_cond_ex = ~br_less_ex;       // BGE
            3'b110: br_cond_ex = br_less_ex;        // BLTU
            3'b111: br_cond_ex = ~br_less_ex;       // BGEU
            default: br_cond_ex = 1'b0;
        endcase
    end

    // --- Đánh giá thực tế và phát hiện Misprediction ---
    assign actual_taken_branch = is_branch_ex & br_cond_ex;
    assign branch_target_ex    = pc_curr_ex + imm_ex;

    // Phát hiện sai dự đoán rẽ nhánh:
    // - Sai hướng (pred_taken != actual_taken)
    // - Hoặc đúng hướng Taken nhưng sai địa chỉ đích trong BTB
    assign is_mispred_branch = is_branch_ex && (
        (pred_taken_ex != actual_taken_branch) ||
        (actual_taken_branch && (pred_target_ex != branch_target_ex))
    );

    // Phát hiện JALR chưa được dự đoán hoặc dự đoán sai địa chỉ (RAS miss / mismatch)
    logic is_mispred_jalr;
    assign is_mispred_jalr = is_jalr_ex && (
        !pred_taken_ex || 
        (pred_target_ex != (alu_result_ex & ~32'b1))
    );

    // Phát hiện JAL chưa được dự đoán hoặc dự đoán sai địa chỉ
    logic is_mispred_jal;
    assign is_mispred_jal = is_jal_ex && (!pred_taken_ex || (pred_target_ex != branch_target_ex));

    // Yêu cầu chuyển hướng PC từ tầng EX:
    // Kích hoạt khi có JALR đoán sai, hoặc JAL đoán sai, hoặc lệnh Branch bị đoán sai
    assign pc_redirect_ex = is_mispred_jalr | is_mispred_jal | is_mispred_branch;

    // Tính toán địa chỉ chuyển hướng sửa sai từ EX:
    always_comb begin
        if (is_mispred_jalr) begin
            pc_redirect_target_ex = alu_result_ex & ~32'b1;
        end else if (is_mispred_jal) begin
            pc_redirect_target_ex = branch_target_ex;
        end else if (is_branch_ex && is_mispred_branch) begin
            // Nếu thực tế là Taken -> Nhảy đến branch_target_ex
            // Nếu thực tế là Not Taken -> Phục hồi về PC kế tiếp (pc_plus4_ex)
            pc_redirect_target_ex = (actual_taken_branch) ? branch_target_ex : pc_plus4_ex;
        end else begin
            pc_redirect_target_ex = pc_plus4_if;
        end
    end

    // --- Tín hiệu debug / thống kê chuyển quyền điều khiển ---
    assign ctrl_ex    = valid_instr_ex & (is_branch_ex | is_jal_ex | is_jalr_ex);
    assign mispred_ex = valid_instr_ex & pc_redirect_ex;

    // --- PIPELINE: EX -> MEM ---
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            reg_wren_mem    <= 1'b0; 
            mem_wren_mem    <= 1'b0; 
            wb_sel_mem      <= 2'b0;
            pc_curr_mem     <= 32'b0; 
            pc_plus4_mem    <= 32'b0; 
            alu_result_mem  <= 32'b0; 
            store_data_mem  <= 32'b0;
            rd_addr_mem     <= 5'b0; 
            funct3_mem      <= 3'b0;
            ctrl_mem        <= 1'b0; 
            mispred_mem     <= 1'b0; 
            valid_instr_mem <= 1'b0;
        end else begin
            reg_wren_mem    <= reg_wren_ex; 
            mem_wren_mem    <= mem_wren_ex; 
            wb_sel_mem      <= wb_sel_ex;
            pc_curr_mem     <= pc_curr_ex; 
            pc_plus4_mem    <= pc_plus4_ex; 
            alu_result_mem  <= alu_result_ex;
            store_data_mem  <= fwd_b_val; 
            rd_addr_mem     <= rd_addr_ex; 
            funct3_mem      <= funct3_ex;
            ctrl_mem        <= ctrl_ex;
            mispred_mem     <= mispred_ex;
            valid_instr_mem <= valid_instr_ex;
        end
    end

    // ========================================================================
    // 6. STAGE 4: MEMORY (MEM)
    // ========================================================================
    lsu LSU (
        .i_clk(i_clk), 
        .i_reset(~i_reset), 
        .i_lsu_addr(alu_result_mem), 
        .i_st_data(store_data_mem), 
        .i_lsu_wren(mem_wren_mem),
        .o_ld_data(ld_data_mem), 
        .i_funct3(funct3_mem), 
        .i_load(wb_sel_mem == 2'b10),
        .o_io_ledr(o_io_ledr), 
        .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0), 
        .o_io_hex1(o_io_hex1), 
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3), 
        .o_io_hex4(o_io_hex4), 
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6), 
        .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd),    
        .i_io_sw(i_io_sw)
    );

    // --- PIPELINE: MEM -> WB ---
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            reg_wren_wb     <= 1'b0; 
            wb_sel_wb       <= 2'b0;
            pc_curr_wb      <= 32'b0; 
            pc_plus4_wb     <= 32'b0; 
            alu_result_wb   <= 32'b0; 
            rd_addr_wb      <= 5'b0;
            ctrl_wb         <= 1'b0; 
            mispred_wb      <= 1'b0; 
            valid_instr_wb  <= 1'b0;
        end else begin
            reg_wren_wb <= reg_wren_mem; wb_sel_wb <= wb_sel_mem;
            pc_curr_wb <= pc_curr_mem; 
            pc_plus4_wb <= pc_plus4_mem; 
            alu_result_wb <= alu_result_mem;
            rd_addr_wb <= rd_addr_mem;
            ctrl_wb <= ctrl_mem;
            mispred_wb <= mispred_mem;
            valid_instr_wb <= valid_instr_mem;
        end
    end
    
    // ========================================================================
    // 7. STAGE 5: WRITE BACK (WB)
    // ========================================================================
    mux4 #(32) mux_wb (
        .d0(pc_plus4_wb), 
        .d1(alu_result_wb), 
        .d2(ld_data_mem), 
        .d3(32'b0),
        .sel(wb_sel_wb), 
        .y(wb_data_final)
    );

    assign o_pc_debug = pc_curr_wb; 
    assign o_insn_vld = valid_instr_wb;
    assign o_ctrl     = ctrl_wb;
    assign o_mispred  = mispred_wb;
endmodule