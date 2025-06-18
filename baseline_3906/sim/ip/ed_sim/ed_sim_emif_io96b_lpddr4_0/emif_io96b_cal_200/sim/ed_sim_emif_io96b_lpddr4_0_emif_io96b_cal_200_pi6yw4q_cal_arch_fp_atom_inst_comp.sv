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


module cal_arch_fp_atom_inst_comp #(
   parameter IS_USED  = 0,

   parameter BASE_ADDRESS                                    = 0,

   localparam PORT_I_AVM_ADDRESS_WIDTH                        = 22,
   localparam PORT_I_AVM_WRITEDATA_WIDTH                      = 32,
   localparam PORT_O_AVM_READDATA_COMP_WIDTH                  = 32
) (
);
   timeunit 1ns;
   timeprecision 1ps;

   logic                                                      avm_clk;
   logic                                                      avm_rst_n;
   logic [PORT_I_AVM_ADDRESS_WIDTH-1:0]                       i_avm_address;
   logic                                                      i_avm_read;
   logic                                                      i_avm_write;
   logic [PORT_I_AVM_WRITEDATA_WIDTH-1:0]                     i_avm_writedata;
   logic [PORT_O_AVM_READDATA_COMP_WIDTH-1:0]                 o_avm_readdata_comp;

   tennm_compensation_block # (
      .base_address                                         (BASE_ADDRESS)
   ) comp (
      .avm_clk                                              (avm_clk),
      .avm_rst_n                                            (avm_rst_n),
      .i_avm_address                                        (i_avm_address),
      .i_avm_read                                           (i_avm_read),
      .i_avm_write                                          (i_avm_write),
      .i_avm_writedata                                      (i_avm_writedata),
      .o_avm_readdata_comp                                  (o_avm_readdata_comp)
   );

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "WgQPBVH1VBdyP1GnR2LUpBzapu3xqcPGd0xGo/Q4H4WpUeO+Hjltnkr805HvMqRkWDh3DyN3peSztswEbmtfL0y+XxwNgZXD8HzMTx127Mwzcyz+hm45kBealsJBAXnHmYFlorRoaB/cee+emunA/0c48mpmEF4OlQtcwz5XqcWvwenzsvQhJKdJ/IF87NHqDP/WjB3TeL4879eoAz/zIDUkxAOJQxnV3qexrxF9wbIPV/br7eW4hdW3Qzkdp1SZjbvOmVm0xQ8CITI5YPhM06Tvx7nkLRuLwz8sbWjlRo9+qdTEReMiqewYPDwOFR/cAkXYkJh2g2AaFVg0GuGJAv/HjidwuvE2YV/Q3GvkooHL4oYgZbN659LRKJfgSspjZob1EQhlVEm3Y0RJ3OvvBQoBHpjaYjM13QBdtDHrr8yGIuI7ra5bz11SgtdQKlmj//l70Xti+WDnc5fq2+w1X3KVo9eDZAkpBBqFBcXtenOVAFd2f8yJiAN/n/uWLpjIAPK+sIEE8iz6TEAM+BNlspLfiJEL5L8ZgQfaF2w73MwrRaH2atQkPei3ELEMu0cc7dpRczgJtrmT83UzmfvCw9Upa2FebTEppYcMGdSe/JgRBuPOjoz6UkEupxIgGRK2ZFXRuIJm/8PLresCtids5Tu0hyenFRE+7e7WX9qQQgysiX6gnFOesNSMAyd3gxpQOqlnPklJul3vuG+vI+xkJW68Gi2V6U6ZwdM+K8CeWsc9LDG3FHNXomozz6GrbihbM2LkC0RCLMmZYkwoJnWwkJFVF6EUtryHPkQH5ww+Hl290xrlDVpJF9+ybbOwYVhbSOa37mKygLWyLKjUlnxsZWwbvkAWor4JdHfCQuesCXaPftIB4AEdCKooC9FcbRaSP4MxV1xkC4gbholDQlmQ8fz9JT3NOsV9eXx0cVTRsv5JWZoQ3Y0oPbb3fBK9vIa7XvtrkVKbTM2rq2T/3Wy6zweOXXsZCMIV+5V+EmHi3TByqAG50W8oy1CPuQaxWfak"
`endif