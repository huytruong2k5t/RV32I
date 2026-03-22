module Or_module(
	 input logic [31:0] Or_A, Or_B,
	 output logic [31:0] Or_kq
);

assign Or_kq = Or_A | Or_B; 
endmodule 