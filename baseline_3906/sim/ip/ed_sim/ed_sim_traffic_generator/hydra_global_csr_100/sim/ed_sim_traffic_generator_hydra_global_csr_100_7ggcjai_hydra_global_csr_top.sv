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



module ed_sim_traffic_generator_hydra_global_csr_100_7ggcjai # (
   parameter NUM_DRIVERS                           = 1,
   parameter ENABLE_CSR_INTF                       = 1,
   parameter RUN_ON_RESET                          = 1,
   parameter CALL_SIM_FINISH                       = 1,


   parameter PORT_HYDRA_DRIVER_SYNC_POST_OUT_WIDTH = 1,
   parameter PORT_HYDRA_DRIVER_SYNC_POST_IN_WIDTH  = 1,
   parameter PORT_HYDRA_DRIVER_SYNC_WAIT_OUT_WIDTH = 1,
   parameter PORT_HYDRA_DRIVER_SYNC_WAIT_IN_WIDTH  = 1,


   parameter PORT_HYDRA_APB3_PADDR_WIDTH           = 1,
   parameter PORT_HYDRA_APB3_PWDATA_WIDTH          = 1,
   parameter PORT_HYDRA_APB3_PRDATA_WIDTH          = 1
) (

   input  logic                                             driver_clk_0,
   input  logic                                             driver_reset_n_0,              



   output logic                                             driver_run_0,
   input  logic                                             driver_done_0,
   input  logic                                             driver_error_0,



   input  logic [PORT_HYDRA_DRIVER_SYNC_POST_OUT_WIDTH-1:0] driver_post_out_0,
   output logic [PORT_HYDRA_DRIVER_SYNC_POST_IN_WIDTH-1:0]  driver_post_in_0,

   input  logic [PORT_HYDRA_DRIVER_SYNC_WAIT_OUT_WIDTH-1:0] driver_wait_out_0,
   output logic [PORT_HYDRA_DRIVER_SYNC_WAIT_IN_WIDTH-1:0]  driver_wait_in_0,



   input  logic                                             clk,
   input  logic                                             reset_n,
   
   output logic                                             status_done,
   output logic                                             status_error,


   input  logic [PORT_HYDRA_APB3_PWDATA_WIDTH-1:0]          apb3_pwdata,
   input  logic                                             apb3_penable,
   input  logic                                             apb3_pwrite,
   input  logic                                             apb3_psel,
   output logic [PORT_HYDRA_APB3_PRDATA_WIDTH-1:0]          apb3_prdata,
   output logic                                             apb3_pready,
   output logic                                             apb3_pslverr,
   input  logic [PORT_HYDRA_APB3_PADDR_WIDTH-1:0]           apb3_paddr

);
   initial begin
      assert(NUM_DRIVERS  == 1)
         else $fatal(1, "IP was configured for NUM_DRIVERS=%0d, but RTL has NUM_DRIVERS=%0d", 1, NUM_DRIVERS);
   end

   localparam DRIVER_SYNC_POST_WIDTH = PORT_HYDRA_DRIVER_SYNC_POST_OUT_WIDTH;
   localparam DRIVER_SYNC_WAIT_WIDTH = PORT_HYDRA_DRIVER_SYNC_WAIT_OUT_WIDTH;

   logic reset_int;

   logic [NUM_DRIVERS-1:0] driver_clk;
   logic [NUM_DRIVERS-1:0] driver_reset_n;

   logic [NUM_DRIVERS-1:0] driver_run_ext, driver_run_int;
   logic [NUM_DRIVERS-1:0] driver_done_ext, driver_done_int;
   logic [NUM_DRIVERS-1:0] driver_error_ext, driver_error_int;
   
   logic [NUM_DRIVERS-1:0][DRIVER_SYNC_POST_WIDTH-1:0] driver_post_out;
   logic [NUM_DRIVERS-1:0][DRIVER_SYNC_POST_WIDTH-1:0] driver_post_in;

   logic [NUM_DRIVERS-1:0][DRIVER_SYNC_WAIT_WIDTH-1:0] driver_wait_out;
   logic [NUM_DRIVERS-1:0][DRIVER_SYNC_WAIT_WIDTH-1:0] driver_wait_in;

   hydra_local_reset_tree # (
      .ACTIVE_LOW             (0),
      .ASYNC_INPUT            (1),
      .OUTPUT_ASSERT_LENGTH   (16),
      .TREE_DEPTH             (3),
      .TREE_NODE_FANOUT       (30)
   ) reset_tree (
      .clk        (clk),
      .reset_in   (~reset_n),
      .reset_out  (reset_int)
   );

   always_comb begin
      driver_clk[0] = driver_clk_0; driver_reset_n[0] = driver_reset_n_0;

      driver_run_0 = driver_run_ext[0]; driver_done_ext[0] = driver_done_0; driver_error_ext[0] = driver_error_0;

      driver_post_in_0 = driver_post_in[0]; driver_post_out[0] = driver_post_out_0;

      driver_wait_in_0 = driver_wait_in[0]; driver_wait_out[0] = driver_wait_out_0;
   end

   hydra_global_csr_sync # (
      .NUM_DRIVERS               (NUM_DRIVERS),
      .ENABLE_CSR_INTF           (ENABLE_CSR_INTF),
      .DRIVER_SYNC_POST_WIDTH    (DRIVER_SYNC_POST_WIDTH),
      .DRIVER_SYNC_WAIT_WIDTH    (DRIVER_SYNC_WAIT_WIDTH)
   ) global_csr_sync (
      .global_csr_clk      (clk),
      .global_csr_reset_n  (~reset_int),

      .driver_clk          (driver_clk),
      .driver_reset_n      (driver_reset_n),

      .driver_run_ext      (driver_run_ext),
      .driver_done_ext     (driver_done_ext),
      .driver_error_ext    (driver_error_ext),

      .driver_run_int      (driver_run_int),
      .driver_done_int     (driver_done_int),
      .driver_error_int    (driver_error_int),

      .driver_post_out     (driver_post_out),
      .driver_post_in      (driver_post_in),
      .driver_wait_out     (driver_wait_out),
      .driver_wait_in      (driver_wait_in)
   );

   hydra_global_csr_impl # (
      .NUM_DRIVERS                  (NUM_DRIVERS),
      .ENABLE_CSR_INTF              (ENABLE_CSR_INTF),
      .RUN_ON_RESET                 (RUN_ON_RESET),
      .CALL_SIM_FINISH              (CALL_SIM_FINISH),


      .PORT_HYDRA_APB3_PADDR_WIDTH  (PORT_HYDRA_APB3_PADDR_WIDTH),
      .PORT_HYDRA_APB3_PWDATA_WIDTH (PORT_HYDRA_APB3_PWDATA_WIDTH),
      .PORT_HYDRA_APB3_PRDATA_WIDTH (PORT_HYDRA_APB3_PRDATA_WIDTH)
   ) global_csr_impl (
      .clk              (clk),
      .reset_n          (~reset_int),

      .driver_run       (driver_run_int),
      .driver_done      (driver_done_int),
      .driver_error     (driver_error_int),

      .status_done      (status_done),
      .status_error     (status_error),

      .apb3_pwdata      (apb3_pwdata),
      .apb3_penable     (apb3_penable),
      .apb3_pwrite      (apb3_pwrite),
      .apb3_psel        (apb3_psel),
      .apb3_prdata      (apb3_prdata),
      .apb3_pready      (apb3_pready),
      .apb3_pslverr     (apb3_pslverr),
      .apb3_paddr       (apb3_paddr)
   );

endmodule



