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


///////////////////////////////////////////////////////////////////////////////////////////
// LPDDR4 Memory model rank formed by wiring together a number of x16 dies in parallel
// Top > Channel > Rank > DRAM
///////////////////////////////////////////////////////////////////////////////////////////


module altera_emif_lpddr4_model_rank
   # (

      parameter MEM_CK_WIDTH                             = 1,
      parameter MEM_CS_WIDTH                             = 1,
      parameter MEM_CA_WIDTH                             = 7,
      parameter MEM_DQ_WIDTH                             = 16,
      parameter MEM_DMI_WIDTH                            = 2,
      parameter MEM_DQS_WIDTH                            = 2,
      parameter MEM_ROW_ADDR_WIDTH                       = 13,
      parameter MEM_COL_ADDR_WIDTH                       = 6,
      parameter MEM_BA_WIDTH                             = 4,
      parameter MEM_RESET_N_WIDTH                        = 1,
      parameter MEM_ZQ_WIDTH                             = 1,
      parameter MEM_DENSITY                              = "2Gb",
      parameter MEM_CHANNEL_IDX                          = "-1",
      parameter MEM_RANK_IDX                             = -1,
      parameter MEM_VERBOSE                              = 1

   )  (

      input  logic                                       mem_ck_t,
      input  logic                                       mem_ck_c,
      input  logic                                       mem_cke,
      input  logic         [MEM_CS_WIDTH     -1 : 0]     mem_cs,
      input  logic         [MEM_CA_WIDTH     -1 : 0]     mem_ca,
      inout  tri           [MEM_DQ_WIDTH     -1 : 0]     mem_dq,
      inout  tri           [MEM_DQS_WIDTH    -1 : 0]     mem_dqs_t,
      inout  tri           [MEM_DQS_WIDTH    -1 : 0]     mem_dqs_c,
      inout  tri           [MEM_DMI_WIDTH    -1 : 0]     mem_dmi,
      input  logic                                       mem_reset_n

   );

   timeunit 1ps;
   timeprecision 1ps;

   localparam MEM_NUM_CHIPS_PER_RANK = (MEM_DQ_WIDTH == 16) ? 1 : 
                                       ((MEM_DQ_WIDTH == 32) ? 2 :
                                       ((MEM_DQ_WIDTH == 64) ? 4 : 0));

   genvar dram_component_id;

   generate
      for(dram_component_id = 0; dram_component_id < MEM_NUM_CHIPS_PER_RANK; dram_component_id = dram_component_id + 1) begin : dram_component_gen

      localparam DQ_WIDTH_THIS_CHIP   = 16;        
      localparam DMI_WIDTH_THIS_CHIP  = 2;         
      localparam DQS_WIDTH_THIS_CHIP  = 2;         

      altera_emif_lpddr4_model_dram_component #(
         .MEM_CK_WIDTH                       (MEM_CK_WIDTH),
         .MEM_CS_WIDTH                       (MEM_CS_WIDTH),
         .MEM_CA_WIDTH                       (MEM_CA_WIDTH),
         .MEM_DQ_WIDTH                       (DQ_WIDTH_THIS_CHIP),
         .MEM_DMI_WIDTH                      (DMI_WIDTH_THIS_CHIP),
         .MEM_ROW_ADDR_WIDTH                 (MEM_ROW_ADDR_WIDTH),
         .MEM_COL_ADDR_WIDTH                 (MEM_COL_ADDR_WIDTH),
         .MEM_BA_WIDTH                       (MEM_BA_WIDTH),
         .MEM_DQS_WIDTH                      (DQS_WIDTH_THIS_CHIP),
         .MEM_RESET_N_WIDTH                  (MEM_RESET_N_WIDTH),
         .MEM_ZQ_WIDTH                       (MEM_ZQ_WIDTH),
         .MEM_DENSITY                        (MEM_DENSITY),
         .MEM_CHANNEL_IDX                    (MEM_CHANNEL_IDX),
         .MEM_RANK_IDX                       (MEM_RANK_IDX),
         .MEM_DEVICE_IDX                     (dram_component_id),
         .MEM_VERBOSE                        (MEM_VERBOSE)
      ) chip_inst (

         .mem_ck_t                           (mem_ck_t),
         .mem_ck_c                           (mem_ck_c),
         .mem_cs                             (mem_cs),
         .mem_ca                             (mem_ca),
         .mem_dq                             (mem_dq        [(dram_component_id+1)*DQ_WIDTH_THIS_CHIP-1:dram_component_id*DQ_WIDTH_THIS_CHIP]),
         .mem_dqs_t                          (mem_dqs_t     [(dram_component_id+1)*DQS_WIDTH_THIS_CHIP-1:dram_component_id*DQS_WIDTH_THIS_CHIP]),
         .mem_dqs_c                          (mem_dqs_c     [(dram_component_id+1)*DQS_WIDTH_THIS_CHIP-1:dram_component_id*DQS_WIDTH_THIS_CHIP]),
         .mem_dmi                            (mem_dmi       [(dram_component_id+1)*DMI_WIDTH_THIS_CHIP-1:dram_component_id*DMI_WIDTH_THIS_CHIP]),
         .mem_reset_n                        (mem_reset_n)
      );

      end
   endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFldU5kRuB55w/LGP5uKAuJDfOQ/vC7N81Ire6BWnz0Q6/s5eESA+fFXHtlueZ7uAECiIsB+cWIgXxGitpwGsGqa5NmcbXQzLqwVIGleE4ks1AQDVdcwDY0sJ4Os6BygUw5mJ7By9uvK+rW24pr0RSU/MmmCVQW3McezRXbVjNfU6uhB3ueZcnS2qjAklqZeLYxRx/72HOklY7WWu+SbsU5OV6hCumwvSOoGIv5GFmWxV9q8POmUyEiFePNwE2Dn27Kxz6ErkdeW+4ahvz5HY4jsX8hgmNkn8bVWqb7DCY5SxJk29Upywiwef+WoULZTZbOJVIeX8ehUzF9EDvmYBO4OerwlKF1dJluNSEJI/TZoFjyo8kLpXGBCRvMOp9RLDYTJ+3bGNDbZEE2iP8/qpCemXLkDDq1hf4cLMt17uaAO2Dx0fgjwdj4G9MfP1mmqVzYvXgXSTXdIv4pt9Hus//3OZQXsTg/llWRlGH7jn8Bqb2Oslj53n1gLmkvkViiS/0BBCuI1HHwMyxlKPOrXEH3I57Mu2SxhLDedndYu+1BVKka0NX/Psen2VCPHEuX0faKZ0vxmfk3Day0QagBvjycF2qioUD/SdW2aA2qqihkawZewg6wOOOrB6vLLkk3+6L3Wyx8IkoT6Ys5F90DePjpZ61A5xxusxEy3pu0pLVtwaOEjQHwB7YGwfihSmLd6BPWEbXmzZhB4TPrpmb9M/cpxRgpdlIEFfc/fmjvD4ymwAq4ZGoaZeLddG0mh8ir/9cZGRyiaskQqyxsS+mdj2zyCW"
`endif