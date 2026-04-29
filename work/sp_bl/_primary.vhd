library verilog;
use verilog.vl_types.all;
entity sp_bl is
    generic(
        N               : integer := 16;
        h0              : vl_logic_vector(15 downto 0);
        h1              : vl_logic_vector(15 downto 0);
        h2              : vl_logic_vector(15 downto 0);
        h3              : vl_logic_vector(15 downto 0)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        x_in            : in     vl_logic;
        vld_in          : in     vl_logic;
        y               : out    vl_logic_vector(26 downto 0);
        cnt             : in     vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
    attribute mti_svvh_generic_type of h0 : constant is 6;
    attribute mti_svvh_generic_type of h1 : constant is 6;
    attribute mti_svvh_generic_type of h2 : constant is 6;
    attribute mti_svvh_generic_type of h3 : constant is 6;
end sp_bl;
