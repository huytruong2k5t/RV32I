`timescale 1ns / 1ps
// =============================================================================
// Module Name: de2_top
// Description: Top-level wrapper cho kit Altera DE2 (FPGA Cyclone II EP2C35F672C6)
//              kết nối với bộ xử lý RISC-V Single-Cycle (single_cycle.sv).
//
// Chức năng chính:
//  1. CHIA XUNG CLOCK (Clock Divider):
//     - Hạ tần số từ 50MHz (20ns) xuống 10MHz (100ns) hoặc 5MHz (200ns)
//       giúp triệt tiêu hoàn toàn vi phạm Timing Setup (Slack > 0) trên Cyclone II.
//  2. ĐA CHẾ ĐỘ XUNG NHỊP (Clock Modes qua Switch SW[17:16]):
//     - 2'b00: Auto Fast Clock (10 MHz) - Chạy tốc độ cao ổn định.
//     - 2'b01: Auto Slow Clock (2 Hz)   - Quan sát lệnh chạy chậm tự động.
//     - 2'b1x: Manual Single-Step       - Nhấn nút KEY[1] để chạy từng chu kỳ lệnh.
//  3. LỌC RUNG PHÍM BẤM (Debounce + Edge Detector cho nút nhấn KEY[1]).
//  4. KHỚP NỐI CHÂN NGOẠI VI DE2:
//     - KEY[0]: Reset hệ thống (Active-low: Nhấn = 0 = Reset, Nhả = 1 = Chạy).
//     - SW[15:0]: 16 Switch đầu vào cho CPU.
//     - LEDR[17:0]: 18 LED đỏ hiển thị kết quả từ LSU.
//     - LEDG[7:0]: 8 LED xanh hiển thị kết quả từ LSU; LEDG[8] là Heartbeat LED.
//     - HEX0..HEX7: 8 LED 7 đoạn hiển thị kết quả LSU hoặc debug PC.
// =============================================================================

module de2_top (
    // Xung clock thạch anh 50MHz trên board DE2
    input  logic        CLOCK_50,

    // 4 nút nhấn (Active-Low)
    input  logic [3:0]  KEY,

    // 18 Switch gạt
    input  logic [17:0] SW,

    // 18 LED đỏ, 9 LED xanh
    output logic [17:0] LEDR,
    output logic [8:0]  LEDG,

    // 8 Bộ LED 7-đoạn (Active-Low)
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5,
    output logic [6:0]  HEX6,
    output logic [6:0]  HEX7
);

    // =========================================================================
    // 1. TÍN HIỆU RESET VÀ ĐIỀU KHIỂN
    // =========================================================================
    // KEY[0] trên DE2: Nhấn = 0, Nhả = 1.
    // single_cycle.sv dùng Active-Low reset (if (~i_reset)), do đó đấu trực tiếp!
    logic cpu_reset;
    assign cpu_reset = KEY[0];

    // Chế độ clock chọn bằng 2 Switch trên cùng:
    // SW[17] = 0, SW[16] = 0 -> 10MHz Fast Clock (Chu kỳ 100ns)
    // SW[17] = 0, SW[16] = 1 -> 2Hz Slow Clock (Quan sát LED nhảy)
    // SW[17] = 1             -> Single-Step (Nhấn KEY[1] chạy từng xung)
    wire mode_manual = SW[17];
    wire mode_slow   = SW[16];

    // =========================================================================
    // 2. BỘ CHIA XUNG CLOCK (CLOCK DIVIDERS)
    // =========================================================================

    // --- A. Bộ chia 50MHz -> 10MHz (T = 100ns, an toàn tuyệt đối cho Single-Cycle) ---
    // Đếm từ 0 đến 4 (5 chu kỳ 50MHz = 100ns). Đảo trạng thái mỗi 25 chu kỳ hoặc đếm 0..2
    logic [2:0]  cnt_10mhz;
    logic        clk_10mhz;
    always_ff @(posedge CLOCK_50 or negedge cpu_reset) begin
        if (!cpu_reset) begin
            cnt_10mhz <= 3'd0;
            clk_10mhz <= 1'b0;
        end else begin
            if (cnt_10mhz == 3'd2) begin // Đổi trạng thái sau mỗi 2.5 chu kỳ (50M / 5 = 10M)
                cnt_10mhz <= 3'd0;
                clk_10mhz <= ~clk_10mhz;
            end else begin
                cnt_10mhz <= cnt_10mhz + 1'b1;
            end
        end
    end

    // --- B. Bộ chia 50MHz -> 2Hz (Chu kỳ 0.5s để quan sát trực tiếp bằng mắt) ---
    // 50,000,000 / (2 * 2) = 12,500,000
    logic [24:0] cnt_2hz;
    logic        clk_2hz;
    always_ff @(posedge CLOCK_50 or negedge cpu_reset) begin
        if (!cpu_reset) begin
            cnt_2hz <= 25'd0;
            clk_2hz <= 1'b0;
        end else begin
            if (cnt_2hz == 25'd12_499_999) begin
                cnt_2hz <= 25'd0;
                clk_2hz <= ~clk_2hz;
            end else begin
                cnt_2hz <= cnt_2hz + 1'b1;
            end
        end
    end

    // =========================================================================
    // 3. MẠCH CHỐNG RUNG (DEBOUNCE) & PHÁT 1 XUNG DUY NHẤT CHO SINGLE-STEP
    // =========================================================================
    // KEY[1] dùng để bấm từng bước lệnh (Single-Step)
    logic [19:0] debounce_cnt;
    logic        key1_clean;
    logic        key1_dly;
    logic        step_pulse;

    // Lọc rung trong ~20ms (1,000,000 chu kỳ tại 50MHz)
    always_ff @(posedge CLOCK_50 or negedge cpu_reset) begin
        if (!cpu_reset) begin
            debounce_cnt <= 20'd0;
            key1_clean   <= 1'b1;
        end else begin
            if (KEY[1] != key1_clean) begin
                debounce_cnt <= debounce_cnt + 1'b1;
                if (debounce_cnt == 20'd1_000_000) begin
                    key1_clean   <= KEY[1];
                    debounce_cnt <= 20'd0;
                end
            end else begin
                debounce_cnt <= 20'd0;
            end
        end
    end

    // Phát 1 xung clock hoàn chỉnh khi nhấn KEY[1] (từ 1 xuống 0)
    logic key1_prev;
    logic step_clk;
    always_ff @(posedge CLOCK_50 or negedge cpu_reset) begin
        if (!cpu_reset) begin
            key1_prev <= 1'b1;
            step_clk  <= 1'b0;
        end else begin
            key1_prev <= key1_clean;
            // Khi nhấn nút KEY[1] (falling edge do active-low): kích hoạt xung
            if (key1_prev && !key1_clean) begin
                step_clk <= 1'b1;
            end else begin
                step_clk <= 1'b0;
            end
        end
    end

    // =========================================================================
    // 4. BỘ MUX CHỌN XUNG CLOCK CUỐI CÙNG CẤP CHO CPU
    // =========================================================================
    logic cpu_clk;
    always_comb begin
        if (mode_manual) begin
            cpu_clk = step_clk;
        end else if (mode_slow) begin
            cpu_clk = clk_2hz;
        end else begin
            cpu_clk = clk_10mhz; // 10MHz an toàn
        end
    end

    // =========================================================================
    // 5. KẾT NỐI VỚI MODULE SINGLE_CYCLE (GIỮ NGUYÊN SOURCE CODE GỐC)
    // =========================================================================
    logic [31:0] cpu_sw_in;
    assign cpu_sw_in = {16'h0000, SW[15:0]}; // 16 switch dữ liệu (SW[17:16] dành cho clock mode)

    logic [31:0] cpu_pc_debug;
    logic [31:0] cpu_ledr;
    logic [31:0] cpu_ledg;
    logic [31:0] cpu_lcd;
    logic [6:0]  cpu_hex0, cpu_hex1, cpu_hex2, cpu_hex3;
    logic [6:0]  cpu_hex4, cpu_hex5, cpu_hex6, cpu_hex7;
    logic        cpu_insn_vld;

    single_cycle u_single_cycle (
        .i_clk       (cpu_clk),
        .i_reset     (cpu_reset),
        .i_io_sw     (cpu_sw_in),
        .o_pc_debug  (cpu_pc_debug),
        .o_io_ledr   (cpu_ledr),
        .o_io_ledg   (cpu_ledg),
        .o_io_lcd    (cpu_lcd),
        .o_io_hex0   (cpu_hex0),
        .o_io_hex1   (cpu_hex1),
        .o_io_hex2   (cpu_hex2),
        .o_io_hex3   (cpu_hex3),
        .o_io_hex4   (cpu_hex4),
        .o_io_hex5   (cpu_hex5),
        .o_io_hex6   (cpu_hex6),
        .o_io_hex7   (cpu_hex7),
        .o_insn_vld  (cpu_insn_vld)
    );

    // =========================================================================
    // 6. ÁNH XẠ ĐẦU RA RA CÁC NGOẠI VI TRÊN BOARD DE2
    // =========================================================================
    // 18 LED Đỏ: Map 18 bit thấp của cpu_ledr
    assign LEDR = cpu_ledr[17:0];

    // 9 LED Xanh:
    // - LEDG[7:0]: 8 bit thấp của cpu_ledg
    // - LEDG[8]: Heartbeat LED (nhấp nháy theo xung 2Hz để biết chip đang chạy)
    assign LEDG[7:0] = cpu_ledg[7:0];
    assign LEDG[8]   = clk_2hz;

    // 8 LED 7-đoạn:
    // Mặc định xuất theo LSU của CPU (cpu_hex0..7)
    // Nếu muốn hiển thị PC lên HEX, bạn có thể dễ dàng chuyển đổi
    assign HEX0 = cpu_hex0;
    assign HEX1 = cpu_hex1;
    assign HEX2 = cpu_hex2;
    assign HEX3 = cpu_hex3;
    assign HEX4 = cpu_hex4;
    assign HEX5 = cpu_hex5;
    assign HEX6 = cpu_hex6;
    assign HEX7 = cpu_hex7;

endmodule
