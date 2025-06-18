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



package hydra_mem_axi4_driver_pkg;

   localparam AXBURST_FIXED = 2'b00;
   localparam AXBURST_INCR  = 2'b01;
   localparam AXBURST_WRAP  = 2'b10;

   localparam XRESP_OKAY   = 2'b00;
   localparam XRESP_EXOKAY = 2'b01;
   localparam XRESP_SLVERR = 2'b10;
   localparam XRESP_DECERR = 2'b11;



   localparam CSR_DATA_WIDTH = 32;

   localparam CSR_RAM_ADDR_WIDTH = 18; 

   typedef struct packed {
      logic driver_done_reg__wen;      logic [CSR_DATA_WIDTH-1:0] driver_done_reg__wdata;
      logic driver_error_reg__wen;     logic [CSR_DATA_WIDTH-1:0] driver_error_reg__wdata;
      logic wr_log_ram_wrptr_reg__wen; logic [CSR_DATA_WIDTH-1:0] wr_log_ram_wrptr_reg__wdata;
      logic rd_log_ram_wrptr_reg__wen; logic [CSR_DATA_WIDTH-1:0] rd_log_ram_wrptr_reg__wdata;
      logic num_bid_errors_reg__wen;   logic [CSR_DATA_WIDTH-1:0] num_bid_errors_reg__wdata;
      logic num_bresp_errors_reg__wen; logic [CSR_DATA_WIDTH-1:0] num_bresp_errors_reg__wdata;
      logic num_rid_errors_reg__wen;   logic [CSR_DATA_WIDTH-1:0] num_rid_errors_reg__wdata;
      logic num_rresp_errors_reg__wen; logic [CSR_DATA_WIDTH-1:0] num_rresp_errors_reg__wdata;
      logic num_rdata_errors_reg__wen; logic [CSR_DATA_WIDTH-1:0] num_rdata_errors_reg__wdata;
      logic num_rlast_errors_reg__wen; logic [CSR_DATA_WIDTH-1:0] num_rlast_errors_reg__wdata;
      logic rdata_pnf_0_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_0_lo_reg__wdata;
      logic rdata_pnf_0_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_0_hi_reg__wdata;
      logic rdata_pnf_1_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_1_lo_reg__wdata;
      logic rdata_pnf_1_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_1_hi_reg__wdata;
      logic rdata_pnf_2_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_2_lo_reg__wdata;
      logic rdata_pnf_2_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_2_hi_reg__wdata;
      logic rdata_pnf_3_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_3_lo_reg__wdata;
      logic rdata_pnf_3_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_3_hi_reg__wdata;
      logic rdata_pnf_4_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_4_lo_reg__wdata;
      logic rdata_pnf_4_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_4_hi_reg__wdata;
      logic rdata_pnf_5_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_5_lo_reg__wdata;
      logic rdata_pnf_5_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_5_hi_reg__wdata;
      logic rdata_pnf_6_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_6_lo_reg__wdata;
      logic rdata_pnf_6_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_6_hi_reg__wdata;
      logic rdata_pnf_7_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_7_lo_reg__wdata;
      logic rdata_pnf_7_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_7_hi_reg__wdata;
      logic rdata_pnf_8_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_8_lo_reg__wdata;
      logic rdata_pnf_8_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_8_hi_reg__wdata;
      logic rdata_pnf_9_lo_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_9_lo_reg__wdata;
      logic rdata_pnf_9_hi_reg__wen;   logic [CSR_DATA_WIDTH-1:0] rdata_pnf_9_hi_reg__wdata;
      logic rdata_pnf_10_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_10_lo_reg__wdata;
      logic rdata_pnf_10_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_10_hi_reg__wdata;
      logic rdata_pnf_11_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_11_lo_reg__wdata;
      logic rdata_pnf_11_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_11_hi_reg__wdata;
      logic rdata_pnf_12_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_12_lo_reg__wdata;
      logic rdata_pnf_12_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_12_hi_reg__wdata;
      logic rdata_pnf_13_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_13_lo_reg__wdata;
      logic rdata_pnf_13_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_13_hi_reg__wdata;
      logic rdata_pnf_14_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_14_lo_reg__wdata;
      logic rdata_pnf_14_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_14_hi_reg__wdata;
      logic rdata_pnf_15_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_15_lo_reg__wdata;
      logic rdata_pnf_15_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_15_hi_reg__wdata;
      logic rdata_pnf_16_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_16_lo_reg__wdata;
      logic rdata_pnf_16_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_16_hi_reg__wdata;
      logic rdata_pnf_17_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_17_lo_reg__wdata;
      logic rdata_pnf_17_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_17_hi_reg__wdata;
      logic rdata_pnf_18_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_18_lo_reg__wdata;
      logic rdata_pnf_18_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_18_hi_reg__wdata;
      logic rdata_pnf_19_lo_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_19_lo_reg__wdata;
      logic rdata_pnf_19_hi_reg__wen;  logic [CSR_DATA_WIDTH-1:0] rdata_pnf_19_hi_reg__wdata;
      logic ter_reg__wen;              logic [CSR_DATA_WIDTH-1:0] ter_reg__wdata;

      logic [CSR_DATA_WIDTH-1:0] wr__log_ram__rdata; logic wr__log_ram__rdatavalid;
      logic [CSR_DATA_WIDTH-1:0] rd__log_ram__rdata; logic rd__log_ram__rdatavalid;
   } r2u_t;

   typedef struct packed {
      logic [CSR_DATA_WIDTH-1:0] trafficgen_reset_reg;
      logic [CSR_DATA_WIDTH-1:0] driver_run_reg;
      logic [CSR_DATA_WIDTH-1:0] stop_on_error_reg;
      logic [CSR_DATA_WIDTH-1:0] write_on_error_reg;
      logic [CSR_DATA_WIDTH-1:0] wstrb_nt_mask_en_reg;
      logic [CSR_DATA_WIDTH-1:0] ter_dq_mask_0_lo_reg;
      logic [CSR_DATA_WIDTH-1:0] ter_dq_mask_0_hi_reg;
      logic [CSR_DATA_WIDTH-1:0] ter_dq_mask_1_lo_reg;
      logic [CSR_DATA_WIDTH-1:0] ter_dq_mask_1_hi_reg;

      logic aw_w__ctrl_ram__wen;
      logic aw_w__main_ram__wen;
      logic aw_w__issue_ram__wen;
      logic aw_w__worker_ram__wen;
      logic aw_w__addr_alu_ram__wen;
      logic aw_w__dq_alu_ram__wen;
      logic aw_w__dm_alu_ram__wen;

      logic ar__ctrl_ram__wen;
      logic ar__main_ram__wen;
      logic ar__issue_ram__wen;
      logic ar__worker_ram__wen;
      logic ar__addr_alu_ram__wen;

      logic b__head_ram__wen;
      logic b__ctrl_iter_ram__wen;
      logic b__ctrl_ram__wen;
      logic b__worker_iter_ram__wen;
      logic b__worker_ram__wen;
      logic b__addr_alu_ram__wen;

      logic r__head_ram__wen;
      logic r__ctrl_iter_ram__wen;
      logic r__ctrl_ram__wen;
      logic r__worker_iter_ram__wen;
      logic r__worker_ram__wen;
      logic r__addr_alu_ram__wen;
      logic r__dq_alu_ram__wen;
      logic r__dm_alu_ram__wen;

      logic orch__ctrl_ram__wen;
      logic orch__main_ram__wen;

      logic [CSR_RAM_ADDR_WIDTH-1:0] ram_waddr;
      logic [CSR_DATA_WIDTH-1:0]     ram_wdata;
      logic [CSR_DATA_WIDTH/8-1:0]   ram_wstrb;

      logic wr__log_ram__ren;
      logic rd__log_ram__ren;

      logic [CSR_RAM_ADDR_WIDTH-1:0] ram_raddr;
   } u2r_t;

