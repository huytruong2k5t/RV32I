library verilog;
use verilog.vl_types.all;
entity FA is
    port(
        FA_a            : in     vl_logic;
        FA_b            : in     vl_logic;
        C_i             : in     vl_logic;
        FA_S            : out    vl_logic;
        C_o             : out    vl_logic
    );
end FA;
