module load_unit_logic (
    input  logic [31:0] i_rdata,   //  RAM data
    input  logic [31:0] i_addr,    // address
    input  logic [2:0]  i_funct3,  // funct3 load
    input  logic        is_load,  //  LOAD detect
    output logic [31:0] o_ld_dataout  // sign/zero-extend
);

    // (LB, LH, LW, LBU, LHU)
    wire is_lb, is_lh, is_lw, is_lbu, is_lhu;

    assign is_lb  = (~i_funct3[2]) & (~i_funct3[1]) & (~i_funct3[0]);  // 000
    assign is_lh  = (~i_funct3[2]) & (~i_funct3[1]) &  (i_funct3[0]);  // 001
    assign is_lw  = (~i_funct3[2]) &  (i_funct3[1]) & (~i_funct3[0]);  // 010
    assign is_lbu = ( i_funct3[2]) & (~i_funct3[1]) & (~i_funct3[0]);  // 100
    assign is_lhu = ( i_funct3[2]) & (~i_funct3[1]) &  (i_funct3[0]);  // 101

    logic [7:0]  byte_data;
    logic [15:0] half_data;
	 
        always_comb begin
        byte_data = 8'h00;
        half_data = 16'h0000;

        if      ((~i_addr[1]) & (~i_addr[0])) begin
            byte_data = i_rdata[7:0];
            half_data = i_rdata[15:0];    
        end
        else if ((~i_addr[1]) & (i_addr[0])) begin
            byte_data = i_rdata[15:8];
            half_data = i_rdata[15:0];     
        end
        else if ((i_addr[1]) & (~i_addr[0])) begin
            byte_data = i_rdata[23:16];
            half_data = i_rdata[31:16];    
        end
        else if ((i_addr[1]) & (i_addr[0])) begin
            byte_data = i_rdata[31:24];
            half_data = i_rdata[31:16];    
        end
    end


    //sign/zero-extend
    always_comb begin
        o_ld_dataout = 32'h0;

        if (is_load & is_lb)
            o_ld_dataout = {{24{byte_data[7]}}, byte_data};          // LB - sign extend 8→32

        else if (is_load & is_lh)
            o_ld_dataout = {{16{half_data[15]}}, half_data};         // LH - sign extend 16→32

        else if (is_load & is_lw)
            o_ld_dataout = i_rdata;                                  // LW - 32-bit full

        else if (is_load & is_lbu)
            o_ld_dataout = {24'h0, byte_data};                       // LBU - zero extend 8→32

        else if (is_load & is_lhu)
            o_ld_dataout = {16'h0, half_data};                       // LHU - zero extend 16→32
    end

endmodule