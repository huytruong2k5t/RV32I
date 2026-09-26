library verilog;
use verilog.vl_types.all;
entity Xor_module is
    port(
        Xor_A           : in     vl_logic_vector(31 downto 0);
        Xor_B           : in     vl_logic_vector(31 downto 0);
        Xor_kq          : out    vl_logic_vector(31 downto 0)
    );
end Xor_module;
