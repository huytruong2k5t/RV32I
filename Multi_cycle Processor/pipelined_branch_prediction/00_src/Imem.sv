//-----------------------------------------------------------------------------
// File          : Imem.sv
// Author(s)     : Trương Đào Đan Huy
// Email         :
// Project       : 32-bit RISC-V Pipelined Processor
// Creation Date : 2025-11-25
//
// Description   : Instruction Memory (ROM) initialized with test hex program.
//-----------------------------------------------------------------------------
// $Source: $
// $Revision: $
// $Log: $

module Imem (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_pc,
    output logic [31:0] o_rom_mem
);

    logic [31:0] instruction_memory [2047:0];

    initial begin
        $readmemh("../02_test/isa_4b.hex", instruction_memory);
    end

    assign o_rom_mem = instruction_memory[i_pc[31:2]];

endmodule : Imem