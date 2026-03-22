module Xor_module(
	 input logic [31:0] Xor_A, Xor_B,
	 output logic [31:0] Xor_kq
);

assign Xor_kq = Xor_A ^ Xor_B; 
endmodule 