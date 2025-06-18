
namespace eval ed_sim_traffic_generator {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages              1
    dict set libraries hydra_software_100                     1
    dict set libraries hydra_rtl_library_100                  1
    dict set libraries altera_jtag_dc_streaming_191           1
    dict set libraries timing_adapter_1950                    1
    dict set libraries altera_avalon_sc_fifo_1932             1
    dict set libraries altera_avalon_st_bytes_to_packets_1922 1
    dict set libraries altera_avalon_st_packets_to_bytes_1922 1
    dict set libraries altera_avalon_packets_to_master_1922   1
    dict set libraries channel_adapter_1922                   1
    dict set libraries altera_reset_controller_1924           1
    dict set libraries altera_jtag_avalon_master_191          1
    dict set libraries hydra_global_csr_100                   1
    dict set libraries altera_axi_bridge_1992                 1
    dict set libraries hydra_driver_mem_axi4_100              1
    dict set libraries altera_merlin_apb_translator_1920      1
    dict set libraries altera_merlin_axi_master_ni_19100      1
    dict set libraries altera_merlin_apb_slave_agent_1940     1
    dict set libraries altera_merlin_router_1921              1
    dict set libraries altera_merlin_demultiplexer_1921       1
    dict set libraries altera_merlin_multiplexer_1922         1
    dict set libraries altera_mm_interconnect_1920            1
    dict set libraries altera_merlin_master_translator_192    1
    dict set libraries altera_merlin_master_agent_1930        1
    dict set libraries altera_merlin_axi_slave_ni_19112       1
    dict set libraries altera_avalon_st_pipeline_stage_1930   1
    dict set libraries altera_merlin_traffic_limiter_1921     1
    dict set libraries hydra_200                              1
    dict set libraries ed_sim_traffic_generator               1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::hydra_rtl_library_pkg"     "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_rtl_library_pkg.sv"]\"   -end"        
    dict set design_files "altera_common_sv_packages::hydra_mem_axi4_driver_pkg" "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/hydra_mem_axi4_driver_pkg.sv"]\"   -end"
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [list]
    lappend design_files "-makelib hydra_software_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_software_100/sim/hydra_software_dummy_top.sv"]\"   -L altera_common_sv_packages -end"                                                                                 
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_id_checker.sv"]\"   -L altera_common_sv_packages -end"                                                                                   
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_local_reset_tree.sv"]\"   -L altera_common_sv_packages -end"                                                                             
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_orchestrator.sv"]\"   -L altera_common_sv_packages -end"                                                                                 
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_rtl_library_dummy_top.sv"]\"   -L altera_common_sv_packages -end"                                                                        
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_alu_generator.sv"]\"   -L altera_common_sv_packages -end"                                                                                
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_mem_addr_alu.sv"]\"   -L altera_common_sv_packages -end"                                                                                 
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_mem_dq_alu.sv"]\"   -L altera_common_sv_packages -end"                                                                                   
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_main_control.sv"]\"   -L altera_common_sv_packages -end"                                                                                 
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_ooo_worker_head_control.sv"]\"   -L altera_common_sv_packages -end"                                                                      
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_ooo_worker_list_control.sv"]\"   -L altera_common_sv_packages -end"                                                                      
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_worker_control.sv"]\"   -L altera_common_sv_packages -end"                                                                               
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_binary_to_gray.sv"]\"   -L altera_common_sv_packages -end"                                                                               
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_dcfifo_s.sv"]\"   -L altera_common_sv_packages -end"                                                                                     
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_dcfifo_s_normal.sv"]\"   -L altera_common_sv_packages -end"                                                                              
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_dcfifo_s_showahead.sv"]\"   -L altera_common_sv_packages -end"                                                                           
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_generic_mlab_dc.sv"]\"   -L altera_common_sv_packages -end"                                                                              
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_gray_to_binary.sv"]\"   -L altera_common_sv_packages -end"                                                                               
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_synchronizer_ff_r2.sv"]\"   -L altera_common_sv_packages -end"                                                                           
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_synchronizer_mlab.sv"]\"   -L altera_common_sv_packages -end"                                                                            
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_add_a_b_s0_s1.sv"]\"   -L altera_common_sv_packages -end"                                                                                
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_generic_mlab_sc.sv"]\"   -L altera_common_sv_packages -end"                                                                              
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_scfifo_s.sv"]\"   -L altera_common_sv_packages -end"                                                                                     
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_scfifo_s_normal.sv"]\"   -L altera_common_sv_packages -end"                                                                              
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_scfifo_s_showahead.sv"]\"   -L altera_common_sv_packages -end"                                                                           
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_contxt_ram.sv"]\"   -L altera_common_sv_packages -end"                                                                                   
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_instr_ram.sv"]\"   -L altera_common_sv_packages -end"                                                                                    
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_log_ram.sv"]\"   -L altera_common_sv_packages -end"                                                                                      
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_user_to_ram_adapter.sv"]\"   -L altera_common_sv_packages -end"                                                                          
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_skid_buffer.sv"]\"   -L altera_common_sv_packages -end"                                                                                  
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_ready_valid_fork_merge.sv"]\"   -L altera_common_sv_packages -end"                                                                       
    lappend design_files "-makelib hydra_rtl_library_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_rtl_library_100/sim/hydra_stream_multiplier.sv"]\"   -L altera_common_sv_packages -end"                                                                            
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
    lappend design_files "-makelib altera_jtag_dc_streaming_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_191/sim/altera_avalon_st_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib timing_adapter_1950 \"[normalize_path "$QSYS_SIMDIR/../timing_adapter_1950/sim/ed_sim_traffic_generator_timing_adapter_1950_obb3kfy.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib altera_avalon_sc_fifo_1932 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/ed_sim_traffic_generator_altera_avalon_sc_fifo_1932_onpcouq.v"]\"   -end"                                                            
    lappend design_files "-makelib altera_avalon_st_bytes_to_packets_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_bytes_to_packets_1922/sim/altera_avalon_st_bytes_to_packets.v"]\"   -end"                                                              
    lappend design_files "-makelib altera_avalon_st_packets_to_bytes_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_packets_to_bytes_1922/sim/altera_avalon_st_packets_to_bytes.v"]\"   -end"                                                              
    lappend design_files "-makelib altera_avalon_packets_to_master_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_packets_to_master_1922/sim/altera_avalon_packets_to_master.v"]\"   -end"                                                                    
    lappend design_files "-makelib channel_adapter_1922 \"[normalize_path "$QSYS_SIMDIR/../channel_adapter_1922/sim/ed_sim_traffic_generator_channel_adapter_1922_rd56ufy.sv"]\"   -L altera_common_sv_packages -end"                                                
    lappend design_files "-makelib channel_adapter_1922 \"[normalize_path "$QSYS_SIMDIR/../channel_adapter_1922/sim/ed_sim_traffic_generator_channel_adapter_1922_5vp3d5a.sv"]\"   -L altera_common_sv_packages -end"                                                
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"   -end"                                                                                            
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"   -end"                                                                                          
    lappend design_files "-makelib altera_jtag_avalon_master_191 \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_avalon_master_191/sim/ed_sim_traffic_generator_altera_jtag_avalon_master_191_unfwqdy.v"]\"   -end"                                                   
    lappend design_files "-makelib hydra_global_csr_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_global_csr_100/sim/ed_sim_traffic_generator_hydra_global_csr_100_7ggcjai_hydra_global_csr_top.sv"]\"   -L altera_common_sv_packages -end"                           
    lappend design_files "-makelib hydra_global_csr_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_global_csr_100/sim/hydra_global_csr_impl.sv"]\"   -L altera_common_sv_packages -end"                                                                                
    lappend design_files "-makelib hydra_global_csr_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_global_csr_100/sim/hydra_global_csr_sync.sv"]\"   -L altera_common_sv_packages -end"                                                                                
    lappend design_files "-makelib hydra_global_csr_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_global_csr_100/sim/hydra_global_csr_registers.sv"]\"   -L altera_common_sv_packages -end"                                                                           
    lappend design_files "-makelib altera_axi_bridge_1992 \"[normalize_path "$QSYS_SIMDIR/../altera_axi_bridge_1992/sim/ed_sim_traffic_generator_altera_axi_bridge_1992_kxv226q.sv"]\"   -L altera_common_sv_packages -end"                                          
    lappend design_files "-makelib altera_axi_bridge_1992 \"[normalize_path "$QSYS_SIMDIR/../altera_axi_bridge_1992/sim/altera_avalon_st_pipeline_base.v"]\"   -L altera_common_sv_packages -end"                                                                    
    lappend design_files "-makelib hydra_driver_mem_axi4_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/hydra_mem_axi4_driver_csr_interface.sv"]\"   -L altera_common_sv_packages -end"                                                        
    lappend design_files "-makelib hydra_driver_mem_axi4_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/hydra_mem_axi4_driver_csr_bank.sv"]\"   -L altera_common_sv_packages -end"                                                             
    lappend design_files "-makelib hydra_driver_mem_axi4_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/hydra_mem_axi4_driver_top.sv"]\"   -L altera_common_sv_packages -end"                                                                  
    lappend design_files "-makelib hydra_driver_mem_axi4_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/hydra_mem_axi4_driver_channel_path.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib hydra_driver_mem_axi4_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/hydra_mem_axi4_driver_gen_path.sv"]\"   -L altera_common_sv_packages -end"                                                             
    lappend design_files "-makelib hydra_driver_mem_axi4_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/hydra_mem_axi4_driver_narrow_xstrb.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib hydra_driver_mem_axi4_100 \"[normalize_path "$QSYS_SIMDIR/../hydra_driver_mem_axi4_100/sim/altera_std_synchronizer_nocut.v"]\"   -end"                                                                                            
    lappend design_files "-makelib altera_merlin_apb_translator_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_apb_translator_1920/sim/ed_sim_traffic_generator_altera_merlin_apb_translator_1920_6aahr2a.sv"]\"   -L altera_common_sv_packages -end"         
    lappend design_files "-makelib altera_merlin_axi_master_ni_19100 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19100/sim/altera_merlin_address_alignment.sv"]\"   -L altera_common_sv_packages -end"                                            
    lappend design_files "-makelib altera_merlin_axi_master_ni_19100 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19100/sim/ed_sim_traffic_generator_altera_merlin_axi_master_ni_19100_y3ctica.sv"]\"   -L altera_common_sv_packages -end"         
    lappend design_files "-makelib altera_merlin_apb_slave_agent_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_apb_slave_agent_1940/sim/ed_sim_traffic_generator_altera_merlin_apb_slave_agent_1940_4j3b5gq.sv"]\"   -L altera_common_sv_packages -end"      
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/ed_sim_traffic_generator_altera_merlin_router_1921_iegcfmq.sv"]\"   -L altera_common_sv_packages -end"                                 
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/ed_sim_traffic_generator_altera_merlin_router_1921_ah5veci.sv"]\"   -L altera_common_sv_packages -end"                                 
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/ed_sim_traffic_generator_altera_merlin_demultiplexer_1921_bcyqn7i.sv"]\"   -L altera_common_sv_packages -end"            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/ed_sim_traffic_generator_altera_merlin_multiplexer_1922_faztmpq.sv"]\"   -L altera_common_sv_packages -end"                  
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/ed_sim_traffic_generator_altera_merlin_demultiplexer_1921_lpkcrti.sv"]\"   -L altera_common_sv_packages -end"            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/ed_sim_traffic_generator_altera_merlin_multiplexer_1922_wwowo6i.sv"]\"   -L altera_common_sv_packages -end"                  
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/ed_sim_traffic_generator_altera_mm_interconnect_1920_rqcbspq.v"]\"   -end"                                                         
    lappend design_files "-makelib altera_merlin_master_translator_192 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_192/sim/ed_sim_traffic_generator_altera_merlin_master_translator_192_54w642y.sv"]\"   -L altera_common_sv_packages -end"   
    lappend design_files "-makelib altera_merlin_master_agent_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_1930/sim/ed_sim_traffic_generator_altera_merlin_master_agent_1930_l64uqry.sv"]\"   -L altera_common_sv_packages -end"               
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_19112_qo57tlq.v"]\"   -end"                    
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/ed_sim_traffic_generator_altera_avalon_st_pipeline_stage_1930_oiupeiq.sv"]\"   -L altera_common_sv_packages -end"
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/altera_avalon_st_pipeline_base.v"]\"   -L altera_common_sv_packages -end"                                        
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19112_r3vseti.v"]\"   -end"          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19112_34k67jq.v"]\"   -end"          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19112_htxwsja.v"]\"   -end"          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/altera_merlin_burst_uncompressor.sv"]\"   -L altera_common_sv_packages -end"                                             
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/altera_merlin_address_alignment.sv"]\"   -L altera_common_sv_packages -end"                                              
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/compare_eq.sv"]\"   -L altera_common_sv_packages -end"                                                                   
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_response_mem_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_comp_sel_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_pri_mux_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                           
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_sipo_plus_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_response_mem_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_comp_sel_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_pri_mux_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                           
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_sipo_plus_ykxseta.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_19112_ykxseta.sv"]\"   -L altera_common_sv_packages -end"            
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_19112_3oiloga.v"]\"   -end"                    
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19112_r3vseti.v"]\"   -end"          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19112_34k67jq.v"]\"   -end"          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19112_htxwsja.v"]\"   -end"          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/altera_merlin_burst_uncompressor.sv"]\"   -L altera_common_sv_packages -end"                                             
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/altera_merlin_address_alignment.sv"]\"   -L altera_common_sv_packages -end"                                              
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/compare_eq.sv"]\"   -L altera_common_sv_packages -end"                                                                   
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_response_mem_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_comp_sel_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_pri_mux_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                           
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/rd_sipo_plus_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_response_mem_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_comp_sel_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                          
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_pri_mux_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                           
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/wr_sipo_plus_5emdibi.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19112 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19112/sim/ed_sim_traffic_generator_altera_merlin_axi_slave_ni_19112_5emdibi.sv"]\"   -L altera_common_sv_packages -end"            
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/ed_sim_traffic_generator_altera_merlin_router_1921_lras3ty.sv"]\"   -L altera_common_sv_packages -end"                                 
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/ed_sim_traffic_generator_altera_merlin_router_1921_cq4uqsy.sv"]\"   -L altera_common_sv_packages -end"                                 
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/ed_sim_traffic_generator_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_ihngjoq.v"]\"   -end"              
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"   -L altera_common_sv_packages -end"                                             
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"   -L altera_common_sv_packages -end"                                            
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/ed_sim_traffic_generator_altera_merlin_traffic_limiter_1921_6hyjguq.sv"]\"   -L altera_common_sv_packages -end"      
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/ed_sim_traffic_generator_altera_merlin_demultiplexer_1921_yicp2kq.sv"]\"   -L altera_common_sv_packages -end"            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/ed_sim_traffic_generator_altera_merlin_multiplexer_1922_avyhzyy.sv"]\"   -L altera_common_sv_packages -end"                  
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/ed_sim_traffic_generator_altera_merlin_demultiplexer_1921_qq5eekq.sv"]\"   -L altera_common_sv_packages -end"            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/ed_sim_traffic_generator_altera_merlin_multiplexer_1922_wrdg73y.sv"]\"   -L altera_common_sv_packages -end"                  
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -L altera_common_sv_packages -end"                                                         
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/ed_sim_traffic_generator_altera_mm_interconnect_1920_vtrezla.v"]\"   -end"                                                         
    lappend design_files "-makelib hydra_200 \"[normalize_path "$QSYS_SIMDIR/../hydra_200/sim/ed_sim_traffic_generator_hydra_200_gcz73hi.v"]\"   -end"                                                                                                               
    lappend design_files "-makelib ed_sim_traffic_generator \"[normalize_path "$QSYS_SIMDIR/ed_sim_traffic_generator.v"]\"   -end"                                                                                                                                   
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
