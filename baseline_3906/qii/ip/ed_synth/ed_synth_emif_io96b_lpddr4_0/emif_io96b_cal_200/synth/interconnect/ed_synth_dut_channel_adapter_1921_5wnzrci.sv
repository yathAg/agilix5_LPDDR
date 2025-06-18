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




module ed_synth_dut_channel_adapter_1921_5wnzrci 
(
 output reg         in_ready,
 input              in_valid,
 input     [8-1: 0] in_data,
 input [8-1: 0] in_channel,
 input              in_startofpacket,
 input              in_endofpacket,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 output reg          out_startofpacket,
 output reg          out_endofpacket,
 input              clk,
 input              reset_n
 
 
);

    reg out_channel;

   always @* begin
      in_ready = out_ready;
      out_valid = in_valid;
      out_data = in_data;
      out_startofpacket = in_startofpacket;
      out_endofpacket = in_endofpacket;

      out_channel = in_channel; 

      if (in_channel > 0) begin
         out_valid = 0;
      end
   end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzoLzAgwB4MlVnsgmrJhlxmUoCZip/WeIbyCL5PqIgoJn453D7KQVlxny3dKPGI82+Q0So4vwWbNhJHiDIi5yCrONU7XB6cMW75u8ktDnfgpvK+2VjhBQYjZ8WKhEMrZhBSclLEuGaev0QzkBTuevKZ/dekzYaVV8naP5rZrJx+c4Djea97jkD2apK9d4WoOncYPDBnztkohLLh6WRfEuTkseDXt7XwafPbU2x3hAu+1UgKfrQN+O0Bpf4/QtiyiXGkYO2Fe5caQWlG8TWGqTpQURvCWnAYAn9CCcpCuDuAiyyz5XrVOKoiJHcsqv+lMxd3BCQbpMcdqrv4+b5khzBMT8V5LlvZEdJ+gNAtlr5f6sQ3PxdZUbtTT59pjjqQtVuGW89Zog4hDhmLAmc78QCUUEmwGYZAN5U73ro0tSogeDJdv5fxfoBUMr45C7o2f4uR3n1NExFTSOMZlVvp33bkR/4LZ8ZJXtYN2LHqglybDdnuF05iSxH+FDJ6oNRCSjzOw8pXiTz92Ku4t4jDL+797MIq5vz8vw1uRKuxJ6LXbMNmIXWs6J9H5H8HDyKmdYThMCkdgbO4y3a/1sa/MiKwZv1ngKvgRC6Qs46mbaZpA1rlJe9B44THhn0BxQhyKsTHkVxm7zqmdH2CVa1wRP/bpCQzI4Vq4al5w3raXDdwTcGwF2g67rA2naSbTgfd++DXQ3dPH7cm53EHQbRXa5fFXy55BWyq/Uh5QKx31kzeNceJ+d51JnTTRFqdKANcCAKUxHMuEdkAvgkP5gsuJyHE"
`endif