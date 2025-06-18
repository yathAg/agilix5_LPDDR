
namespace eval ed_sim_axil_driver_0 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries emif_ph2_axil_driver_100 1
    dict set libraries ed_sim_axil_driver_0     1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [list]
    lappend design_files "-makelib emif_ph2_axil_driver_100 \"[normalize_path "$QSYS_SIMDIR/../emif_ph2_axil_driver_100/sim/ed_sim_axil_driver_0_emif_ph2_axil_driver_100_qakapty.sv"]\"   -end"                
    lappend design_files "-makelib emif_ph2_axil_driver_100 \"[normalize_path "$QSYS_SIMDIR/../emif_ph2_axil_driver_100/sim/ed_sim_axil_driver_0_emif_ph2_axil_driver_100_qakapty_axil_driver_top.sv"]\"   -end"
    lappend design_files "-makelib ed_sim_axil_driver_0 \"[normalize_path "$QSYS_SIMDIR/ed_sim_axil_driver_0.v"]\"   -end"                                                                                      
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
