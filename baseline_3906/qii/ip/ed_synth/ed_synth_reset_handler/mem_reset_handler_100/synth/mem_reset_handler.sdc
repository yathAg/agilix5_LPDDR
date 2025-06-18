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


#__ACDS_USER_COMMENT__####################################################################
#__ACDS_USER_COMMENT__
#__ACDS_USER_COMMENT__ THIS IS AN AUTO-GENERATED FILE!
#__ACDS_USER_COMMENT__ -------------------------------
#__ACDS_USER_COMMENT__ If you modify this files, all your changes will be lost if you
#__ACDS_USER_COMMENT__ regenerate the core!
#__ACDS_USER_COMMENT__
#__ACDS_USER_COMMENT__ FILE DESCRIPTION
#__ACDS_USER_COMMENT__ ----------------
#__ACDS_USER_COMMENT__ This file specifies the timing constraints for the EMIF local_reset_combiner
#__ACDS_USER_COMMENT__ component, which is instantiated as part of the EMIF example design.

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

    set tmp_pin [get_pins -nowarn ${hier_path}|clrn]
    if {[get_collection_size $tmp_pin] > 0} {
        if {$::fit_flow == 1} {
            set_multicycle_path -through $tmp_pin -to $hier_path -setup 7 -end
            set_multicycle_path -through $tmp_pin -to $hier_path -hold 6 -end
        } else {
            set_false_path -through $tmp_pin -to $hier_path
        }
    }
}

proc apply_sdc_data_synchronizer_input {hier_path} {
    global ::fit_flow

    set tmp_pin [get_pins -nowarn ${hier_path}|d]
    if {[get_collection_size $tmp_pin] > 0} {
        if {$::fit_flow == 1} {
            set_multicycle_path -through $tmp_pin -to $hier_path -setup 7 -end
            set_multicycle_path -through $tmp_pin -to $hier_path -hold 6 -end
        } else {
            set_false_path -through $tmp_pin -to [get_keepers $hier_path]
        }
    }
}

#apply_sdc_reset_synchronizer "*mem_reset_handler_inst*reset_sync_inst|din_s1"
apply_sdc_data_synchronizer_input "mem_reset_handler_inst|reset_n_sync.reset_sync_inst|din_s1"

