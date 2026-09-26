library verilog;
use verilog.vl_types.all;
entity pc_plus_four is
    port(
        i_pc            : in     vl_logic_vector(31 downto 0);
        o_pc_plus_four  : out    vl_logic_vector(31 downto 0)
    );
end pc_plus_four;
