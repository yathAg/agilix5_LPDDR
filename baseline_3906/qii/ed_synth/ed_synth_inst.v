	ed_synth u0 (
		.emif_io96b_lpddr4_0_mem_0_mem_cs            (_connected_to_emif_io96b_lpddr4_0_mem_0_mem_cs_),            //  output,   width = 1,       emif_io96b_lpddr4_0_mem_0.mem_cs
		.emif_io96b_lpddr4_0_mem_0_mem_ca            (_connected_to_emif_io96b_lpddr4_0_mem_0_mem_ca_),            //  output,   width = 6,                                .mem_ca
		.emif_io96b_lpddr4_0_mem_0_mem_cke           (_connected_to_emif_io96b_lpddr4_0_mem_0_mem_cke_),           //  output,   width = 1,                                .mem_cke
		.emif_io96b_lpddr4_0_mem_0_mem_dq            (_connected_to_emif_io96b_lpddr4_0_mem_0_mem_dq_),            //   inout,  width = 32,                                .mem_dq
		.emif_io96b_lpddr4_0_mem_0_mem_dqs_t         (_connected_to_emif_io96b_lpddr4_0_mem_0_mem_dqs_t_),         //   inout,   width = 4,                                .mem_dqs_t
		.emif_io96b_lpddr4_0_mem_0_mem_dqs_c         (_connected_to_emif_io96b_lpddr4_0_mem_0_mem_dqs_c_),         //   inout,   width = 4,                                .mem_dqs_c
		.emif_io96b_lpddr4_0_mem_0_mem_dmi           (_connected_to_emif_io96b_lpddr4_0_mem_0_mem_dmi_),           //   inout,   width = 4,                                .mem_dmi
		.emif_io96b_lpddr4_0_mem_ck_0_mem_ck_t       (_connected_to_emif_io96b_lpddr4_0_mem_ck_0_mem_ck_t_),       //  output,   width = 1,    emif_io96b_lpddr4_0_mem_ck_0.mem_ck_t
		.emif_io96b_lpddr4_0_mem_ck_0_mem_ck_c       (_connected_to_emif_io96b_lpddr4_0_mem_ck_0_mem_ck_c_),       //  output,   width = 1,                                .mem_ck_c
		.emif_io96b_lpddr4_0_mem_reset_n_mem_reset_n (_connected_to_emif_io96b_lpddr4_0_mem_reset_n_mem_reset_n_), //  output,   width = 1, emif_io96b_lpddr4_0_mem_reset_n.mem_reset_n
		.emif_io96b_lpddr4_0_oct_0_oct_rzqin         (_connected_to_emif_io96b_lpddr4_0_oct_0_oct_rzqin_),         //   input,   width = 1,       emif_io96b_lpddr4_0_oct_0.oct_rzqin
		.ref_clk_clk                                 (_connected_to_ref_clk_clk_),                                 //   input,   width = 1,                         ref_clk.clk
		.ref_clk_usr_pll_clk                         (_connected_to_ref_clk_usr_pll_clk_)                          //   input,   width = 1,                 ref_clk_usr_pll.clk
	);

