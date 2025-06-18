	ed_sim_async_clk_source #(
		.CLOCK_RATE (POSITIVE_VALUE_FOR_CLOCK_RATE),
		.CLOCK_UNIT (POSITIVE_VALUE_FOR_CLOCK_UNIT)
	) u0 (
		.clk (_connected_to_clk_)  //  output,  width = 1, clk.clk
	);

