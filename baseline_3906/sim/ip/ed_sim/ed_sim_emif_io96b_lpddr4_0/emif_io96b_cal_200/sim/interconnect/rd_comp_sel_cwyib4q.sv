// (C) 2001-2025 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.




`timescale 1ps/1ps

module rd_comp_sel_cwyib4q #(
    parameter WIDTH=10,
    parameter PIPELINE_OUT=0,
    parameter PIPELINE_CMP=0
) (
    input           clk,
input [WIDTH:0] in_0, 

    input [WIDTH-1:0] base,
    input [1-1:0] shift_occurred, 
    input [1-1:0] clr,    
    output logic sel,
    output logic [1-1:0] sel_index
);
logic [1-1:0] equal,equal_reg;
logic sel_int;
logic [1-1:0] sel_index_int;
logic [1-1:0] shift_occurred_reg;


compare_eq #( .WIDTH (WIDTH) ) com0 ( .in_a(in_0[WIDTH-1:0]), .in_b(base), .equal(equal[0]) );



generate 
    if (PIPELINE_CMP) begin : PIPELINE_CMP_OUT
        always @ (posedge clk) begin
            equal_reg <= equal;
            shift_occurred_reg <= shift_occurred;
        end
    end
    else begin : NO_PIPELINE_CMP_OUT
        assign equal_reg = equal;
        assign shift_occurred_reg = shift_occurred;
    end
endgenerate

rd_pri_mux_cwyib4q pri_mux (
.in0             (equal_reg[0] && in_0[WIDTH]),

    .shift_index_out (shift_occurred_reg),
    .sel             (sel_int),
    .sel_index       (sel_index_int),
    .clr             (clr)

);

generate
    if (PIPELINE_OUT) begin
        always @ (posedge clk) begin
            sel       <= sel_int;
            sel_index <= sel_index_int;
        end
    end
    else begin
        assign sel = sel_int;
        assign sel_index = sel_index_int;
    end
endgenerate 
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzLG06ab4jKQhkEaGhJMRyaUwZTHdLsqwR2+krxYcSnThhywrg9GAez3IBbZKBRzUly3oaYO0Zfy74chWQjfVHf+y/uvDKNP/4VKANHBLnKxmYxiyDa59ruve33q3Xxn0HTKkJ3aysn8WaXvUXsRGYvRkuDGMZLBolfybvmtrvb3PMU1tWTinO0jQCsHaC2/58ecwaopGUnZhbl/6XGoL5e2+lsKpttXOkf3bKg8sjZ3CXQ7wgtb0L3Nc1K/+9Zx/eNfECvA8Nz7C7A74E6hMMQxv6S+DW0bbW1QCKkVsUCsW5wl6NNnASaxg0e1TBW5Wr/oQIniivQLyZROMzZF3UEi8HsJaBvUz8HOJ51G7rlSbV/o9qfiucoIKHuY29fTR4c7jQXQfSJq7yuR/n7dpG/R5wJ9R+Ik8M+3s6vuhKzc1nDwQEGjYWBW9TYiibgtx4244jT63Fr89wB+LIIJmjazf5JH/AnlzAQnqkasEpTVTW78NSZjOYs4ati1FvvMllQtNw+OGUwDfuYNutWD6DnaflsV2NhFyRDLMAigLSQB58sdPLkgaIWLno1BcMq4TsAR4L1BzqFD+pqTT5tUyxuzgssIrC48WJpuyYKxdo1X9i2m8wxrpgbY/WwzNluYI2uM2bFy0SdfQLxob02lvaTGBt1BzA0gbZMFieVkdiWz19sHN0DrXcqoTgjT8ZvglCGqeUxorEUgGnZK1u7K4u3GrLYe04OyHheRVkn2WvW0NZO6Kfvvp38qDdtBumUbVdPcsOMPe1sZBRTfG2/oexj"
`endif