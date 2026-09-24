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

    always_comb begin
        // Output 1
        if (i_rs1_addr == 5'b0) 
            o_rs1_data = 32'b0;
        else 
            o_rs1_data = register_rf[i_rs1_addr];

        // Output 2
        if (i_rs2_addr == 5'b0) 
            o_rs2_data = 32'b0;
        else 
            o_rs2_data = register_rf[i_rs2_addr];
    end

    always_ff @(negedge i_clk) begin
        if (i_reset) begin
            // Reset toàn bộ về 0
            for (i = 0; i < 32; i = i + 1) begin
                register_rf[i] <= 32'b0;
            end
        end 
        else if (i_rd_wren && (i_rd_addr != 5'b0)) begin
            // Chỉ ghi khi Enable bật VÀ địa chỉ khác 0 (Bảo vệ x0)
            register_rf[i_rd_addr] <= i_rd_data;
        end
    end

endmodule