library verilog;
use verilog.vl_types.all;
entity scoreboard is
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_io_sw         : in     vl_logic_vector(31 downto 0);
        o_io_ledr       : in     vl_logic_vector(31 downto 0);
        o_io_ledg       : in     vl_logic_vector(31 downto 0);
        o_io_hex0       : in     vl_logic_vector(6 downto 0);
        o_io_hex1       : in     vl_logic_vector(6 downto 0);
        o_io_hex2       : in     vl_logic_vector(6 downto 0);
        o_io_hex3       : in     vl_logic_vector(6 downto 0);
        o_io_hex4       : in     vl_logic_vector(6 downto 0);
        o_io_hex5       : in     vl_logic_vector(6 downto 0);
        o_io_hex6       : in     vl_logic_vector(6 downto 0);
        o_io_hex7       : in     vl_logic_vector(6 downto 0);
        o_io_lcd        : in     vl_logic_vector(31 downto 0);
        o_pc_debug      : in     vl_logic_vector(31 downto 0);
        o_insn_vld      : in     vl_logic
    );
end scoreboard;
