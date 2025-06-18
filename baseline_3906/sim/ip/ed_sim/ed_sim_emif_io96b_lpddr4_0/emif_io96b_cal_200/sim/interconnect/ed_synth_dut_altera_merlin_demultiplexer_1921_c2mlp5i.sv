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






`timescale 1 ns / 1 ns



module ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i
(
    input  [1-1      : 0]   sink_valid,
    input  [440-1    : 0]   sink_data, 
    input  [2-1 : 0]   sink_channel, 
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    output reg                      src0_valid,
    output reg [440-1    : 0] src0_data, 
    output reg [2-1 : 0] src0_channel, 
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,


    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input reset

);

    localparam NUM_OUTPUTS = 1;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid;

    end

    assign ready_vector[0] = src0_ready;

    assign sink_ready = |(sink_channel & {{1{1'b0}},{ready_vector[NUM_OUTPUTS - 1 : 0]}});

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzyIVB/trUJmElOo6zhnk7guJDJvdK/kRfdLsOKlbPzUcACvTORnOvLuP882LQFMM2q7e948/0a2+rus8tYtg0QUtXoY9GkjnR7EBDxEx6/SeqToOh/PCXhLk3/SxAUer/lxd4RKVVgI4g9dQcWdUqt5e+wOaT2l3WN2EGLCOWv+wsAP3xS61wEMIcjDN2wXGSYL2iWQm7VIBIfwpN3AsEEm+ndEEBJ7gzgD7/yVxd79ZQq9TNcx6ZjuUnIIroRzzBQSLp7uf6p+1FzYTHcWEjmhwcI97ZhviTMPDnyWiFAiP6KR7TDBiegwVWjU6T3ygBvWHc+45oTMEeZH+KeOJcZrfdvNws2kvOX5m66yiIWEo1oqk18P6qqpvsoiFSpcrfZvzf6IEmR2ASSje+K8meNGBxgA2V7/ezSAc9OuOv1CLAnwhMqRSTV0LHiFT5j9JVCleSpm2NnbU4JI5c64723+bNbsmloA3lLfjO9Zin92by4pQlGiRnaeE92QDyLbCgvLHWx+PZIJWYRvzznARdX3cq9ThFN4Xmt0X+Lb2AoBu2oKmbkMfQTemWVcOLNSB+a0mdTcowBkQViJT+znKO1TGGX+1DmYmEbonucZuXnHxOE+bf0RXLESooU0gf5YsBYJJDIY6UscJhviGtHnrR+4P0p3US4giX44tL7DsFWfibCWqBqUvH9mTt08tE1brAqI5txIW6nsT55LK6mE2ii+wkY0rsCW35GGyhEgRqTj+x1Dh4LT2hjIoxSkFn4mcv97OGbn3rz4QaoxW1OCpDu"
`endif