library verilog;
use verilog.vl_types.all;
entity PC is
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_next          : in     vl_logic_vector(31 downto 0);
        o_pc            : out    vl_logic_vector(31 downto 0)
    );
end PC;
