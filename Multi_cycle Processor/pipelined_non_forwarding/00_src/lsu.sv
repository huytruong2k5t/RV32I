module lsu (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_lsu_addr,
    input  logic [31:0] i_st_data,
    input  logic        i_lsu_wren,
    input  logic [2:0]  i_funct3,
    input  logic        i_load,        
    output logic [31:0] o_ld_data,
    
    // Peripherals
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic [31:0] o_io_lcd,
    input  logic [31:0] i_io_sw
);

    // ========================================================================
    // 1. MEMORY & REGISTERS
    // ========================================================================
    logic [31:0] data_mem [0:16383]; // 64 KiB
    
    initial begin 
        $readmemh("../02_test/dmem.dump", data_mem);
    end

    logic [31:0] ledr_reg, ledg_reg, lcd_reg;
    logic [6:0]  hex_reg [0:7];
    
    // Address decoding
    logic [13:0] word_addr;
    assign word_addr = i_lsu_addr[15:2]; 

    logic mem_en, ledr_en, ledg_en, hex30_en, hex74_en, lcd_en, sw_en;

    // ========================================================================
    // 2. ADDRESS DECODER
    // ========================================================================
    always_comb begin
        mem_en   = ~(|i_lsu_addr[31:16]); 
        ledr_en  = (i_lsu_addr[31:12] == 20'h10000); 
        ledg_en  = (i_lsu_addr[31:12] == 20'h10001); 
        hex30_en = (i_lsu_addr[31:12] == 20'h10002); 
        hex74_en = (i_lsu_addr[31:12] == 20'h10003); 
        lcd_en   = (i_lsu_addr[31:12] == 20'h10004); 
        sw_en    = (i_lsu_addr[31:12] == 20'h10010); 
    end

    // ========================================================================
    // 3. STORE LOGIC
    // ========================================================================
    logic [31:0] st_data_logic;
    logic [3:0]  st_mask_logic;

    store_unit_logic u_store (
        .i_st_data(i_st_data),
        .i_addr(i_lsu_addr),
        .i_funct3(i_funct3),
        .o_st_data(st_data_logic),
        .o_bmask(st_mask_logic)
    );

    // ========================================================================
    // 4. SYNCHRONOUS WRITE
    // ========================================================================
    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            ledr_reg <= 32'h0; ledg_reg <= 32'h0; lcd_reg  <= 32'h0;
            for (int i=0; i<8; i++) hex_reg[i] <= 7'b0;
        end else if (i_lsu_wren) begin
            if (mem_en) begin
                if (st_mask_logic[0]) data_mem[word_addr][7:0]   <= st_data_logic[7:0];
                if (st_mask_logic[1]) data_mem[word_addr][15:8]  <= st_data_logic[15:8];
                if (st_mask_logic[2]) data_mem[word_addr][23:16] <= st_data_logic[23:16];
                if (st_mask_logic[3]) data_mem[word_addr][31:24] <= st_data_logic[31:24];
            end
            if (ledr_en)  ledr_reg <= st_data_logic;
            if (ledg_en)  ledg_reg <= st_data_logic;
            if (hex30_en) begin
                hex_reg[0] <= st_data_logic[6:0]; hex_reg[1] <= st_data_logic[14:8];
                hex_reg[2] <= st_data_logic[22:16]; hex_reg[3] <= st_data_logic[30:24];
            end
            if (hex74_en) begin
                hex_reg[4] <= st_data_logic[6:0]; hex_reg[5] <= st_data_logic[14:8];
                hex_reg[6] <= st_data_logic[22:16]; hex_reg[7] <= st_data_logic[30:24];
            end
            if (lcd_en) lcd_reg <= st_data_logic;
        end
    end

    // ========================================================================
    // 5. READ LOGIC (đồng bộ với ghi nếu đọc từ Memory)
    // ========================================================================
    logic [31:0] io_rdata_comb;
    logic [31:0] rdata_reg; // Thanh ghi lưu dữ liệu đọc (cả RAM và IO)
    
    // 1. Tính toán giá trị IO hiện tại (Combinational)
    always_comb begin
        io_rdata_comb = 32'h0;
        if (sw_en)         io_rdata_comb = i_io_sw;
        else if (ledr_en)  io_rdata_comb = ledr_reg;
        else if (ledg_en)  io_rdata_comb = ledg_reg;
        else if (hex30_en) io_rdata_comb = {hex_reg[3], 1'b0, hex_reg[2], 1'b0, hex_reg[1], 1'b0, hex_reg[0]};
        else if (hex74_en) io_rdata_comb = {hex_reg[7], 1'b0, hex_reg[6], 1'b0, hex_reg[5], 1'b0, hex_reg[4]};
        else if (lcd_en)   io_rdata_comb = lcd_reg;
    end

    // 2. Control Pipeline Registers
    logic [2:0] funct3_reg;
    logic       load_reg;
    logic [1:0] addr_offset_reg; 

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            rdata_reg <= 0;
            funct3_reg <= 0;
            load_reg <= 0;
            addr_offset_reg <= 0;
        end else begin
            // SỬA: Chọn nguồn dữ liệu để lưu vào thanh ghi
            if (mem_en) 
                rdata_reg <= data_mem[word_addr]; // Đọc RAM
            else 
                rdata_reg <= io_rdata_comb;       // Đọc IO (Lưu lại giá trị lúc sw_en=1)

            // Lưu tín hiệu điều khiển
            funct3_reg <= i_funct3;
            load_reg   <= i_load;
            addr_offset_reg <= i_lsu_addr[1:0];
        end
    end
    
    // 3. Load Unit Logic (Sử dụng dữ liệu đã Register)
    load_unit_logic u_load (
        .i_rdata  (rdata_reg),                // Dữ liệu cần được vào module load lọc lại
        .i_addr   ({30'b0, addr_offset_reg}), 
        .i_funct3 (funct3_reg),               
        .is_load  (load_reg),                 
        .o_ld_dataout(o_ld_data)
    );

    // Outputs
    assign o_io_ledr = ledr_reg;
    assign o_io_ledg = ledg_reg;
    assign o_io_lcd  = lcd_reg;
    assign o_io_hex0 = hex_reg[0];
    assign o_io_hex1 = hex_reg[1];
    assign o_io_hex2 = hex_reg[2];
    assign o_io_hex3 = hex_reg[3];
    assign o_io_hex4 = hex_reg[4];
    assign o_io_hex5 = hex_reg[5];
    assign o_io_hex6 = hex_reg[6];
    assign o_io_hex7 = hex_reg[7];

endmodule