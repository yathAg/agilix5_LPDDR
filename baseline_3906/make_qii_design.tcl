# (C) 2001-2025 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.



proc error_and_exit {msg} {
   post_message -type error "SCRIPT_ABORTED!!!"
   foreach line [split $msg "\n"] {
      post_message -type error $line
   }
   qexit -error
}

proc ls_recursive {base glob} {
    set files [list]

    foreach f [glob -nocomplain -types f -directory $base $glob] {
        set file_path [file join $base $f]
        lappend files $file_path
    }

    foreach d [glob -nocomplain -types d -directory $base *] {
        set files_recursive [ls_recursive [file join $base $d] $glob]
        lappend files {*}$files_recursive
    }

    return $files
}

proc ls_dirs_recursive {base glob} {
    set dirs [list]

    foreach d [glob -nocomplain -types d -directory $base $glob] {
        set dir_path [file join $base $d]
        lappend dirs $dir_path
    }

    foreach d [glob -nocomplain -types d -directory $base *] {
        set dirs_recursive [ls_dirs_recursive [file join $base $d] $glob]
        lappend dirs {*}$dirs_recursive
    }

    return $dirs
}

proc get_relative_path {base path} {
    return [string trimleft [ string range $path [string length $base] [string length $path] ] "/"]
}

proc deep_copy {ifn ofn} {
   set ifh       [open $ifn r]
   set ofh       [open $ofn w]
   
   fconfigure $ifh -translation binary
   fconfigure $ofh -translation binary
   
   set blob [read $ifh]
   puts -nonewline $ofh $blob

   close $ofh
   close $ifh
}

proc parse_extra_configs {str} {
   array set retval {}
   foreach item [split $str ",; "] {
      set tmp [split $item "="]
      if {[llength $tmp] == 2} {
         set name [string toupper [lindex $tmp 0]]
         set val [lindex $tmp 1]
         set retval($name) $val
      }
   }
   return [array get retval]
}

proc iniu_inst {ch} {
   global noc_init
   return ${noc_init}|intel_noc_initiator_inst|iniu_${ch}|initiator_inst_0
}
proc iniu_inst_lite {ch} {
   global noc_init_lite
   return ${noc_init_lite}_${ch}|intel_noc_initiator_inst|iniu_0|initiator_inst_0
}
proc tniu_inst {ch} {
   global emif_name
   global emif_module_name
   return ${emif_name}|${emif_module_name}_inst|t${ch}.tniu_${ch}|tniu_0|target_0.target_inst_0
}
proc tniu_inst_lite {ch} {
   global emif_name
   global emif_module_name
   return ${emif_name}|${emif_module_name}_inst|io${ch}.calip_${ch}|cal_${ch}|gen_tniu.tniu|tniu|target_0.target_lite_inst_0
}

if {[string compare -nocase $quartus(nameofexecutable) "quartus"] == 0} {
   set gui_mode 1
} else {
   set gui_mode 0
}

set script_path [file dirname [file normalize [info script]]]

source "$script_path/params.tcl"

if {[is_project_open]} {
   post_message "Closing currently opened project..."
   project_close
}

set ex_design_path         "$script_path/qii"
set system_name            $ed_params(SYNTH_QSYS_NAME)
set qsys_file              "${system_name}.qsys"
set family                 $ip_params(SYSINFO_DEVICE_FAMILY)
set issp_en                false
set emif_name              $ed_params(EMIF_NAME)
set emif_module_name       $ed_params(EMIF_MODULE_NAME)
set proto                  $ed_params(tech_features.protocol)
set noc_init               $ed_params(NOC_INIT_NAME)
set noc_init_lite          $ed_params(NOC_INIT_LITE_NAME)

set extra_config_str $ip_params(DIAG_EXTRA_PARAMETERS);
puts $extra_config_str
array set extra_config_arr [parse_extra_configs $extra_config_str]

set arg [lindex $argv 0]
if {$argc > 1} {
   error_and_exit "make_qii_design.tcl can only take one argument.\nThe argument must be a valid device OPN,"
} elseif {$argc == 1} {
   set device $arg 
} else {
   set device $ed_params(DEFAULT_DEVICE)
}

