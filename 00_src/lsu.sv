module lsu (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_lsu_addr,
    input  logic [31:0] i_st_data,
    input  logic        i_lsu_wren,
	 input  logic [2:0]  i_funct3,  // funct3 -> load/store
    input  logic [6:0]  i_opcode,  // opcode -> LOAD/STORE
    output logic [31:0] o_ld_data,
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

//    localparam ADDR_MEM_TOP = 32'h0000_07FF;

    logic [31:0] data_mem [0:511];
    initial begin 
    $readmemh("../02_test/dmem.dump", data_mem);
    end
    logic [31:0] ledr_reg, ledg_reg, lcd_reg;
    logic [6:0]  hex_reg [0:7];
    logic [29:0]  word_addr;
	 assign word_addr = i_lsu_addr [11:2];
    logic        mem_en, ledr_en, ledg_en, hex30_en, hex74_en, lcd_en, sw_en;


    // ------------------ Address Decoder ------------------
    always_comb begin
        mem_en   = ~(|i_lsu_addr[31:12]);
        ledr_en  = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
                   ( i_lsu_addr[28]) & (~|i_lsu_addr[27:12]);
        ledg_en  = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
                   ( i_lsu_addr[28]) & (~|i_lsu_addr[27:13]) & (i_lsu_addr[12]);
        hex30_en = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
                   ( i_lsu_addr[28]) & (~|i_lsu_addr[27:14]) & (i_lsu_addr[13]) & (~i_lsu_addr[12]);
        hex74_en = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
                   ( i_lsu_addr[28]) & (~|i_lsu_addr[27:14]) & (i_lsu_addr[13]) & (i_lsu_addr[12]);
        lcd_en   = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
                   ( i_lsu_addr[28]) & (~|i_lsu_addr[27:15]) & (i_lsu_addr[14]) & (~i_lsu_addr[13]);
        sw_en    = (~i_lsu_addr[31]) & (~i_lsu_addr[30]) & (~i_lsu_addr[29]) &
                   ( i_lsu_addr[28]) & (~|i_lsu_addr[27:17]) & (i_lsu_addr[16]);
    end
	 
	 // ------------SH,SW,SB detected--------------
		logic [31:0] st_data_logic;
		logic [3:0]  st_mask_logic;

		store_unit_logic u_store (
			 .i_st_data(i_st_data),
			 .i_addr(i_lsu_addr),
			 .i_funct3(i_funct3),
			 .i_opcode(i_opcode),
			 .o_st_data(st_data_logic),
			 .o_bmask(st_mask_logic)
		);

    // ------------------ Write Logic ------------------
    always_ff @(posedge i_clk) begin
        if (~i_reset) begin
            ledr_reg <= 32'h0;
            ledg_reg <= 32'h0;
            lcd_reg  <= 32'h0;
            hex_reg[0] <= 7'b0000000;
				hex_reg[1] <= 7'b0000000;
				hex_reg[2] <= 7'b0000000;
				hex_reg[3] <= 7'b0000000;
				hex_reg[4] <= 7'b0000000;
				hex_reg[5] <= 7'b0000000;
				hex_reg[6] <= 7'b0000000;
				hex_reg[7] <= 7'b0000000;
        end else if (i_lsu_wren) begin
            if (mem_en) begin
					 if (st_mask_logic[0]) data_mem[word_addr][7:0]   <= st_data_logic[7:0];
					 if (st_mask_logic[1]) data_mem[word_addr][15:8]  <= st_data_logic[15:8];
					 if (st_mask_logic[2]) data_mem[word_addr][23:16] <= st_data_logic[23:16];
					 if (st_mask_logic[3]) data_mem[word_addr][31:24] <= st_data_logic[31:24];
				end
            if (ledr_en) ledr_reg <= st_data_logic;
            if (ledg_en) ledg_reg <= st_data_logic;
            if (hex30_en) begin
                hex_reg[0] <= st_data_logic[6:0];
                hex_reg[1] <= st_data_logic[14:8];
                hex_reg[2] <= st_data_logic[22:16];
                hex_reg[3] <= st_data_logic[30:24];
            end
            if (hex74_en) begin
                hex_reg[4] <= st_data_logic[6:0];
                hex_reg[5] <= st_data_logic[14:8];
                hex_reg[6] <= st_data_logic[22:16];
                hex_reg[7] <= st_data_logic[30:24];
            end
            if (lcd_en) lcd_reg <= st_data_logic;
        end
    end

    // ------------------ Read Logic ------------------
    // Load logic
    logic [31:0] ld_data_logic;
    
    always_comb begin
        ld_data_logic = 32'h0;
        if (mem_en)
            ld_data_logic =  data_mem[word_addr];
        else if (sw_en) 
            ld_data_logic = i_io_sw;
        else if (ledr_en) 
            ld_data_logic = ledr_reg;
        else if (ledg_en) 
            ld_data_logic = ledg_reg;
		  else if (hex30_en) 
			 ld_data_logic = {hex_reg[3], 1'b0, hex_reg[2], 1'b0, hex_reg[1], 1'b0, hex_reg[0]};
		  else if (hex74_en)
			 ld_data_logic = {hex_reg[7], 1'b0, hex_reg[6], 1'b0, hex_reg[5], 1'b0, hex_reg[4]};
        else if (lcd_en)
            ld_data_logic = lcd_reg;
    end
	 load_unit_logic u_load (
        .i_rdata  (ld_data_logic),
        .i_addr   (i_lsu_addr),
        .i_funct3 (i_funct3),
        .i_opcode (i_opcode),
        .o_ld_dataout(o_ld_data)
    );
    // ------------------ Peripheral Outputs ------------------
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
endmodule: lsu