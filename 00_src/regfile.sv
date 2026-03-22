module regfile (
  input  logic        i_clk,
  input  logic        i_reset,
  input  logic [4:0]  i_rs1_addr,
  input  logic [4:0]  i_rs2_addr,
  input  logic [4:0]  i_rd_addr, 
  input  logic [31:0] i_rd_data,
  input  logic        i_rd_wren,
  output logic [31:0] o_rs1_data,
  output logic [31:0] o_rs2_data
);

  logic [31:0] register_rf [31:0];
  integer i;

  // Output read ports
  always_comb begin
    //output 1
    o_rs1_data = register_rf[i_rs1_addr];
	 //output 2
    o_rs2_data = register_rf[i_rs2_addr];
  end

  // Write & Reset
  always_ff @(posedge i_clk) begin
    if (!i_reset) begin
      // Reset all registers to 0
      for (i = 0; i < 32; i = i + 1)
        register_rf[i] <= 32'b0;
    end 
	 else if (i_rd_wren && (i_rd_addr != 5'b0)) begin
      // Write if not x0
      register_rf[i_rd_addr] <= i_rd_data;
    end
  end

endmodule
         