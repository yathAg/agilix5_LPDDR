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
# This file contains timing constraints for Test Engine's Memory AXI4 Driver

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


apply_sdc_data_synchronizer "reset_tree|sync|din_s1"
apply_sdc_data_synchronizer "csr_reset_tree|sync|din_s1"

set from_regs [get_registers -nowarn "csr_reset_tree|reset_leaf*"]
set to_regs   [get_registers -nowarn "csr_bank|*_skidbuf|skid.showahead_fifo|empty"]
if {[get_collection_size $from_regs] > 0 && [get_collection_size $to_regs] > 0} {
    set_false_path -from $from_regs -to $to_regs
}

set from_regs [get_registers -nowarn "csr_reset_tree|reset_leaf*"]
set to_regs   [get_registers -nowarn "csr_bank|*_skidbuf|skid.showahead_fifo|dc.dcfifo_inst|a*|*"]
if {[get_collection_size $from_regs] > 0 && [get_collection_size $to_regs] > 0} {
    set_false_path -from $from_regs -to $to_regs
}

set from_keep [get_keepers -nowarn "*_skidbuf|skid.showahead_fifo|dc.dcfifo_inst*ff_launch[*]"]
set to_keep   [get_keepers -nowarn "*_skidbuf|skid.showahead_fifo|dc.dcfifo_inst*ff_meta[*]"]
if {[get_collection_size $from_keep] > 0 && [get_collection_size $to_keep] > 0} {
    if {$::fit_flow == 1} {
        set_multicycle_path -from $from_keep -to $to_keep -setup 2 -end
        set_multicycle_path -from $from_keep -to $to_keep -hold 1 -end
    } else {
        set_false_path -from $from_keep -to $to_keep
    }
}
