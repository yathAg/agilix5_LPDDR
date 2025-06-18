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



module ed_synth_dut_altera_merlin_multiplexer_1922_jy53pgi
(
    input                       sink0_valid,
    input [440-1   : 0]  sink0_data,
    input [2-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    output reg                  src_valid,
    output [440-1    : 0] src_data,
    output [2-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    input clk,
    input reset
);
    localparam PAYLOAD_W        = 440 + 2 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 1;
    localparam ST_DATA_W        = 440;
    localparam ST_CHANNEL_W     = 2;
    localparam PKT_TRANS_LOCK   = 324;
    localparam SYNC_RESET       = 0;

    assign	src_valid			=  sink0_valid;
    assign	src_data			=  sink0_data;
    assign	src_channel			=  sink0_channel;
    assign	src_startofpacket  	        =  sink0_startofpacket;
    assign	src_endofpacket		        =  sink0_endofpacket;
    assign	sink0_ready			=  src_ready;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOw55y2a8i9Te9U3baYZDRLbuDToroHh2X165g8VYofxW9O8QjlgBUDh8yHyGTkh34oxv6wolnkdgGviqizGSXLTriPu1CdU4eeOhduRKT7JOxU+r/KwKyaJV2AGcYe+48yEjE0uLOmrjEbOMgXqDorQz70/CmITmIozg0hT3dskYEJMVAglhkBAZIybLiZUpMcHH6YZ58b4IdO+l3z0oGYlnnPX9JLWR7zC0UYTuMRBLmWpnGaPq+qgcP+E0jSdtz2yoqzpwjUtCZdvzR0VPkQ9KVi+2MZXjkRgLe8D6UojHZF66v/pky6JSNVsz9rGpfBSn94mPRBrtC4H3GFH/qpD3+WhAzneL46Sc9EajYCOFxZ7LibebWiDCPwy6Fi9aHLMZxOQ2/PS7+tj6S6lQf9RLUfa93yOzrFe+cUFHHy3NAcWBUT64r2nM7lQ6lb+9qCScaZQWHO9VPxEuf/p2WwPGsPzxP+W+TL7VRPK98102XbqDX4KwP1bcrjrqL1137AHDk8UK2DghT05HZa10XnVjit4RJfwdy4TMVdDSOwECDG2wg70nLfhtVOE2PO6K26wMhheDbeV1ytkfQ0hRHt8+iwSK9RBEz2RwHKjAaput18jGEjAlqE3f8tx6Fp7Z0jy4G/kVmwddO/KakmzDk5S0QXdlLGNtQeH9ILt2mV1g7WRg423SkXqewWi9y/N3/aMr5xaAZwf3yslXpoizIox3Lif8Ksuitd6XwqkRXGyBa9ril3oVZ1YiiMqh4zWgh76ZwNH+R/wUSualtv3YsaI"
`endif