post_message " "
post_message "*************************************************************************"
post_message "Intel External Memory Interface IP Example Design Builder"
post_message " "
post_message "Type  : Quartus Prime Project"
post_message "Family: $family"
post_message "Device: $device"
post_message " "
post_message "This script takes ~1 minute to execute..."
post_message "*************************************************************************"
post_message " "

if {[file isdirectory $ex_design_path]} {
   error_and_exit "Directory $ex_design_path has already been generated.\nThis script cannot overwrite generated example designs.\nIf you would like to regenerate the design by re-running the script, please remove the directory."
}

file mkdir $ex_design_path
file copy -force "${script_path}/$qsys_file" "${ex_design_path}/$qsys_file"

file mkdir "${ex_design_path}/ip"
file copy -force "${script_path}/ip/${system_name}" "${ex_design_path}/ip/."

deep_copy "$::env(QUARTUS_ROOTDIR)/../ip/altera/emif_io96b/ip_emif/ex_design/jtag_example.sdc" "${ex_design_path}/jtag_example.sdc"

if {[file exists "${script_path}/quartus.ini"]} {
   file copy -force "${script_path}/quartus.ini" "${ex_design_path}/quartus.ini"
}

post_message "Generating example design files..."

set qsys_generate_exe_path "$::env(QUARTUS_ROOTDIR)/sopc_builder/bin/qsys-generate"
set quartus_py_exe_path "$::env(QUARTUS_ROOTDIR)/bin/quartus_py"
if {![file exists $quartus_py_exe_path]} { set quartus_py_exe_path "$::env(QUARTUS_ROOTDIR)/bin64/quartus_py" }

cd $ex_design_path
exec -ignorestderr $qsys_generate_exe_path $qsys_file --pro --quartus-project=none --synthesis --family=$family --part=$device --search-path=$::env(QUARTUS_ROOTDIR)/../not_shipped/ip/altera/**/*,$ >>& ip_generate.out

post_message "Creating Quartus Prime project..."
project_new -family $family -part $device $system_name
set_global_assignment -name QSYS_FILE ${system_name}.qsys

if {$issp_en} {
   set_global_assignment -name VERILOG_MACRO "\"ALTERA_EMIF_ENABLE_ISSP=1\""
}
foreach ip_file [lsort [ls_recursive "${ex_design_path}/ip" "*.ip"]] {
   set ip_file [get_relative_path $ex_design_path $ip_file]
   set_global_assignment -name IP_FILE $ip_file
}

set_global_assignment -name SDC_FILE jtag_example.sdc

if {[info exists extra_config_arr(OSC_1_CLOCK_FREQUENCY)]} {
   set_global_assignment -name DEVICE_INITIALIZATION_CLOCK $extra_config_arr(OSC_1_CLOCK_FREQUENCY)
} else {
   set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_100MHZ
}

if {[regexp "A5E.*B23A" $device] || [regexp "A5E.00\[57\].*B23B" $device] || [regexp "SM7REVB_EC_A_V839A" $device]} {
   set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to ref_clk_usr_pll_clk -entity ed_synth
   set_instance_assignment -name IO_STANDARD "1.8-V LVCMOS" -to ref_clk_usr_pll_clk
}

if ([string match "1SG10MHN3F74C2LGS1*"  $device]) {
    set_global_assignment -name ASIC_PROTOTYPING on 
}

set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCSMX ../sim/ed_sim/synopsys/vcsmx/vcsmx_setup.sh -section_id eda_simulation
set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_XCELIUM ../sim/ed_sim/xcelium/xcelium_setup.sh -section_id eda_simulation
set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_RIVIERAPRO ../sim/ed_sim/aldec/run_rivierapro_setup.tcl -section_id eda_simulation
set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_QUESTA ../sim/ed_sim/mentor/run_msim_setup.tcl -section_id eda_simulation
if {$family eq "Agilex 7"} {
    set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCS ../sim/ed_sim/synopsys/vcs/vcs_setup.sh -section_id eda_simulation 
}


