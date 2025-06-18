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

proc error_and_exit {msg} {
   post_message -type error "SCRIPT_ABORTED!!!"
   foreach line [split $msg "\n"] {
      post_message -type error $line
   }
   qexit -error
}

proc show_usage_and_exit {argv0} {
   post_message -type error  "USAGE: $argv0 \[VERILOG|VHDL\]"
   qexit -error
}

set print_profile_flag 1

set argv0 "quartus_sh -t [info script]"
set args $quartus(args)

if {[llength $args] == 1 } {
   set lang [string toupper [string trim [lindex $args 0]]]
   if {$lang != "VERILOG" && $lang != "VHDL"} {
      show_usage_and_exit $argv0
   }
} else {
   set lang "VERILOG"
}

if {[llength $args] > 1} {
   show_usage_and_exit $argv0
}

if {[is_project_open]} {
   post_message "Closing currently opened project..."
   project_close
}

set script_path [file dirname [file normalize [info script]]]

set time_start [clock clicks -milliseconds]
source "$script_path/params.tcl"
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   post_message "EMIF make_sim_design.tcl: extracting EMIF parameterization took [expr {$time_end - $time_start}]ms."
}

set ex_design_path         "$script_path/sim"
set system_name            $ed_params(SIM_QSYS_NAME)
set qsys_file              "${system_name}.qsys"
set family                 $ip_params(SYSINFO_DEVICE_FAMILY)
set device                 $ed_params(DEFAULT_DEVICE)
set emif_name              $ed_params(EMIF_NAME)
set ed_sim                 $ed_params(SIM_QSYS_NAME)

post_message " "
post_message "*************************************************************************"
post_message "Intel External Memory Interface IP Example Design Builder"
post_message " "
post_message "Type    : Simulation Design"
post_message "Family  : $family"
post_message "Language: $lang"
post_message " "
post_message "This script takes ~1 minute to execute..."
post_message "*************************************************************************"
post_message " "


if {$lang == "VHDL"} {
   error_and_exit "Simulation for this HDL is not supported by the current IP version."
}

if {[file isdirectory $ex_design_path]} {
   error_and_exit "Directory $ex_design_path has already been generated.\nThis script cannot overwrite generated example designs.\nIf you would like to regenerate the design by re-running the script, please remove the directory."
}

set time_start [clock clicks -milliseconds]
file mkdir $ex_design_path
file copy -force "${script_path}/$qsys_file" "${ex_design_path}/$qsys_file"

file mkdir "${ex_design_path}/ip"
file copy -force "${script_path}/ip/${system_name}" "${ex_design_path}/ip/."

if {[file exists "${script_path}/quartus.ini"]} {
   file copy -force "${script_path}/quartus.ini" "${ex_design_path}/quartus.ini"
}
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   post_message "EMIF make_sim_design.tcl: file copying took [expr {$time_end - $time_start}]ms."
}

post_message "Generating example design files..."

set qsys_generate_exe_path "$::env(QUARTUS_ROOTDIR)/sopc_builder/bin/qsys-generate"
set ip_make_simscript_exe_path "$::env(QUARTUS_ROOTDIR)/sopc_builder/bin/ip-make-simscript"
set quartus_py_exe_path "$::env(QUARTUS_ROOTDIR)/bin/quartus_py"
if {![file exists $quartus_py_exe_path]} { set quartus_py_exe_path "$::env(QUARTUS_ROOTDIR)/bin64/quartus_py" }

set time_start [clock clicks -milliseconds]
cd $ex_design_path
exec -ignorestderr $qsys_generate_exe_path $qsys_file --pro --quartus-project=none --simulation=$lang --family=$family --part=$device --search-path=$::env(QUARTUS_ROOTDIR)/../not_shipped/ip/altera/**/*,$ >>& ip_generate.out
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   post_message "EMIF make_sim_design.tcl: example design generation took [expr {$time_end - $time_start}]ms."
}
set time_start [clock clicks -milliseconds]
file delete -force "${ex_design_path}/ed_sim/sim/synopsys"
file delete -force "${ex_design_path}/ed_sim/sim/cadence"
file delete -force "${ex_design_path}/ed_sim/sim/xcelium"
file delete -force "${ex_design_path}/ed_sim/sim/aldec"
file delete -force "${ex_design_path}/ed_sim/sim/mentor"

