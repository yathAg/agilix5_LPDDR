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





 


`timescale 1ns / 100ps




module ed_synth_dut_channel_adapter_1921_fkajlia 
(
 output reg         in_ready,
 input              in_valid,
 input     [8-1: 0] in_data,
 input              in_startofpacket,
 input              in_endofpacket,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 output reg [8-1: 0] out_channel,
 output reg          out_startofpacket,
 output reg          out_endofpacket,
 input              clk,
 input              reset_n
 
 
);

    wire in_channel;
    assign in_channel =0 ;

   always @* begin
      in_ready = out_ready;
      out_valid = in_valid;
      out_data = in_data;
      out_startofpacket = in_startofpacket;
      out_endofpacket = in_endofpacket;

      out_channel = 0;
      out_channel = in_channel;

   end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzzmwhn0XJ+cGDN1lM+NyIpIT/ugdDRepTLnxdwLIf6mzsg6/Io4xWr1tJSUfN27ZusPWQP1JlEKcOMJggTi+LDUPb7v7XgeL9a9QY/qPdHMhv3uWn65M9picSEzztfA0qlLb+yg0sdaN0iGuHquvJtabR9U2Q4DWYx2tRpzXmxC/1XtVhyc4MzJijz3GiGz7fKEgN9qh36ud8acFAsFOpTjbpFATpXZrvVjJnJhw4XE0jNGzy3TcuBsuliwKa6gdNvofvy38761tz4VDquxfD7+wMDXOfBeca5MAHAjUJUVYuTIegCcIoNakmVmAOi8P+Q+qlmebKAbdd91YnJI/IO6TqI/HplVUEhDJTUCORgR/LfSpHfzvwZ+MWncwanNVHTS5w8IXNsM03Fm1NTfaTku7ONI8pLoUGPmryl4P50cy2dCTeU3EJ3wo0RcBOjwywD29I6wlSzWflNVvLZQYVt+bGAW1lUmnzLLnGSg20Z9a8eCNnk/J9sQKDn2AdlOyBnlwpCUPHK1l0BXARdY81j8FUwWJWboyZuHAstPZIWrMauwFCzCOk2VA5HfrmGX7EAI8OXdl80qg39nU4XHr/8SymoquGg9XEICg9l2zNSPcQssfDVQUvUt0sBaEX3dgmarhiVpyMqqsLS4eB+dndAisuVBaHoYm14EY7+YoYTpbKTM2VkJCtdWaM4JO4g+arS3GUvb091Iz/ceO1cYZjigUZ+Cs1g1bW77mlFmQeT5cen/xpq5NdGP1RBiRqbunc48uK+WUKUockYjwsC+ufo"
`endif