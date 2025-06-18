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


module mem_reset_handler #(
   parameter  SYNC_TO_CLK          = 1,
   parameter  USE_AND_GATE         = 1,
   parameter  NUM_RESETS           = 1,
   parameter  NUM_CONDUITS         = 0,
   parameter  CONDUIT_INVERT_0     = 0,
   parameter  CONDUIT_INVERT_1     = 0,
   parameter  CONDUIT_INVERT_2     = 0,
   parameter  CONDUIT_INVERT_3     = 0,
   parameter  CONDUIT_INVERT_4     = 0,
   parameter  CONDUIT_INVERT_5     = 0,
   parameter  CONDUIT_INVERT_6     = 0,
   parameter  CONDUIT_INVERT_7     = 0,
   parameter  CONDUIT_INVERT_8     = 0,
   parameter  CONDUIT_INVERT_9     = 0,
   parameter  CONDUIT_INVERT_10    = 0,
   parameter  CONDUIT_INVERT_11    = 0,
   parameter  CONDUIT_INVERT_12    = 0,
   parameter  CONDUIT_INVERT_13    = 0,
   parameter  CONDUIT_INVERT_14    = 0,
   parameter  CONDUIT_INVERT_15    = 0
) (
   input logic clk ,
   input logic reset_n_0 ,
   input logic reset_n_1 ,
   input logic reset_n_2 ,
   input logic reset_n_3 ,
   input logic reset_n_4 ,
   input logic reset_n_5 ,
   input logic reset_n_6 ,
   input logic reset_n_7 ,
   input logic reset_n_8 ,
   input logic reset_n_9 ,
   input logic reset_n_10,
   input logic reset_n_11,
   input logic reset_n_12,
   input logic reset_n_13,
   input logic reset_n_14,
   input logic reset_n_15,
   input logic conduit_0 ,
   input logic conduit_1 ,
   input logic conduit_2 ,
   input logic conduit_3 ,
   input logic conduit_4 ,
   input logic conduit_5 ,
   input logic conduit_6 ,
   input logic conduit_7 ,
   input logic conduit_8 ,
   input logic conduit_9 ,
   input logic conduit_10,
   input logic conduit_11,
   input logic conduit_12,
   input logic conduit_13,
   input logic conduit_14,
   input logic conduit_15,
   output logic reset_out_n
);
   timeunit 1ps;
   timeprecision 1ps;

   logic [15:0] resets_n;
   logic [15:0] conduits;
   logic reset_out_n_async;

   assign resets_n[0 ] = NUM_RESETS > 0  ? reset_n_0  : 1'b1;
   assign resets_n[1 ] = NUM_RESETS > 1  ? reset_n_1  : 1'b1;
   assign resets_n[2 ] = NUM_RESETS > 2  ? reset_n_2  : 1'b1;
   assign resets_n[3 ] = NUM_RESETS > 3  ? reset_n_3  : 1'b1;
   assign resets_n[4 ] = NUM_RESETS > 4  ? reset_n_4  : 1'b1;
   assign resets_n[5 ] = NUM_RESETS > 5  ? reset_n_5  : 1'b1;
   assign resets_n[6 ] = NUM_RESETS > 6  ? reset_n_6  : 1'b1;
   assign resets_n[7 ] = NUM_RESETS > 7  ? reset_n_7  : 1'b1;
   assign resets_n[8 ] = NUM_RESETS > 8  ? reset_n_8  : 1'b1;
   assign resets_n[9 ] = NUM_RESETS > 9  ? reset_n_9  : 1'b1;
   assign resets_n[10] = NUM_RESETS > 10 ? reset_n_10 : 1'b1;
   assign resets_n[11] = NUM_RESETS > 11 ? reset_n_11 : 1'b1;
   assign resets_n[12] = NUM_RESETS > 12 ? reset_n_12 : 1'b1;
   assign resets_n[13] = NUM_RESETS > 13 ? reset_n_13 : 1'b1;
   assign resets_n[14] = NUM_RESETS > 14 ? reset_n_14 : 1'b1;
   assign resets_n[15] = NUM_RESETS > 15 ? reset_n_15 : 1'b1;

   assign conduits[0 ] = NUM_CONDUITS > 0  ? (CONDUIT_INVERT_0 ? !conduit_0  : conduit_0 ) : 1'b1;
   assign conduits[1 ] = NUM_CONDUITS > 1  ? (CONDUIT_INVERT_1 ? !conduit_1  : conduit_1 ) : 1'b1;
   assign conduits[2 ] = NUM_CONDUITS > 2  ? (CONDUIT_INVERT_2 ? !conduit_2  : conduit_2 ) : 1'b1;
   assign conduits[3 ] = NUM_CONDUITS > 3  ? (CONDUIT_INVERT_3 ? !conduit_3  : conduit_3 ) : 1'b1;
   assign conduits[4 ] = NUM_CONDUITS > 4  ? (CONDUIT_INVERT_4 ? !conduit_4  : conduit_4 ) : 1'b1;
   assign conduits[5 ] = NUM_CONDUITS > 5  ? (CONDUIT_INVERT_5 ? !conduit_5  : conduit_5 ) : 1'b1;
   assign conduits[6 ] = NUM_CONDUITS > 6  ? (CONDUIT_INVERT_6 ? !conduit_6  : conduit_6 ) : 1'b1;
   assign conduits[7 ] = NUM_CONDUITS > 7  ? (CONDUIT_INVERT_7 ? !conduit_7  : conduit_7 ) : 1'b1;
   assign conduits[8 ] = NUM_CONDUITS > 8  ? (CONDUIT_INVERT_8 ? !conduit_8  : conduit_8 ) : 1'b1;
   assign conduits[9 ] = NUM_CONDUITS > 9  ? (CONDUIT_INVERT_9 ? !conduit_9  : conduit_9 ) : 1'b1;
   assign conduits[10] = NUM_CONDUITS > 10 ? (CONDUIT_INVERT_10? !conduit_10 : conduit_10) : 1'b1;
   assign conduits[11] = NUM_CONDUITS > 11 ? (CONDUIT_INVERT_11? !conduit_11 : conduit_11) : 1'b1;
   assign conduits[12] = NUM_CONDUITS > 12 ? (CONDUIT_INVERT_12? !conduit_12 : conduit_12) : 1'b1;
   assign conduits[13] = NUM_CONDUITS > 13 ? (CONDUIT_INVERT_13? !conduit_13 : conduit_13) : 1'b1;
   assign conduits[14] = NUM_CONDUITS > 14 ? (CONDUIT_INVERT_14? !conduit_14 : conduit_14) : 1'b1;
   assign conduits[15] = NUM_CONDUITS > 15 ? (CONDUIT_INVERT_15? !conduit_15 : conduit_15) : 1'b1;

   assign reset_out_n_async = USE_AND_GATE ? (&resets_n) && (&conduits) : (&resets_n) || (&conduits);

   if (SYNC_TO_CLK) begin : reset_n_sync
      (* altera_attribute = "-name DESIGN_ASSISTANT_EXCLUDE \"CDC-50012\" -to \"reset_n_sync.reset_sync_inst\|*\" " *)
      altera_std_synchronizer_nocut #(
         .depth(3),
         .rst_value (0)
      ) reset_sync_inst (
         .clk(clk),
         .reset_n(1'b1),
         .din(reset_out_n_async),
         .dout(reset_out_n)
      );
   end else begin : reset_n_async
      assign reset_out_n = reset_out_n_async;
   end

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "tpmhs+4zb9RkWeenD6UhyeYdRhzQ0RXjLI+qL/J26KZAWPi64p3f1jCX5T17T3GRe3mUncRbSswuf6gk+Y9jTNFhTUkjGwy8WGoiJnVLByuFgFI6EDlRofR4Onf1gGEnu40Y9M88U8S+qvzXPSRAqz3nBz9D4JU51FoLJ3KekP85wl6d/CxyHiZhbxHiKs7yP0xMO+iaTFVahTsXreie3S9xvx7wHC8RFNp9TCU6qjE+OJQfqipMCpmoQZ4d/N/M8I5n1hEc72eoTRIP50zji80WcBcM5rWjWG7RxuVXURAqbHX2/Avd8QHVRYAFrW7DFlGIJM1FQDP1Wf0n4p5sdJKT7YEQ7/sFVKf5M/iCAU80YNwAS/zZ+f0lg8fQlLHZI9uAGH7MRt+fOEyaVZ02QzmAzY8ctd6BUTEXGuBkh74QuIBZXt3fRd7nybO5kZtkX8ovhlqIiz7qdlXAVd29TWBLBOYp3sZAvLlF36irxShWMWGH/XQkUVRJr/BtyYPMeiB9VKVv9VjYOC1ytz6k+rdgpSfSRGWQSRd43vyw8hDX3tBs2QMclRFiqrY7QeynTb6hR8QITFvu1cLbkXYtLgm1PJymgFqT3yA5iFN8sp1wpjygM/ZwhANXR3zJyURmXzJUYo1Qh7L1L/MqOB0lZdrpIQ3kaQ/HA2NUIjRTMmofAaLA7+7flQHdiGxoQ+2HtbX2FK+axUSwLBcxWzd92tj+MkPbJiV3mxai/7Bky5/NW7ZC3sVduMw0bC0Ln/kiaRsynKtJTUscEciokuirhBVHyWGVToAMeOz6cjaXrSkTG6w5LhoPif/iHKQNXEO/ITEvrIUHySPQgu2ELsI8cTkK2PNgQ3p8nd6MldmFozyiOdfUxxv1kruTH+1lO729FQpYwZ7IYEgLBQn3JI6M1QPVCs+PuUlq15Z8NH/2YilN70KvdXH44AY0TTr1UdmTF2CjZkC0ODXTmvqyTiU/nMNJ8deWyCaNqzfL+c6WoaL57GEYKHGJ0fQmwVpnr8lj"
`endif