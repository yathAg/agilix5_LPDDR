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


#####################################################################
#
# THIS IS AN AUTO-GENERATED FILE!
# -------------------------------
# If you modify this files, all your changes will be lost if you
# regenerate the core!
#
# FILE DESCRIPTION
# ----------------
# This file contains timing constraints for Test Engine's Global CSR

set ::syn_flow 0
set ::sta_flow 0
set ::fit_flow 0
set ::pow_flow 0

if { $::TimeQuestInfo(nameofexecutable) == "quartus_map" || $::TimeQuestInfo(nameofexecutable) == "quartus_syn" } {
    set ::syn_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_sta" } {
    set ::sta_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_fit" } {
    set ::fit_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_pow" } {
    set ::pow_flow 1
}

proc apply_sdc_reset_synchronizer {hier_path} {
    # Relax timing for the async reset signal going into the synchronizers
    # See RTL for the justification of setup=7 and hold=6
    global ::fit_flow

    set tmp_keep [get_keepers -nowarn $hier_path]
    set tmp_pin [get_pins -nowarn ${hier_path}|clrn]
    if {[get_collection_size $tmp_pin] > 0} {
        if {$::fit_flow == 1} {
            set_multicycle_path -through $tmp_pin -to $tmp_keep -setup 7 -end
            set_multicycle_path -through $tmp_pin -to $tmp_keep -hold 6 -end
        } else {
            set_false_path -through $tmp_pin -to $tmp_keep
        }
    }
}

proc apply_sdc_data_synchronizer {hier_path} {
    # Relax timing for signal going into the synchronizers
    # setup=7 and hold=6 are somewhat arbitrary choices
    global ::fit_flow

    set tmp_keep [get_keepers -nowarn $hier_path]
    set tmp_pin [get_pins -nowarn [list "${hier_path}|d" "${hier_path}|*data"]]
    if {[get_collection_size $tmp_pin] > 0} {
        if {$::fit_flow == 1} {
            set_multicycle_path -through $tmp_pin -to $tmp_keep -setup 7 -end
            set_multicycle_path -through $tmp_pin -to $tmp_keep -hold 6 -end
        } else {
            set_false_path -through $tmp_pin -to $tmp_keep
        }
    }
}

# Timing constraints for global signal synchronizers
foreach sync [list "global_csr_sync|g2d[*].run_sync" \
                   "global_csr_sync|g2d[*].done_sync" \
                   "global_csr_sync|g2d[*].error_sync" \
                   \
                   "global_csr_sync|d2d[*].post_in[*].sync" \
                   "global_csr_sync|d2d[*].wait_in[*].sync" \
    ] {

    apply_sdc_reset_synchronizer "${sync}|*"
    apply_sdc_data_synchronizer "${sync}|din_s1"
}

# Timing constraints for reset signal synchronizer
apply_sdc_data_synchronizer "reset_tree|sync|*"