endpackage

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "cddlQdKSXObe9GTelUexZ9kuKGcyyss5FDlImpfdXwLvV7ku/wKMzbqjrt8Pwr8gzWDzoHTtLdozqDIeBtpg/Z+LgcjOeWMk2pxaURA+XoG8jRzSlWA5MQAAwphLt/JYLc8V2titsbrOUk3vVav2kVNGA1HeF/AmV+1j4+/EKOa66TkJFyJw3vwzGtwKEt7MRWo1HYaZvJEDEEaY5p+VkLaRgAiu70vGeA1CwxFG228dqzHIff2FSToFb8fdylDxYLAYWpggv6cn3hRZb3NO42vDftRVNcgvPw79vQOkBa5QoYlzyxYi/hRIvw3Tjnqfi97kMpJBBdaP4oGZmY/0si13b04bdMKQ7vYKR1vtlaCxpI63zf9Da1yWwXwuPZA13OomYdHNVgjD17giYz0JsrBXBBjNQGr5/vv6ewYFpAlOMKdUFkJpGBnRCayamFzq9SHXGitA3TN2yfhEACQvjUiOg69gkLULE0y4NYlMRUyl0Cs+Nw9E6Y7rEWkuy798cDHIadOetNzzJgf1+aDIdZ2jlwup6uBuE7w9pg4zPuR9iV1xckfCgEeLo2MQuAtdcPIP2oiWPgS+1q7tsbDTAgSiw5Q81/DzAgaLFKjZu2HExbiSTQsXRoPqIqZVYyjBKvS6RmdLcleW5N7iTCNBuB9iS0+uS9woGTi30Jq79gPxrxioMqm2QDNTz2se21JX3deNYJgik7pAA+zHIvwJ1VRofP2BsrfQuDBO6n4cgoPCug4Kl0uxtSOr78OHyPqB9LITMYRdB9uKthmYU+6KVCEjoVx2SDfkclYAhcdEDxoq3sWQ1tRRPKe2BVdzJrWXE88x5qgOiWh0ce/RMcDW4QYVLKLXGMNbGkPfbjGphyEFuk2+At05uJOMJNgZnFAQxbInWyBmfEfFn92AlZ5JWaFzPPV/PbKodcdxQWMnPbjStmPcNjNuQDx71rbudrGuPNBIOrRH3qvngr+F3R0c//ckGTJ4fleMTahHDa/J/I+WMs339R88kZOaJNXaVw2/"
`endif