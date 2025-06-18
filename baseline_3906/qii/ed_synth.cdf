/* Quartus Prime Version 24.3.1 Build 102 01/14/2025 SC Pro Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(A5ED065BB32AR0) Path("C:/LPDDR_test/baseline_3906/qii/") File("ed_synth.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(VTAP10) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
	Frequency(24000000);
AlteraEnd;
