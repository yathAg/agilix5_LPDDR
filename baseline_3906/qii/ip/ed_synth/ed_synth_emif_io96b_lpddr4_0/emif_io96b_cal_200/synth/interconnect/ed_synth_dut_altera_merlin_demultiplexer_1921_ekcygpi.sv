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



module ed_synth_dut_altera_merlin_demultiplexer_1921_ekcygpi
(
    input  [2-1      : 0]   sink_valid,
    input  [124-1    : 0]   sink_data, 
    input  [2-1 : 0]   sink_channel, 
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    output reg                      src0_valid,
    output reg [124-1    : 0] src0_data, 
    output reg [2-1 : 0] src0_channel, 
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,

    output reg                      src1_valid,
    output reg [124-1    : 0] src1_data, 
    output reg [2-1 : 0] src1_channel, 
    output reg                      src1_startofpacket,
    output reg                      src1_endofpacket,
    input                           src1_ready,


    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input reset

);

    localparam NUM_OUTPUTS = 2;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid[0];

        src1_data          = sink_data;
        src1_startofpacket = sink_startofpacket;
        src1_endofpacket   = sink_endofpacket;
        src1_channel       = sink_channel >> NUM_OUTPUTS;

        src1_valid         = sink_channel[1] && sink_valid[1];

    end

    assign ready_vector[0] = src0_ready;
    assign ready_vector[1] = src1_ready;

    assign sink_ready = |(sink_channel & ready_vector);

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzVbAXSaaZt/rKysGYBVHvACnspaQCSA28m2pYasLGWKLmrjHeJi9OtReMPYPp/GeAVqNyVkc20W47IqSR0jLI/kHPlrZXMQZxcEmjMOJwK17AaqaWvNnijZzXF5nI5NMPm2vCVT5eiV5rnHF6WthT7TId+Mh/O8ubFn8Rn4QGQh872/d6Inf+KYDA72WyQgABKC3f8GOQyHED1UWYSEfgnLzPYuAKSewUKXxlBh2+Mg5lYGHuArSgyjdsodY74cTV+ZT97hA5bD9+AQjCqtXTJb0/aZUIG0TylOjzo5J4MWdA9NdazvhBUU3qJ3T8/D5jJKVL/xYKZRz9DgAt4Z5nYHfuNVyGwgoffkf0XKKOOTrI/TZnt9wPBxh4MbyBkH++TYgT3ee85hIM2WIwmcmri4F4K4XG7Gqj5kRU7J1dQg7u1iM3uKOslMXu8VbVfaTLnVSgi72LnHCEUUZaNBWIB1/6q/WGze2HT+Aui79CRm/94oEYumMhG9qI4l3/u+fkvC4w2mLzZK1T/o8GTQpDRxOtZ9u9HQLwWGJk86vbI+WcaXkDlO/vBGQjFBJVNr4CDQSS/bvfncwTG6pMt6qpY9nuOmJEx4+PQUwCG++MSjgQq5CbRisVPyJNYhdyWSrwZX8QiELj7KQpmmM8/F8OKpkub1SzeMhYhyPkvvpm9y4Yigm6VX56VG1RcPC+xsLk5Ja8d/6UBgqjf5Y3q585PxpUV6wI5HA35FjCJE7XGQO9MNYhwSXhy4GcjJElm+aUPqiVY48nWDy7cb09Cregh"
`endif