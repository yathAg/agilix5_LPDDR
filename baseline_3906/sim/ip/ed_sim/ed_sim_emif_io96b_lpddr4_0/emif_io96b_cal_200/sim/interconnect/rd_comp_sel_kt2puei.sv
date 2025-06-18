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

module rd_comp_sel_kt2puei #(
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

rd_pri_mux_kt2puei pri_mux (
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
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOxfM5DhjE7RailPT4M8d0Oiq6DWZz/VMyom7mDd7lSjd2TQCTbn3HDDBaj6AX8F9QgyyCzN3OUcKsVKY9+r7lH4Hhsy5MDNPIIOBcnORzjcK6u8oVZ44IGbLJRwzRO3WjTTLvo7K7626vRM0CXugRiNUy4y0CX6gvfp7T3evKcVbm5HqsGX0qPHIWm71PJI9HpbKCigQIA4emT58n6NOS7MtNwKVNiq72aJ1HK5VS9fplYc3mEDP+e1Sc+/mYz5bn52wGZvq6QEk+KmSrw1lhHnUoWd2bzE10oeSqjjxO8/fpKPi7JOiSWvnvMtEC2nakYko+hUzNwQ5ar2Xg8m2CpAwqrVTJM4UuIgs6EspiXzTs1vAgmAmXsIDq6jSRM7ng5S80R8DFvKaR8dGHW9GJGT5cbxD4iKst1m7o6f1bhWF6zQ8CtzzqlM4lsWmSEh/PK8S8P3S/4p61T/iS0fwlZGFiRpdNDsaWJXcp8TJ2+1z+zMXsOEQk1WxpT26qA/bb9b+G56/LcJWKk8pflj32bi/sbMt99YaTDCU+ro1GrM+Bz/hUFuK+f9s/kp5aY1NWfjPKqA23sW05poucmio3k6W0I8JkNL6LluqVv5jugKd3wyNlhkTIZqYSAzPKTSFdPCcXTWBqhUCa4xNQAZh6gbfVst7YOkK3HnSXrvxfGC5ofcc4Z0EEj9UihBvhk/SO4F4cYhxt0MPAPlr9qgRLa39tiCGCOPp/RV/JPmvfhgb1EYnsuRZ9cEJmuiUODUp/t/NZgRayRdCz8L21PDd2pt"
`endif