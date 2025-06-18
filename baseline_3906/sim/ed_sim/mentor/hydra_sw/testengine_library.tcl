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




namespace eval ::testengine_lib:: {
    namespace export testengine_num_drivers
    namespace export testengine_driver_list
    namespace export testengine_run
    namespace export testengine_reset
    namespace export testengine_get_errors
    namespace export testengine_get_done
    namespace export testengine_status
    namespace export testengine_reprogram
    namespace export testengine_axi4_parse_errors
}


set ::g_update 1
set ::g_num_loops 0
set ::g_number_driver 50
set ::g_sof ""

if {[info exists argc] && [info exists argv]} {
    set n 0
    while {$argc > $n} {
       switch -glob -- [lindex $argv $n] {
          --sof=*               { set ::g_sof                   [string range [lindex $argv $n] [string length "--sof="] end]  }
          --update=*            { set ::g_update                [string range [lindex $argv $n] [string length "--update="] end] }
          --n-loops=*           { set ::g_num_loops             [string range [lindex $argv $n] [string length "--n-loops="] end] }
          --                    { break }
          default               { return -code error "Bad option \"[lindex $argv $n]\". Must be one of --sof=* --update=* --n-loops=*" }
       }
       incr n
    }

    if {$::g_sof == ""} {
        puts "No sof chosen, please load sof manually or use --sof=* option to choose sof. Ignore if sourcing in system-console"
    } else {
        puts "Loading sof: $::g_sof"
        if { [catch {design_load $::g_sof} message] } {
            puts "$message"
        }
    }
}

global bin_found
set bin_found 0
global traffic_program_dir
set traffic_program_dir "bin"
global claim_testengine_jamb_path

set path [lindex [get_service_paths master] [lsearch -glob [get_service_paths master] *remote_access_jamb*]]
if { $path == ""} {
   puts "Error : Test Engine remote JTAG interface not found"
   puts "Ensure .sof is loaded and JTAG access is functional before loading Test Engine System console library"
   set claim_testengine_jamb_path ""
   return
} else {
    puts "Test Engine remote JTAG interface found"
    set claim_testengine_jamb_path [claim_service master $path {} {}]
}

# TEST ENGINE FUNCTIONS

proc ::testengine_lib::testengine_num_drivers {} {
    global claim_testengine_jamb_path
    if {$claim_testengine_jamb_path == ""} {
        puts "Error : Test Engine remote JTAG interface not found"
        puts "Check if design is loaded and source the Test Engine IP System Console library again"
        return -1
    }
    set num_drivers 0
    set driver_list [list]
    for {set i 0x0} {$i < 32} {incr i} {
        set scratchpad [expr { ($i + 1) * 0x1000000 + 0x0000070} ]
        set ovlp_chk [master_read_32 $claim_testengine_jamb_path [format 0x%x $scratchpad] 1]
        if { $ovlp_chk == 0x0F10BACC } {
            break
        }

        master_write_32 $claim_testengine_jamb_path $scratchpad 0x1234ABCD
        set read0 [master_read_32 $claim_testengine_jamb_path $scratchpad 1]
        master_write_32 $claim_testengine_jamb_path $scratchpad 0x0F10BACC
        set read1 [master_read_32 $claim_testengine_jamb_path $scratchpad 1]

        if { $read0 == 0x1234ABCD && $read1 == 0x0F10BACC } {
            lappend driver_list $num_drivers
            incr num_drivers
        } else {
            break
        }
    }

    for {set i 0x0} {$i < $num_drivers} {incr i} {
       set scratchpad [expr { ($i + 1) * 0x1000000 + 0x0000070} ]
       set scratchpad [format 0x%x $scratchpad]
       master_write_32 $claim_testengine_jamb_path $scratchpad 0x0
    }

    if { $num_drivers == 0 } {
       puts "Error : Failed to discover Test Engine"
       return -1
    }
    return $driver_list
}

