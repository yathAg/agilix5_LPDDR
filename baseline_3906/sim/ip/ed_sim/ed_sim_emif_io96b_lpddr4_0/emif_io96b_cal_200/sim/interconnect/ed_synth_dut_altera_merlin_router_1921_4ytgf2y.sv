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


module ed_synth_dut_altera_merlin_router_1921_4ytgf2y_default_decode
  #(
     parameter DEFAULT_CHANNEL = 0,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 0 
   )
  (output [152 - 152 : 0] default_destination_id,
   output [2-1 : 0] default_wr_channel,
   output [2-1 : 0] default_rd_channel,
   output [2-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[152 - 152 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 2'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 2'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 2'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module ed_synth_dut_altera_merlin_router_1921_4ytgf2y
(
    input clk,
    input reset,

    input                       sink_valid,
    input  [188-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    output                          src_valid,
    output reg [188-1    : 0] src_data,
    output reg [2-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 152;
    localparam PKT_DEST_ID_L = 152;
    localparam PKT_PROTECTION_H = 162;
    localparam PKT_PROTECTION_L = 160;
    localparam ST_DATA_W = 188;
    localparam ST_CHANNEL_W = 2;
    localparam DECODER_TYPE = 1;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    localparam ADDR_RANGE = 64'h0;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

    reg [PKT_DEST_ID_W-1 : 0] destid;

    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [2-1 : 0] default_src_channel;




    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    ed_synth_dut_altera_merlin_router_1921_4ytgf2y_default_decode the_default_decode(
      .default_destination_id (),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;

        destid      = sink_data[PKT_DEST_ID_H : PKT_DEST_ID_L];



        if (destid == 0  && read_transaction) begin
            src_channel = 2'b1;
        end

    end


    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOxZ1MW5q8b19sHl+QEaru/BUYrWIZiyeP2YlJu+5DmM+ROkHAFu+iCc5glpr2ysOwo8RQgYPEIQrcdF/f9UsX3J292Er+dnvg0KB99RR/Tt16AzVYsnnW8wYAQ2lGmlRMhIHwzT4+9BreMbRluVS10OoIPH2lFFHCQ4zPdEA2ysif2dy+u3mJJsAqu86q4+e5RaPx5rX2xX63fID3os+d7cyGL0+ZwWejgBylM334Qix66KBlUzJ/FPEt+RIvCjKQWgN0XrO5OHf8GM9yMdBvnqRPNiZ9niQ9glWGdTgo6WqKU7BzHRWPaiyjhl0eSVdQmrvIz1MQcOeOtbuaWlZ3zu1h6chbzGPlxGPxEOUxSRS+0NCZp5P1aMWf1iyElmql2ZCPZnhS+dq7yWcgGltoXcVe+pPgxLCj+9YS6v99ZqQ2o6bfN4DRPO5yH8qfvzFKi2sxH0JMVoVzS7G+1h7KPg6A+BRNMTJ4k+GJ11vHqO0IHERxt/RjGrh5VDGY7xhc8jB/ZvAHM1eSpd1djLr9vwQ2YUSOqfWvHARKBut/gtnUFneU92cau5oO0MPDYGNbDE/i0PuagfpnpORHFy94U8B+UP9KmrYW/03RuUh9Q2pUmsnNIzSdl/qgQ0+iEuo6qHXBmDFBfiud/aMJ4EzX+wLfN/TBZeJmzxNQUhy91K6ebCrFkFCwZ7/L/8Qqvho6K4Bxp4t6+bzoadz3AMBeHbAe0Ib2Q3KnxT/bbK8pl+Qctm185W5Pe3YnfmVI0RvIODuzCneA485VGv/BB/z4I/"
`endif