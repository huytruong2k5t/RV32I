module mux2 #(parameter W=32)(
  input  logic [W-1:0] a,b,
  input  logic         sel,
  output logic [W-1:0] y
); 
assign y = sel ? b : a; 
endmodule