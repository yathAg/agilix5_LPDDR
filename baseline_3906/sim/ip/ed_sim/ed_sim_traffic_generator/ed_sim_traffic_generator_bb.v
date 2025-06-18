module ed_sim_traffic_generator (
		input  wire         remote_intf_clk,              //   remote_intf_clk.clk,     Clock Input
		input  wire         remote_intf_reset_n,          // remote_intf_reset.reset_n, Reset Input
		output wire         master_jtag_reset_jtag_reset, //        jtag_reset.reset,   Reset Output
		input  wire         driver0_axi4_awready,         //      driver0_axi4.awready
		output wire         driver0_axi4_awvalid,         //                  .awvalid
		output wire [6:0]   driver0_axi4_awid,            //                  .awid
		output wire [31:0]  driver0_axi4_awaddr,          //                  .awaddr
		output wire [7:0]   driver0_axi4_awlen,           //                  .awlen
		output wire [2:0]   driver0_axi4_awsize,          //                  .awsize
		output wire [1:0]   driver0_axi4_awburst,         //                  .awburst
		output wire [0:0]   driver0_axi4_awlock,          //                  .awlock
		output wire [3:0]   driver0_axi4_awcache,         //                  .awcache
		output wire [2:0]   driver0_axi4_awprot,          //                  .awprot
		output wire [0:0]   driver0_axi4_awuser,          //                  .awuser
		input  wire         driver0_axi4_arready,         //                  .arready
		output wire         driver0_axi4_arvalid,         //                  .arvalid
		output wire [6:0]   driver0_axi4_arid,            //                  .arid
		output wire [31:0]  driver0_axi4_araddr,          //                  .araddr
		output wire [7:0]   driver0_axi4_arlen,           //                  .arlen
		output wire [2:0]   driver0_axi4_arsize,          //                  .arsize
		output wire [1:0]   driver0_axi4_arburst,         //                  .arburst
		output wire [0:0]   driver0_axi4_arlock,          //                  .arlock
		output wire [3:0]   driver0_axi4_arcache,         //                  .arcache
		output wire [2:0]   driver0_axi4_arprot,          //                  .arprot
		output wire [0:0]   driver0_axi4_aruser,          //                  .aruser
		input  wire         driver0_axi4_wready,          //                  .wready
		output wire         driver0_axi4_wvalid,          //                  .wvalid
		output wire [255:0] driver0_axi4_wdata,           //                  .wdata
		output wire [31:0]  driver0_axi4_wstrb,           //                  .wstrb
		output wire         driver0_axi4_wlast,           //                  .wlast
		output wire         driver0_axi4_bready,          //                  .bready
		input  wire         driver0_axi4_bvalid,          //                  .bvalid
		input  wire [6:0]   driver0_axi4_bid,             //                  .bid
		input  wire [1:0]   driver0_axi4_bresp,           //                  .bresp
		output wire         driver0_axi4_rready,          //                  .rready
		input  wire         driver0_axi4_rvalid,          //                  .rvalid
		input  wire [6:0]   driver0_axi4_rid,             //                  .rid
		input  wire [255:0] driver0_axi4_rdata,           //                  .rdata
		input  wire [1:0]   driver0_axi4_rresp,           //                  .rresp
		input  wire         driver0_axi4_rlast,           //                  .rlast
		input  wire         driver0_clk,                  //       driver0_clk.clk,     Clock Input
		input  wire         driver0_reset_n               //     driver0_reset.reset_n, Reset Input
	);
endmodule