proc ::testengine_lib::testengine_driver_list {} {
    global traffic_program_dir
    global claim_testengine_jamb_path

    if {$claim_testengine_jamb_path == ""} {
        puts "Error : Test Engine remote JTAG interface not found"
        puts "Check if design is loaded and source the Test Engine IP System Console library again"
        return -1
    }
    if { [catch { set drivers [glob -directory $traffic_program_dir -- "*"] } errorstring] } {
       puts "Traffic program directory $traffic_program_dir was not found : $errorstring"
       return -1
    }
    set drivers [lsort -dictionary $drivers]
    set driver_list [list]

    foreach driver $drivers {
        regexp {driver(?:(\w+)_mem_axi4)} $driver -> c1
        if {[info exists c1]} {
            lappend driver_list [lindex $c1]
        }
    }
    if {[llength $driver_list] == 0} {
        return -1
    }
    return $driver_list
}

proc ::testengine_lib::testengine_run {} {
    # Rerun Test Engine Traffic across all drivers through the global CSR path
    global claim_testengine_jamb_path
    global bin_found

    if {$bin_found} {
        set num_drivers [testengine_driver_list]
    } else {
        set num_drivers [testengine_num_drivers]
    }
    if { $num_drivers == -1 } {
        puts "Unable to find number of drivers in the system, try another traffic program"
        return
    }
    puts "Running traffic on all drivers ..."
    set driver_run_bitmask_0_addr 0x0080
    set driver_run_bitmask_1_addr 0x0084
    set driver_run_bitmask_0 [master_read_32 $claim_testengine_jamb_path $driver_run_bitmask_0_addr 1]
    set driver_run_bitmask_1 [master_read_32 $claim_testengine_jamb_path $driver_run_bitmask_1_addr 1]

    set driver_run_bitmask [expr {($driver_run_bitmask_1 << 32) | $driver_run_bitmask_0}]

    set bitmask 0x0
    foreach driver $num_drivers {
        set bit_pos [expr 0x1 << $driver]
        set bitmask [expr $bitmask | $bit_pos]
    }

    set driver_run_bitmask [expr $bitmask | $driver_run_bitmask]
    master_write_32 $claim_testengine_jamb_path $driver_run_bitmask_0_addr [expr {($driver_run_bitmask >> (0*32)) & 0xFFFFFFFF}]
    master_write_32 $claim_testengine_jamb_path $driver_run_bitmask_1_addr [expr {($driver_run_bitmask >> (1*32)) & 0xFFFFFFFF}]

    set testengine_ctrl_status_0_addr 0x0078
    set testengine_ctrl_status_0 [master_read_32 $claim_testengine_jamb_path $testengine_ctrl_status_0_addr 1]

    if {$testengine_ctrl_status_0 & 0x4} {
        puts "Traffic has already been run."
        puts "Please call testengine_status to view results, and call testengine_reset before invoking testengine_run."
        return
    }

    set testengine_ctrl_status_0 [expr {$testengine_ctrl_status_0 | 0x4}]
    master_write_32 $claim_testengine_jamb_path $testengine_ctrl_status_0_addr $testengine_ctrl_status_0

    puts "Traffic is now running for all drivers"
}

proc ::testengine_lib::testengine_reset {} {
    global claim_testengine_jamb_path
    global bin_found

    if {$bin_found} {
        set num_drivers [testengine_driver_list]
    } else {
        set num_drivers [testengine_num_drivers]
    }
    if { $num_drivers == -1 } {
        puts "Unable to find number of drivers in the system, try another traffic program"
        return
    }

    puts "Resetting all drivers ..."
    set testengine_ctrl_status_0_addr 0x0078
    set testengine_ctrl_status_0 [master_read_32 $claim_testengine_jamb_path $testengine_ctrl_status_0_addr 1]

    set testengine_ctrl_status_0 [expr {$testengine_ctrl_status_0 & 0xFFFFFFFB}]
    master_write_32 $claim_testengine_jamb_path $testengine_ctrl_status_0_addr $testengine_ctrl_status_0

    foreach driver $num_drivers {
        set driver_ctrl_stat_addr [expr { ($driver + 1) * 0x1000000 + 0x0000068} ]
        master_write_32 $claim_testengine_jamb_path $driver_ctrl_stat_addr [expr {[master_read_32 $claim_testengine_jamb_path $driver_ctrl_stat_addr 1] | 0x1 }]
    }

    foreach driver $num_drivers {
        set driver_ctrl_stat_addr [expr { ($driver + 1) * 0x1000000 + 0x0000068} ]
        master_write_32 $claim_testengine_jamb_path $driver_ctrl_stat_addr [expr {[master_read_32 $claim_testengine_jamb_path $driver_ctrl_stat_addr 1] & ~0x1 }]
    }

    puts "Reset complete"
}

