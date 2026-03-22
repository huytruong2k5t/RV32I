module PC (	
  input  logic        i_clk,
  input  logic        i_reset,    // 1 => reset PC=0
  input  logic [31:0] i_next,
  output logic [31:0] o_pc
);

//==== BAT DAU BO NHO LUON BANG 0 ========
  always_ff @(posedge i_clk) begin
    if (~i_reset) o_pc <= 32'h0000_0000;
    else         o_pc <= i_next;
  end
  
endmodule 