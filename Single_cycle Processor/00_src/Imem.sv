module Imem(
   input logic [31:0] pc,
	input logic i_reset,
	input logic i_clk,
   output logic [31:0] Rom_mem
);
	
   logic [31:0] instruction_memory [0:2047]; 

    initial begin
        $readmemh("../02_test/mem.dump", instruction_memory);  
    end
    assign Rom_mem = instruction_memory[pc[31:2]];
endmodule