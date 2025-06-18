	component ed_sim_ref_clk_source_0 is
		generic (
			CLOCK_RATE : positive := 100000000;
			CLOCK_UNIT : positive := 1
		);
		port (
			clk : out std_logic   -- clk
		);
	end component ed_sim_ref_clk_source_0;

	u0 : component ed_sim_ref_clk_source_0
		generic map (
			CLOCK_RATE => POSITIVE_VALUE_FOR_CLOCK_RATE,
			CLOCK_UNIT => POSITIVE_VALUE_FOR_CLOCK_UNIT
		)
		port map (
			clk => CONNECTED_TO_clk  -- clk.clk
		);

