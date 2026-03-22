module FA(
    input logic FA_a, FA_b, C_i,
	 output logic FA_S, C_o
);
    assign FA_S= FA_a ^ FA_b ^ C_i;
	 assign C_o = (FA_a & FA_b) | (FA_a & C_i) | (FA_b & C_i);
endmodule

