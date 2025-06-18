	component ed_sim_mem is
		port (
			mem_cke_0     : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_cke
			mem_cs_0      : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_cs
			mem_ca_0      : in    std_logic_vector(5 downto 0)  := (others => 'X'); -- mem_ca
			mem_dq_0      : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			mem_dqs_t_0   : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_t
			mem_dqs_c_0   : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_c
			mem_dmi_0     : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dmi
			mem_ck_t_0    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_ck_t
			mem_ck_c_0    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_ck_c
			oct_rzqin_0   : out   std_logic;                                        -- oct_rzqin
			mem_reset_n_0 : in    std_logic                     := 'X'              -- mem_reset_n
		);
	end component ed_sim_mem;

	u0 : component ed_sim_mem
		port map (
			mem_cke_0     => CONNECTED_TO_mem_cke_0,     --       mem_0.mem_cke
			mem_cs_0      => CONNECTED_TO_mem_cs_0,      --            .mem_cs
			mem_ca_0      => CONNECTED_TO_mem_ca_0,      --            .mem_ca
			mem_dq_0      => CONNECTED_TO_mem_dq_0,      --            .mem_dq
			mem_dqs_t_0   => CONNECTED_TO_mem_dqs_t_0,   --            .mem_dqs_t
			mem_dqs_c_0   => CONNECTED_TO_mem_dqs_c_0,   --            .mem_dqs_c
			mem_dmi_0     => CONNECTED_TO_mem_dmi_0,     --            .mem_dmi
			mem_ck_t_0    => CONNECTED_TO_mem_ck_t_0,    --    mem_ck_0.mem_ck_t
			mem_ck_c_0    => CONNECTED_TO_mem_ck_c_0,    --            .mem_ck_c
			oct_rzqin_0   => CONNECTED_TO_oct_rzqin_0,   --       oct_0.oct_rzqin
			mem_reset_n_0 => CONNECTED_TO_mem_reset_n_0  -- mem_reset_n.mem_reset_n
		);

