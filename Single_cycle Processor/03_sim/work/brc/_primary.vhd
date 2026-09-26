library verilog;
use verilog.vl_types.all;
entity brc is
    port(
        i_rs1_data      : in     vl_logic_vector(31 downto 0);
        i_rs2_data      : in     vl_logic_vector(31 downto 0);
        i_br_un         : in     vl_logic;
        o_br_less       : out    vl_logic;
        o_br_equal      : out    vl_logic
    );
end brc;
