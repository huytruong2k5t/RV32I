library verilog;
use verilog.vl_types.all;
entity immgen is
    port(
        i_instr         : in     vl_logic_vector(31 downto 0);
        o_imm           : out    vl_logic_vector(31 downto 0)
    );
end immgen;
