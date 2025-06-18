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

module wr_comp_sel_cwyib4q #(
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

wr_pri_mux_cwyib4q pri_mux (
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
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFlcLGcVeFbe7Kpw/dIBIsX8P0hRtb98oKHpjWpA9cCsV6EUY69wZvpp3n6tlEIkcV8pnsmpL61VmeWqQClHu1t5cArGPZdR7u4bH5MhT8gfr+1etvYadQ812kbW+yVfPvt41zfYVbGfhWx4Iyhqg/lRC0dWMS3EPBNoJSHUGcKRszhlU0JVCz+LfrKV443R5f4cKTn5IryQ1JRvXckSRRdWFQkbGH0LVFWz0YHYfe7/0AK6dcoJlsAhrp4RyuLcmC0JyS0Ez6kBd8j6efMPXceFWc7DBJKXosbCjzlZunAYnNmSbIFKp05QxGW0pjpxwxbGjEJSi/eyPG7h++2ghgLlyJh3MkSO4VtjNB64ZB7DeK3O55Ms1T+uSD+y30FUau6WeOcKqkt39vg+9Pgyg9VSYMn59YVRhHSFawM5N6DGGQTuLtXU1avNB2599TEvceqOWNwkEst3tE/3H/Gp6DBEWeElycdMiZyh74uCmJ79gPUCurqKyetiREqZiTCUpYL6u4jPdjBEWeHWfqk5aGxKAYl8OFi8qBSZn20W354p1IKFRrPPlzyssvFdobO/qnCiZudZU9a9WndMBnrEPFin2iL9sD5MOWAemCRgiuS831TYosUDlX5iMFkjuMFVEcm0PbK8xPl8sBjJpx9FRIZcWOwmSESZ/4c4qoxIHtGlm59q/SQdpVwK/fo4K/HAf6x9IMVShhC2KvJ4euiz5ToLlOW0U05pfGEUR0NHFn297Pg7dy/7WxDVQobd5P5pcmihN/4dUFKKHGNqJjLM3wqyR"
`endif