//-----------------------------------------------------------------------------
// File          : store_unit_logic.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-26
//
// Description   : Store unit generating byte-aligned write data and byte-enable
//                 masks for SB, SH, and SW instructions.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module store_unit_logic (
    input  logic [31:0] i_st_data,
    input  logic [31:0] i_addr,
    input  logic [2:0]  i_funct3,    // funct3: SB/SH/SW
    output logic [31:0] o_st_data,   // Memory write data
    output logic [3:0]  o_bmask      // Byte-enable mask
);

    logic is_sb;
    logic is_sh;
    logic is_sw;

    assign is_sb = (~i_funct3[2]) & (~i_funct3[1]) & (~i_funct3[0]);
    assign is_sh = (~i_funct3[2]) & (~i_funct3[1]) &  (i_funct3[0]);
    assign is_sw = (~i_funct3[2]) &  (i_funct3[1]) & (~i_funct3[0]);

    // Byte/halfword address offsets
    logic addr_bit0;
    logic addr_bit1;
    assign addr_bit0 = i_addr[0];
    assign addr_bit1 = i_addr[1];

    // Generate write data (o_st_data) and byte mask (o_bmask)
    always_comb begin
        o_st_data = 32'h0;
        o_bmask   = 4'b0000;

        // SB - Store Byte
        if (is_sb) begin
            if (~addr_bit1 & ~addr_bit0) begin
                o_st_data = {24'h0, i_st_data[7:0]};
                o_bmask   = 4'b0001;
            end else if (~addr_bit1 & addr_bit0) begin
                o_st_data = {16'h0, i_st_data[7:0], 8'h0};
                o_bmask   = 4'b0010;
            end else if (addr_bit1 & ~addr_bit0) begin
                o_st_data = {8'h0, i_st_data[7:0], 16'h0};
                o_bmask   = 4'b0100;
            end else if (addr_bit1 & addr_bit0) begin
                o_st_data = {i_st_data[7:0], 24'h0};
                o_bmask   = 4'b1000;
            end
        end

        // SH - Store Halfword
        else if (is_sh) begin
            if (~addr_bit1) begin
                o_st_data = {16'h0, i_st_data[15:0]};
                o_bmask   = 4'b0011;
            end else begin
                o_st_data = {i_st_data[15:0], 16'h0};
                o_bmask   = 4'b1100;
            end
        end

        // SW - Store Word
        else if (is_sw) begin
            o_st_data = i_st_data;
            o_bmask   = 4'b1111;
        end

        else begin
            o_st_data = 32'h0;
            o_bmask   = 4'b0000;
        end
    end

endmodule : store_unit_logic