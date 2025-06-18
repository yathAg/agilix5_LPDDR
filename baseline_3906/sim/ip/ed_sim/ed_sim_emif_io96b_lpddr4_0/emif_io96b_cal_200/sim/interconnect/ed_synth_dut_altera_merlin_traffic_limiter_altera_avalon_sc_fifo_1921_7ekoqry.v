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
module ed_synth_dut_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_7ekoqry #(
		parameter SYMBOLS_PER_BEAT    = 1,
		parameter BITS_PER_SYMBOL     = 4,
		parameter FIFO_DEPTH          = 6,
		parameter CHANNEL_WIDTH       = 0,
		parameter ERROR_WIDTH         = 0,
		parameter USE_PACKETS         = 0,
		parameter USE_FILL_LEVEL      = 0,
		parameter EMPTY_LATENCY       = 1,
		parameter USE_MEMORY_BLOCKS   = 0,
		parameter USE_STORE_FORWARD   = 0,
		parameter USE_ALMOST_FULL_IF  = 0,
		parameter USE_ALMOST_EMPTY_IF = 0,
		parameter EMPTY_WIDTH         = 1,
		parameter SYNC_RESET          = 0
	) (
		input  wire       clk,       
		input  wire       reset,     
		input  wire [3:0] in_data,   
		input  wire       in_valid,  
		output wire       in_ready,  
		output wire [3:0] out_data,  
		output wire       out_valid, 
		input  wire       out_ready  
	);

	generate
		if (EMPTY_WIDTH != 1)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					empty_width_check ( .error(1'b1) );
		end
		if (SYNC_RESET != 0)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					sync_reset_check ( .error(1'b1) );
		end
	endgenerate

	ed_synth_dut_altera_avalon_sc_fifo_1931_fzgstwy #(
		.SYMBOLS_PER_BEAT    (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL     (BITS_PER_SYMBOL),
		.FIFO_DEPTH          (FIFO_DEPTH),
		.CHANNEL_WIDTH       (CHANNEL_WIDTH),
		.ERROR_WIDTH         (ERROR_WIDTH),
		.USE_PACKETS         (USE_PACKETS),
		.USE_FILL_LEVEL      (USE_FILL_LEVEL),
		.EMPTY_LATENCY       (EMPTY_LATENCY),
		.USE_MEMORY_BLOCKS   (USE_MEMORY_BLOCKS),
		.USE_STORE_FORWARD   (USE_STORE_FORWARD),
		.USE_ALMOST_FULL_IF  (USE_ALMOST_FULL_IF),
		.USE_ALMOST_EMPTY_IF (USE_ALMOST_EMPTY_IF),
		.EMPTY_WIDTH         (1),
		.SYNC_RESET          (0)
	) my_altera_avalon_sc_fifo_dest_id_fifo (
		.clk               (clk),                                  
		.reset             (reset),                                
		.in_data           (in_data),                              
		.in_valid          (in_valid),                             
		.in_ready          (in_ready),                             
		.out_data          (out_data),                             
		.out_valid         (out_valid),                            
		.out_ready         (out_ready),                            
		.csr_address       (2'b00),                                
		.csr_read          (1'b0),                                 
		.csr_write         (1'b0),                                 
		.csr_readdata      (),                                     
		.csr_writedata     (32'b00000000000000000000000000000000), 
		.almost_full_data  (),                                     
		.almost_empty_data (),                                     
		.in_startofpacket  (1'b0),                                 
		.in_endofpacket    (1'b0),                                 
		.out_startofpacket (),                                     
		.out_endofpacket   (),                                     
		.in_empty          (1'b0),                                 
		.out_empty         (),                                     
		.in_error          (1'b0),                                 
		.out_error         (),                                     
		.in_channel        (1'b0),                                 
		.out_channel       ()                                      
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOxJmh4pdx4JbeWEZJwP2iWwQzE4llNj6WKaM+ODrpn9QCOvNhu+Xy35ZrBx/sh4+gcrik8WFP8cp+MJOtKoMWT6nHeObVWU448qA4w5P9UfK6H/QkoeYNTEbb4Xmm0ubDLRBS+Xti3JetFwCMCKL5LjDRJn3G0RX/DM43kH7ZDCd9hCrrqeJS/Wc5BkWkTEqC2JBV5S1xNIHEPPvhcjQ4dSgdmZcnOa8mIGUGF0PiAHSPfYBPOd8OFvRByJOPxlg31PV0S5H94PGPWlVWE7hcSRGa5Yqr/Am4EaBkzAChNTxQAncvyiNtBXNmuaCHBRlHEYS6kgtFTeNyIWx0Ms5iMOCgSk/7g6AHdrx2roivb8WZSrkZTB8/6rUFRKrbW/AhL+LDzH8ZW/d2Bs8ZTQO0BpAi0zzCvqUOQtVSlk8rHEoGFzpOHoI/bFw6FYYmV5mvFWoyaioOoZ94ZFC++39mJz53vxpK7xagjcxFr2eM6dghCe/d1B8eiQ1Z9BYTciVbHHbBDmv66SwOwQZam7lfkW1/kuYTiBfcJxCQVekkKkvYmd26+rBgwWbybn3XryD8wZAUhVxMKPC+rQqMlsqKnMDdFZMkVMQGbWi+iCY7CdtOlLdo1680IwAj4jwQHoazMzfl5cCI9kQDx7dF647ulBQGf1zDQDJsTdMoiNLIp41FAoXLznTZCnT9EhcPLAiSLfVtE5p4EFGuBl3b8n0/5PqUe43uLkzMT9mnWih/hdcQZisczJGWD/x0kgeAeZI9UGaqr27oQVhLv7Qq5e8U4U"
`endif