proc ::testengine_lib::testengine_get_errors {} {

    global claim_testengine_jamb_path
    global bin_found

    if {$bin_found} {
        set num_drivers [testengine_driver_list]
    } else {
        set num_drivers [testengine_num_drivers]
    }

    if { $num_drivers == -1 } {
        puts "Error: No AXI4 drivers found in Test Engine"
        return [list]
    }

    set testengine_error_0  [master_read_32 $claim_testengine_jamb_path 0x00000C0 1]
    set testengine_error_1  [master_read_32 $claim_testengine_jamb_path 0x00000C4 1]
    set testengine_error    [expr {($testengine_error_1  << 32) | $testengine_error_0}]

    set failed_drivers {}
    foreach driver $num_drivers {
        set bit_pos [expr 0x1 << $driver]

        if { $testengine_error & $bit_pos } {
            lappend failed_drivers $driver
        }
    }

    return $failed_drivers
}

proc ::testengine_lib::testengine_get_done {} {

    global claim_testengine_jamb_path
    global bin_found

    if {$bin_found} {
        set num_drivers [testengine_driver_list]
    } else {
        set num_drivers [testengine_num_drivers]
    }

    if { $num_drivers == -1 } {
        puts "Error: No AXI4 drivers found in Test Engine"
        return [list]
    }

    set testengine_done_0 [master_read_32 $claim_testengine_jamb_path 0x00000A0 1]
    set testengine_done_1 [master_read_32 $claim_testengine_jamb_path 0x00000A4 1]
    set testengine_done   [expr {($testengine_done_1  << 32) | $testengine_done_0}]

    set done_drivers {}
    foreach driver $num_drivers {
        set bit_pos [expr 0x1 << $driver]

        if { $testengine_done & $bit_pos } {
            lappend done_drivers $driver
        }
    }

    return $done_drivers
}

proc ::testengine_lib::testengine_status {} {
    global claim_testengine_jamb_path
    global bin_found

    if {$bin_found} {
        set num_drivers [testengine_driver_list]
    } else {
        set num_drivers [testengine_num_drivers]
    }
    if { $num_drivers == -1 } {
        puts "Error: No drivers found in Test Engine"
        return
    }


    set testengine_done_0 [master_read_32 $claim_testengine_jamb_path 0x00000A0 1]
    set testengine_done_1 [master_read_32 $claim_testengine_jamb_path 0x00000A4 1]
    set testengine_done   [expr {($testengine_done_1  << 32) | $testengine_done_0}]
    set testengine_error_0  [master_read_32 $claim_testengine_jamb_path 0x00000C0 1]
    set testengine_error_1  [master_read_32 $claim_testengine_jamb_path 0x00000C4 1]
    set testengine_error    [expr {($testengine_error_1  << 32) | $testengine_error_0}]
    set drivers_done   0
    set drivers_passed 0
    set unfin_drivers  {}
    set failed_drivers {}

    set current_driver_done 0

    foreach driver $num_drivers {
        set bit_pos [expr 0x1 << $driver]

        if { $testengine_done & $bit_pos } {
            incr drivers_done
            set current_driver_done 1
        } else {
            set current_driver_done 0
            lappend unfin_drivers $driver
        }

        if { $testengine_error & $bit_pos } {
            lappend failed_drivers $driver
        } elseif {$current_driver_done} {
            incr drivers_passed
        }
    }
    puts "Drivers Done: $drivers_done / [llength $num_drivers]"
    if {[llength $unfin_drivers] != 0 } {
       set unfin_str [lindex $unfin_drivers 0]
       if {[llength $unfin_drivers] == 1 } {
          puts "Driver $unfin_str did not finish!"
       } else {
          for {set i 1} {$i < [llength $unfin_drivers]} {incr i} {
             append unfin_str ", " [lindex $unfin_drivers $i]
          }
          puts "List of Unfinished Drivers: \[$unfin_str\]"
       }
    }
    puts "Drivers Passed: $drivers_passed / [llength $num_drivers]"
    if { [llength $failed_drivers] != 0 } {
       set fail_str [lindex $failed_drivers 0]
       if {[llength $failed_drivers] == 1 } {
          puts "Driver $fail_str failed!"
       } else {
          for {set i 1} {$i < [llength $failed_drivers]} {incr i} {
             append fail_str ", " [lindex $failed_drivers $i]
          }
          puts "List of Failed Drivers: \[$fail_str\]"
       }
    }

    if {$drivers_done == 0 && [llength $failed_drivers] == 0} {
        set testengine_ctrl_status_0_addr 0x0078
        set testengine_ctrl_status_0 [master_read_32 $claim_testengine_jamb_path $testengine_ctrl_status_0_addr 1]
        if {$testengine_ctrl_status_0 & 0x4} {
            return
        } else {
            puts "No Traffic was run"
            puts "Please call testengine_run after reset to see traffic results"
            return
        }
    }
}

