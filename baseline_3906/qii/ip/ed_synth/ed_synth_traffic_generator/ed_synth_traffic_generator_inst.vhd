	component ed_synth_traffic_generator is
		port (
			remote_intf_clk              : in  std_logic                      := 'X';             -- clk
			remote_intf_reset_n          : in  std_logic                      := 'X';             -- reset_n
			master_jtag_reset_jtag_reset : out std_logic;                                         -- reset
			driver0_axi4_awready         : in  std_logic                      := 'X';             -- awready
			driver0_axi4_awvalid         : out std_logic;                                         -- awvalid
			driver0_axi4_awid            : out std_logic_vector(6 downto 0);                      -- awid
			driver0_axi4_awaddr          : out std_logic_vector(31 downto 0);                     -- awaddr
			driver0_axi4_awlen           : out std_logic_vector(7 downto 0);                      -- awlen
			driver0_axi4_awsize          : out std_logic_vector(2 downto 0);                      -- awsize
			driver0_axi4_awburst         : out std_logic_vector(1 downto 0);                      -- awburst
			driver0_axi4_awlock          : out std_logic_vector(0 downto 0);                      -- awlock
			driver0_axi4_awcache         : out std_logic_vector(3 downto 0);                      -- awcache
			driver0_axi4_awprot          : out std_logic_vector(2 downto 0);                      -- awprot
			driver0_axi4_awuser          : out std_logic_vector(0 downto 0);                      -- awuser
			driver0_axi4_arready         : in  std_logic                      := 'X';             -- arready
			driver0_axi4_arvalid         : out std_logic;                                         -- arvalid
			driver0_axi4_arid            : out std_logic_vector(6 downto 0);                      -- arid
			driver0_axi4_araddr          : out std_logic_vector(31 downto 0);                     -- araddr
			driver0_axi4_arlen           : out std_logic_vector(7 downto 0);                      -- arlen
			driver0_axi4_arsize          : out std_logic_vector(2 downto 0);                      -- arsize
			driver0_axi4_arburst         : out std_logic_vector(1 downto 0);                      -- arburst
			driver0_axi4_arlock          : out std_logic_vector(0 downto 0);                      -- arlock
			driver0_axi4_arcache         : out std_logic_vector(3 downto 0);                      -- arcache
			driver0_axi4_arprot          : out std_logic_vector(2 downto 0);                      -- arprot
			driver0_axi4_aruser          : out std_logic_vector(0 downto 0);                      -- aruser
			driver0_axi4_wready          : in  std_logic                      := 'X';             -- wready
			driver0_axi4_wvalid          : out std_logic;                                         -- wvalid
			driver0_axi4_wdata           : out std_logic_vector(255 downto 0);                    -- wdata
			driver0_axi4_wstrb           : out std_logic_vector(31 downto 0);                     -- wstrb
			driver0_axi4_wlast           : out std_logic;                                         -- wlast
			driver0_axi4_bready          : out std_logic;                                         -- bready
			driver0_axi4_bvalid          : in  std_logic                      := 'X';             -- bvalid
			driver0_axi4_bid             : in  std_logic_vector(6 downto 0)   := (others => 'X'); -- bid
			driver0_axi4_bresp           : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- bresp
			driver0_axi4_rready          : out std_logic;                                         -- rready
			driver0_axi4_rvalid          : in  std_logic                      := 'X';             -- rvalid
			driver0_axi4_rid             : in  std_logic_vector(6 downto 0)   := (others => 'X'); -- rid
			driver0_axi4_rdata           : in  std_logic_vector(255 downto 0) := (others => 'X'); -- rdata
			driver0_axi4_rresp           : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rresp
			driver0_axi4_rlast           : in  std_logic                      := 'X';             -- rlast
			driver0_clk                  : in  std_logic                      := 'X';             -- clk
			driver0_reset_n              : in  std_logic                      := 'X'              -- reset_n
		);
	end component ed_synth_traffic_generator;

	u0 : component ed_synth_traffic_generator
		port map (
			remote_intf_clk              => CONNECTED_TO_remote_intf_clk,              --   remote_intf_clk.clk
			remote_intf_reset_n          => CONNECTED_TO_remote_intf_reset_n,          -- remote_intf_reset.reset_n
			master_jtag_reset_jtag_reset => CONNECTED_TO_master_jtag_reset_jtag_reset, --        jtag_reset.reset
			driver0_axi4_awready         => CONNECTED_TO_driver0_axi4_awready,         --      driver0_axi4.awready
			driver0_axi4_awvalid         => CONNECTED_TO_driver0_axi4_awvalid,         --                  .awvalid
			driver0_axi4_awid            => CONNECTED_TO_driver0_axi4_awid,            --                  .awid
			driver0_axi4_awaddr          => CONNECTED_TO_driver0_axi4_awaddr,          --                  .awaddr
			driver0_axi4_awlen           => CONNECTED_TO_driver0_axi4_awlen,           --                  .awlen
			driver0_axi4_awsize          => CONNECTED_TO_driver0_axi4_awsize,          --                  .awsize
			driver0_axi4_awburst         => CONNECTED_TO_driver0_axi4_awburst,         --                  .awburst
			driver0_axi4_awlock          => CONNECTED_TO_driver0_axi4_awlock,          --                  .awlock
			driver0_axi4_awcache         => CONNECTED_TO_driver0_axi4_awcache,         --                  .awcache
			driver0_axi4_awprot          => CONNECTED_TO_driver0_axi4_awprot,          --                  .awprot
			driver0_axi4_awuser          => CONNECTED_TO_driver0_axi4_awuser,          --                  .awuser
			driver0_axi4_arready         => CONNECTED_TO_driver0_axi4_arready,         --                  .arready
			driver0_axi4_arvalid         => CONNECTED_TO_driver0_axi4_arvalid,         --                  .arvalid
			driver0_axi4_arid            => CONNECTED_TO_driver0_axi4_arid,            --                  .arid
			driver0_axi4_araddr          => CONNECTED_TO_driver0_axi4_araddr,          --                  .araddr
			driver0_axi4_arlen           => CONNECTED_TO_driver0_axi4_arlen,           --                  .arlen
			driver0_axi4_arsize          => CONNECTED_TO_driver0_axi4_arsize,          --                  .arsize
			driver0_axi4_arburst         => CONNECTED_TO_driver0_axi4_arburst,         --                  .arburst
			driver0_axi4_arlock          => CONNECTED_TO_driver0_axi4_arlock,          --                  .arlock
			driver0_axi4_arcache         => CONNECTED_TO_driver0_axi4_arcache,         --                  .arcache
			driver0_axi4_arprot          => CONNECTED_TO_driver0_axi4_arprot,          --                  .arprot
			driver0_axi4_aruser          => CONNECTED_TO_driver0_axi4_aruser,          --                  .aruser
			driver0_axi4_wready          => CONNECTED_TO_driver0_axi4_wready,          --                  .wready
			driver0_axi4_wvalid          => CONNECTED_TO_driver0_axi4_wvalid,          --                  .wvalid
			driver0_axi4_wdata           => CONNECTED_TO_driver0_axi4_wdata,           --                  .wdata
			driver0_axi4_wstrb           => CONNECTED_TO_driver0_axi4_wstrb,           --                  .wstrb
			driver0_axi4_wlast           => CONNECTED_TO_driver0_axi4_wlast,           --                  .wlast
			driver0_axi4_bready          => CONNECTED_TO_driver0_axi4_bready,          --                  .bready
			driver0_axi4_bvalid          => CONNECTED_TO_driver0_axi4_bvalid,          --                  .bvalid
			driver0_axi4_bid             => CONNECTED_TO_driver0_axi4_bid,             --                  .bid
			driver0_axi4_bresp           => CONNECTED_TO_driver0_axi4_bresp,           --                  .bresp
			driver0_axi4_rready          => CONNECTED_TO_driver0_axi4_rready,          --                  .rready
			driver0_axi4_rvalid          => CONNECTED_TO_driver0_axi4_rvalid,          --                  .rvalid
			driver0_axi4_rid             => CONNECTED_TO_driver0_axi4_rid,             --                  .rid
			driver0_axi4_rdata           => CONNECTED_TO_driver0_axi4_rdata,           --                  .rdata
			driver0_axi4_rresp           => CONNECTED_TO_driver0_axi4_rresp,           --                  .rresp
			driver0_axi4_rlast           => CONNECTED_TO_driver0_axi4_rlast,           --                  .rlast
			driver0_clk                  => CONNECTED_TO_driver0_clk,                  --       driver0_clk.clk
			driver0_reset_n              => CONNECTED_TO_driver0_reset_n               --     driver0_reset.reset_n
		);

