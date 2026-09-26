library verilog;
use verilog.vl_types.all;
entity control_unit is
    generic(
        ALU_ADD         : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        ALU_SUB         : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        ALU_SLT         : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        ALU_SLTU        : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        ALU_XOR         : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        ALU_OR          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        ALU_AND         : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        ALU_SLL         : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        ALU_SRL         : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        ALU_SRA         : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1);
        ALU_LUI         : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi0)
    );
    port(
        i_instr         : in     vl_logic_vector(31 downto 0);
        i_br_less       : in     vl_logic;
        i_br_equal      : in     vl_logic;
        o_pc_sel        : out    vl_logic;
        o_rd_wren       : out    vl_logic;
        o_opa_sel       : out    vl_logic;
        o_opb_sel       : out    vl_logic;
        o_alu_op        : out    vl_logic_vector(3 downto 0);
        o_mem_wren      : out    vl_logic;
        o_wb_sel        : out    vl_logic_vector(1 downto 0);
        o_br_un         : out    vl_logic;
        o_valid_instr   : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ALU_ADD : constant is 1;
    attribute mti_svvh_generic_type of ALU_SUB : constant is 1;
    attribute mti_svvh_generic_type of ALU_SLT : constant is 1;
    attribute mti_svvh_generic_type of ALU_SLTU : constant is 1;
    attribute mti_svvh_generic_type of ALU_XOR : constant is 1;
    attribute mti_svvh_generic_type of ALU_OR : constant is 1;
    attribute mti_svvh_generic_type of ALU_AND : constant is 1;
    attribute mti_svvh_generic_type of ALU_SLL : constant is 1;
    attribute mti_svvh_generic_type of ALU_SRL : constant is 1;
    attribute mti_svvh_generic_type of ALU_SRA : constant is 1;
    attribute mti_svvh_generic_type of ALU_LUI : constant is 1;
end control_unit;
