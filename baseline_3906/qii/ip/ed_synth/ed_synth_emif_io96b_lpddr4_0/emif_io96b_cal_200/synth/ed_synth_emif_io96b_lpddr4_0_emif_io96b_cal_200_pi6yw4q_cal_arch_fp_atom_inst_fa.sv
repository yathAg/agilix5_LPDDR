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



module stdfn_inst_fa_c2p_ssm #(
   parameter IS_USED  = 0,

   parameter SSM_C2P_DATA_MODE                               = "SSM_C2P_DATA_MODE_BYPASS",
   parameter FA_CORE_PERIPH_CLK_SEL_DATA_MODE                = "FA_CORE_PERIPH_CLK_SEL_DATA_MODE_UNUSED",
   parameter SSM_P2C_DATA_MODE                               = "SSM_P2C_DATA_MODE_BYPASS",
   localparam PORT_I_SSM_C2P_WIDTH                            = 40,
   localparam PORT_O_SSM_C2P_WIDTH                            = 40,
   localparam PORT_I_SSM_P2C_WIDTH                            = 20,
   localparam PORT_O_SSM_P2C_WIDTH                            = 20
) (
   input                                                      i_core_clk,
   input [PORT_I_SSM_C2P_WIDTH-1:0]                           i_ssm_c2p,
   output [PORT_O_SSM_C2P_WIDTH-1:0]                           o_ssm_c2p,
   input                                                      i_phy_clk_fr,
   input                                                      i_phy_clk_sync,
   input [PORT_I_SSM_P2C_WIDTH-1:0]                           i_ssm_p2c,
   output [PORT_O_SSM_P2C_WIDTH-1:0]                           o_ssm_p2c
);
   timeunit 1ns;
   timeprecision 1ps;

   tennm_ssm_c2p_fabric_adaptor # (
      .ssm_c2p_data_mode                                    (SSM_C2P_DATA_MODE),
      .fa_core_periph_clk_sel_data_mode                     (FA_CORE_PERIPH_CLK_SEL_DATA_MODE)
   ) fa_c2p_ssm (
      .i_core_clk                                           (i_core_clk),
      .i_phy_clk_fr                                         (i_phy_clk_fr),
      .i_phy_clk_sync                                       (i_phy_clk_sync),
      .i_ssm_c2p                                            (i_ssm_c2p),
      .o_ssm_c2p                                            (o_ssm_c2p)
   );
   tennm_ssm_p2c_fabric_adaptor # (
      .ssm_p2c_data_mode                                    (SSM_P2C_DATA_MODE),
      .fa_core_periph_clk_sel_data_mode                     (FA_CORE_PERIPH_CLK_SEL_DATA_MODE)
   ) fa_p2c_ssm (
      .i_core_clk                                           (i_core_clk),
      .i_phy_clk_fr                                         (i_phy_clk_fr),
      .i_phy_clk_sync                                       (i_phy_clk_sync),
      .i_ssm_p2c                                            (i_ssm_p2c),
      .o_ssm_p2c                                            (o_ssm_p2c)
   );

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "WgQPBVH1VBdyP1GnR2LUpBzapu3xqcPGd0xGo/Q4H4WpUeO+Hjltnkr805HvMqRkWDh3DyN3peSztswEbmtfL0y+XxwNgZXD8HzMTx127Mwzcyz+hm45kBealsJBAXnHmYFlorRoaB/cee+emunA/0c48mpmEF4OlQtcwz5XqcWvwenzsvQhJKdJ/IF87NHqDP/WjB3TeL4879eoAz/zIDUkxAOJQxnV3qexrxF9wbIz0z4WZs+eth3fp1Caj7+0y3uvf0o5KPcNWZYQmFEM4NsxIH5/copFHpHAf1AIa7kJCIaQZCBDzvMf3Ey66sUnSWBbbSJfbdJRsp4hIfcL4cfLDDIMYIHpQCXkuOpm+VoB6uAlh6EHt328BT3Nw9Mlq5SgClygLMb6Eql/EhnZxZs6zOWv61DMRt3mbFrZUHYzKCA0Odfjj0nmWarDHpy6MH6Wns5sfQKYz74aX81W06nRcH2pcqGYsQeayPkYvDhZ2CYbxlY41z/8cjRyigI/uXmCB/Sf7MACC0Y13lwZT41c4+CYCR5vtQIyhe2YAt5NnlweCIzTJ0k0q/Z2NtpCXmHbjRMVvri+hsuRH8rrrvcQ/DQW8D3VRgWEayi//Na3F9Vbe97kzITkIW/HfFz+umeJ+rGG1hgk+tk0dREnCGvkmng6pgZQnGxozDQrd7XZcffQw0+IkInb58r9J4jv6ICtNZ1jOWYjnKlzoiBUz+Eo5FnYT1gdvZUXbOFADEcTxR0vxzBLrKFuuddO9DWmelihd0v2P1lbKL7Uft5lAxrhCUFo0zWK0d+GZEIvgq29D1gOwFQtRPOnIRMZfsTNsE+HIL+B6+n/YStCucYkuByKUG0zcPc7iNTyIs7Lp7KSygzI8i3ZHhyc5/SUpjOTL+IgUTYvxyedg57dUkQNwN7IK6vu1/Ga1R5EACrNV/IL21mjo0fj9oej+bLa2iiJ5Wp433sWj6wz26qqd7taP1dWrMEuSfJzzEwZkyLhiqsiSr9DDoOYIWA2aoyffuLP"
`endif