module PC (
    input  logic i_clk,
    input  logic i_reset,
    input  logic i_en,
    input  logic [31:0] i_next,
    output logic [31:0] o_pc
);
    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset)
            o_pc <= 32'b0;
        else if (i_en)
            o_pc <= i_next;
    end
endmodule