proc ::testengine_lib::testengine_reprogram {{dir "bin"}} {
    global claim_testengine_jamb_path
    global bin_found
    global traffic_program_dir

    set old_dir $traffic_program_dir
    set old_bin_found $bin_found
    set bin_found 1
    set traffic_program_dir $dir

    set driver_list [testengine_driver_list]

    if { $driver_list == -1 } {
        puts "Unable to find number of drivers in the system, try another traffic program"
        set bin_found $old_bin_found
        set traffic_program_dir $old_dir
        return
    } else {
        puts "Traffic program directory updated to $dir"
    }

    foreach driver $driver_list {
        set driver_ctrl_stat_addr [expr { ($driver + 1) * 0x1000000 + 0x0000068} ]
        master_write_32 $claim_testengine_jamb_path $driver_ctrl_stat_addr  [expr {[master_read_32 $claim_testengine_jamb_path $driver_ctrl_stat_addr 1] & ~0x4 }]
    }

    set testengine_ctrl_status_0_addr 0x0078
    set testengine_ctrl_status_0 [master_read_32 $claim_testengine_jamb_path $testengine_ctrl_status_0_addr 1]

    set testengine_ctrl_status_0 [expr {$testengine_ctrl_status_0 & 0xFFFFFFFB}]
    master_write_32 $claim_testengine_jamb_path $testengine_ctrl_status_0_addr $testengine_ctrl_status_0

    foreach driver $driver_list {
        if { [catch { set instr_rams_commands_txt_files [glob -directory ${traffic_program_dir}/driver${driver}_mem_axi4/csr -- "*.txt"] } errorstring] } {
            puts "Traffic program files for driver $driver were not found : $errorstring"
        } else {
            set empty [catch {file size $instr_rams_commands_txt_files} size]
            if {$empty == 0 && $size > 0} {
                puts "Traffic program file $instr_rams_commands_txt_files for driver ${traffic_program_dir}/driver${driver}_mem_axi4 was empty"
            } else {
                puts "Updating instruction memory for driver $driver... this can take ~1 minute"

                set base_addr [expr { ($driver + 1) * 0x1000000}]

                foreach instr_rams_commands_txt_file $instr_rams_commands_txt_files {
                    set file [open $instr_rams_commands_txt_file r]
                    while {[gets $file line]>=0} {
                        set addr [lindex $line 0]
                        set data_32 [lindex $line 1]
                        set addr [expr {$addr | $base_addr}]
                        master_write_32 $claim_testengine_jamb_path $addr [list $data_32]
                    }
                    close $file
                }
            }

        }
        incr driver_idx
    }

    testengine_reset

    puts "Instruction memory update complete"
}

