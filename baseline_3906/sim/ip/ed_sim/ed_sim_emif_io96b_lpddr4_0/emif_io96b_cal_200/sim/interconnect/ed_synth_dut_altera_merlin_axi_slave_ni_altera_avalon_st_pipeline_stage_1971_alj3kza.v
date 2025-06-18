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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_alj3kza #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 37,
		parameter USE_PACKETS      = 0,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 0,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 0,
		parameter SYNC_RESET       = 0
	) (
		input  wire        clk,       
		input  wire        reset,     
		output wire        in_ready,  
		input  wire        in_valid,  
		input  wire [36:0] in_data,   
		input  wire        out_ready, 
		output wire        out_valid, 
		output wire [36:0] out_data   
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
	) my_altera_avalon_st_pipeline_stage_rd (
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
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOyYJPVwrfjIXcrEhMtcwrzrSXUSWHnVxGuoeV4xw95HX60alDmWlEDuOcyoqmqFkzSLDJQ09ueHzQAIWCulREV+Ft9PeaHeXd4w11X8V3QqwI/60iCbty/IPEjnaXmZgPaxlD6+Mh4FmpdJ9/yfLfe+1hzv+QP7jlMtWaVB+TrDQ8sUKx+lWBXqF5/45MnaygInmnzEEQ5rGMQyC4sLu3va1a/WsgjYpn493AbS0cwmaLXnwvPSoGrNSyXUy6CLe71ZWQN8P3kvz8iKE2e/zZlow+n+BbZEOC/Oyhs0HhLhxHtQ/d9mWNUDfL0bUozlUT4XEbGQaulfXxppGtwqZktifYpflvjjd8UY9syW7EkEcLsOqq+RRUnCQd+pFUn1NI48IuXW2DGyR3f2dyIxCW93ZHtw7YauqLe0GwMFdOwUZcLc1aOi9J5VJJ/DKqAgEoyfSwRnrdNd7lWGl0sdkwCgN6fnwcNxcC/5Y6pMkSmCp69nz9xLvt/TnTECHK21ZqC70z8vESYz6f7f1uxZcK/IlcUqZ9jlDLr8ZLDuanUpl5ntIENCdOC71G7bLX0GMqZlLulf6nc0YKLq8U6UgbRFNLNpEL6AAzxJGpPDeF4a+H2936BACp94oV1bprDohzXSXYRJXWrBoAdOD3Q54jn4ck4El7Qq30pzBk6mKwaTN74eVSXkx2s/8pgHbSzXUPoM0IhNjfB7B0hwXVV4tv0/XAU2cvs5sHw4ZHhvB1oZSDf12rWDw5P/Mvk614CSN7yB1N12dDch/ld2z9zPLV7Q"
`endif