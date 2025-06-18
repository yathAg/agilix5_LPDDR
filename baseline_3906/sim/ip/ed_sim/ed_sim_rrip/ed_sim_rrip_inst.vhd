	component ed_sim_rrip is
		port (
			ninit_done : out std_logic   -- reset
		);
	end component ed_sim_rrip;

	u0 : component ed_sim_rrip
		port map (
			ninit_done => CONNECTED_TO_ninit_done  -- ninit_done.reset
		);

