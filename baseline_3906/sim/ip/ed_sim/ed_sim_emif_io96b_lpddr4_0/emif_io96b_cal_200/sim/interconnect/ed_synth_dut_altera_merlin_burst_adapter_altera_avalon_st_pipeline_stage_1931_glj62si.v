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
module ed_synth_dut_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1931_glj62si #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 188,
		parameter USE_PACKETS      = 1,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 2,
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
		input  wire [1:0]   in_channel,        
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [187:0] out_data,          
		output wire [1:0]   out_channel        
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
	) my_altera_avalon_st_pipeline_stage (
		.clk               (clk),               
		.reset             (reset),             
		.in_ready          (in_ready),          
		.in_valid          (in_valid),          
		.in_startofpacket  (in_startofpacket),  
		.in_endofpacket    (in_endofpacket),    
		.in_data           (in_data),           
		.in_channel        (in_channel),        
		.out_ready         (out_ready),         
		.out_valid         (out_valid),         
		.out_startofpacket (out_startofpacket), 
		.out_endofpacket   (out_endofpacket),   
		.out_data          (out_data),          
		.out_channel       (out_channel),       
		.in_empty          (1'b0),              
		.out_empty         (),                  
		.out_error         (),                  
		.in_error          (1'b0)               
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOwI6qlxcz2bpRnEGrlNzajiOvjCcY0QfnI73C6zW8dIqWDR59rSFyWCPOkLMQouUA4AiKcA9iuCrzDQcAd1W5EFDZN5tDFcNqc/9W7zIbTXTRcwNZ1g/mxEfcBcSnhEv+PtZTy5kggMGIbrN7egMmuCH/r+3K43lOVVfsuDKZiqnrA9HGjTO0olEeqgeRa3IWfkhzgvMTOFcJyixL/kBGx4ENbMuu0jbEBLgFtGnOq2RyqXXrsDZCbsr4+jy1zMcMHfocT4NFhX8Hfy60zuN+0r2KAdGwcr67mTSxmePRhijUDRSKd63A3tQnhQzJCbQAu4iMXr/PFvukinNJTDYwUVtkRmcQ5Cxb46oo6DNniAUeCgPReYBZv6bBiO6dhA+jSIpq+a7DnRPIudSFE19K6juvmOTWB1vV72RgnqigwM8u55O9OFME4toFRNZNlimBUwpJhdy9voESEi/mQyC7xynWAEdPAhwjs9ivG1M+3F0g+131qIexQT/Iko3g/IBIh6vQwsQUbCEuylK/8Ck2c+dRfxbG2UhuHtZu95Z2/4qPVU7dJMWWIXk7he7ctTH3ZsZZ4GnoaDxngyMEL77C7Yrczilps1RT77WzQJ4NDHpXyDXwPJcQSq0BlaImfpl6ycRc6VjjE3XYi+YDqzSDxpa2X1QVAEHEZpeBmttkspHn3n91hWalX1SNVBu3NEWlGyThAELXa8V1ihFnu7nPEbs3HmQnSrkxSrjD4nRbDs+XkinSeheuW2rchI46TfvmxncwnQJEmGhoBHuDlhMRbb"
`endif