library verilog;
use verilog.vl_types.all;
entity FA32 is
    port(
        FA32_A          : in     vl_logic_vector(31 downto 0);
        FA32_B          : in     vl_logic_vector(31 downto 0);
        FA32_T          : in     vl_logic;
        FA32_S          : out    vl_logic_vector(31 downto 0);
        FA32_C_o        : out    vl_logic
    );
end FA32;
