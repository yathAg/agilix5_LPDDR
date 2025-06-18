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



module ed_synth_dut_altera_merlin_demultiplexer_1921_rcor4va
(
    input  [1-1      : 0]   sink_valid,
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
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOwlctCPWPADU87iP9V8jc/Odp/3yOqZ1R11LL+akobbVFodq5wvY3nuh1ZlRgqJaZJW+zi0UqMw6K/iCMknK/HLWFpLAzWuFXI4YCw7JieFPdyhVe5Zz7wdM8pHcaL1ORt2gHXurhkNI3sv6n9KIbQiHBIaEqzK6zaqQ1NXDp65Oxn8kgoc3xH9z6urCNp8LEYLp8wfrEt8F+0cTcRhxNGJU3mzLIqzDj9pB33l+PlWsiWYRj7bplKLTdf4y4m6q8sfWF3r5KJb8qPbHuMVanGwbfnMGKn8M7aCnPiy3m1V1JQYmN7G/ceWi3SMD5UxScdEmjt0G1jzgt9usM4qDEmUM2cGjWVzO8wi6eO4aRDh9LJWGgVQ8t47oRvLwgX9EUEgKIdunhXT11GRCUy+FgWfb7hOKmBW+OP3hk6Jgk6nMJinYPEDayi/EExXUyHXVpu8CDbjhx2WZ8KV1aDBI09s2BPRjgJ19N+GCycPuKaIySNOMpOUY/FzGX7nEHyoMWyfjLJoyJ3AwDwhhECBwXcEUQU9qKab/eCLyLQsHLjxLR9I7nqdnx86WKVr4Q3As1aWWTm4iUK4fnf1YGGCLCI+6AsH8UH2iU6JW2hWQVa9Ju/CvXImEQoZzHCpdlFuEmIFVnIp9TGDG9cRynfgTcdgF5I6Z6MwM+YWYjSOkxIPuO6F1BV8SNopKAcjRN6zTlr9BBqDNWgw2IBV7q5Ugk3kKP5p5VveHBo4jgo9g34Kp11rvi1w0U9/qY7D6vpp1Bsw/RDQmLuCw39D4DQdy2nq"
`endif