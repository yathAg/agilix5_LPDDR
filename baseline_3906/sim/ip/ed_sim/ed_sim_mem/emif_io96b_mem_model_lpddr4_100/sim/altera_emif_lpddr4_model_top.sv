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


///////////////////////////////////////////////////////////////////////////////
// Top-level wrapper of LPDDR4 Per-Channel Memory Model formed by wiring together one or two ranks in parallel
// All four channels will have ports instantiated, but only the necessary amount of channels used will actually be tied to something in the wrapper layer above this module
///////////////////////////////////////////////////////////////////////////////


module altera_emif_lpddr4_model_top
   # (


      parameter MEM_CK_C_WIDTH                           = 1,
      parameter MEM_CK_T_WIDTH                           = 1,
      parameter MEM_CKE_WIDTH                            = 1,
      parameter MEM_CS_WIDTH                             = 1,
      parameter MEM_CA_WIDTH                             = 7,
      parameter MEM_DQ_WIDTH                             = 32,
      parameter MEM_DMI_WIDTH                            = 4,
      parameter MEM_DQS_T_WIDTH                          = 4,                 
      parameter MEM_DQS_C_WIDTH                          = 4,
      parameter MEM_RESET_N_WIDTH                        = 1,                 
      parameter MEM_ZQ_WIDTH                             = 1,                 
      parameter MEM_ROW_ADDR_WIDTH                       = 13,                
      parameter MEM_COL_ADDR_WIDTH                       = 6,                 
      parameter MEM_BA_WIDTH                             = 4,                 
      parameter MEM_NUM_CHANNELS                         = 4,                 
      parameter MEM_NUM_RANKS                            = 1,                 
      parameter MEM_VERBOSE                              = 1,                 

      parameter CTRL_RD_DBI_FSP0_EN                      = 0,
      parameter CTRL_WR_DBI_FSP0_EN                      = 0,
      parameter CTRL_RD_DBI_FSP1_EN                      = 0,
      parameter CTRL_WR_DBI_FSP1_EN                      = 0
   ) (

      input  logic                                       mem_reset_n_0,
      input  logic         [MEM_ZQ_WIDTH     -1 : 0]     mem_zq_0,

      input  logic                                       mem_ck_t_0,
      input  logic                                       mem_ck_c_0,
      input  logic                                       mem_cke_0,
      input  logic         [MEM_CS_WIDTH     -1 : 0]     mem_cs_0,
      input  logic         [MEM_CA_WIDTH     -1 : 0]     mem_ca_0,
      inout  tri           [MEM_DQ_WIDTH     -1 : 0]     mem_dq_0,
      inout  tri           [MEM_DQS_T_WIDTH  -1 : 0]     mem_dqs_t_0,
      inout  tri           [MEM_DQS_C_WIDTH  -1 : 0]     mem_dqs_c_0,
      inout  tri           [MEM_DMI_WIDTH    -1 : 0]     mem_dmi_0,

      input  logic                                       mem_ck_t_1,
      input  logic                                       mem_ck_c_1,
      input  logic                                       mem_cke_1,
      input  logic         [MEM_CS_WIDTH     -1 : 0]     mem_cs_1,
      input  logic         [MEM_CA_WIDTH     -1 : 0]     mem_ca_1,
      inout  tri           [MEM_DQ_WIDTH     -1 : 0]     mem_dq_1,
      inout  tri           [MEM_DQS_T_WIDTH  -1 : 0]     mem_dqs_t_1,
      inout  tri           [MEM_DQS_C_WIDTH  -1 : 0]     mem_dqs_c_1,
      inout  tri           [MEM_DMI_WIDTH    -1 : 0]     mem_dmi_1,

      input  logic                                       mem_ck_t_2,
      input  logic                                       mem_ck_c_2,
      input  logic                                       mem_cke_2,
      input  logic         [MEM_CS_WIDTH     -1 : 0]     mem_cs_2,
      input  logic         [MEM_CA_WIDTH     -1 : 0]     mem_ca_2,
      inout  tri           [MEM_DQ_WIDTH     -1 : 0]     mem_dq_2,
      inout  tri           [MEM_DQS_T_WIDTH  -1 : 0]     mem_dqs_t_2,
      inout  tri           [MEM_DQS_C_WIDTH  -1 : 0]     mem_dqs_c_2,
      inout  tri           [MEM_DMI_WIDTH    -1 : 0]     mem_dmi_2,

      input  logic                                       mem_ck_t_3,
      input  logic                                       mem_ck_c_3,
      input  logic                                       mem_cke_3,
      input  logic         [MEM_CS_WIDTH     -1 : 0]     mem_cs_3,
      input  logic         [MEM_CA_WIDTH     -1 : 0]     mem_ca_3,
      inout  tri           [MEM_DQ_WIDTH     -1 : 0]     mem_dq_3,
      inout  tri           [MEM_DQS_T_WIDTH  -1 : 0]     mem_dqs_t_3,
      inout  tri           [MEM_DQS_C_WIDTH  -1 : 0]     mem_dqs_c_3,
      inout  tri           [MEM_DMI_WIDTH    -1 : 0]     mem_dmi_3,

      output logic                                       oct_rzqin_0,
      output logic                                       oct_rzqin_1,
      output logic                                       oct_rzqin_2,
      output logic                                       oct_rzqin_3
   );


   timeunit 1ps;
   timeprecision 1ps;

   localparam MEM_DENSITY = "2Gb";

   assign oct_rzqin_0 = 'h0;
   assign oct_rzqin_1 = 'h0;

   altera_emif_lpddr4_model_channel # (
      .MEM_CK_WIDTH                       (MEM_CK_T_WIDTH),
      .MEM_CS_WIDTH                       (MEM_CS_WIDTH),
      .MEM_CA_WIDTH                       (MEM_CA_WIDTH),
      .MEM_DQ_WIDTH                       (MEM_DQ_WIDTH),
      .MEM_DMI_WIDTH                      (MEM_DMI_WIDTH),
      .MEM_RESET_N_WIDTH                  (MEM_RESET_N_WIDTH),
      .MEM_ZQ_WIDTH                       (MEM_ZQ_WIDTH),
      .MEM_ROW_ADDR_WIDTH                 (MEM_ROW_ADDR_WIDTH),
      .MEM_COL_ADDR_WIDTH                 (MEM_COL_ADDR_WIDTH),
      .MEM_BA_WIDTH                       (MEM_BA_WIDTH),
      .MEM_DQS_WIDTH                      (MEM_DQS_T_WIDTH),
      .MEM_DENSITY                        ("2Gb"),
      .MEM_CHANNEL_IDX                    ("0"),
      .MEM_NUM_RANKS                      (MEM_NUM_RANKS),
      .MEM_VERBOSE                        (MEM_VERBOSE)

   )  channel_A_inst (

      .mem_ck_t                           (mem_ck_t_0),
      .mem_ck_c                           (mem_ck_c_0),
      .mem_cke                            (mem_cke_0),
      .mem_cs                             (mem_cs_0),
      .mem_ca                             (mem_ca_0),
      .mem_dq                             (mem_dq_0),
      .mem_dqs_t                          (mem_dqs_t_0),
      .mem_dqs_c                          (mem_dqs_c_0),
      .mem_dmi                            (mem_dmi_0),
      .mem_reset_n                        (mem_reset_n_0)

   );

   altera_emif_lpddr4_model_channel # (
      .MEM_CK_WIDTH                       (MEM_CK_T_WIDTH),
      .MEM_CS_WIDTH                       (MEM_CS_WIDTH),
      .MEM_CA_WIDTH                       (MEM_CA_WIDTH),
      .MEM_DQ_WIDTH                       (MEM_DQ_WIDTH),
      .MEM_DMI_WIDTH                      (MEM_DMI_WIDTH),
      .MEM_RESET_N_WIDTH                  (MEM_RESET_N_WIDTH),
      .MEM_ZQ_WIDTH                       (MEM_ZQ_WIDTH),
      .MEM_ROW_ADDR_WIDTH                 (MEM_ROW_ADDR_WIDTH),
      .MEM_COL_ADDR_WIDTH                 (MEM_COL_ADDR_WIDTH),
      .MEM_BA_WIDTH                       (MEM_BA_WIDTH),
      .MEM_DQS_WIDTH                      (MEM_DQS_T_WIDTH),
      .MEM_DENSITY                        ("2Gb"),
      .MEM_CHANNEL_IDX                    ("1"),
      .MEM_NUM_RANKS                      (MEM_NUM_RANKS),
      .MEM_VERBOSE                        (MEM_VERBOSE)

   ) channel_B_inst (

      .mem_ck_t                           (mem_ck_t_1),
      .mem_ck_c                           (mem_ck_c_1),
      .mem_cke                            (mem_cke_1),
      .mem_cs                             (mem_cs_1),
      .mem_ca                             (mem_ca_1),
      .mem_dq                             (mem_dq_1),
      .mem_dqs_t                          (mem_dqs_t_1),
      .mem_dqs_c                          (mem_dqs_c_1),
      .mem_dmi                            (mem_dmi_1),
      .mem_reset_n                        (mem_reset_n_0)

   );

   generate 
      if (MEM_NUM_CHANNELS == 4) begin
         altera_emif_lpddr4_model_channel # (
            .MEM_CK_WIDTH                       (MEM_CK_T_WIDTH),
            .MEM_CS_WIDTH                       (MEM_CS_WIDTH),
            .MEM_CA_WIDTH                       (MEM_CA_WIDTH),
            .MEM_DQ_WIDTH                       (MEM_DQ_WIDTH),
            .MEM_DMI_WIDTH                      (MEM_DMI_WIDTH),
            .MEM_RESET_N_WIDTH                  (MEM_RESET_N_WIDTH),
            .MEM_ZQ_WIDTH                       (MEM_ZQ_WIDTH),
            .MEM_ROW_ADDR_WIDTH                 (MEM_ROW_ADDR_WIDTH),
            .MEM_COL_ADDR_WIDTH                 (MEM_COL_ADDR_WIDTH),
            .MEM_BA_WIDTH                       (MEM_BA_WIDTH),
            .MEM_DQS_WIDTH                      (MEM_DQS_T_WIDTH),
            .MEM_DENSITY                        ("2Gb"),
            .MEM_CHANNEL_IDX                    ("2"),
            .MEM_NUM_RANKS                      (MEM_NUM_RANKS),
            .MEM_VERBOSE                        (MEM_VERBOSE)

         ) channel_C_inst (

            .mem_ck_t                           (mem_ck_t_2),
            .mem_ck_c                           (mem_ck_c_2),
            .mem_cke                            (mem_cke_2),
            .mem_cs                             (mem_cs_2),
            .mem_ca                             (mem_ca_2),
            .mem_dq                             (mem_dq_2),
            .mem_dqs_t                          (mem_dqs_t_2),
            .mem_dqs_c                          (mem_dqs_c_2),
            .mem_dmi                            (mem_dmi_2),
            .mem_reset_n                        (mem_reset_n_0)

         );

         altera_emif_lpddr4_model_channel # (
            .MEM_CK_WIDTH                       (MEM_CK_T_WIDTH),
            .MEM_CS_WIDTH                       (MEM_CS_WIDTH),
            .MEM_CA_WIDTH                       (MEM_CA_WIDTH),
            .MEM_DQ_WIDTH                       (MEM_DQ_WIDTH),
            .MEM_DMI_WIDTH                      (MEM_DMI_WIDTH),
            .MEM_RESET_N_WIDTH                  (MEM_RESET_N_WIDTH),
            .MEM_ZQ_WIDTH                       (MEM_ZQ_WIDTH),
            .MEM_ROW_ADDR_WIDTH                 (MEM_ROW_ADDR_WIDTH),
            .MEM_COL_ADDR_WIDTH                 (MEM_COL_ADDR_WIDTH),
            .MEM_BA_WIDTH                       (MEM_BA_WIDTH),
            .MEM_DQS_WIDTH                      (MEM_DQS_T_WIDTH),
            .MEM_DENSITY                        ("2Gb"),
            .MEM_CHANNEL_IDX                    ("3"),
            .MEM_NUM_RANKS                      (MEM_NUM_RANKS),
            .MEM_VERBOSE                        (MEM_VERBOSE)

         ) channel_D_inst (

            .mem_ck_t                           (mem_ck_t_3),
            .mem_ck_c                           (mem_ck_c_3),
            .mem_cke                            (mem_cke_3),
            .mem_cs                             (mem_cs_3),
            .mem_ca                             (mem_ca_3),
            .mem_dq                             (mem_dq_3),
            .mem_dqs_t                          (mem_dqs_t_3),
            .mem_dqs_c                          (mem_dqs_c_3),
            .mem_dmi                            (mem_dmi_3),
            .mem_reset_n                        (mem_reset_n_0)

         );
      end
      
   endgenerate
   
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFleAMxKG7Qj8vsIjRtOWZ5L37nJTGxxa9qBEZc6I769Acsx9rppwl0kp1J5IuCrPlFhOYCnKMhTDX1STS7o7bYW9/5oE5dYrsXy2pP8cfSk407AQmudPOtmYfbYbPgQ3YQEJCsDS6hTsW9gxge3r0y63H/MbCOqXL/ZM3/L64cD06PnGS5LN/81LMUDlGXvJUUWEqXHiNoP2+JMf7UCKrXqerUgjIhuNcEYroHR0wHo67cI0+hIb9z7okrRJteq/6qPKoww3ELlR/thVG6uee7eURH+NzFEuJe4g5hwv45xE10D7chgkxjcpm22Ba8BCTT4bW5N/mof14vNtMOrpLikxB9QhXfhn19oD8y1wXTSEuGNeTkiRJMWYJDiRu67aehm5ce6qPY4ltrOW5AYFaYzoNLv3XbITyPo5ydS7IhDz53G4+AhCc7lcf/qJghAhL4tN1SsTE2amuWf96+4LKxkxs+3sHonJDo3FcAmWNVurttQT/A63gA1t0LOcs5Iz1w11CN3j33s5tUl3e5OYYeq3W7J8mv839VH6AToHGabT4BMoYUeuADIDmFK0uAKSmVEZci/qlzjCaYIpeTf/wz00umRNN2td6Kz9epwDtZ9sPSKJy90lNTKDmsKA5esOxuP6OyzLLuWcw8vdc6cDi6z476cuCuO336bGCU17km9nmP2TBtKssiSTIAVJoy5ErPIneAO1xKBuJscF4vOwIqMMwMtleFDOdxtXuuoBtsk9ivS4zNcRARxTGKdXtEr4BpTJTLcvkcqTj5QOjwyEW8IT"
`endif