cd $system_name
set spd_file_list [ls_recursive "${ex_design_path}/ip/" "*.spd"]
lappend spd_file_list "$system_name.spd"
set spd_files [join $spd_file_list ","]
exec -ignorestderr $ip_make_simscript_exe_path --use-relative-paths --spd=$spd_files >>& make_simscript.out
file delete -force make_simscript.out
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   post_message "EMIF make_sim_design.tcl: re-generating simulation setup scripts took [expr {$time_end - $time_start}]ms."
}

set time_start [clock clicks -milliseconds]
post_message "Finalizing..."

set sim_scripts [list]
set vcs_script     "${ex_design_path}/ed_sim/synopsys/vcs/vcs_setup.sh"
set xcelium_script "${ex_design_path}/ed_sim/xcelium/xcelium_setup.sh"
set ncsim_script   "${ex_design_path}/ed_sim/cadence/ncsim_setup.sh"
set vcsmx_script   "${ex_design_path}/ed_sim/synopsys/vcsmx/vcsmx_setup.sh"
set riviera_script "${ex_design_path}/ed_sim/aldec/rivierapro_setup.tcl"
if {$lang == "VERILOG"} {
   lappend sim_scripts $vcs_script
}
lappend sim_scripts $vcsmx_script
lappend sim_scripts $ncsim_script
lappend sim_scripts $xcelium_script
lappend sim_scripts $riviera_script

