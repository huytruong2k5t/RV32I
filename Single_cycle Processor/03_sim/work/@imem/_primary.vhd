library verilog;
use verilog.vl_types.all;
entity Imem is
    port(
        pc              : in     vl_logic_vector(31 downto 0);
        i_reset         : in     vl_logic;
        i_clk           : in     vl_logic;
        Rom_mem         : out    vl_logic_vector(31 downto 0)
    );
end Imem;
