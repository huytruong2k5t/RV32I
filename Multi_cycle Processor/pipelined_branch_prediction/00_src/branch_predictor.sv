//-----------------------------------------------------------------------------
// File          : branch_predictor.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-29
//
// Description   : Dynamic branch predictor integrating G-share Branch History
//                 Table (BHT), Branch Target Buffer (BTB), and Return Address
//                 Stack (RAS) to minimize branch penalties.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module branch_predictor #(
    parameter BTB_ENTRIES = 256,
    parameter BHT_DEPTH   = 256,
    parameter RAS_DEPTH   = 8,
    parameter PTR_W       = 3,
    parameter N_ENTRY     = BTB_ENTRIES,
    parameter IDX_BITS    = 8
)(
    input  logic                     i_clk,
    input  logic                     i_reset,

    // READ PORT (IF Stage)
    input  logic [31:0]              i_pc_if,
    input  logic [31:0]              i_instr_if,

    // UPDATE PORT (EX Stage / Execution Feedback)
    input  logic [31:0]              i_pc_id,
    input  logic                     i_valid_id,
    input  logic                     i_is_branch,
    input  logic                     i_actual_taken,
    input  logic [31:0]              i_target_id,
    input  logic                     i_is_call,
    input  logic                     i_is_ret,
    input  logic [31:0]              i_ra_id,

    // RECOVERY PORT
    input  logic                     i_mispredict,
    input  logic [PTR_W-1:0]         i_recovery_ptr,

    // OUTPUT SIGNALS (Predictions for IF Stage)
    output logic                     o_pred_taken,
    output logic [31:0]              o_pred_target,
    output logic [PTR_W-1:0]         o_current_ptr,
    output logic [IDX_BITS-1:0]      o_ghr_if
);

    // ========================================================================
    // 1. MEMORY STRUCTURES (BHT, BTB, GHR, RAS)
    // ========================================================================
    logic [1:0] bht [BHT_DEPTH-1:0];
    logic [31:0] btb [BTB_ENTRIES-1:0];

    localparam TAG_WIDTH = 32 - IDX_BITS - 2;
    logic [TAG_WIDTH-1:0] tag_mem [BTB_ENTRIES-1:0];
    logic                 valid_mem [BTB_ENTRIES-1:0];

    // GHR: Global History Register for G-share architecture
    logic [IDX_BITS-1:0] ghr;
    assign o_ghr_if = ghr;

    // RAS: Return Address Stack
    logic [31:0] ras_stack [RAS_DEPTH-1:0];
    logic [PTR_W-1:0] ras_ptr;
    logic [$clog2(RAS_DEPTH):0] ras_count;
    assign o_current_ptr = ras_ptr;

    // ========================================================================
    // 2. G-SHARE INDEX CALCULATION (PC XOR GHR)
    // ========================================================================
    wire [IDX_BITS-1:0] read_idx   = i_pc_if[IDX_BITS+1:2] ^ ghr;
    wire [IDX_BITS-1:0] update_idx = i_pc_id[IDX_BITS+1:2] ^ ghr;

    // ========================================================================
    // 3. FAST DECODE FOR JAL, RET, AND BRANCH AT IF STAGE
    // ========================================================================
    logic is_jal_if;
    logic [31:0] jal_imm;
    logic [31:0] jal_target_if;
    assign is_jal_if     = (i_instr_if[6:0] == 7'b1101111);
    assign jal_imm       = {{12{i_instr_if[31]}}, i_instr_if[19:12], i_instr_if[20], i_instr_if[30:21], 1'b0};
    assign jal_target_if = i_pc_if + jal_imm;

    logic is_ret_if;
    assign is_ret_if = (i_instr_if[6:0] == 7'b1100111) &&
                       (i_instr_if[11:7] == 5'd0)      &&
                       (i_instr_if[19:15] == 5'd1 || i_instr_if[19:15] == 5'd5);

    logic is_branch_if;
    logic [31:0] branch_imm;
    logic [31:0] branch_target_if;
    assign is_branch_if     = (i_instr_if[6:0] == 7'b1100011);
    assign branch_imm       = {{20{i_instr_if[31]}}, i_instr_if[7], i_instr_if[30:25], i_instr_if[11:8], 1'b0};
    assign branch_target_if = i_pc_if + branch_imm;

    // ========================================================================
    // 4. PREDICTION LOGIC (IF Stage - Combinational)
    // ========================================================================
    wire [PTR_W-1:0] ras_top_idx = ras_ptr - 1'b1;

    always_comb begin
        o_pred_taken  = 1'b0;
        o_pred_target = 32'b0;

        if (is_ret_if && (ras_count > 0)) begin
            // PRIORITY 1: RET instruction uses top of RAS
            o_pred_taken  = 1'b1;
            o_pred_target = ras_stack[ras_top_idx];
        end else if (is_jal_if) begin
            // PRIORITY 2: JAL computes immediate target directly (0-cycle penalty)
            o_pred_taken  = 1'b1;
            o_pred_target = jal_target_if;
        end else if (is_branch_if) begin
            // PRIORITY 3: Conditional Branch predicted via G-share BHT
            if (bht[read_idx] >= 2'b10) begin
                o_pred_taken  = 1'b1;
                o_pred_target = branch_target_if;
            end
        end
    end

    // ========================================================================
    // 5. UPDATE & RESET LOGIC (Execution Feedback)
    // ========================================================================
    integer k;
    always_ff @(negedge i_clk) begin
        if (!i_reset) begin
            for (k = 0; k < BHT_DEPTH; k = k + 1) begin
                bht[k]       <= 2'b01; // Weakly Not Taken
                btb[k]       <= 32'b0;
                tag_mem[k]   <= '0;
                valid_mem[k] <= 1'b0;
            end
            ghr       <= '0;
            ras_ptr   <= '0;
            ras_count <= '0;
            for (k = 0; k < RAS_DEPTH; k = k + 1) begin
                ras_stack[k] <= 32'b0;
            end
        end else begin
            // --- A. UPDATE RETURN ADDRESS STACK (RAS) ---
            if (i_is_call) begin
                ras_stack[ras_ptr] <= i_ra_id;
                ras_ptr            <= ras_ptr + 1'b1;
                if (ras_count < RAS_DEPTH) begin
                    ras_count <= ras_count + 1'b1;
                end
            end else if (i_is_ret) begin
                if (ras_count > 0) begin
                    ras_ptr   <= ras_ptr - 1'b1;
                    ras_count <= ras_count - 1'b1;
                end
            end

            // --- B. UPDATE G-SHARE BHT & BTB ---
            if (i_valid_id && i_is_branch) begin
                tag_mem[update_idx]   <= i_pc_id[31:IDX_BITS+2];
                valid_mem[update_idx] <= 1'b1;
                btb[update_idx]       <= i_target_id;

                // 2-bit Saturating Counter Update
                if (i_actual_taken) begin
                    if (bht[update_idx] != 2'b11) begin
                        bht[update_idx] <= bht[update_idx] + 2'b01;
                    end
                end else begin
                    if (bht[update_idx] != 2'b00) begin
                        bht[update_idx] <= bht[update_idx] - 2'b01;
                    end
                end

                // GHR Update
                ghr <= {ghr[IDX_BITS-2:0], i_actual_taken};
            end
        end
    end

endmodule : branch_predictor