library verilog;
use verilog.vl_types.all;
entity load_unit_logic is
    port(
        i_rdata         : in     vl_logic_vector(31 downto 0);
        i_addr          : in     vl_logic_vector(31 downto 0);
        i_funct3        : in     vl_logic_vector(2 downto 0);
        i_opcode        : in     vl_logic_vector(6 downto 0);
        o_ld_dataout    : out    vl_logic_vector(31 downto 0)
    );
end load_unit_logic;
