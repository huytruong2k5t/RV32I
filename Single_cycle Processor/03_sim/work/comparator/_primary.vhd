library verilog;
use verilog.vl_types.all;
entity comparator is
    port(
        A               : in     vl_logic_vector(31 downto 0);
        B               : in     vl_logic_vector(31 downto 0);
        less_s          : out    vl_logic;
        less_u          : out    vl_logic
    );
end comparator;
