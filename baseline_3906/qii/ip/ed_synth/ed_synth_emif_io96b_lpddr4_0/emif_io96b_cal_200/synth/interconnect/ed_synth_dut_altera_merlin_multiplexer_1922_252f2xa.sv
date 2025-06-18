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



module ed_synth_dut_altera_merlin_multiplexer_1922_252f2xa
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
    localparam PIPELINE_ARB     = 0;
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
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOz3aOE9K2o7UJSyqHMcUdfWClwExaSOAlyZU3Y8ZuqX7DJX+YV0fi0SQMJmsigmdO1p48iPla1CKdV0NCixJ2PjgzpktjTuDhaK3uEBEBZ6toaeTwOkbPstiksaRcIcQOlPUzqFZ33NrcXJBoDI9qU2sW7ne9b39YlZUx2bZ0OsusVmgfQ3vzuYIC7+nRkoYeiQhU2AAYrWKfF2nn45t25oKF1dMFvdiBupFjBfW8kmcLRXMDWadwMV9Op2NlvJztBOUqxby5GVQ/7bRREUVylShhm4dmcaNG6+Sh1WL6qLZeYb9uWILDihi6p/Kv/gUhevd1kLH1MwSZDlC+VRwslYvDlMmGzegz7wQ+CMDguz0ScpF0MX6jLFe/4nRZnHoEY9TlT1j+JJ+SFVbt/znwpnH10foyQGbaIEMO0ji1R7thWBFB7NwJ/mBgNp9ApBfT7g6LTb+4bK0TVfsnAWD/bjEcs4vRx/8ByUKEZvTzOWsj3ygS7Bi9nRMhCndO/5zu+iSTdytEwr5HLMmt062wN3PANUCeH5xjhE1x0L8DvdaCeLR2UxOEh3fe+/qMGjm7nP4pe0WoDxPZPb0FfHRqqYAIAvtD8JfExZq7BlZyeT6/2AouPBuw/mJl9zsDxL68rW4JXrTz/RXSdxck7BeBQ46X0XoDtRcyyYLyNEj5KSWdDCt0GH6dkgLTonWbIza1ryYZxBnLIGeBojaZCtBDNLpk1FY5neadd+lsrYqMJ2tdrUbdlvkwdV6CJ4GQqaWgmBDGmMwEbPofWL9bWVmKLt"
`endif