# (C) 2001-2025 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Intel 
# Program License Subscription Agreement, Intel MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Intel and sold by Intel 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 24.3.1 102 win32 2025.06.02.16:07:27
# ----------------------------------------
# Auto-generated simulation script run_msim_setup.tcl
# ----------------------------------------
# This script provides commands to run the msim_setup.tcl script for the following IP detected in
# your Quartus project:
#     ed_sim_rrip
# 
# 
# Intel recommends that you source this Quartus-generated IP simulation
# script to compile, elab and run the design without any customization.
# For customization, please follow the steps mentioned in msim_setup.tcl.

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

source $QSYS_SIMDIR/mentor/msim_setup.tcl
ld
run -all
quit
