	component ed_synth_reset_handler is
		port (
			reset_n_0   : in  std_logic := 'X'; -- reset_n
			conduit_0   : in  std_logic := 'X'; -- export
			clk         : in  std_logic := 'X'; -- clk
			reset_out_n : out std_logic         -- reset_n
		);
	end component ed_synth_reset_handler;

	u0 : component ed_synth_reset_handler
		port map (
			reset_n_0   => CONNECTED_TO_reset_n_0,   --   reset_n_0.reset_n
			conduit_0   => CONNECTED_TO_conduit_0,   --   conduit_0.export
			clk         => CONNECTED_TO_clk,         --         clk.clk
			reset_out_n => CONNECTED_TO_reset_out_n  -- reset_n_out.reset_n
		);