foreach sim_script $sim_scripts {
   if {[file exists $sim_script]} { 
      set fh [open $sim_script r]
      set file_data [read $fh]
      close $fh
      
      set fh [open $sim_script w]
      foreach line [split $file_data "\n"] {
         if {[regexp -- {USER_DEFINED_SIM_OPTIONS\s*=.*\+vcs\+finish\+100} $line]} {
            regsub -- {\+vcs\+finish\+100} $line {} line
         }
         if {[regexp -- {USER_DEFINED_SIM_OPTIONS\s*=.*\-input \\\"\@run 100; exit\\\"} $line]} {
            regsub -- {\-input \\\"\@run 100; exit\\\"} $line {} line
         }
         if {$sim_script == $vcs_script && [regexp -- {TOP_LEVEL_NAME\s*=.*} $line]} {
            set line "TOP_LEVEL_NAME=\"${system_name}\""
         }
         if {$sim_script == $xcelium_script && [regexp -- {USER_DEFINED_ELAB_OPTIONS} $line]} {
            regsub -- {\"\"} $line {"-timescale 1ps/1ps"} line
         }
         if {$sim_script == $xcelium_script && [regexp -- {tclsh.*USER_DEFINED_VERILOG_COMPILE_OPTIONS} $line]} {
            regsub -- {USER_DEFINED_VERILOG_COMPILE_OPTIONS} $line {USER_DEFINED_VERILOG_COMPILE_OPTIONS -sv} line
         }
         if {$sim_script == $ncsim_script && [regexp -- {USER_DEFINED_ELAB_OPTIONS} $line]} {
            regsub -- {\"\"} $line {"-timescale 1ps/1ps"} line
         }
         if {[regexp -- {eda/sim_lib/.*hssi.*sv} $line]} {
            continue
         }
         if {[regexp -- {eda/sim_lib/fp4_maibo_atoms_ncrypt\.sv} $line]} {
            continue
         }
         puts $fh $line
      }
      close $fh
   }
}


set sim_script "${ex_design_path}/ed_sim/mentor/msim_setup.tcl"
if {[file exists $sim_script]} { 
    set fh [open $sim_script r]
    set file_data [read $fh]
    close $fh
    
    set fh [open $sim_script w]
    foreach line [split $file_data "\n"] {
        if {[regexp -- {eval vsim} $line]} {
           regsub -- {eval vsim} $line {eval vsim -suppress 2732 -suppress 1130 -suppress 7041 -suppress 7033 -voptargs=-svext=+adta} line
        }
        if {[regexp -- {libraries/.*hssi.*ver} $line] || [regexp -- {eda/sim_lib/.*hssi.*sv} $line]} {
           continue
        }
        if {[regexp -- {set logical_libraries.*hssi} $line]} {
           regsub -all -- { "\w*_hssi_\w*"} $line {} line
        }
        if {[regexp -- {set USER_DEFINED_COMPILE_OPTIONS} $line]} {
           set line "set USER_DEFINED_COMPILE_OPTIONS \"-O0\""
        }
        puts $fh $line

    }
    puts $fh "ld\nrun -all"
    close $fh
}

set sim_dirs [list]
lappend sim_dirs "${ex_design_path}/${system_name}/synopsys/vcs"
lappend sim_dirs "${ex_design_path}/${system_name}/synopsys/vcsmx"
lappend sim_dirs "${ex_design_path}/${system_name}/cadence"
lappend sim_dirs "${ex_design_path}/${system_name}/mentor"
lappend sim_dirs "${ex_design_path}/${system_name}/aldec"
lappend sim_dirs "${ex_design_path}/${system_name}/xcelium"
   
set noc_inc_file "${ex_design_path}/${ed_sim}/sim/${ed_sim}_noc_sim.inc"
if {[file exists $noc_inc_file]} {
   foreach sim_dir $sim_dirs {
      if {[file exists $sim_dir]} {
         deep_copy "$noc_inc_file" "$sim_dir/${ed_sim}_noc_sim.inc"
      }
   }

   set ed_sim_file "${ex_design_path}/${ed_sim}/sim/${ed_sim}.v"
   set fh    [open $ed_sim_file r]
   set lines [read $fh]
   close $fh

   set fh [open $ed_sim_file w]
   foreach line [split $lines "\n"] {
      if {[string match "*endmodule*" $line]} {
         puts $fh "   `include \"${ed_sim}_noc_sim.inc\"\n"
      }
      puts $fh $line
   }
   close $fh
}

set mentor_fileset_file "${ex_design_path}/${ed_sim}/common/modelsim_files.tcl"
set fh [open $mentor_fileset_file r]
set lines [read $fh]
close $fh

set fh [open $mentor_fileset_file w]
foreach line [split $lines "\n"] {
   if {[regexp "${ed_sim}.v" $line]} {
      regsub -- {vlog} $line {vlog -sv} line
   }
   puts $fh $line
}
close $fh
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   post_message "EMIF make_sim_design.tcl: modifying simulation files took [expr {$time_end - $time_start}]ms."
}



set extra_config_str        $ip_params(DIAG_EXTRA_PARAMETERS);
puts $extra_config_str
array set extra_config_arr       [parse_extra_configs $extra_config_str]


set time_start [clock clicks -milliseconds]

set hydra_prog $ed_params(TG_PROGRAM)

foreach sim_dir $sim_dirs {
   set srcdir [ls_dirs_recursive "${ex_design_path}/ip" "hydra_software*"]
   set srcdir [ls_dirs_recursive "$srcdir" "sw"]
   set dstdir "$sim_dir/hydra_sw"
   file mkdir $dstdir
   foreach script_file [lsort [ls_recursive $srcdir "*"]] {
      set dst_script_file [file join $dstdir [get_relative_path $srcdir $script_file]]
      file mkdir [file dirname $dst_script_file]
      deep_copy $script_file $dst_script_file
   }

   set cmd [concat [list exec -ignorestderr $quartus_py_exe_path ${dstdir}/main.py --ipdir=${ex_design_path} --prog=$hydra_prog >>& hydra_compile.out]]
   cd $sim_dir
   eval $cmd
}

set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   post_message "EMIF make_sim_design.tcl: generating HYDRA firmware took [expr {$time_end - $time_start}]ms."
}
post_message " "
post_message "*************************************************************************"
post_message "Successfully generated example design at the following location:"
post_message " "
post_message "   $ex_design_path"
post_message " "
post_message "*************************************************************************"
post_message " "
