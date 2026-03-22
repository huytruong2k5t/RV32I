module alu (
    input  logic [31:0] i_op_a,
    input  logic [31:0] i_op_b,
    input  logic [3:0]  i_alu_op,
    output logic [31:0] o_alu_data
);

//======OPCODE=====
  parameter 
      ADD  = 4'b0000,
      SUB  = 4'b0001,
      SLT  = 4'b0010,
      SLTU = 4'b0011,
      XOR  = 4'b0100,
      OR   = 4'b0101,
      AND  = 4'b0110,
      SLL  = 4'b0111,
      SRL  = 4'b1000,
      SRA  = 4'b1001,
      LUI  = 4'b1010;

//=====KET QUA TRUNG GIAN======
  logic [31:0] and_kq;
  logic [31:0] or_kq;
  logic [31:0] xor_kq;
  logic sel_sub; 
  assign sel_sub = &(i_alu_op ^~ SUB);
  logic sel_srl;
  assign sel_srl = &(i_alu_op ^~ SRL);
  logic sel_sra;
  assign sel_sra = &(i_alu_op ^~ SRA);
  logic Shfright;
  logic Shfarith;
   assign Shfarith = sel_sra;
  assign Shfright = sel_srl | sel_sra;
  logic [31:0] shft_o;
  logic less_s, less_u;
  wire [31:0] FA_o;
  wire        FA_co;
  logic [31:0] slt_kq  ;
  logic [31:0] sltu_kq ;

//======AND=====
 And_module Khoi_And (
    .And_A  (i_op_a),
    .And_B  (i_op_b),
    .And_kq (and_kq)
  );

//======OR=====
 Or_module Khoi_Or (
    .Or_A  (i_op_a),
    .Or_B  (i_op_b),
    .Or_kq (or_kq)
  );
  
//======XOR=====
 Xor_module Khoi_Xor (
    .Xor_A  (i_op_a),
    .Xor_B  (i_op_b),
    .Xor_kq (xor_kq)
  );  
////=======NHOM CAU LENH ADD/SUB/LUI======
logic [31:0] op_a;
 always_comb begin
 	case(i_alu_op)
	LUI: op_a = 32'b0;
	default: op_a = i_op_a;
	endcase
end

  FA32 FA_32bit (
    .FA32_A  (op_a),
    .FA32_B  (i_op_b),
    .FA32_T  (sel_sub),
    .FA32_S  (FA_o),
    .FA32_C_o(FA_co)
  );

 //======SLT/SLTU==========
  comparator Bo_so_sanh(
    .A(i_op_a), 
	 .B(i_op_b),
    .less_s(less_s), 
	 .less_u(less_u)
  );
  assign slt_kq = {31'b0, less_s};
  assign sltu_kq = {31'b0, less_u};
 
 //====CAC CAU LENH DICH=======
   barrel_shifter Bo_dich_bit(
    .in   (i_op_a),
    .shamt(i_op_b[4:0]),
    .dir  (Shfright),
    .arith(Shfarith),
    .out  (shft_o)
  );

//=====MUX CHON KET QUA======
  always_comb begin
    case (i_alu_op)
      ADD  : o_alu_data = FA_o;
      SUB  : o_alu_data = FA_o;
      SLT  : o_alu_data = slt_kq;
      SLTU : o_alu_data = sltu_kq;
      XOR  : o_alu_data = xor_kq;
      OR   : o_alu_data = or_kq;
      AND  : o_alu_data = and_kq;
      SLL  : o_alu_data = shft_o;
      SRL  : o_alu_data = shft_o;
      SRA  : o_alu_data = shft_o;
      LUI  : o_alu_data = FA_o;
      default: o_alu_data = 32'b0;
    endcase
  end

endmodule: alu


