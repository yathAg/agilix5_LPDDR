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
module altera_s10_user_rst_clkgate (
	output logic ninit_done
);

	localparam USER_RESET_DELAY = 0;
	
	initial begin
		#0 ninit_done = 1;
		#1 ninit_done = 0;
	end
					
	
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "RuNHKftaC60EWvOMgDOYl1ufiNZWP+mTLOgtnOMRVIWuWgchMKII7nF2zm2x/eQf0O64zREM+xCMiOR8KN7UEfigHnMtCXZFkRsIaP6O551IDYPPCuj6sO/UvzmAQ7EURyXnRQl0eN4mAH0lLQnbz6iOqh0/alcjMFqR4E64AEh3WD8fLOyrIuKsE3wBu3uUmfLfYrFFSKgN+8lCRzq697nIco/+r0I3u1of3maJFi5mAnu2SK6FCWupSj3vZltcayi9vV4raRCO0oCtuzd7n/75usoFP80akumkF8ceZiIZ4Ss5wNql9EN94daZJep7WvRBq25zISCokY8PLric7wFCSuwrVxDe6DctUkQzFbewJXa4ckdMpuIN+exVOb9QeIDNhsb3RxX9qcNeNKqKbble87ozHoWOxPR4zATUGQvQelBek+a+J8GplathpcgeMGJg622yMkUoMfwd5DZvn2VkoCXk1ouh5tSYRM87gCv32gz38+SY5HRpr1QKDiReqvk+USp5TonWLQM3I7HgdsC4t7KYc/XP086BKfforfrdzFV6iqJPf/EZEVKszUHmFzDHj3z3FL+KCVd2Gf63Glu1mr2bfRlzXMT/jrvjD5nzIFXDPFEYTV7rZA4OvdODEIatuFyjnl75qGVrjV0Pys+I1/Hv+tQuufo6Mhg7RogH9syWhQCfwkdB3Cj12qRk+dMdiA2wng0uCy3KdG8q/PZwvVqCUGlsapr2GMWfX+qeAK4L95wNVOjYRYMT+FfLsNxZXMInaZ6+0LCq0tmKPQVeORHzMK64KpRI49sRWlLJNA8YkTxHeI+GsFC4lxNsANi1ggWWWzrSE+eK/sLORRNI/G6845vwwk4TR6WoZGf1A+smuGBsQKIiGif53CnYRk+XDaLecSrAsWoxmS+kgJICUIZY5VRi6qMtBIFGTd3GqmICjjbAk8V22Jd7uQIzU/XfSZbUQ8eGHxJsFhhcH8K7lB/haHh5S3IiQCELKoUuVLig6xAWy2JL7mFBP1og"
`endif