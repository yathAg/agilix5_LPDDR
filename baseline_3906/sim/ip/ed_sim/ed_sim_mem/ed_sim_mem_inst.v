	ed_sim_mem u0 (
		.mem_cke_0     (_connected_to_mem_cke_0_),     //   input,   width = 1,       mem_0.mem_cke
		.mem_cs_0      (_connected_to_mem_cs_0_),      //   input,   width = 1,            .mem_cs
		.mem_ca_0      (_connected_to_mem_ca_0_),      //   input,   width = 6,            .mem_ca
		.mem_dq_0      (_connected_to_mem_dq_0_),      //   inout,  width = 32,            .mem_dq
		.mem_dqs_t_0   (_connected_to_mem_dqs_t_0_),   //   inout,   width = 4,            .mem_dqs_t
		.mem_dqs_c_0   (_connected_to_mem_dqs_c_0_),   //   inout,   width = 4,            .mem_dqs_c
		.mem_dmi_0     (_connected_to_mem_dmi_0_),     //   inout,   width = 4,            .mem_dmi
		.mem_ck_t_0    (_connected_to_mem_ck_t_0_),    //   input,   width = 1,    mem_ck_0.mem_ck_t
		.mem_ck_c_0    (_connected_to_mem_ck_c_0_),    //   input,   width = 1,            .mem_ck_c
		.oct_rzqin_0   (_connected_to_oct_rzqin_0_),   //  output,   width = 1,       oct_0.oct_rzqin
		.mem_reset_n_0 (_connected_to_mem_reset_n_0_)  //   input,   width = 1, mem_reset_n.mem_reset_n
	);

