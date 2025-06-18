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

from .driver_compiler import MemAxi4Driver

write_cmd         = MemAxi4Driver.write_cmd
read_cmd          = MemAxi4Driver.read_cmd
wait_writes_cmd   = MemAxi4Driver.wait_writes_cmd
wait_reads_cmd    = MemAxi4Driver.wait_reads_cmd
sleep_cmd         = MemAxi4Driver.sleep_cmd
loop_cmd          = MemAxi4Driver.loop_cmd
parallel_cmd      = MemAxi4Driver.parallel_cmd
driver_post_cmd   = MemAxi4Driver.driver_post_cmd
driver_wait_cmd   = MemAxi4Driver.driver_wait_cmd

write_worker_op   = MemAxi4Driver.write_worker_op
read_worker_op    = MemAxi4Driver.read_worker_op

addr_op           = MemAxi4Driver.addr_op
addr_alu_echo_op  = MemAxi4Driver.addr_alu_echo_op
addr_alu_incr_op  = MemAxi4Driver.addr_alu_incr_op
addr_alu_rand_op  = MemAxi4Driver.addr_alu_rand_op

data_eq_addr_op   = MemAxi4Driver.data_eq_addr_op
data_eq_id_op     = MemAxi4Driver.data_eq_id_op
data_eq_dq_op     = MemAxi4Driver.data_eq_dq_op
dq_alu_echo_op    = MemAxi4Driver.dq_alu_echo_op
dq_alu_invert_op  = MemAxi4Driver.dq_alu_invert_op
dq_alu_rotate_op  = MemAxi4Driver.dq_alu_rotate_op
dq_alu_prbs_op    = MemAxi4Driver.dq_alu_prbs_op

strb_eq_dm_op     = MemAxi4Driver.strb_eq_dm_op
dm_alu_echo_op    = MemAxi4Driver.dm_alu_echo_op
dm_alu_invert_op  = MemAxi4Driver.dm_alu_invert_op
dm_alu_rotate_op  = MemAxi4Driver.dm_alu_rotate_op
dm_alu_prbs_op    = MemAxi4Driver.dm_alu_prbs_op

