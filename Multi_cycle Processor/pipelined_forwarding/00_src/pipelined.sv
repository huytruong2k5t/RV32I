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

    // --- ID Stage ---
    logic [31:0] pc_curr_id, pc_plus4_id, instr_id;
    logic [31:0] rs1_data_id, rs2_data_id, imm_id;
    logic [4:0]  rs1_addr_id, rs2_addr_id, rd_addr_id;
    logic [6:0]  opcode_id;
    logic [2:0]  funct3_id;
    
    logic        br_less_id, br_equal_id, br_un_id, br_taken_id;
    logic        reg_wren_id, mem_wren_id, op_a_sel_id, op_b_sel_id, valid_instr_id;
    logic [1:0]  wb_sel_id;
    logic [3:0]  alu_op_id;
    logic [31:0] pc_target_id;
    logic        is_jalr_id;

    logic ctrl_id, mispred_id; 

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
    
    logic ctrl_ex, mispred_ex, valid_instr_ex;

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
    // 0. BOOT STALL LOGIC (STALL ĐỢI LỆNH ĐẦU TIÊN VÀO ID)
    // ========================================================================
    // Logic này ép CPU dừng lại 1 nhịp ngay sau khi Reset để chờ Imem lấy dữ liệu
    logic is_booting;
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            is_booting <= 1'b1; // Đang trong quá trình khởi động
        end else begin
            is_booting <= 1'b0; // Sau nhịp clock đầu tiên, tắt cờ boot
        end
    end
    
    // Tín hiệu Stall thực tế = Stall từ Hazard Unit HOẶC Stall do Boot
    logic stall_pc_final, stall_if_id_final;
    assign stall_pc_final    = stall_pc    | is_booting;
    assign stall_if_id_final = stall_if_id | is_booting;

    // ========================================================================
    // 2. HAZARD UNIT
    // ========================================================================
    hazard_forwarding  hazard_unit (
        .i_rs1_addr_id  (rs1_addr_id), 
        .i_rs2_addr_id  (rs2_addr_id),
        .i_rs1_addr_ex  (rs1_addr_ex), 
        .i_rs2_addr_ex  (rs2_addr_ex),
        .i_rd_addr_ex   (rd_addr_ex),  
        .i_rd_addr_dm   (rd_addr_mem), 
        .i_rd_addr_wb   (rd_addr_wb),
        
        .i_reg_wr_ex    (reg_wren_ex), 
        .i_reg_wr_dm    (reg_wren_mem), 
        .i_reg_wr_wb    (reg_wren_wb),
        .i_is_load_ex   (wb_sel_ex == 2'b10), 
        
        .i_opcode_is_branch (opcode_id == 7'b1100011), 
        .i_opcode_is_jalr   (opcode_id == 7'b1100111), 
        .i_branch_taken     (br_taken_id),
        
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
    
    pc_target calc_pc_next (
        .i_pc_id       (pc_curr_id),
        .i_pc_plus4_if (pc_plus4_if),
        .i_rs1_data    (rs1_data_id),
        .i_imm         (imm_id),
        .i_opcode      (opcode_id),
        .i_br_taken    (br_taken_id),
        .o_pc_next     (pc_next)
    );

    PC pc_reg (
        .i_clk   (i_clk), 
        .i_reset (~i_reset), 
        .i_en    (!stall_pc_final), // SỬA: Dùng stall_pc_final
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

    // --- PIPELINE: IF -> ID ---
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin 
            pc_curr_id <= 0; 
            pc_plus4_id <= 0; 
            instr_id <= 0;
        end else if (flush_if_id) begin
            instr_id <= 0; 
            pc_plus4_id <= 0; 
            // pc_curr_id <= pc_curr_id; // Implicit hold
        end else if (!stall_if_id_final) begin // SỬA: Dùng stall_if_id_final
            pc_curr_id <= pc_curr_if;
            pc_plus4_id <= pc_plus4_if; 
            instr_id <= instr_if;
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

    brc branch_comp (
        .i_rs1_data(rs1_data_id), 
        .i_rs2_data(rs2_data_id),
        .i_br_un(br_un_id), 
        .o_br_less(br_less_id), 
        .o_br_equal(br_equal_id)
    );

    control_unit cu (
        .i_instr(instr_id), 
        .i_br_less(br_less_id), 
        .i_br_equal(br_equal_id),
        .o_pc_sel(br_taken_id),
        .o_rd_wren(reg_wren_id), 
        .o_opa_sel(op_a_sel_id), 
        .o_opb_sel(op_b_sel_id),
        .o_alu_op(alu_op_id), 
        .o_mem_wren(mem_wren_id), 
        .o_wb_sel(wb_sel_id),
        .o_br_un(br_un_id), 
        .o_valid_instr(valid_instr_id)
    );
    // --- Ctrl_id báo hiệu có lệnh rẽ nhánh (jal/jalr/branch) tại tầng ID
    // --- mispred các lệnh rẽ nhánh dự đoán sai (nằm trong phần branch prediction)
    assign ctrl_id = (opcode_id == 7'b1100011) | (opcode_id == 7'b1101111) | (opcode_id == 7'b1100111);
    assign mispred_id = br_taken_id; 

    // --- PIPELINE: ID -> EX ---
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            reg_wren_ex <= 0; mem_wren_ex <= 0; wb_sel_ex <= 0;
            alu_op_ex <= 0; op_a_sel_ex <= 0; op_b_sel_ex <= 0;
            pc_curr_ex <= 0; 
            pc_plus4_ex <= 0;
            rs1_data_ex <= 0; rs2_data_ex <= 0; imm_ex <= 0;
            rs1_addr_ex <= 0; rs2_addr_ex <= 0; rd_addr_ex <= 0; funct3_ex <= 0;
            ctrl_ex <= 0; mispred_ex <= 0; valid_instr_ex <= 0;
        end else if (flush_id_ex) begin
            // Stall/Flush logic
            reg_wren_ex <= 0; mem_wren_ex <= 0; wb_sel_ex <= 0; 
            alu_op_ex <= 0; op_a_sel_ex <= 0; op_b_sel_ex <= 0;
            rs1_data_ex <= 0; rs2_data_ex <= 0; imm_ex <= 0;
            rs1_addr_ex <= 0; rs2_addr_ex <= 0; rd_addr_ex <= 0; 
            ctrl_ex <= 0; mispred_ex <= 0; valid_instr_ex <= 0;
        end else begin
            // Normal
            reg_wren_ex <= reg_wren_id; mem_wren_ex <= mem_wren_id; wb_sel_ex <= wb_sel_id;
            alu_op_ex <= alu_op_id; op_a_sel_ex <= op_a_sel_id; op_b_sel_ex <= op_b_sel_id;
            
            pc_curr_ex <= pc_curr_id; 
            pc_plus4_ex <= pc_plus4_id;
            rs1_data_ex <= rs1_data_id; rs2_data_ex <= rs2_data_id; imm_ex <= imm_id;
            rs1_addr_ex <= rs1_addr_id; rs2_addr_ex <= rs2_addr_id; rd_addr_ex <= rd_addr_id; funct3_ex <= funct3_id;
            
            ctrl_ex <= ctrl_id;
            mispred_ex <= mispred_id;
            valid_instr_ex <= valid_instr_id;
        end
    end

    // ========================================================================
    // 5. STAGE 3: EXECUTE (EX)
    // ========================================================================
    logic [31:0] mem_fwd_data;
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

    // --- PIPELINE: EX -> MEM ---
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            reg_wren_mem <= 0; mem_wren_mem <= 0; wb_sel_mem <= 0;
            pc_curr_mem <= 0; pc_plus4_mem <= 0; 
            alu_result_mem <= 0; store_data_mem <= 0;
            rd_addr_mem <= 0; funct3_mem <= 0;
            ctrl_mem <= 0; mispred_mem <= 0; valid_instr_mem <= 0;
        end else begin
            reg_wren_mem <= reg_wren_ex; mem_wren_mem <= mem_wren_ex; wb_sel_mem <= wb_sel_ex;
            pc_curr_mem <= pc_curr_ex; 
            pc_plus4_mem <= pc_plus4_ex; 
            alu_result_mem <= alu_result_ex;
            store_data_mem <= fwd_b_val; 
            rd_addr_mem <= rd_addr_ex; funct3_mem <= funct3_ex;
            ctrl_mem <= ctrl_ex;
            mispred_mem <= mispred_ex;
            valid_instr_mem <= valid_instr_ex;
        end
    end

    // ========================================================================
    // 6. STAGE 4: MEMORY (MEM)
    // ========================================================================
    lsu LSU (
        .i_clk(i_clk), 
        .i_reset(~i_reset), // Giả sử Active Low Reset, nếu LSU active high
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
            reg_wren_wb <= 0; wb_sel_wb <= 0;
            pc_curr_wb <= 0; pc_plus4_wb <= 0; 
            alu_result_wb <= 0; rd_addr_wb <= 0;
            ctrl_wb <= 0; mispred_wb <= 0; valid_instr_wb <= 0;
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