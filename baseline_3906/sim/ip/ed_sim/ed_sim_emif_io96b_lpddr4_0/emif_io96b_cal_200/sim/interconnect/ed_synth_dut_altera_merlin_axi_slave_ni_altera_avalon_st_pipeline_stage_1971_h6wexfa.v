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




`timescale 1 ps / 1 ps
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_h6wexfa #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 4,
		parameter USE_PACKETS      = 0,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 0,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 0,
		parameter SYNC_RESET       = 0
	) (
		input  wire       clk,       
		input  wire       reset,     
		output wire       in_ready,  
		input  wire       in_valid,  
		input  wire [3:0] in_data,   
		input  wire       out_ready, 
		output wire       out_valid, 
		output wire [3:0] out_data   
	);

	ed_synth_dut_altera_avalon_st_pipeline_stage_1930_bv2ucky #(
		.SYMBOLS_PER_BEAT (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL  (BITS_PER_SYMBOL),
		.USE_PACKETS      (USE_PACKETS),
		.USE_EMPTY        (USE_EMPTY),
		.EMPTY_WIDTH      (EMPTY_WIDTH),
		.CHANNEL_WIDTH    (CHANNEL_WIDTH),
		.PACKET_WIDTH     (PACKET_WIDTH),
		.ERROR_WIDTH      (ERROR_WIDTH),
		.PIPELINE_READY   (PIPELINE_READY),
		.SYNC_RESET       (SYNC_RESET)
	) my_altera_avalon_st_pipeline_stage_wr (
		.clk               (clk),       
		.reset             (reset),     
		.in_ready          (in_ready),  
		.in_valid          (in_valid),  
		.in_data           (in_data),   
		.out_ready         (out_ready), 
		.out_valid         (out_valid), 
		.out_data          (out_data),  
		.in_startofpacket  (1'b0),      
		.in_endofpacket    (1'b0),      
		.out_startofpacket (),          
		.out_endofpacket   (),          
		.in_empty          (1'b0),      
		.out_empty         (),          
		.out_error         (),          
		.in_error          (1'b0),      
		.out_channel       (),          
		.in_channel        (1'b0)       
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOwCIzDmOqyAnft/N4yJEFZM/qJly1v26ERMxnT8phO3vsHtLWp70Nw6WTFD82hO9Ej7z9GZfYmLtT+8bqWlFLK+DA4pDhIEjvOup1uW6v1oW+xYyz5QxhBNXg/1bxaTQjcApjaTgDskYIlWmWxZdJnIdFrqOvCGMYcLmFA9Q9qr4YnRixQMIafkPAyVZzZzlQc0C8HoChDy3aoQXoI6///HnEB2zp2mGH5jP7GFZz0cgbGSbGJQAz2nQGn9VP/x06MRUBaBzad/0Z6x7IdUjbVsR20nqkgpY5zGFpXeHwnlQKca9l/vBPfDeRdeTZA5rkChoFUnohVRda+/F/eL2hP6qjlfK6oN1nEjuo0TrpOdW6yZaD2S0i6V0XkMR68b85t0MHd7BvVtPIWMzkvsDeCIHthN96PV0RQTCzXOoh93mhmf5U+K/UCiHH5V80h2HGvXlW3g4BcTgn/2wmFljFyvZ30lz4XoFlu36VtIYUsv4IPF5xtjaWjEFcviMIZhks/H0mZT65DdGrG+Uf2H2P3UgXEO34MCe4SiP0mExYC04T/g9WTDrQO83KGzB+hHKdyKmQuFD9+0RzA8qFUOI/bV5c57Lg4p40JXrCeHT8IW0c1MMi/m50BZOMFJUKa79zZAk33whqKI2FE7Ih3xBQNJq+WFEPPNnwGhH1y4u9TC0W+Ji26W3XsppAYjbhf1aAHJuOHamwOzVSsz+r8KqChh6PxmjtkqtlaVU0/ojoDQw10N0OR42GMQnL+h7dLtj2FA8Oz8ky4Gm5L6a98RBXMy"
`endif