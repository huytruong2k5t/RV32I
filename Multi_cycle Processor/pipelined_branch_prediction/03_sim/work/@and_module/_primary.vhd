library verilog;
use verilog.vl_types.all;
entity And_module is
    port(
        And_A           : in     vl_logic_vector(31 downto 0);
        And_B           : in     vl_logic_vector(31 downto 0);
        And_kq          : out    vl_logic_vector(31 downto 0)
    );
end And_module;
