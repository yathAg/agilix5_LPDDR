	component ed_synth is
		port (
			emif_io96b_lpddr4_0_mem_0_mem_cs            : out   std_logic_vector(0 downto 0);                     -- mem_cs
			emif_io96b_lpddr4_0_mem_0_mem_ca            : out   std_logic_vector(5 downto 0);                     -- mem_ca
			emif_io96b_lpddr4_0_mem_0_mem_cke           : out   std_logic_vector(0 downto 0);                     -- mem_cke
			emif_io96b_lpddr4_0_mem_0_mem_dq            : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			emif_io96b_lpddr4_0_mem_0_mem_dqs_t         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_t
			emif_io96b_lpddr4_0_mem_0_mem_dqs_c         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_c
			emif_io96b_lpddr4_0_mem_0_mem_dmi           : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dmi
			emif_io96b_lpddr4_0_mem_ck_0_mem_ck_t       : out   std_logic_vector(0 downto 0);                     -- mem_ck_t
			emif_io96b_lpddr4_0_mem_ck_0_mem_ck_c       : out   std_logic_vector(0 downto 0);                     -- mem_ck_c
			emif_io96b_lpddr4_0_mem_reset_n_mem_reset_n : out   std_logic;                                        -- mem_reset_n
			emif_io96b_lpddr4_0_oct_0_oct_rzqin         : in    std_logic                     := 'X';             -- oct_rzqin
			ref_clk_clk                                 : in    std_logic                     := 'X';             -- clk
			ref_clk_usr_pll_clk                         : in    std_logic                     := 'X'              -- clk
		);
	end component ed_synth;

	u0 : component ed_synth
		port map (
			emif_io96b_lpddr4_0_mem_0_mem_cs            => CONNECTED_TO_emif_io96b_lpddr4_0_mem_0_mem_cs,            --       emif_io96b_lpddr4_0_mem_0.mem_cs
			emif_io96b_lpddr4_0_mem_0_mem_ca            => CONNECTED_TO_emif_io96b_lpddr4_0_mem_0_mem_ca,            --                                .mem_ca
			emif_io96b_lpddr4_0_mem_0_mem_cke           => CONNECTED_TO_emif_io96b_lpddr4_0_mem_0_mem_cke,           --                                .mem_cke
			emif_io96b_lpddr4_0_mem_0_mem_dq            => CONNECTED_TO_emif_io96b_lpddr4_0_mem_0_mem_dq,            --                                .mem_dq
			emif_io96b_lpddr4_0_mem_0_mem_dqs_t         => CONNECTED_TO_emif_io96b_lpddr4_0_mem_0_mem_dqs_t,         --                                .mem_dqs_t
			emif_io96b_lpddr4_0_mem_0_mem_dqs_c         => CONNECTED_TO_emif_io96b_lpddr4_0_mem_0_mem_dqs_c,         --                                .mem_dqs_c
			emif_io96b_lpddr4_0_mem_0_mem_dmi           => CONNECTED_TO_emif_io96b_lpddr4_0_mem_0_mem_dmi,           --                                .mem_dmi
			emif_io96b_lpddr4_0_mem_ck_0_mem_ck_t       => CONNECTED_TO_emif_io96b_lpddr4_0_mem_ck_0_mem_ck_t,       --    emif_io96b_lpddr4_0_mem_ck_0.mem_ck_t
			emif_io96b_lpddr4_0_mem_ck_0_mem_ck_c       => CONNECTED_TO_emif_io96b_lpddr4_0_mem_ck_0_mem_ck_c,       --                                .mem_ck_c
			emif_io96b_lpddr4_0_mem_reset_n_mem_reset_n => CONNECTED_TO_emif_io96b_lpddr4_0_mem_reset_n_mem_reset_n, -- emif_io96b_lpddr4_0_mem_reset_n.mem_reset_n
			emif_io96b_lpddr4_0_oct_0_oct_rzqin         => CONNECTED_TO_emif_io96b_lpddr4_0_oct_0_oct_rzqin,         --       emif_io96b_lpddr4_0_oct_0.oct_rzqin
			ref_clk_clk                                 => CONNECTED_TO_ref_clk_clk,                                 --                         ref_clk.clk
			ref_clk_usr_pll_clk                         => CONNECTED_TO_ref_clk_usr_pll_clk                          --                 ref_clk_usr_pll.clk
		);

