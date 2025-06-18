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
// Models a single LPDDR4 channel formed by one or two ranks
// Top > Channel > Rank > DRAM
///////////////////////////////////////////////////////////////////////////////

module altera_emif_lpddr4_model_channel
   # (

      parameter MEM_CKE_WIDTH                         = 1,
      parameter MEM_CK_WIDTH                          = 1,
      parameter MEM_CS_WIDTH                          = 1,
      parameter MEM_CA_WIDTH                          = 7,
      parameter MEM_DQ_WIDTH                          = 16,
      parameter MEM_DMI_WIDTH                         = 2,
      parameter MEM_DQS_WIDTH                         = 2,
      parameter MEM_ROW_ADDR_WIDTH                    = 13,
      parameter MEM_COL_ADDR_WIDTH                    = 6,
      parameter MEM_BA_WIDTH                          = 4,
      parameter MEM_RESET_N_WIDTH                     = 1,
      parameter MEM_ZQ_WIDTH                          = 1,
      parameter MEM_DENSITY                           = "2Gb",
      parameter MEM_CHANNEL_IDX                       = "-1",
      parameter MEM_NUM_RANKS                         = 1,
      parameter MEM_VERBOSE                           = 1
   
   ) (

      input  logic                                    mem_ck_t,
      input  logic                                    mem_ck_c,
      input  logic                                    mem_cke,
      input  logic      [MEM_CS_WIDTH     -1 : 0]     mem_cs,
      input  logic      [MEM_CA_WIDTH     -1 : 0]     mem_ca,
      inout  tri        [MEM_DQ_WIDTH     -1 : 0]     mem_dq,
      inout  tri        [MEM_DQS_WIDTH    -1 : 0]     mem_dqs_t,
      inout  tri        [MEM_DQS_WIDTH    -1 : 0]     mem_dqs_c,
      inout  tri        [MEM_DMI_WIDTH    -1 : 0]     mem_dmi,
      input  logic                                    mem_reset_n
   
   );


   timeunit 1ps;
   timeprecision 1ps;

   genvar rank_id;
   generate
      for (rank_id = 0; rank_id < MEM_CS_WIDTH; rank_id = rank_id + 1) begin : rank_gen
      
         altera_emif_lpddr4_model_rank # (
            .MEM_CK_WIDTH                       (MEM_CK_WIDTH),
            .MEM_CA_WIDTH                       (MEM_CA_WIDTH),
            .MEM_DQ_WIDTH                       (MEM_DQ_WIDTH),
            .MEM_DQS_WIDTH                      (MEM_DQS_WIDTH),
            .MEM_DMI_WIDTH                      (MEM_DMI_WIDTH),
            .MEM_ROW_ADDR_WIDTH                 (MEM_ROW_ADDR_WIDTH),
            .MEM_COL_ADDR_WIDTH                 (MEM_COL_ADDR_WIDTH),
            .MEM_BA_WIDTH                       (MEM_BA_WIDTH),
            .MEM_RESET_N_WIDTH                  (MEM_RESET_N_WIDTH),
            .MEM_ZQ_WIDTH                       (MEM_ZQ_WIDTH),
            .MEM_DENSITY                        ("2Gb"),
            .MEM_CHANNEL_IDX                    (MEM_CHANNEL_IDX),
            .MEM_RANK_IDX                       (rank_id),
            .MEM_VERBOSE                        (MEM_VERBOSE)

         ) rank_inst (
            
            .mem_ck_t                           (mem_ck_t),
            .mem_ck_c                           (mem_ck_c),
            .mem_cke                            (mem_cke),
            .mem_cs                             (mem_cs[rank_id]),
            .mem_ca                             (mem_ca),
            .mem_dq                             (mem_dq),
            .mem_dqs_t                          (mem_dqs_t),
            .mem_dqs_c                          (mem_dqs_c),
            .mem_dmi                            (mem_dmi),
            .mem_reset_n                        (mem_reset_n)
         
         );

      end
   endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFlc9MyCEtlGxKxnc19sWCkW/m/dgmNVyG7zuZMP7IxOWsV3oe7Dm6LMm2kqs8nwr/KAvO/qrm2XcY75F7spD5ZyabJ/s5Wse04DzQj5Hc6dHJy7tG6XIfMn+mVKlqS7YnuMicvoLjsFPZzkF5VMB8SjscX0YGxSMgpazEI05X3mQ2ExH+dKI0DrGrtP3XmH3aa3uJWKmiWozTJm5ImgAgJOXXRP5l4MQXO5uDtLeUa3e1FtiJITmi+ZVGGkB1lGqDz5mITTyxDXN0ofG6hErE4B9Liad/1/r5/Fp8aCoMxFwcbHvdeUAyxzjTWx4XVm4byYyVPM16JmKSdqqSFI8gjzgTYs7z8aWrisWn8QnQNTK1hLDpWfUGpXgk/U61notVs5cRODLhmVsl4BwwJi4mgDLQpgJTdL6Cv8XRdlDQSMNFDgqwOWQL2r9rqs0e2g3AF4Yogr45/XCqMGU4j9AJazCSS605J6AaPdWB7FFNappjqXscTLlop+eEU2PQFk2dcqZizqdYKntSOEhzRcSkD0Hn5p3wt8dZQ2rZySgt9fsdlZRkyREbr271DshZu+B3oLJmlIImesR8eela0yNN8KC3ISWHbEikGW0r6l5F5x9Xppx7ZRTsihe76f4d9eVOoNDaWLtgpZHjwrZrMiHPgWgEVTAPvOeSLB83Rtep/sRYaeE85q83uZgK1dvfIV1/qvmOJ2r0MmJAR5dHP6z+9VeuQxDfrcD4JCn5bd3gOc/q+/fkNTlk9yTx/pxtK3LPWTq7V3v3KbuxAocRlaCuC6v"
`endif