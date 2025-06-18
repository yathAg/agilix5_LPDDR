module ed_sim_mem (
		input  wire [0:0]  mem_cke_0,     //       mem_0.mem_cke
		input  wire [0:0]  mem_cs_0,      //            .mem_cs
		input  wire [5:0]  mem_ca_0,      //            .mem_ca
		inout  wire [31:0] mem_dq_0,      //            .mem_dq
		inout  wire [3:0]  mem_dqs_t_0,   //            .mem_dqs_t
		inout  wire [3:0]  mem_dqs_c_0,   //            .mem_dqs_c
		inout  wire [3:0]  mem_dmi_0,     //            .mem_dmi
		input  wire [0:0]  mem_ck_t_0,    //    mem_ck_0.mem_ck_t
		input  wire [0:0]  mem_ck_c_0,    //            .mem_ck_c
		output wire        oct_rzqin_0,   //       oct_0.oct_rzqin
		input  wire        mem_reset_n_0  // mem_reset_n.mem_reset_n
	);
endmodule

