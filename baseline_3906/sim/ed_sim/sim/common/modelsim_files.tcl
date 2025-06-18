source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_user_pll/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_async_clk_source/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_axil_driver_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_mem/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_ref_clk_source_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_rrip/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_traffic_generator/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_reset_handler/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/ed_sim/ed_sim_emif_io96b_lpddr4_0/sim/common/modelsim_files.tcl]

namespace eval ed_sim {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [ed_sim_user_pll::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_async_clk_source::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_axil_driver_0::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_mem::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_ref_clk_source_0::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_rrip::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_traffic_generator::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_reset_handler::get_design_libraries]]
    set libraries [dict merge $libraries [ed_sim_emif_io96b_lpddr4_0::get_design_libraries]]
    dict set libraries altera_merlin_axi_translator_1972 1
    dict set libraries altera_mm_interconnect_1920       1
    dict set libraries altera_reset_controller_1924      1
    dict set libraries ed_sim                            1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [ed_sim_user_pll::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_user_pll/sim/"]]
    set memory_files [concat $memory_files [ed_sim_async_clk_source::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_async_clk_source/sim/"]]
    set memory_files [concat $memory_files [ed_sim_axil_driver_0::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_axil_driver_0/sim/"]]
    set memory_files [concat $memory_files [ed_sim_mem::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_mem/sim/"]]
    set memory_files [concat $memory_files [ed_sim_ref_clk_source_0::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_ref_clk_source_0/sim/"]]
    set memory_files [concat $memory_files [ed_sim_rrip::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_rrip/sim/"]]
    set memory_files [concat $memory_files [ed_sim_traffic_generator::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_traffic_generator/sim/"]]
    set memory_files [concat $memory_files [ed_sim_reset_handler::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_reset_handler/sim/"]]
    set memory_files [concat $memory_files [ed_sim_emif_io96b_lpddr4_0::get_memory_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_emif_io96b_lpddr4_0/sim/"]]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [ed_sim_user_pll::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_user_pll/sim/"]]
    set design_files [dict merge $design_files [ed_sim_async_clk_source::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_async_clk_source/sim/"]]
    set design_files [dict merge $design_files [ed_sim_axil_driver_0::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_axil_driver_0/sim/"]]
    set design_files [dict merge $design_files [ed_sim_mem::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_mem/sim/"]]
    set design_files [dict merge $design_files [ed_sim_ref_clk_source_0::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_ref_clk_source_0/sim/"]]
    set design_files [dict merge $design_files [ed_sim_rrip::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_rrip/sim/"]]
    set design_files [dict merge $design_files [ed_sim_traffic_generator::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_traffic_generator/sim/"]]
    set design_files [dict merge $design_files [ed_sim_reset_handler::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_reset_handler/sim/"]]
    set design_files [dict merge $design_files [ed_sim_emif_io96b_lpddr4_0::get_common_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_emif_io96b_lpddr4_0/sim/"]]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [list]
    set design_files [concat $design_files [ed_sim_user_pll::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_user_pll/sim/"]]
    set design_files [concat $design_files [ed_sim_async_clk_source::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_async_clk_source/sim/"]]
    set design_files [concat $design_files [ed_sim_axil_driver_0::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_axil_driver_0/sim/"]]
    set design_files [concat $design_files [ed_sim_mem::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_mem/sim/"]]
    set design_files [concat $design_files [ed_sim_ref_clk_source_0::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_ref_clk_source_0/sim/"]]
    set design_files [concat $design_files [ed_sim_rrip::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_rrip/sim/"]]
    set design_files [concat $design_files [ed_sim_traffic_generator::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_traffic_generator/sim/"]]
    set design_files [concat $design_files [ed_sim_reset_handler::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_reset_handler/sim/"]]
    set design_files [concat $design_files [ed_sim_emif_io96b_lpddr4_0::get_design_files "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_emif_io96b_lpddr4_0/sim/"]]
    lappend design_files "-makelib altera_merlin_axi_translator_1972 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_translator_1972/sim/ed_sim_altera_merlin_axi_translator_1972_npbsrda.sv"]\"   -end"
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/ed_sim_altera_mm_interconnect_1920_h43vqey.v"]\"   -end"                   
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"   -end"                                    
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"   -end"                                  
    lappend design_files "-makelib ed_sim \"[normalize_path "$QSYS_SIMDIR/ed_sim.v"]\"   -end"                                                                                                               
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
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_user_pll::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_async_clk_source::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_axil_driver_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_mem::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_ref_clk_source_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_rrip::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_traffic_generator::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_reset_handler::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [ed_sim_emif_io96b_lpddr4_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [ed_sim_user_pll::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_async_clk_source::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_axil_driver_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_mem::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_ref_clk_source_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_rrip::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_traffic_generator::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_reset_handler::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [ed_sim_emif_io96b_lpddr4_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_user_pll::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_async_clk_source::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_axil_driver_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_mem::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_ref_clk_source_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_rrip::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_traffic_generator::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_reset_handler::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [ed_sim_emif_io96b_lpddr4_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
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
    set libraries [dict merge $libraries [ed_sim_user_pll::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_user_pll/sim/"]]
    set libraries [dict merge $libraries [ed_sim_async_clk_source::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_async_clk_source/sim/"]]
    set libraries [dict merge $libraries [ed_sim_axil_driver_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_axil_driver_0/sim/"]]
    set libraries [dict merge $libraries [ed_sim_mem::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_mem/sim/"]]
    set libraries [dict merge $libraries [ed_sim_ref_clk_source_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_ref_clk_source_0/sim/"]]
    set libraries [dict merge $libraries [ed_sim_rrip::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_rrip/sim/"]]
    set libraries [dict merge $libraries [ed_sim_traffic_generator::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_traffic_generator/sim/"]]
    set libraries [dict merge $libraries [ed_sim_reset_handler::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_reset_handler/sim/"]]
    set libraries [dict merge $libraries [ed_sim_emif_io96b_lpddr4_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/ed_sim/ed_sim_emif_io96b_lpddr4_0/sim/"]]
    
    return $libraries
  }
  
}
