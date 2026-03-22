module control_unit (
    input  logic [31:0] i_instr,
    input  logic        i_br_less,
    input  logic        i_br_equal,
    output logic        o_pc_sel,
    output logic        o_rd_wren,
    output logic        o_opa_sel,
    output logic        o_opb_sel,
    output logic [3:0]  o_alu_op,
    output logic        o_mem_wren,
    output logic [1:0]  o_wb_sel,
    output logic        o_br_un,
    output logic        o_valid_instr
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    assign opcode = i_instr[6:0];
    assign funct3 = i_instr[14:12];
    assign funct7 = i_instr[31:25];

//========= DINH NGHIA HAM ===============
    parameter 
      ALU_ADD  = 4'b0000,
      ALU_SUB  = 4'b0001,
      ALU_SLT  = 4'b0010,
      ALU_SLTU = 4'b0011,
      ALU_XOR  = 4'b0100,
      ALU_OR   = 4'b0101,
      ALU_AND  = 4'b0110,
      ALU_SLL  = 4'b0111,
      ALU_SRL  = 4'b1000,
      ALU_SRA  = 4'b1001,
      ALU_LUI  = 4'b1010;

    always_comb begin
	 o_rd_wren     = 1'b0;
    o_mem_wren    = 1'b0;
    o_opa_sel     = 1'b0;
    o_opb_sel     = 1'b0;
    o_alu_op      = ALU_ADD;
    o_wb_sel      = 2'b00;
    o_br_un       = 1'b0;
    o_pc_sel      = 1'b1;
    o_valid_instr = 1'b0;
//====== XU LI OPCODE R-TYPE========        
         case (opcode)
            7'b0110011: begin
                o_rd_wren = 1'b1;   
                o_opa_sel = 1'b1;   
                o_opb_sel = 1'b0;   
					 o_br_un    = 1'b0;
                o_mem_wren = 1'b0;  
                o_wb_sel = 2'b01;   
					o_valid_instr = 1'b1;
                 case (funct3)
                    3'b000: begin
                        
                        if (funct7 == 7'b0100000) begin
                            o_alu_op = 4'b0001;
                        end else begin
                            o_alu_op = 4'b0000;
                        end
                    end
                    3'b001: o_alu_op = ALU_SLL;
                    3'b010: o_alu_op = ALU_SLT;
                    3'b011: o_alu_op = ALU_SLTU;
                    3'b100: o_alu_op = ALU_XOR;
                    3'b101: begin
                        
                        if (funct7 == 7'b0100000) begin
                            o_alu_op = ALU_SRA;
                        end else begin
                            o_alu_op = ALU_SRL;
                        end
                    end
                    3'b110: o_alu_op = ALU_OR;
                    3'b111: o_alu_op = ALU_AND;
                    default: o_alu_op = ALU_ADD;
                endcase
                o_pc_sel = 1'b1;    
            end

//======= XU LY OPCODE I-TYPE===========        
            7'b0010011: begin

		  o_rd_wren  = 1'b1;
		  o_opa_sel  = 1'b1;   
		  o_opb_sel  = 1'b1;   
		  o_mem_wren = 1'b0;
		  o_wb_sel   = 2'b01; 
		  o_pc_sel   = 1'b1;  
		  o_br_un    = 1'b0;
		  o_valid_instr = 1'b1;



			case (funct3)

			 3'b000: o_alu_op = ALU_ADD;   

			 3'b010: o_alu_op = ALU_SLT;  

			 3'b011: o_alu_op = ALU_SLTU;  

			 3'b100: o_alu_op = ALU_XOR;   

			 3'b110: o_alu_op = ALU_OR;    

			 3'b111: o_alu_op = ALU_AND;   

			 3'b001: begin

				if (i_instr[31:25]==7'b0000000) 
			o_alu_op = ALU_SLL;

				else o_valid_instr = 1'b0;

			 end

			 3'b101: begin 

				if      (i_instr[31:25]==7'b0000000) 
			o_alu_op = ALU_SRL;

				else if (i_instr[31:25]==7'b0100000) 
			o_alu_op = ALU_SRA;

			 end

			 default: o_valid_instr = 1'b0;

		  endcase

		end

		//====== XU LY LENH LOAD==========
						7'b0000011: begin
							 o_rd_wren  = 1'b1;   
							 o_opa_sel  = 1'b1;   
							 o_opb_sel  = 1'b1; 
							 o_alu_op   = ALU_ADD; 
							 o_mem_wren = 1'b0;   
							 o_wb_sel   = 2'b10; 
							 o_br_un    = 1'b0;
							 o_pc_sel   = 1'b1;
				o_valid_instr = 1'b1;
						end

		 //========== XU LY LENH S-TYPE==========          
						7'b0100011: begin
							 o_rd_wren  = 1'b0;   
							 o_opa_sel  = 1'b1;   
							 o_opb_sel  = 1'b1;   
							 o_alu_op   = ALU_ADD; 
							 o_mem_wren = 1'b1;   
							 o_wb_sel   = 2'b11;  
							 o_pc_sel   = 1'b1;
				o_valid_instr = 1'b1;
						end

//========= XU LY LENH B-TYPE ==============  
            7'b1100011: begin

                o_rd_wren  = 1'b0;
                o_mem_wren = 1'b0;

                o_opa_sel  = 1'b0;   
                o_opb_sel  = 1'b1;   
                o_alu_op   = ALU_ADD;
                o_wb_sel   = 2'b01;  
		o_valid_instr = 1'b1;

                if (funct3 == 3'b110 || funct3 == 3'b111) begin
                    o_br_un = 1'b0;
                end else begin
                    o_br_un = 1'b1;
                end
  
             
                 case (funct3)
                    3'b000: o_pc_sel = ~i_br_equal;       
                    3'b001: o_pc_sel = i_br_equal;     
                    3'b100: o_pc_sel = ~i_br_less;       
                    3'b101: o_pc_sel = i_br_less;       
                    3'b110: o_pc_sel = ~i_br_less;      
                    3'b111: o_pc_sel = i_br_less;      
                    default: o_pc_sel = 1'b1;
                endcase
            end

//========= XU LY LENH JAL ===========
            7'b1101111: begin
                o_rd_wren  = 1'b1;   
                o_opa_sel  = 1'b0;   
                o_opb_sel  = 1'b1;   
                o_alu_op   = ALU_ADD; 
                o_mem_wren = 1'b1;
                o_wb_sel   = 2'b00;  
                o_br_un    = 1'b0;
                o_pc_sel   = 1'b0;   
		o_valid_instr = 1'b1;
            end

//========= XU LY LENH JARL ===========
            7'b1100111: begin
                o_rd_wren  = 1'b1;   
                o_opa_sel  = 1'b1;   
                o_opb_sel  = 1'b1;   
                o_alu_op   = ALU_ADD; 
                o_mem_wren = 1'b0;
                o_wb_sel   = 2'b01;  
                o_br_un    = 1'b0;
                o_pc_sel   = 1'b0;   
		o_valid_instr = 1'b1;
            end

//========== XU LY LENH U-TYPE ==========
            7'b0110111: begin
                o_rd_wren  = 1'b1;
 
                o_opa_sel  = 1'b0;
                o_opb_sel  = 1'b1;
                o_alu_op   = ALU_LUI;
                o_mem_wren = 1'b0;
                o_wb_sel   = 2'b01;  
                o_pc_sel   = 1'b1;
		o_valid_instr = 1'b1;
            end

//========= XU LY AUIPC ===========
            7'b0010111: begin
                o_rd_wren  = 1'b1;
                o_opa_sel  = 1'b0;   
                o_opb_sel  = 1'b1;   
                o_alu_op   = ALU_ADD;
                o_mem_wren = 1'b0;
                o_wb_sel   = 2'b01;  
                o_pc_sel   = 1'b1;
		o_valid_instr = 1'b1;
            end

//========= CAC TRUONG HOP KHAC =================
					default: begin
               
                o_rd_wren     = 1'b0;
                o_mem_wren    = 1'b0;
                o_opa_sel     = 1'b0;
                o_opb_sel     = 1'b0;
                o_alu_op      = ALU_ADD;
                o_wb_sel      = 2'b00;
                o_br_un       = 1'b0;
                o_pc_sel      = 1'b1;
                o_valid_instr = 1'b0;
            end
        endcase
    end
endmodule 