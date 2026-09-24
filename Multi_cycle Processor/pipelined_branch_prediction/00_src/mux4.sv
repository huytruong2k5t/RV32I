module mux4 #(parameter W=32)(
  input  logic [W-1:0] d0,d1,d2,d3,
  input  logic [1:0]   sel,
  output logic [W-1:0] y
); always_comb unique case(sel)
    2'b00: y=d0; 
	 2'b01: y=d1; 
	 2'b10: y=d2; 
	 default: y=d3;
  endcase 
  endmodule 
