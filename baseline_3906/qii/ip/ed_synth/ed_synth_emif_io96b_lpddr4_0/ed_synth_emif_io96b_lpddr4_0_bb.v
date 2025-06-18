module ed_synth_emif_io96b_lpddr4_0 (
		input  wire         s0_axi4_clock_in,    //    s0_axi4_clock_in.clk,         User clock for mainband axi. Input clock to the EMIF IP, no relationship to PHY clock.
		input  wire         core_init_n,         //         core_init_n.reset_n,     Core init signal going into EMIF. Used to generate the reset signal on the core-EMIF interface in fabric modes. When high, indicates core initialization is complete.
		output wire         s0_axi4_reset_n,     //  s0_axi4_ctrl_ready.reset_n,     Output signal from EMIF IP (primary I/O bank), indicating that Calibration of the channels in this I/O bank is complete, and controllers in this I/O bank are ready for use.
		input  wire [31:0]  s0_axi4_awaddr,      //             s0_axi4.awaddr,      Write Address , channel 0.
		input  wire [1:0]   s0_axi4_awburst,     //                    .awburst,     Write Burst Type, channel 0.
		input  wire [6:0]   s0_axi4_awid,        //                    .awid,        Write Address ID, channel 0.
		input  wire [7:0]   s0_axi4_awlen,       //                    .awlen,       Write Burst Length, channel 0.
		input  wire         s0_axi4_awlock,      //                    .awlock,      Write Lock Type, channel 0.
		input  wire [3:0]   s0_axi4_awqos,       //                    .awqos,       Write Quality of Service, channel 0.
		input  wire [2:0]   s0_axi4_awsize,      //                    .awsize,      Write Burst Size, channel 0.
		input  wire         s0_axi4_awvalid,     //                    .awvalid,     Write Address Valid, channel 0.
		input  wire [13:0]  s0_axi4_awuser,      //                    .awuser,      Write Address User Signal, channel 0.
		input  wire [2:0]   s0_axi4_awprot,      //                    .awprot,      Write Protection Type, channel 0.
		output wire         s0_axi4_awready,     //                    .awready,     Write Address Ready, channel 0.
		input  wire [31:0]  s0_axi4_araddr,      //                    .araddr,      Read Address , channel 0.
		input  wire [1:0]   s0_axi4_arburst,     //                    .arburst,     Read Burst Type, channel 0.
		input  wire [6:0]   s0_axi4_arid,        //                    .arid,        Read Address ID, channel 0.
		input  wire [7:0]   s0_axi4_arlen,       //                    .arlen,       Read Burst Length, channel 0.
		input  wire         s0_axi4_arlock,      //                    .arlock,      Read Lock Type, channel 0.
		input  wire [3:0]   s0_axi4_arqos,       //                    .arqos,       Read Quality of Service, channel 0.
		input  wire [2:0]   s0_axi4_arsize,      //                    .arsize,      Read Burst Size, channel 0.
		input  wire         s0_axi4_arvalid,     //                    .arvalid,     Read Address Valid, channel 0.
		input  wire [13:0]  s0_axi4_aruser,      //                    .aruser,      Read Address User Signal, channel 0.
		input  wire [2:0]   s0_axi4_arprot,      //                    .arprot,      Read Protection Type, channel 0.
		output wire         s0_axi4_arready,     //                    .arready,     Read Address Ready, channel 0.
		input  wire [255:0] s0_axi4_wdata,       //                    .wdata,       Write Data , channel 0.
		input  wire [31:0]  s0_axi4_wstrb,       //                    .wstrb,       Write Strobes, channel 0.
		input  wire         s0_axi4_wlast,       //                    .wlast,       Write Last, channel 0.
		input  wire         s0_axi4_wvalid,      //                    .wvalid,      Write Valid, channel 0.
		input  wire [31:0]  s0_axi4_wuser,       //                    .wuser,       Write User Signal, channel 0.
		output wire         s0_axi4_wready,      //                    .wready,      Write Ready, channel 0.
		input  wire         s0_axi4_bready,      //                    .bready,      Write Response Ready, channel 0.
		output wire [6:0]   s0_axi4_bid,         //                    .bid,         Write Response ID, channel 0.
		output wire [1:0]   s0_axi4_bresp,       //                    .bresp,       Write Response , channel 0.
		output wire         s0_axi4_bvalid,      //                    .bvalid,      Write Response Valid, channel 0.
		input  wire         s0_axi4_rready,      //                    .rready,      Read Ready, channel 0.
		output wire [31:0]  s0_axi4_ruser,       //                    .ruser,       Read User Signal, channel 0.
		output wire [255:0] s0_axi4_rdata,       //                    .rdata,       Read Data, channel 0.
		output wire [6:0]   s0_axi4_rid,         //                    .rid,         Read ID , channel 0.
		output wire         s0_axi4_rlast,       //                    .rlast,       Read Last, channel 0.
		output wire [1:0]   s0_axi4_rresp,       //                    .rresp,       Read Response, channel 0.
		output wire         s0_axi4_rvalid,      //                    .rvalid,      Read Valid, channel 0.
		input  wire         s0_axi4lite_clock,   //   s0_axi4lite_clock.clk,         Axi-Lite clock, to primary IOSSM.
		input  wire         s0_axi4lite_reset_n, // s0_axi4lite_reset_n.reset_n,     Axi-Lite reset_n, to primary IOSSM.
		input  wire [26:0]  s0_axi4lite_awaddr,  //         s0_axi4lite.awaddr,      Axi-Lite Write Address, to primary IOSSM.
		input  wire [2:0]   s0_axi4lite_awprot,  //                    .awprot,      Axi-Lite Write Address Protection Signal, to primary IOSSM.
		input  wire         s0_axi4lite_awvalid, //                    .awvalid,     Axi-Lite Write Address Valid, to primary IOSSM.
		output wire         s0_axi4lite_awready, //                    .awready,     Axi-Lite Write Address Ready, to primary IOSSM.
		input  wire [26:0]  s0_axi4lite_araddr,  //                    .araddr,      Axi-Lite Read Address, to primary IOSSM.
		input  wire [2:0]   s0_axi4lite_arprot,  //                    .arprot,      Axi-Lite Read Address Protection Signal, to primary IOSSM.
		input  wire         s0_axi4lite_arvalid, //                    .arvalid,     Axi-Lite Read Address Valid, to primary IOSSM.
		output wire         s0_axi4lite_arready, //                    .arready,     Axi-Lite Read Address Ready, to primary IOSSM.
		input  wire [31:0]  s0_axi4lite_wdata,   //                    .wdata,       Axi-Lite Write Data, to primary IOSSM.
		input  wire [3:0]   s0_axi4lite_wstrb,   //                    .wstrb,       Axi-Lite Write Strobe, to primary IOSSM.
		input  wire         s0_axi4lite_wvalid,  //                    .wvalid,      Axi-Lite Write Valid, to primary IOSSM.
		output wire         s0_axi4lite_wready,  //                    .wready,      Axi-Lite Write Ready, to primary IOSSM.
		input  wire         s0_axi4lite_bready,  //                    .bready,      Axi-Lite Write Response Ready, to primary IOSSM.
		output wire [1:0]   s0_axi4lite_bresp,   //                    .bresp,       Axi-Lite Write Response, to primary IOSSM.
		output wire         s0_axi4lite_bvalid,  //                    .bvalid,      Axi-Lite Write Response Valid, to primary IOSSM.
		input  wire         s0_axi4lite_rready,  //                    .rready,      Axi-Lite Read Ready, to primary IOSSM.
		output wire [31:0]  s0_axi4lite_rdata,   //                    .rdata,       Axi-Lite Read Data, to primary IOSSM.
		output wire [1:0]   s0_axi4lite_rresp,   //                    .rresp,       Axi-Lite Read Response, to primary IOSSM.
		output wire         s0_axi4lite_rvalid,  //                    .rvalid,      Axi-Lite Read Valid, to primary IOSSM.
		output wire [0:0]   mem_0_cs,            //               mem_0.mem_cs,      Chip Select channel 0.
		output wire [5:0]   mem_0_ca,            //                    .mem_ca,      Command/Address Bus channel 0.
		output wire [0:0]   mem_0_cke,           //                    .mem_cke,     Clock Enable channel 0.
		inout  wire [31:0]  mem_0_dq,            //                    .mem_dq,      Data (read/write) channel 0.
		inout  wire [3:0]   mem_0_dqs_t,         //                    .mem_dqs_t,   Data Strobe (true) channel 0.
		inout  wire [3:0]   mem_0_dqs_c,         //                    .mem_dqs_c,   Data Strobe (complement) channel 0.
		inout  wire [3:0]   mem_0_dmi,           //                    .mem_dmi,     Data Mask/Data Inversion channel 0.
		output wire [0:0]   mem_0_ck_t,          //            mem_ck_0.mem_ck_t,    CK Clock (true) channel 0.
		output wire [0:0]   mem_0_ck_c,          //                    .mem_ck_c,    CK Clock (complement) channel 0.
		output wire         mem_0_reset_n,       //         mem_reset_n.mem_reset_n, Asynchronous Reset channel 0.
		input  wire         oct_rzqin_0,         //               oct_0.oct_rzqin,   Calibrated On-Chip Termination (OCT) input pin channel 0.
		input  wire         ref_clk              //             ref_clk.clk,         PLL reference clock input.
	);
endmodule