proc ::testengine_lib::testengine_axi4_parse_errors { {driver 0} {log_dir "."} {axid_width -1} {axaddr_width -1} {xdata_width -1} } {
    global claim_testengine_jamb_path
    global bin_found

    set missing_args 0

    if { $axid_width   == -1 } { 
        puts "Warning: Missing axid_width argument."
        incr missing_args 
    }
    if { $axaddr_width == -1 } { 
        puts "Warning: Missing axaddr_width argument."
        incr missing_args 
    }
    if { $xdata_width  == -1 } { 
        puts "Warning: Missing xdata_width argument."
        incr missing_args 
    }

    if { $missing_args == 3 } {
        puts "Info: No AXI port widths have been provided. Defaulting to reading error counters only."
    } elseif {$missing_args != 0} {
        puts "Error: Please provide the arguments noted above for detailed error logs."
        return
    }

    if {$bin_found} {
        set num_drivers [testengine_driver_list]
    } else {
        set num_drivers [testengine_num_drivers]
    }

    if {[lsearch -exact $num_drivers $driver] == -1} {
        puts "Error: $driver is not a valid choice for an AXI4 driver index"
        return
    }


    if { [catch {set log [open "${log_dir}/driver_${driver}_errors.txt" w+]} fid] } {
        puts "Error: Invalid directory $log_dir provided for writing\n$fid"
        return
    }

    puts $log "Driver $driver :"
    puts $log ""

    set driver_base_addr [expr { ($driver + 1) * 0x1000000}]

    puts "Reading from driver $driver error log"
    set csrs [master_read_32 $claim_testengine_jamb_path [expr {$driver_base_addr + 0x98}] 51]
    puts "Writing to results to ${log_dir}/driver_${driver}_errors.txt"
    puts $log "Num BID errors = [lindex $csrs 0]"
    puts $log "Num BRESP errors = [lindex $csrs 1]"
    puts $log "Num RID errors = [lindex $csrs 2]"
    puts $log "Num RRESP errors = [lindex $csrs 3]"
    puts $log "Num RDATA errors = [lindex $csrs 4]"
    puts $log "Num RLAST errors = [lindex $csrs 5]"
    set val 0
    for {set i 45} {$i >= 6} {incr i -1} {
        set val "${val}[string range [lindex $csrs $i] 2 end]"
    }
    puts $log "PNF = 0x$val"
    set val 0
    for {set i 49} {$i >= 46} {incr i -1} {
        set val "${val}[string range [lindex $csrs $i] 2 end]"
    }
    puts $log "TER DQ mask = 0x$val"
    puts $log "TER (Transaction Error Count) = [lindex $csrs 50]"

    if {$missing_args == 0} {
        puts "Info: Reading detailed error logs"

        set xstrb_width [expr {int($xdata_width / 8)}]

        foreach is_read {true false} {
            if {$is_read} {
                puts $log "\nRead Error Log:\n"
                set err_signals [list \
                    unexpected_id   1 \
                    xresp           2 \
                    golden_xresp    2 \
                    xdata           $xdata_width \
                    golden_xdata    $xdata_width \
                    golden_xstrb    $xstrb_width \
                    xlast           1 \
                    golden_xlast    1 \
                    xid             $axid_width \
                    golden_xid      $axid_width \
                    golden_axid     $axid_width \
                    golden_axaddr   $axaddr_width \
                ]

                set log_ram_csr_MSB 0x1e
                set wrptr_csr_syscon_addr 0x88

            } else {
                puts $log "\nWrite Error Log:\n"
                set err_signals [list \
                    unexpected_id   1 \
                    xresp           2 \
                    golden_xresp    2 \
                    golden_axid     $axid_width \
                    golden_axaddr   $axaddr_width \
                ]

                set log_ram_csr_MSB 0x1d
                set wrptr_csr_syscon_addr 0x78
            }

            set LOG_WIDTH 0
            foreach {key val} $err_signals { incr LOG_WIDTH $val }

            set CSR_DATA_WIDTH 32

            set RAM_WIDTH -1
            set LOG_ENTRY_SIZE_LIST [list 1 2 4 8 16 32 64]
            foreach log_size $LOG_ENTRY_SIZE_LIST {
                if { $LOG_WIDTH <= $CSR_DATA_WIDTH * $log_size } {
                    set RAM_WIDTH [expr {$CSR_DATA_WIDTH * $log_size}]
                    set LOG_ENTRY_SIZE $log_size
                    break
                }
            }

            set wrptr_csr_syscon_addr [expr {$wrptr_csr_syscon_addr + $driver_base_addr}]
            set reads_req_per_log [expr {int(ceil(double($LOG_WIDTH) / $CSR_DATA_WIDTH))}]
            set padding [expr { ($CSR_DATA_WIDTH * $reads_req_per_log) - $LOG_WIDTH}]

            set log_ram_base_syscon_addr [expr {$log_ram_csr_MSB << 18}]
            set log_ram_base_syscon_addr [expr {$log_ram_base_syscon_addr + $driver_base_addr}]
            set log_ram_wrptr_ram_addr [master_read_32 $claim_testengine_jamb_path $wrptr_csr_syscon_addr 1]
            set log_ram_wrptr_syscon_addr [expr {$log_ram_base_syscon_addr + $log_ram_wrptr_ram_addr}]

            set error_strings [list]

            set log_ram_rdptr_syscon_addr $log_ram_base_syscon_addr

            format 0x%x $log_ram_rdptr_syscon_addr
            format 0x%x $log_ram_wrptr_syscon_addr

            while {$log_ram_rdptr_syscon_addr < $log_ram_wrptr_syscon_addr} {
                set error_string ""

                set entry [master_read_32 $claim_testengine_jamb_path $log_ram_rdptr_syscon_addr $reads_req_per_log]

                foreach hex $entry {
                set length [string length $hex]
                set value [string range $hex 2 $length]
                binary scan [binary format H* $value] B* bits

                set error_string $bits$error_string
                }

                set length [string length $error_string]
                set error_string [string range $error_string $padding $length]

                lappend error_strings $error_string

                set log_ram_rdptr_syscon_addr [expr {int( $log_ram_rdptr_syscon_addr + 4 * $LOG_ENTRY_SIZE )} ]
            }

            foreach error_string $error_strings {
                set i 0
                foreach {key val} $err_signals {
                    set err_signal [string range $error_string $i [expr {$i + $val - 1}]]
                    set width [expr int(ceil($val/8.0) * 8)]
                    set err_signal [format "%0*s" $width $err_signal]
                    binary scan [binary format B* $err_signal] H* err_signal
                    puts $log "$key = 0x$err_signal"
                    incr i $val
                }
                puts $log "\n**************************************************************************\n"
            }

        }
    } 


    

    close $log

    set errors [lrange $csrs 0 5]
    if {[lsearch -not $errors 0x00000000] == -1} {
        puts "Error logging complete. No errors found in log."
    } else {
        puts "Error logging complete. Errors found in log."
    }
}

# LIBRARY INITIALIZATION

namespace import ::testengine_lib::*

puts "Test Engine System Console library loaded"


if { [catch { set driver_list [glob -directory "bin" -- "*"] } errorstring] } {
    set dir_list [glob -type d "*"]
    foreach dir $dir_list {
        set traffic_program_dir $dir
        set te_driver_list [testengine_driver_list]
        if { $te_driver_list != -1 } {
            set bin_found 1
            puts "Traffic program directory $dir was found"
            puts "If this traffic program does not match the design on board run testengine_reprogram <dir> "
            break
        }
    }
    if { $bin_found == 0}  {
        set traffic_program_dir "bin"
        puts "No Traffic program directory was found : $errorstring"
    }
} else {
    set bin_found 1
    puts "Traffic program directory bin was found"
}

# system-console --script=testengine_library.tcl test

if {[info exists argc] && [info exists argv]} {
    set ::updated 0

    for { set loop 0 } { $loop < $::g_num_loops } { incr loop } {

        puts "\n****    Loop $loop    ****"
        testengine_reset

        if { $::g_update &&  ($::updated == "0" ) } {
            testengine_reprogram
            set ::updated 1
        }

        testengine_run
        testengine_status
    }
}

