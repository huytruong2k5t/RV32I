library verilog;
use verilog.vl_types.all;
entity Or_module is
    port(
        Or_A            : in     vl_logic_vector(31 downto 0);
        Or_B            : in     vl_logic_vector(31 downto 0);
        Or_kq           : out    vl_logic_vector(31 downto 0)
    );
end Or_module;
