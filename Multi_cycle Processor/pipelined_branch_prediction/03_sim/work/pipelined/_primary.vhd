library verilog;
use verilog.vl_types.all;
entity pipelined is
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_io_sw         : in     vl_logic_vector(31 downto 0);
        o_io_lcd        : out    vl_logic_vector(31 downto 0);
        o_io_ledr       : out    vl_logic_vector(31 downto 0);
        o_io_ledg       : out    vl_logic_vector(31 downto 0);
        o_io_hex0       : out    vl_logic_vector(6 downto 0);
        o_io_hex1       : out    vl_logic_vector(6 downto 0);
        o_io_hex2       : out    vl_logic_vector(6 downto 0);
        o_io_hex3       : out    vl_logic_vector(6 downto 0);
        o_io_hex4       : out    vl_logic_vector(6 downto 0);
        o_io_hex5       : out    vl_logic_vector(6 downto 0);
        o_io_hex6       : out    vl_logic_vector(6 downto 0);
        o_io_hex7       : out    vl_logic_vector(6 downto 0);
        o_pc_debug      : out    vl_logic_vector(31 downto 0);
        o_insn_vld      : out    vl_logic;
        o_ctrl          : out    vl_logic;
        o_mispred       : out    vl_logic
    );
end pipelined;
