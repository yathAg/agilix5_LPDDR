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



module ed_synth_dut_altera_merlin_multiplexer_1922_7b7u3ni
(
    input                       sink0_valid,
    input [124-1   : 0]  sink0_data,
    input [2-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    output reg                  src_valid,
    output [124-1    : 0] src_data,
    output [2-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    input clk,
    input reset
);
    localparam PAYLOAD_W        = 124 + 2 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 1;
    localparam ST_DATA_W        = 124;
    localparam ST_CHANNEL_W     = 2;
    localparam PKT_TRANS_LOCK   = 72;
    localparam SYNC_RESET       = 0;

    assign	src_valid			=  sink0_valid;
    assign	src_data			=  sink0_data;
    assign	src_channel			=  sink0_channel;
    assign	src_startofpacket  	        =  sink0_startofpacket;
    assign	src_endofpacket		        =  sink0_endofpacket;
    assign	sink0_ready			=  src_ready;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOwMuwqoVyAWG1PnjZ0jSe+p02dmbNqIRdxdX11HG3Z5n7+uVUeAwORXdRL2WDkcwx35GjsaIr/5f29oU9PMuwy6vCkp8lHop4W9Xz+IRzgywm9sqa3LVZOquuAnkZQee5y14lN158pKKTULQaQ+x41fWeSPe5xwotYo3kEPqYrL3TopBDxnuKBkqX1rJn0Z/dHtTKKZ/W44BRnwO1/Dm3ujvViMcIbu7pERnHCe9idrchoL7Pc5bWAjL2hyjYjFTGpFvQNfeDBuA93+qHIiqQrJ1h16xUCzUQKC4ZcLvqUqw+ODe5jFtsxfO5X2Bw42gnMPvzFqCgaU9jOQRocrDEu5uyn938eTY4uWpymAf8YAnYvrevZetEkZHo7OUFoWwHcJw8qASgpsze+zSZ3nw0q4ahcNCf6ppyntGe2ZEqR7lHzDwQZ8k6fQ/XmrOKdrh8RiXgG50NYGvwshP6uo3tS3eyiXZU+esGrs/URUOXFnO1HgNRSOIUGPn//qvjfqGtPBcWWG+XIsZoZ0/HpBcc6V6d4wemTY/rWB+eEPVNgGOMV8trCZSm8xqnKAHC6iZpqLEJL5Ci33ZPJXIVfQWaV64nCL3kc6Xo+boUj+CFkx6mA5mA88OybXNAtTHFH+UvHtobIKX+v8BWq2e921jWSw27wkFtYCqanw5yECPt/eUSYwhTi2lvq+q3H+XQK0S2+RkVxdWZqF2M4bqB7WRoB3vYkr6l+ZF/RBpnQjJdwdu8XafPLFH44OgetSaHMrPKxiWL93bv9aUGCtIYvpXreL"
`endif