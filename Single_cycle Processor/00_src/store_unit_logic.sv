module store_unit_logic (
    input  logic [31:0] i_st_data,  
    input  logic [31:0] i_addr,      
    input  logic [2:0]  i_funct3,    // funct3:  SB/SH/SW
    input  logic [6:0]  i_opcode,    // opcode STORE
    output logic [31:0] o_st_data,   //  memory
    output logic [3:0]  o_bmask      // byte-enable mask
);

    logic is_store;
    //assign is_store = (~i_opcode[6]) & (i_opcode[5]) & (~i_opcode[4]) & (~i_opcode[3]) & (~i_opcode[2]) & (i_opcode[1]) & (i_opcode[0]);
    // Opcode = 0100011

    // (000 = SB, 001 = SH, 010 = SW)

    logic is_sb, is_sh, is_sw;
    assign is_sb = (~i_funct3[2]) & (~i_funct3[1]) & (~i_funct3[0]);
    assign is_sh = (~i_funct3[2]) & (~i_funct3[1]) &  (i_funct3[0]);
    assign is_sw = (~i_funct3[2]) &  (i_funct3[1]) & (~i_funct3[0]);


    //byte/halfword
    logic addr_bit0, addr_bit1;
    assign addr_bit0 = i_addr[0];
    assign addr_bit1 = i_addr[1];

    //Tạo dữ liệu ghi (o_st_data) và mặt nạ byte (o_bmask)
    always_comb begin
        o_st_data = 32'h0;
        o_bmask   = 4'b0000;

        // Lệnh SB - Store Byte
        if (is_sb) begin
            if (~addr_bit1 & ~addr_bit0) begin
                o_st_data = {24'h0, i_st_data[7:0]};
                o_bmask   = 4'b0001;
            end
            else if (~addr_bit1 & addr_bit0) begin
                o_st_data = {16'h0, i_st_data[7:0], 8'h0};
                o_bmask   = 4'b0010;
            end
            else if (addr_bit1 & ~addr_bit0) begin
                o_st_data = {8'h0, i_st_data[7:0], 16'h0};
                o_bmask   = 4'b0100;
            end
            else if (addr_bit1 & addr_bit0) begin
                o_st_data = {i_st_data[7:0], 24'h0};
                o_bmask   = 4'b1000;
            end
        end

        // Lệnh SH - Store Halfword
        else if (is_sh) begin
            if (~addr_bit1) begin
                o_st_data = {16'h0, i_st_data[15:0]};
                o_bmask   = 4'b0011;
            end
            else begin
                o_st_data = {i_st_data[15:0], 16'h0};
                o_bmask   = 4'b1100;
            end
        end

        // Lệnh SW - Store Word
        else if (is_sw) begin
            o_st_data = i_st_data;
            o_bmask   = 4'b1111;
        end

        else begin
            o_st_data = 32'h0;
            o_bmask   = 4'b0000;
        end
    end

endmodule