set mainband_noc [expr {$ip_params(PHY_MAINBAND_ACCESS_MODE) == "NOC"}]
set sideband_noc [expr {$ip_params(PHY_SIDEBAND_ACCESS_MODE) == "NOC"}]
if {$mainband_noc || $sideband_noc}  {
   if {$mainband_noc} {
      set extra_config_str        $ip_params(DIAG_EXTRA_PARAMETERS)
      array set extra_config_arr  [parse_extra_configs $extra_config_str]
      if {[info exists extra_config_arr(USR_CLK_FREQ_OVRD)]} {
         set iniu_freq_MHz $extra_config_arr(USR_CLK_FREQ_OVRD)
      } else {
         set iniu_freq_MHz $ip_params(EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ)
      }
      set Mbytes_per_sec [expr {double($iniu_freq_MHz) * 32.0 * 0.9}]
      set Gbytes_per_sec [expr {$Mbytes_per_sec / 1000.0}]
      set bw_mb [expr {$Gbytes_per_sec / 2.0}]
 
      set tr_size_mb 32
      if {$proto == "DDR4"} {
         set tr_size_mb 32
         set bw_mb [expr {$bw_mb / 2.0}]
      } elseif {$proto == "DDR5" || $proto == "LPDDR5"} {
         set tr_size_mb 64
      } elseif {$proto == "LPDDR4"} {
         set tr_size_mb 128
      }

      for {set ch_idx 0} {$ch_idx < $ip_params(MEM_NUM_CHANNELS)} {incr ch_idx} {
         set_instance_assignment -name NOC_READ_BANDWIDTH $bw_mb -from [iniu_inst $ch_idx] -to [tniu_inst $ch_idx] -entity $system_name
         set_instance_assignment -name NOC_WRITE_BANDWIDTH $bw_mb -from [iniu_inst $ch_idx] -to [tniu_inst $ch_idx] -entity $system_name
         set_instance_assignment -name NOC_READ_TRANSACTION_SIZE $tr_size_mb -from [iniu_inst $ch_idx] -to [tniu_inst $ch_idx] -entity $system_name
         set_instance_assignment -name NOC_WRITE_TRANSACTION_SIZE $tr_size_mb -from [iniu_inst $ch_idx] -to [tniu_inst $ch_idx] -entity $system_name
      }
   }
 
   if {$sideband_noc} {
      set bw_sb 0
      set tr_size_sb 32

      for {set io_idx 0} {$io_idx < $ip_params(MEM_NUM_IO96)} {incr io_idx} {
         set_instance_assignment -name NOC_READ_BANDWIDTH $bw_sb -from [iniu_inst_lite $io_idx] -to [tniu_inst_lite $io_idx] -entity $system_name
         set_instance_assignment -name NOC_WRITE_BANDWIDTH $bw_sb -from [iniu_inst_lite $io_idx] -to [tniu_inst_lite $io_idx] -entity $system_name
         set_instance_assignment -name NOC_READ_TRANSACTION_SIZE $tr_size_sb -from [iniu_inst_lite $io_idx] -to [tniu_inst_lite $io_idx] -entity $system_name
         set_instance_assignment -name NOC_WRITE_TRANSACTION_SIZE $tr_size_sb -from [iniu_inst_lite $io_idx] -to [tniu_inst_lite $io_idx] -entity $system_name
      }
   }
}

project_close

set hydra_prog $ed_params(TG_PROGRAM)

set srcdir [ls_dirs_recursive "${ex_design_path}/ip" "hydra_software*"]
set srcdir [ls_dirs_recursive "$srcdir" "sw"]
set dstdir "$ex_design_path/hydra_sw"
file mkdir $dstdir
foreach script_file [lsort [ls_recursive $srcdir "*"]] {
   set dst_script_file [file join $dstdir [get_relative_path $srcdir $script_file]]
   file mkdir [file dirname $dst_script_file]
   deep_copy $script_file $dst_script_file
}

set cmd [concat [list exec -ignorestderr $quartus_py_exe_path ${dstdir}/main.py --ipdir=${ex_design_path} --prog=$hydra_prog >>& hydra_compile.out]]
puts "ex_design_path=$ex_design_path"
puts "CMD: $cmd"
cd $ex_design_path
eval $cmd

if {$ip_params(EX_DESIGN_PMON_EN)} {
   set srcfile [ls_recursive "${ex_design_path}/ip" "pmon_library.tcl"]
   set srcfile [lindex $srcfile 0]
   deep_copy $srcfile "$ex_design_path/pmon_library.tcl"
}

if {$gui_mode} {
   project_open $system_name
}

post_message " "
post_message "*************************************************************************"
post_message "Successfully generated example design at the following location:"
post_message " "
post_message "   $ex_design_path"
post_message " "
post_message "*************************************************************************"
post_message " "
