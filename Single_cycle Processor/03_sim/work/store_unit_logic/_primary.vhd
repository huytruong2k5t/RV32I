library verilog;
use verilog.vl_types.all;
entity store_unit_logic is
    port(
        i_st_data       : in     vl_logic_vector(31 downto 0);
        i_addr          : in     vl_logic_vector(31 downto 0);
        i_funct3        : in     vl_logic_vector(2 downto 0);
        i_opcode        : in     vl_logic_vector(6 downto 0);
        o_st_data       : out    vl_logic_vector(31 downto 0);
        o_bmask         : out    vl_logic_vector(3 downto 0)
    );
end store_unit_logic;
