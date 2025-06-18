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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_vnonqiy #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 124,
		parameter USE_PACKETS      = 1,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 2,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 1,
		parameter SYNC_RESET       = 0
	) (
		input  wire         clk,               
		input  wire         reset,             
		output wire         in_ready,          
		input  wire         in_valid,          
		input  wire         in_startofpacket,  
		input  wire         in_endofpacket,    
		input  wire [123:0] in_data,           
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [123:0] out_data           
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
	) my_altera_avalon_st_pipeline_stage_rp (
		.clk               (clk),               
		.reset             (reset),             
		.in_ready          (in_ready),          
		.in_valid          (in_valid),          
		.in_startofpacket  (in_startofpacket),  
		.in_endofpacket    (in_endofpacket),    
		.in_data           (in_data),           
		.out_ready         (out_ready),         
		.out_valid         (out_valid),         
		.out_startofpacket (out_startofpacket), 
		.out_endofpacket   (out_endofpacket),   
		.out_data          (out_data),          
		.in_empty          (1'b0),              
		.out_empty         (),                  
		.out_error         (),                  
		.in_error          (1'b0),              
		.out_channel       (),                  
		.in_channel        (1'b0)               
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzmp/xBSQUQIhLUiSnOvSEVx57SzsuduRNHj3jup/HKwa6T7tvEr1SiU7UEUXGTuOvdlUowW3LBIAeEEHeyCZA9FFF+3kORXBE2qtzoEPrpLDT4sGAvipqEOZyGqaarv/ljUB822KUpwYTUa6GnNUzNJ5e8XaKO/9bDnZaZVeMNyWbtiEEV9jbgy1v4dY0b4XcjICO1so2PuVjk5kbewa3+YCAQOYt/rGBITN/GRj1cSqgx2tHccbk9C77z7pXxgBqmSu4RePylR0cLQxgjGscwFena2eA7A/YaLLOdyMtUujfjzCjdW+qrjGCR+JLACGzIB5zGeXnpPNe38hviwWTqDjGN92LI+800nLK3WIyVUYSVDY2Uw4GT5PPQ+XfrNQ/P3dWIz50FI1ULnH1Zz9KTXsNN8vYJ9GjOQEd1IoL2xGd82dS4EnUlIuvpJzIYJouWcG2D40dg4U6mVEdU+1XUMhgzZ75W38wRrAKi0lgRHDK23h96+S2/8lnSHdlpf3GfyiuQmW3gnPTE7a1SRbvgao1JrTloXl65qiaICdRMDl5IPLe5hgTWDzrCiVgfoyH0QWjmH6hrRmm7qSl17yGVwmG1T+eFaqOajxM9VxW8a977EU2g3IxhCmJABDw1riWZIHmEu6Q/OyuslfuPZoWuViT0TwTcrci9c6SIXxs7nG481Dg2bxKPfPIClx8DaYz9O1V7NFVzn4G+WAsQqC4TfQckQ7Zy98+yY94optPFbUIT1SxaqrqjuSvAL5jE3WNzQloROg9QAnLw30Q4Z0nI"
`endif