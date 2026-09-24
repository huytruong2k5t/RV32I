library verilog;
use verilog.vl_types.all;
entity hazard_forwarding is
    port(
        i_rs1_addr_id   : in     vl_logic_vector(4 downto 0);
        i_rs2_addr_id   : in     vl_logic_vector(4 downto 0);
        i_rs1_addr_ex   : in     vl_logic_vector(4 downto 0);
        i_rs2_addr_ex   : in     vl_logic_vector(4 downto 0);
        i_rd_addr_ex    : in     vl_logic_vector(4 downto 0);
        i_rd_addr_dm    : in     vl_logic_vector(4 downto 0);
        i_rd_addr_wb    : in     vl_logic_vector(4 downto 0);
        i_reg_wr_dm     : in     vl_logic;
        i_reg_wr_wb     : in     vl_logic;
        i_is_load_ex    : in     vl_logic;
        i_pc_sel_ex     : in     vl_logic;
        i_rs1_used_id   : in     vl_logic;
        i_rs2_used_id   : in     vl_logic;
        o_stall_pc_if   : out    vl_logic;
        o_stall_if_id   : out    vl_logic;
        o_clear_if_id   : out    vl_logic;
        o_clear_id_ex   : out    vl_logic;
        o_rs1_sel       : out    vl_logic_vector(1 downto 0);
        o_rs2_sel       : out    vl_logic_vector(1 downto 0)
    );
end hazard_forwarding;
