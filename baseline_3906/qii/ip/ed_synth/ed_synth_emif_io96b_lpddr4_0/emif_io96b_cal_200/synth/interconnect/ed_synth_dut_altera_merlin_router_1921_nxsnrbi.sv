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


module ed_synth_dut_altera_merlin_router_1921_nxsnrbi_default_decode
  #(
     parameter DEFAULT_CHANNEL = 0,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 0 
   )
  (output [404 - 404 : 0] default_destination_id,
   output [2-1 : 0] default_wr_channel,
   output [2-1 : 0] default_rd_channel,
   output [2-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[404 - 404 : 0];

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


module ed_synth_dut_altera_merlin_router_1921_nxsnrbi
(
    input clk,
    input reset,

    input                       sink_valid,
    input  [440-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    output                          src_valid,
    output reg [440-1    : 0] src_data,
    output reg [2-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    localparam PKT_ADDR_H = 319;
    localparam PKT_ADDR_L = 288;
    localparam PKT_DEST_ID_H = 404;
    localparam PKT_DEST_ID_L = 404;
    localparam PKT_PROTECTION_H = 414;
    localparam PKT_PROTECTION_L = 412;
    localparam ST_DATA_W = 440;
    localparam ST_CHANNEL_W = 2;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 322;
    localparam PKT_TRANS_READ  = 323;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    localparam ADDR_RANGE = 64'h8000000;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;


    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [2-1 : 0] default_src_channel;




    wire write_transaction;
    assign write_transaction = sink_data[PKT_TRANS_WRITE];


    ed_synth_dut_altera_merlin_router_1921_nxsnrbi_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

           
         if (write_transaction) begin
          src_channel = 2'b1;
          src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
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
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzso4G6bYqVt7ChN5UAD5ZJT5ED+vzcAGcObIdkLmJh8LzF3eZIhepYcTgA/qn4a2HYux5g9ZrGfnanj/FnwEaIPt2UPiZFZb/ERn6m4awUcls5oSNVQeFGTPDUZfGaDrvay3gPmZZOdjKWZJGW6UUKR9ko4OcCmFGcsu0y9PM2XHh+LyXgxYKSRytMflGgVP8Oc8jfRrFtLkUyqz2ePnsxz9AoUJAnWGQlNb+ZyQOTpJYYoop8HoOGvc/PNmDyt4nJF/+ipcUbVSusZzg+8rYhFLH97H0FH6CRyhhXYfMDXiAn4kQ7Ye1MjuJh6iINbhPhJ6R8wFROyKydE+W3b2nzpbUVfoPOFAR+POUcDmYEYrwHDt/znefGafZxGgPcoOF68orqeZp64Idx9x78pLRd0rdVqemxHfAj+eZkxE4uKZg74DEGw3s8dmDC9iyYj1Vpg2XsH/GL7Bmjl2KUeIZLZTH7AvCBfdUjElGHI4+mGQYzISVBFKAcVmA6N5cX4LasnacRxEzk9EiheuXGKPTUz3GCgEaBcD9yiYR6yPsopIAjXjZya/8q55a1Qcp+Cqx1bMlDu5f2kOmu/EqM7uI8CdqShxveEj6p3jZqfYDbdmFleyVZqqBkpilxRn/l1QEh+w4ILtQiR/bRftfn9WtuS9KhkpVH3TJRgBOp2aniHhT3PNz0Cy8+65Jb9HB/Axuzp3vK4R8jA+h9pacrvssUb9iSHoF45lSdltPLC7Hf3Gmx1a5pXK//3qswfBbh5D4169y7awdUKXKIzv40iV4u"
`endif