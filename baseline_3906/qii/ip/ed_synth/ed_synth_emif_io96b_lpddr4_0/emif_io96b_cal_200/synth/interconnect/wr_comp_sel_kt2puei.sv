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

module wr_comp_sel_kt2puei #(
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

wr_pri_mux_kt2puei pri_mux (
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
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFldr1G0dxwn3S9UtTzaelQerxRf4H4tjYBMGo1juspclOevc9IdGgtQ+stxQzeB6qOZhXInMERjUplL1idlSLliRaTDc3P5IMYtbud1IjTXpZj186hSKDOHVr1/CaGDE+aKFZA7RO6DIG4nvnp590zFsm4e3Lc36lUCZGOvwNz3P6fJQ8OyjINAmjb1UdMIjrXtPLYqfgsDrjQ7yH4PYRVhWMgUxeYIICLh04rhASbaw6uzxAixTYGhPhhNrJs1ZqULUgVmUaJrt9cNm9pEskNZPwYqF+aCYIgzWsfqygqncHQpsFGHHdzpa7JUqNjovxNoBlT0Bq8flk/QNjpFglEbKCWUZj+JbgeJ6Kdqgs2tz36Rw18ELekhblZo2iewscZ7yqa6ov24YdhpFzEjGbvS6OfLJCZd+3jtQl3RNhUFWAXWZWAUh7Uz4bqqqmIFDYcYIJWDLELaiK01fYg7H1DIjAp33mjo/jbQU1PxAGNQgltSfp6bnCuAcLtQA8iremjzZZUAPYXz81Ph7dC1Qp6U1ePnvC1BxCNoefVKefHXbheRVZGqRr5EGZBEt+XJrkVyQlJN9WE8B5ZZJlg/4qbk4Fe5ark8cVkIVMTiTWJvLhwHD1icMWx5J3Ivs7PATkJQuJl51BJNlEqYcZ2699g8L+6gBpZYsXanwOVVuBcVjzTFrd88/zz9WT63OfZ73W9K/szTXAxr6Xivy2cghYMmxrkZ0+5Z++lvq39XXW9s/tK/XvvXv6aTrw5+9TDyIZsI+0ZknoNQSfjHOZ6wazCMb"
`endif