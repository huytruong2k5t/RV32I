library verilog;
use verilog.vl_types.all;
entity branch_predictor is
    generic(
        BTB_ENTRIES     : integer := 256;
        BHT_DEPTH       : integer := 256;
        RAS_DEPTH       : integer := 8;
        PTR_W           : integer := 3;
        N_ENTRY         : vl_notype;
        IDX_BITS        : integer := 8
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_pc_if         : in     vl_logic_vector(31 downto 0);
        i_instr_if      : in     vl_logic_vector(31 downto 0);
        i_pc_id         : in     vl_logic_vector(31 downto 0);
        i_valid_id      : in     vl_logic;
        i_is_branch     : in     vl_logic;
        i_actual_taken  : in     vl_logic;
        i_target_id     : in     vl_logic_vector(31 downto 0);
        i_is_call       : in     vl_logic;
        i_is_ret        : in     vl_logic;
        i_ra_id         : in     vl_logic_vector(31 downto 0);
        i_mispredict    : in     vl_logic;
        i_recovery_ptr  : in     vl_logic_vector;
        o_pred_taken    : out    vl_logic;
        o_pred_target   : out    vl_logic_vector(31 downto 0);
        o_current_ptr   : out    vl_logic_vector;
        o_ghr_if        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BTB_ENTRIES : constant is 1;
    attribute mti_svvh_generic_type of BHT_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of RAS_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of PTR_W : constant is 1;
    attribute mti_svvh_generic_type of N_ENTRY : constant is 3;
    attribute mti_svvh_generic_type of IDX_BITS : constant is 1;
end branch_predictor;
