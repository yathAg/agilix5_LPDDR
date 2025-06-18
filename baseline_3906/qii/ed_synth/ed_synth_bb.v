module ed_synth (
		output wire [0:0]  emif_io96b_lpddr4_0_mem_0_mem_cs,            //       emif_io96b_lpddr4_0_mem_0.mem_cs
		output wire [5:0]  emif_io96b_lpddr4_0_mem_0_mem_ca,            //                                .mem_ca
		output wire [0:0]  emif_io96b_lpddr4_0_mem_0_mem_cke,           //                                .mem_cke
		inout  wire [31:0] emif_io96b_lpddr4_0_mem_0_mem_dq,            //                                .mem_dq
		inout  wire [3:0]  emif_io96b_lpddr4_0_mem_0_mem_dqs_t,         //                                .mem_dqs_t
		inout  wire [3:0]  emif_io96b_lpddr4_0_mem_0_mem_dqs_c,         //                                .mem_dqs_c
		inout  wire [3:0]  emif_io96b_lpddr4_0_mem_0_mem_dmi,           //                                .mem_dmi
		output wire [0:0]  emif_io96b_lpddr4_0_mem_ck_0_mem_ck_t,       //    emif_io96b_lpddr4_0_mem_ck_0.mem_ck_t
		output wire [0:0]  emif_io96b_lpddr4_0_mem_ck_0_mem_ck_c,       //                                .mem_ck_c
		output wire        emif_io96b_lpddr4_0_mem_reset_n_mem_reset_n, // emif_io96b_lpddr4_0_mem_reset_n.mem_reset_n
		input  wire        emif_io96b_lpddr4_0_oct_0_oct_rzqin,         //       emif_io96b_lpddr4_0_oct_0.oct_rzqin
		input  wire        ref_clk_clk,                                 //                         ref_clk.clk
		input  wire        ref_clk_usr_pll_clk                          //                 ref_clk_usr_pll.clk
	);
endmodule

