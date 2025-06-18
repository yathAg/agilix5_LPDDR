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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_cgpn6xq #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 188,
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
		input  wire [187:0] in_data,           
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [187:0] out_data           
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
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOwgXEOCP8noWMJJ2FdIQ7zXDAIP6tUc5EJaIToL7SnV2JpSG0lFZRtll8e6pO9mLCeftnZ4E4C2fS7nBN16j7M8C71uuFrBp83MHNB+W1zjUZrWoUtqTquMJoJ7bd6/klGNe6Aiex4TJrjYUb/EArC+miFidtzSEylOj/TWDjNS10Q+3mHuetZywro055sKxgr2GLUpTH8zxCJIVqwA1AjBwLk/gF6AC95XbnO6TUYAxtN/xmQnTetAZAc8SLwxxMGJepT1Fol9kl2wbdimcnJyOu0Qw8wfMSPjYuFR2X3VMEjGXkeEWnnMKdOni1eGMz8u0/pmCltfL8WlQ7iwEk0R+9ojRiS+xlbFn5S0vbGGMCek1cElbqgWAijkS5oE7GaE5uhEiE3Fq8F/6JA6EhH9Y6i+bUHC6boNZggU+nfBupoWF8DEcBqNaDzCXYQvlfK1vTMdb6EWTKh2zqwu98iOtl9Z/Z+2jBKq+5v7mGNQNyjv5Zs+fNT6GX7A2RlcpxPolBSogJZ71ohVGKM0ovjS0Jb08y8wljIP9qDVJF5pwJbC7TJY5mwVvHlVKffJIaNayD662R4UBfYNwzT2cJuDuTSB7VoDZ3AbwGXmwMQGPM/jnhLMC/tClatn4M24sjtSsiVMhz9aouvYWCK8jZQnGcdvsqsRCxnY51xQD37f3aeX0AWD5nBNxeTc5+RLFxg5lkbPNFFfsWl07i6jn+4D2G72muKeQMtT2rvmGqm6fXK9MuPlzWurM7vHeiYPKlDJOaWsaVB5omBlY5bLUM29"
`endif