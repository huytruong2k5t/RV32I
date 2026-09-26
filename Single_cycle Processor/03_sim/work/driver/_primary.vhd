library verilog;
use verilog.vl_types.all;
entity driver is
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        o_sw_data       : out    vl_logic_vector(31 downto 0)
    );
end driver;
