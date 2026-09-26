//-----------------------------------------------------------------------------
// File          : load_unit_logic.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-26
//
// Description   : Load data formatting unit handling sign-extension and
//                 zero-extension for LB, LH, LW, LBU, and LHU instructions.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module load_unit_logic (
    input  logic [31:0] i_rdata,      // RAM data (byte-aligned from LSU)
    input  logic [31:0] i_addr,       // Address offset (unused in current alignment)
    input  logic [2:0]  i_funct3,     // funct3 load selector
    input  logic        is_load,      // Load operation indicator
    output logic [31:0] o_ld_dataout  // Formatted sign/zero-extended output
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

endmodule : load_unit_logic