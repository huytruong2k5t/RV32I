module load_unit_logic (
    input  logic [31:0] i_rdata,      // RAM data (đã được byte-align từ LSU)
    input  logic [31:0] i_addr,       // address
    input  logic [2:0]  i_funct3,     // funct3 load
    input  logic        is_load,      // LOAD detect
    output logic [31:0] o_ld_dataout  // sign/zero-extend
);

    always_comb begin
        o_ld_dataout = 32'h0;
        if (is_load) begin
            case (i_funct3)
                3'b000:  o_ld_dataout = {{24{i_rdata[7]}},  i_rdata[7:0]};   // LB
                3'b001:  o_ld_dataout = {{16{i_rdata[15]}}, i_rdata[15:0]};  // LH
                3'b010:  o_ld_dataout = i_rdata;                             // LW
                3'b100:  o_ld_dataout = {24'h0, i_rdata[7:0]};              // LBU
                3'b101:  o_ld_dataout = {16'h0, i_rdata[15:0]};             // LHU
                default: o_ld_dataout = i_rdata;
            endcase
        end
    end

endmodule