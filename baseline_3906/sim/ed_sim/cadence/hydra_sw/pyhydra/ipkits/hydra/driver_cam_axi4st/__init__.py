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


# Anything imported here can be imported by users from pyhydra.ipkits.hydra.driver_mem_axi4 package
# So we use this to selectively expose user accessible functions

from .driver_compiler import CamAxi4stDriver

write_cmd         = CamAxi4stDriver.write_cmd
read_cmd          = CamAxi4stDriver.read_cmd
wait_writes_cmd   = CamAxi4stDriver.wait_writes_cmd
wait_reads_cmd    = CamAxi4stDriver.wait_reads_cmd
sleep_cmd         = CamAxi4stDriver.sleep_cmd
loop_cmd          = CamAxi4stDriver.loop_cmd
parallel_cmd      = CamAxi4stDriver.parallel_cmd
driver_post_cmd   = CamAxi4stDriver.driver_post_cmd
driver_wait_cmd   = CamAxi4stDriver.driver_wait_cmd

write_worker_op   = CamAxi4stDriver.write_worker_op
read_worker_op    = CamAxi4stDriver.read_worker_op

addr_op           = CamAxi4stDriver.addr_op
addr_alu_echo_op  = CamAxi4stDriver.addr_alu_echo_op
addr_alu_incr_op  = CamAxi4stDriver.addr_alu_incr_op
addr_alu_rand_op  = CamAxi4stDriver.addr_alu_rand_op

data_eq_addr_op   = CamAxi4stDriver.data_eq_addr_op
data_eq_id_op     = CamAxi4stDriver.data_eq_id_op
data_eq_dq_op     = CamAxi4stDriver.data_eq_dq_op
dq_alu_echo_op    = CamAxi4stDriver.dq_alu_echo_op
dq_alu_invert_op  = CamAxi4stDriver.dq_alu_invert_op
dq_alu_rotate_op  = CamAxi4stDriver.dq_alu_rotate_op
dq_alu_prbs_op    = CamAxi4stDriver.dq_alu_prbs_op

strb_eq_dm_op     = CamAxi4stDriver.strb_eq_dm_op
dm_alu_echo_op    = CamAxi4stDriver.dm_alu_echo_op
dm_alu_invert_op  = CamAxi4stDriver.dm_alu_invert_op
dm_alu_rotate_op  = CamAxi4stDriver.dm_alu_rotate_op
dm_alu_prbs_op    = CamAxi4stDriver.dm_alu_prbs_op

