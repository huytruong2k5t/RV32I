library verilog;
use verilog.vl_types.all;
entity barrel_shifter is
    port(
        \in\            : in     vl_logic_vector(31 downto 0);
        shamt           : in     vl_logic_vector(4 downto 0);
        dir             : in     vl_logic;
        arith           : in     vl_logic;
        \out\           : out    vl_logic_vector(31 downto 0)
    );
end barrel_shifter;
