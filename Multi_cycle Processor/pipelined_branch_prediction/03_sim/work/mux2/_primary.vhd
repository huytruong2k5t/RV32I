library verilog;
use verilog.vl_types.all;
entity mux2 is
    generic(
        W               : integer := 32
    );
    port(
        a               : in     vl_logic_vector;
        b               : in     vl_logic_vector;
        sel             : in     vl_logic;
        y               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of W : constant is 1;
end mux2;
