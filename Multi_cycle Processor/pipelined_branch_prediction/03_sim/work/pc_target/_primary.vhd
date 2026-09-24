library verilog;
use verilog.vl_types.all;
entity pc_target is
    port(
        i_pc_ex         : in     vl_logic_vector(31 downto 0);
        i_pc_plus4_if   : in     vl_logic_vector(31 downto 0);
        i_alu_result    : in     vl_logic_vector(31 downto 0);
        i_imm           : in     vl_logic_vector(31 downto 0);
        i_is_jalr       : in     vl_logic;
        i_pc_sel        : in     vl_logic;
        o_pc_next       : out    vl_logic_vector(31 downto 0)
    );
end pc_target;
