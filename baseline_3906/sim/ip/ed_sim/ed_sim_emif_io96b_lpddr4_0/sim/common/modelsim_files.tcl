
namespace eval ed_sim_emif_io96b_lpddr4_0 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_jtag_dc_streaming_191           1
    dict set libraries timing_adapter_1950                    1
    dict set libraries altera_avalon_sc_fifo_1932             1
    dict set libraries altera_avalon_st_bytes_to_packets_1922 1
    dict set libraries altera_avalon_st_packets_to_bytes_1922 1
    dict set libraries altera_avalon_packets_to_master_1922   1
    dict set libraries channel_adapter_1922                   1
    dict set libraries altera_reset_controller_1924           1
    dict set libraries alt_mem_if_jtag_master_191             1
    dict set libraries emif_io96b_cal_200                     1
    dict set libraries emif_io96b_lpddr4_200                  1
    dict set libraries ed_sim_emif_io96b_lpddr4_0             1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    lappend memory_files "[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/iossm_cal_boot.hex"]"
    lappend memory_files "[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/iossm_cal.hex"]"
    lappend memory_files "[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_mc_wide_seq_pt_sim.hex"]"
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [list]
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_avalon_st_jtag_interface.v"]\"   -end"                                                                                                                         
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_jtag_dc_streaming.v"]\"   -end"                                                                                                                                
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_jtag_sld_node.v"]\"   -end"                                                                                                                                    
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_jtag_streaming.v"]\"   -end"                                                                                                                                   
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_avalon_st_clock_crosser.v"]\"   -end"                                                                                                                          
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_reset_synchronizer.v"]\"   -end"                                                                                                                               
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_std_synchronizer_nocut.v"]\"   -end"                                                                                                                           
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                                                                                                          
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_avalon_st_idle_remover.v"]\"   -end"                                                                                                                           
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_avalon_st_idle_inserter.v"]\"   -end"                                                                                                                          
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_avalon_st_pipeline_stage.sv"]\"   -end"                                                                                                                        
    lappend design_files "-makelib timing_adapter_1950 \"[normalize_path "$QSYS_SIMDIR/../timing_adapter_1950/sim/ed_sim_emif_io96b_lpddr4_0_timing_adapter_1950_bbjt6kq.sv"]\"   -end"                                                                                                                   
    lappend design_files "-makelib altera_avalon_sc_fifo_1932 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/ed_sim_emif_io96b_lpddr4_0_altera_avalon_sc_fifo_1932_onpcouq.v"]\"   -end"                                                                                               
    lappend design_files "-makelib altera_avalon_st_bytes_to_packets_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_bytes_to_packets_1922/sim/altera_avalon_st_bytes_to_packets.v"]\"   -end"                                                                                                   
    lappend design_files "-makelib altera_avalon_st_packets_to_bytes_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_packets_to_bytes_1922/sim/altera_avalon_st_packets_to_bytes.v"]\"   -end"                                                                                                   
    lappend design_files "-makelib altera_avalon_packets_to_master_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_packets_to_master_1922/sim/altera_avalon_packets_to_master.v"]\"   -end"                                                                                                         
    lappend design_files "-makelib channel_adapter_1922 \"[normalize_path "$QSYS_SIMDIR/../channel_adapter_1922/sim/ed_sim_emif_io96b_lpddr4_0_channel_adapter_1922_rd56ufy.sv"]\"   -end"                                                                                                                
    lappend design_files "-makelib channel_adapter_1922 \"[normalize_path "$QSYS_SIMDIR/../channel_adapter_1922/sim/ed_sim_emif_io96b_lpddr4_0_channel_adapter_1922_5vp3d5a.sv"]\"   -end"                                                                                                                
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"   -end"                                                                                                                                 
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"   -end"                                                                                                                               
    lappend design_files "-makelib alt_mem_if_jtag_master_191 \"[normalize_path "$QSYS_SIMDIR/../alt_mem_if_jtag_master_191/sim/ed_sim_emif_io96b_lpddr4_0_alt_mem_if_jtag_master_191_2xbfrbi.v"]\"   -end"                                                                                               
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_alt_mem_if_jtag_master_200_6eqlegy.v"]\"   -end"                                                                                                
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_atom_attr_fa_c2p_ssm.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                       
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_atom_attr_fa_p2c_ssm.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                       
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_atom_attr_iossm.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                            
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_atom_attr_seq.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                              
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_arbitrator.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_cal_arch_fp_top.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_cal_arch_fp_atom_inst_iossm.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_cal_arch_fp_atom_inst_seq.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                      
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_cal_arch_fp_atom_inst_fa.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                       
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_cal_200_pi6yw4q_cal_arch_fp_atom_inst_comp.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/altera_emif_cal_gearbox.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                              
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/altera_emif_cal_gearbox_bidir.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                        
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_translator_1931_d46vvwa.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                  
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_reset_controller.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                  
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_avalon_st_bytes_to_packets.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                        
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_avalon_packets_to_master.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_master_ni_1962_2kryw2a.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                   
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_merlin_reorder_memory.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                            
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_7ekoqry.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"            
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_traffic_limiter_1921_bk6lvda.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                 
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_channel_adapter_1921_fkajlia.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                               
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_multiplexer_1922_jy53pgi.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_multiplexer_1922_ctb2miq.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_multiplexer_1922_7b7u3ni.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_multiplexer_1922_252f2xa.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_merlin_arbitrator.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_pri_mux_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                      
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_comp_sel_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_channel_adapter_1921_5wnzrci.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                               
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_avalon_st_pipeline_stage_1930_bv2ucky.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                               
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_avalon_st_packets_to_bytes.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                        
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_sipo_plus_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_response_mem_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                 
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_comp_sel_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_response_mem_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                 
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_sipo_plus_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_comp_sel_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_sipo_plus_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_sipo_plus_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_vnonqiy.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_alj3kza.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_1971_ysgnmwa.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"               
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/compare_eq.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                              
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_response_mem_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                 
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_response_mem_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                 
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_pri_mux_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                      
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/rd_comp_sel_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_1971_o34766q.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"               
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_1971_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_1971_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_pri_mux_kt2puei.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                      
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/wr_pri_mux_cwyib4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                      
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_h6wexfa.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_cgpn6xq.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_avalon_sc_fifo_1931_fzgstwy.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_merlin_burst_uncompressor.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                        
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_width_adapter_1933_2qdsena.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                   
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_master_agent_1921_2inlndi.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_demultiplexer_1921_rcor4va.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                   
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_demultiplexer_1921_ekcygpi.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                   
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                   
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_merlin_address_alignment.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                         
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_width_adapter_1933_sqfzewq.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                   
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1931_glj62si.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"    
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_merlin_burst_adapter_uncmpr.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                      
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_merlin_burst_adapter_new.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                         
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_burst_adapter_1931_hbsisni.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                   
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_wrap_burst_converter.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                             
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_merlin_burst_adapter_13_1.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                        
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_incr_burst_converter.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                             
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_default_burst_converter.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_timing_adapter_1940_5ju4ddy.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/intel_axi4lite_injector_dcfifo_s.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                        
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/intel_axi4lite_injector_util.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                            
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/intel_axi4lite_injector_ph2.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                             
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_intel_axi4lite_injector_100_2yowc3a.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                        
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_hs_clk_xer_1940_hvja46q.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_hs_clk_xer_1940_4s7hdhy.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                     
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_mm_interconnect_1920_jmzr6ly.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                         
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_mm_interconnect_1920_5sovoyi.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                         
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_master_translator_192_lykd4la.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_std_synchronizer_nocut.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                            
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_reset_synchronizer.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                                
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_avalon_st_pipeline_base.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                           
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/altera_avalon_st_clock_crosser.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                                           
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_router_1921_vbaxzva.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_router_1921_nxsnrbi.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_router_1921_irryw4q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_router_1921_wqohhgi.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_router_1921_4ytgf2y.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                          
    lappend design_files "-makelib emif_io96b_cal_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/interconnect/ed_synth_dut_altera_merlin_router_1921_2jqun3q.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_cal_200/sim/"]\"  -end"                                          
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_emif_io96b_cal_200_ogvmehq.v"]\"   -end"                                                                                               
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"                                    
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/altera_std_synchronizer_nocut.v"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"                                                                
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/emif_io96b_lib.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"                                                                              
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/emif_io96b_clk_div.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"                                                                          
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_jedec_params.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"                       
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_pin_locations.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_byte.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"         
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_byte_ctrl.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"    
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_cpa.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"          
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_fa_c2p_hmc.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"   
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_fa_p2c_hmc.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"   
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_fa_c2p_lane.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"  
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_fa_p2c_lane.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"  
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_fa_noc.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"       
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_hmc_wide.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_hmc_slim.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_pa.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"           
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_pll.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"          
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_attr_bufs_mem.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_bufs_mem.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_byte.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"         
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_byte_ctrl.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"    
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_cpa.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"          
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_fa_noc.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"       
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_hmc_wide.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_hmc_slim.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"     
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_pa.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"           
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_pll.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"          
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_reftree.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"      
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_fa_hmc.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"       
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_atom_inst_fa_lane.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"      
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_fbr_axi_adapter_wide.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"   
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_fbr_axi_adapter_slim.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"   
    lappend design_files "-makelib emif_io96b_lpddr4_200 \"[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/io96b_0/io0_ed_sim_emif_io96b_lpddr4_0_emif_io96b_lpddr4_200_hyctmiq_io96b_top.sv"]\" \"+incdir+[normalize_path "$QSYS_SIMDIR/../emif_io96b_lpddr4_200/sim/"]\"  -end"              
    lappend design_files "-makelib ed_sim_emif_io96b_lpddr4_0 \"[normalize_path "$QSYS_SIMDIR/ed_sim_emif_io96b_lpddr4_0.v"]\"   -end"                                                                                                                                                                    
    return $design_files
  }
  
  proc get_non_duplicate_elab_option {ELAB_OPTIONS NEW_ELAB_OPTION} {
    set IS_DUPLICATE [string first $NEW_ELAB_OPTION $ELAB_OPTIONS]
    if {$IS_DUPLICATE == -1} {
      return $NEW_ELAB_OPTION
    } else {
      return ""
    }
  }
  
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
  proc normalize_path {FILEPATH} {
      if {[catch { package require fileutil } err]} { 
          return $FILEPATH 
      } 
      set path [fileutil::lexnormalize [file join [pwd] $FILEPATH]]  
      if {[file pathtype $FILEPATH] eq "relative"} { 
          set path [fileutil::relative [pwd] $path] 
      } 
      return $path 
  } 
  proc get_dpi_libraries {QSYS_SIMDIR} {
    set libraries [dict create]
    
    return $libraries
  }
  
}
