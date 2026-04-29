library verilog;
use verilog.vl_types.all;
entity tb is
    generic(
        T               : integer := 10;
        N               : integer := 16
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of T : constant is 1;
    attribute mti_svvh_generic_type of N : constant is 1;
end tb;
