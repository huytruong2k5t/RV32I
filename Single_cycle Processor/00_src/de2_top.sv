//-----------------------------------------------------------------------------
// File          : de2_top.sv
// Author(s)     : Trương Đào Đan Huy
// Email         : 
// Project       : Single-Cycle RISC-V 32I
// Creation Date : 29/10/2025
//
// Description   : Top-level wrapper for Altera DE2 board (FPGA Cyclone II EP2C35F672C6) interfacing with RISC-V Single-Cycle processor.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module de2_top (
    // 50MHz on-board crystal oscillator
    input  logic        CLOCK_50,

    // 4 Pushbuttons (Active-Low)
    input  logic [3:0]  KEY,

    // 18 Slide switches
    input  logic [17:0] SW,

    // 18 Red LEDs, 9 Green LEDs
    output logic [17:0] LEDR,
    output logic [8:0]  LEDG,

    // 8 Seven-segment displays (Active-Low)
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5,
    output logic [6:0]  HEX6,
    output logic [6:0]  HEX7
);

        // KEY[0] on DE2: Pressed = 0, Released = 1.
    // single_cycle.sv uses Active-Low reset (if (~i_reset)), so wire directly!
    logic cpu_reset;
    assign cpu_reset = KEY[0];

    // Clock mode selected by the top 2 switches:
    // SW[17] = 0, SW[16] = 0 -> 10MHz Fast Clock (100ns period)
    // SW[17] = 0, SW[16] = 1 -> 2Hz Slow Clock (Observe LED transitions)
    // SW[17] = 1             -> Single-Step (Press KEY[1] for single cycle)
    wire mode_manual = SW[17];
    wire mode_slow   = SW[16];

        // --- A. 50MHz -> 10MHz Divider (T = 100ns, safe for Single-Cycle) ---
    // Count from 0 to 4 (5 cycles of 50MHz = 100ns). Toggle output every 2.5 cycles or count 0..2
    logic [2:0]  cnt_10mhz;
    logic        clk_10mhz;
    always_ff @(posedge CLOCK_50 or negedge cpu_reset) begin
        if (!cpu_reset) begin
            cnt_10mhz <= 3'd0;
            clk_10mhz <= 1'b0;
        end else begin
            if (cnt_10mhz == 3'd2) begin // Toggle state every 2.5 cycles (50M / 5 = 10M)
                cnt_10mhz <= 3'd0;
                clk_10mhz <= ~clk_10mhz;
            end else begin
                cnt_10mhz <= cnt_10mhz + 1'b1;
            end
        end
    end

    // --- B. 50MHz -> 2Hz Divider (0.5s period for visual observation) ---
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

        // KEY[1] is used for stepping through instructions (Single-Step)
    logic [19:0] debounce_cnt;
    logic        key1_clean;
    logic        key1_dly;
    logic        step_pulse;

    // Debounce filtering over ~20ms (1,000,000 cycles at 50MHz)
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

    // Generate a single complete clock pulse on KEY[1] press (1 to 0 transition)
    logic key1_prev;
    logic step_clk;
    always_ff @(posedge CLOCK_50 or negedge cpu_reset) begin
        if (!cpu_reset) begin
            key1_prev <= 1'b1;
            step_clk  <= 1'b0;
        end else begin
            key1_prev <= key1_clean;
            // On KEY[1] press (falling edge due to active-low): trigger pulse
            if (key1_prev && !key1_clean) begin
                step_clk <= 1'b1;
            end else begin
                step_clk <= 1'b0;
            end
        end
    end

        logic cpu_clk;
    always_comb begin
        if (mode_manual) begin
            cpu_clk = step_clk;
        end else if (mode_slow) begin
            cpu_clk = clk_2hz;
        end else begin
            cpu_clk = clk_10mhz; // Safe 10MHz
        end
    end

        logic [31:0] cpu_sw_in;
    assign cpu_sw_in = {16'h0000, SW[15:0]}; // 16 data switches (SW[17:16] reserved for clock mode)

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

        // 18 Red LEDs: Map lower 18 bits of cpu_ledr
    assign LEDR = cpu_ledr[17:0];

    // 9 Green LEDs:
    // - LEDG[7:0]: lower 8 bits of cpu_ledg
    // - LEDG[8]: Heartbeat LED (blinks at 2Hz to indicate chip is running)
    assign LEDG[7:0] = cpu_ledg[7:0];
    assign LEDG[8]   = clk_2hz;

    // 8 Seven-segment displays:
    // Defaults to LSU outputs from CPU (cpu_hex0..7)
    // Can also display PC on HEX if desired
    assign HEX0 = cpu_hex0;
    assign HEX1 = cpu_hex1;
    assign HEX2 = cpu_hex2;
    assign HEX3 = cpu_hex3;
    assign HEX4 = cpu_hex4;
    assign HEX5 = cpu_hex5;
    assign HEX6 = cpu_hex6;
    assign HEX7 = cpu_hex7;

endmodule
