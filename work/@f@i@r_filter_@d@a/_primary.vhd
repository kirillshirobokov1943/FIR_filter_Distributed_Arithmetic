library verilog;
use verilog.vl_types.all;
entity FIR_filter_DA is
    generic(
        N               : integer := 16;
        h               : vl_notype
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        x_in            : in     vl_logic;
        vld_in          : in     vl_logic;
        y_out           : out    vl_logic_vector(15 downto 0);
        vld_out         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
    attribute mti_svvh_generic_type of h : constant is 4;
end FIR_filter_DA;
