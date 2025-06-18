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


import math
import random
import re

from fractions import Fraction
from typing import List, Tuple, Union

import pyhydra.ipkits.hydra.driver_mem_axi4 as driver
import pyhydra.ipkits.hydra.driver_csr_axi4l as driver_csr


# Function aliases for convenience
# Commands
write       = driver.write_cmd         # AXI write command
read        = driver.read_cmd          # AXI read command
wait_writes = driver.wait_writes_cmd   # Wait for all outstanding AXI write responses
wait_reads  = driver.wait_reads_cmd    # Wait for all outstanding AXI read responses
sleep       = driver.sleep_cmd         # Put the driver to sleep
loop        = driver.loop_cmd          # Repeat a sequence of commands
parallel    = driver.parallel_cmd      # Execute commands simultaneously
post        = driver.driver_post_cmd   # Issue a 'post' to other driver(s)
wait        = driver.driver_wait_cmd   # Wait for a 'post' from other driver(s)

# Ops, passed as arguments to a command
wr_worker   = driver.write_worker_op
rd_worker   = driver.read_worker_op

addr_gen    = driver.addr_op
echo        = driver.addr_alu_echo_op
incr        = driver.addr_alu_incr_op
rand        = driver.addr_alu_rand_op

data_eq_addr= driver.data_eq_addr_op
data_eq_id  = driver.data_eq_id_op
data_eq_dq  = driver.data_eq_dq_op
dq_echo     = driver.dq_alu_echo_op
dq_rotate   = driver.dq_alu_rotate_op
dq_invert   = driver.dq_alu_invert_op
dq_prbs     = driver.dq_alu_prbs_op

strb_eq_dm  = driver.strb_eq_dm_op
dm_echo     = driver.dm_alu_echo_op
dm_rotate   = driver.dm_alu_rotate_op
dm_invert   = driver.dm_alu_invert_op
dm_prbs     = driver.dm_alu_prbs_op

# CSR driver commands
write_csr = driver_csr.write_cmd
read_csr  = driver_csr.read_cmd

# Some enums
axburst_fixed = 0b00
axburst_incr  = 0b01
axburst_wrap  = 0b10

xresp_okay   = 0b00
xresp_exokay = 0b01
xresp_slverr = 0b10
xresp_decerr = 0b11

# Address fields. This assumes Memory AXI Driver's ADDR_FIELD_*_MASK params are configured accordingly.
full  = 0
row   = 2
col   = 3
ba    = 4
bg    = 5


class MemAxi4DriverPrograms:
   '''
   An object of this class should contain traffic programs customized for the specific driver and the specific target
   it's connected to.
   '''

   def __init__(self, config, hydra_ip_name, driver_index):
      ########################################################################
      # How is the Hydra driver configured
      ########################################################################

      hydra_config = config['system']['ips'][hydra_ip_name]
      hydra_params = hydra_config['parameters']

      self.num_drivers = int(hydra_params['NUM_DRIVERS']['value'])
      self.driver_index = driver_index

      driver_type = hydra_params[f'DRIVER_{self.driver_index}_TYPE_ENUM']['value']
      if driver_type != 'DRIVER_TYPE_MEM_AXI4':
         raise Exception(f'Driver {self.driver_index} is of type {driver_type}, this class only supports DRIVER_TYPE_MEM_AXI4')

      # Address ALU arg width, impacts the address range accessible by a single read/write command
      self.addr_alu_arg_width = int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_ADDR_ALU_ARG_WIDTH']['value'])

      # Some parameters related to AXI port widths
      self.max_awid   = 2**int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_AWID_WIDTH']['value']) - 1
      self.max_arid   = 2**int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_ARID_WIDTH']['value']) - 1
      self.max_awaddr = 2**int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_AWADDR_WIDTH']['value']) - 1
      self.max_araddr = 2**int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_ARADDR_WIDTH']['value']) - 1

      # Carefully handle non-power-of-2 data widths.
      # Ex: if data width = 320 bits, then xDATA width = 256 and xUSER width = 64.
      #     AxADDR needs to be aligned to 256-bit boundary, not 320-bit.
      #     AxSIZE corresponds to only 256-bit xDATA, not 320-bit.
      #
      # Gotcha: Memory AXI Driver IP param 'DRIVER_{self.driver_index}_MEM_AXI4_RDATA_WIDTH' captures
      # total data width, which would be 320 in the previous example.
      self.total_wdata_width = int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_WDATA_WIDTH']['value'])
      self.wdata_width       = 2 ** math.floor(math.log2(self.total_wdata_width)) 
      self.wuser_width       = self.total_wdata_width - self.wdata_width          

      self.total_rdata_width = int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_RDATA_WIDTH']['value'])
      self.rdata_width       = 2 ** math.floor(math.log2(self.total_rdata_width)) 
      self.ruser_width       = self.total_rdata_width - self.rdata_width          

      # Min AxADDR increment for xDATA-aligned accesses = num bytes in an xDATA word (since AxADDR is byte-addressable)
      self.min_awaddr_incr = self.wdata_width // 8
      self.min_araddr_incr = self.rdata_width // 8

      # Min column field increment for xDATA-aligned accesses = num DQ-widths in an xDATA word (since column is "DQ-width-addressable")
      #self.min_col_incr = wdata_width // dq_width
      self.min_col_incr = int(hydra_params[f'DRIVER_{self.driver_index}_MEM_AXI4_DATA_DQ_RATIO']['value'])

      # AxSIZE encodes the transfer size, i.e. num valid bits in xDATA.
      # The max transfer size uses all bits in xDATA.
      self.max_awsize = self.clog2(self.min_awaddr_incr)
      self.max_arsize = self.clog2(self.min_araddr_incr)

      # AxQOS is 4-bits wide and AxLEN is 8-bits.
      #NOTE: FP EMIF/HBM uses 2-bit AxQOS and 7-bit AxLEN within the atoms.
      self.max_qos = 2**2 - 1
      self.max_len = 2**7 - 1

      ########################################################################
      # How is the EMIF target channel configured
      # (the EMIF that is connected to this Hydra driver)
      ########################################################################

      emif_config = None
      emif_type = None
      default_mem_technology = None
      emif_ph2_ips = ["emif_ph2"]
      tulip_emif_ips = ["emif_io96b_ddr4comp", "emif_io96b_ddr4dimm", "emif_io96b_ddr5comp", "emif_io96b_ddr5dimm", "emif_io96b_lpddr5", "emif_io96b_lpddr4"]
      combined_emif_ips = emif_ph2_ips + tulip_emif_ips

      for ip_name in config['system']['ips']:
         if config['system']['ips'][ip_name]['type'] in combined_emif_ips:
            emif_config = config['system']['ips'][ip_name]
            emif_type = emif_config['type']

      if emif_config is not None:
         pattern = re.compile(".*axi4.*")
         mem_capacity_gbits_list = []
         for interface in emif_config['interfaces']:
            if pattern.search(interface): 
               value_dict = emif_config['interfaces'][interface]['assignments']
               if 'mem_capacity_gbits' in value_dict.keys():
                  mem_capacity_gbits_list.append(float(value_dict['mem_capacity_gbits']['value']))
               if emif_type in emif_ph2_ips and "default_mem_technology" in value_dict.keys():
                  default_mem_technology = emif_config['interfaces'][interface]['assignments']['default_mem_technology']['value']

         mem_capacity_gbits = min(mem_capacity_gbits_list)
         mem_capacity_bytes = int((mem_capacity_gbits / 8) * (2**30))
         max_addr = mem_capacity_bytes - 1
         min_addr = 0x0
         self.emif_addr_range = (min_addr, max_addr)

         protocol = None
         if emif_type in emif_ph2_ips:
            if emif_config['parameters']['MEM_TECHNOLOGY_AUTO_BOOL']['value'] == "false":
               protocol = emif_config['parameters']['MEM_TECHNOLOGY']['value']
            elif emif_config['parameters']['MEM_TECHNOLOGY_AUTO_BOOL']['value'] == "true":
               protocol = default_mem_technology
         elif emif_type in tulip_emif_ips:
            protocol = emif_type

         if protocol in ["MEM_TECHNOLOGY_DDR4", "emif_io96b_ddr4comp", "emif_io96b_ddr4dimm"]:
            self.emif_bl = 1
            self.emif_bl_wrp = 1
         elif protocol in ["MEM_TECHNOLOGY_DDR5", "emif_io96b_ddr5comp", "emif_io96b_ddr5dimm"]:
            self.emif_bl = 2        
            self.emif_bl_wrp = 1    
         elif protocol in ["MEM_TECHNOLOGY_LPDDR5", "emif_io96b_lpddr5"]:
            self.emif_bl = 2
            self.emif_bl_wrp = 2    
         elif protocol in ["MEM_TECHNOLOGY_LPDDR4", "emif_io96b_lpddr4"]:
            self.emif_bl = 2
            self.emif_bl_wrp = 2

         self.emif_size_wrp = 0.25
         self.emif_bl_wrp = 4
         self.emif_addr_wrp = "seq_stride1_echo1"
         self.emif_strb_wrp = "byteen_test"

         dq_width = int(emif_config['parameters']['MEM_CHANNEL_DATA_DQ_WIDTH']['value'])
         is_emif_lockstep = (protocol in ["MEM_TECHNOLOGY_DDR4", "emif_io96b_ddr4comp", "emif_io96b_ddr4dimm", "MEM_TECHNOLOGY_DDR5", "emif_io96b_ddr5comp", "emif_io96b_ddr5dimm"]) and (dq_width in [40, 64, 72])
         is_io96b_reva = (emif_config['parameters']['SYSINFO_DEVICE_IOBANK_REVISION']['value'] == "IO96B")
         self.emif_axi_narr_support = not(is_emif_lockstep or is_io96b_reva)

      ########################################################################
      # How is the HBM target channel configured
      # (the HBM that is connected to this Hydra driver)
      ########################################################################

      hbm_config = None
      for ip_name in config['system']['ips']:
          if config['system']['ips'][ip_name]['type'] == "hbm_fp":
              hbm_config = config['system']['ips'][ip_name]

      if hbm_config is not None:
         hbm_params = hbm_config['parameters']
         HBM_CH_ID  = 0
         enabled_ch = 0
         for i in range(8):
            if hbm_params[f'CTRL_CH{i}_EN']['value']=="true":
               if enabled_ch == self.driver_index:
                  is_clone  = hbm_params[f'CTRL_CH{i}_CLONE_OF_ID']['value']
                  HBM_CH_ID = i if is_clone=="None" else int(is_clone)
                  break
               enabled_ch += 1

         # burst length should be at least 2 (64B) if pseudo-BL8 mode is enabled OR if fabric NoC is enabled
         fabric_NoC_enabled = hbm_params[f'EX_DESIGN_FABRIC_NOC_MODE']['value'] != "FABRIC_NOC_MODE_NONE"
         is_pBL8            = hbm_params[f'CTRL_CH{HBM_CH_ID}_PSEUDO_BL8_EN']['value'].lower() == "true"
         max_size           = min(self.max_arsize, self.max_awsize)
         self.hbm_i_BL      = 4 if not (max_size >= 6) else 2
         NUM_Tra            = hbm_params[f'EX_DESIGN_DEFAULT_TRAFFIC_PATTERN']['value']

         self.hbm_ADDR_INDEX1 = 0x00000000
         self.hbm_ADDR_INDEX2 = 0x3fffffff
         if hbm_params['SYS_INFO_DEVICE']['value'][3] == 'G' or hbm_params['SYS_INFO_DEVICE']['value'][3] == 'E':
            self.hbm_ADDR_INDEX2 = 0x1fffffff

         # define test duration based on EX_DESIGN_DEFAULT_TRAFFIC_PATTERN parameter
         if re.match("Sequential_Short", NUM_Tra):
            self.hbm_ITERS = 128   
         elif re.match("Sequential_Long", NUM_Tra):
            self.hbm_ITERS = 16000 
         else:
            self.hbm_ITERS = 4000  



   def tut1_block_rw(self):
      return [
         # Write to a specific address with specific data
         *self.gencmd("wr", addr=0x1000, data=0x0123456789ABCDEF),
         # Wait for all write responses to return
         wait_writes(),
         # Read from the same address and check if we get back the same data
         *self.gencmd("rd", addr=0x1000, data=0x0123456789ABCDEF),
         # Wait for all read responses to return
         wait_reads(),

         # Idle for 100 cycles
         sleep(100),

         # Similar to above, but write and read to 10 different (sequential) addresses
         *self.gencmd("wr", iters=10),
         wait_writes(),
         *self.gencmd("rd", iters=10),
         wait_reads(),

         # Idle for 100 cycles
         sleep(100),

         # Similar to above, but write and read to 10 addresses at random using
         # burst access and random data
         *self.gencmd("wr", iters=10, addr="rand", bl=2, data="prbs7"),
         wait_writes(),
         *self.gencmd("rd", iters=10, addr="rand", bl=2, data="prbs7"),
         wait_reads()
      ]

   def tut2_byteen_test(self):
      return [
         # Write twice to every address, and access sequential addresses.
         # Generate a random strobe followed by its inverse.
         # Randomize the data on every write.
         # This setup works with any burst-length and any number of iterations.
         *self.gencmd("wr", iters=10, addr="seq_echo1", data="prbs31", strb="byteen_test", bl=2),
         wait_writes(),
         *self.gencmd("rd", iters=10, addr="seq_echo1", data="prbs31", strb="byteen_test", bl=2),
         wait_reads()
      ]

   def tut3_instr_resume(self):
      return [
         # An instruction can resume the addr/data/strb pattern from where the
         # previous instruction ended (rather than restarting the pattern). This
         # requires the following values to be identical between the instructions
         # that are chained together: addr, data, strb, bl, size
         *self.gencmd("wr", iters=4, addr="rand", bl=2, data="prbs7"),
         *self.gencmd("wr", iters=4, addr="rand", bl=2, data="prbs7", resume=True),
         wait_writes(),
         # This single read command will output the same access pattern as the two
         # write commands that were chained together using instruction-resume
         *self.gencmd("rd", iters=8, addr="rand", bl=2, data="prbs7"),
         wait_reads(),

         # Idle for 100 cycles
         sleep(100),

         # Some example use-cases of using instruction resume:

         # Example 1:
         # You can "randomize/toggle" AXI port values while maintaining an uninterupped
         # pattern on addr/data/strb. Here, we are toggling AxPROT.
         *self.gencmd("wr", addr="rand", prot=0),
         loop(3, [
            *self.gencmd("wr", addr="rand", prot=1, resume=True),
            *self.gencmd("wr", addr="rand", prot=0, resume=True),
         ]),
         wait_writes(),
         *self.gencmd("rd", iters=7, addr="rand"),
         wait_reads(),

         # Idle for 100 cycles
         sleep(100),

         # Example 2:
         # You can decompose a long train of writes and reads into smaller chunks.
         # Here, instead of doing:
         # 8 writes, 8 reads
         # we do:
         # 2 writes, 2 reads, 2 writes, 2 reads, 2 writes, 2 reads, 2 writes, 2 reads
         *self.gencmd("wr", iters=2),
         wait_writes(),
         *self.gencmd("rd", iters=2),
         wait_reads(),
         loop(3, [
            *self.gencmd("wr", iters=2, resume=True),
            wait_writes(),
            *self.gencmd("rd", iters=2, resume=True),
            wait_reads()
         ])
      ]

   def tut4_parallel_rw(self):
      return [
         # Write to an initial address space
         *self.gencmd("wr", iters=10),
         wait_writes(),

         # All instructions within parallel() will execute simultaneously
         parallel([
            # Read from previous address space ...
            *self.gencmd("rd", iters=10),
            # ... and in parallel write to the next address space
            *self.gencmd("wr", iters=10, resume=True)
         ]),
         # Wait for all write responses to return since the next
         # batch of reads will access this same address space.
         # No need to wait for read responses since the next
         # batch of writes will access a different address space.
         wait_writes(),

         # Repeat the above in a loop
         loop(3, [
            parallel([
               *self.gencmd("rd", iters=10, resume=True),
               *self.gencmd("wr", iters=10, resume=True)
            ]),
            wait_writes()
         ]),

         # Read from the final address space
         *self.gencmd("rd", iters=10, resume=True),
         # Wait for all read responses to return
         wait_reads()
      ]

   def tut5_multi_id(self):
      return [
         # AxIDs 0, 1, and 2 are used. Since iters=8, the AxID port wil output 0, 1, 2, 0, 1, 2, 0, 1
         *self.gencmd("wr", iters=8, id=[0, 1, 2]),
         wait_writes(),
         *self.gencmd("rd", iters=8, id=[0, 1, 2]),
         wait_reads(),

         # The ID sequence can be customized, and the traffic pattern for each ID can be uniquely customized (or not).
         # Here, AWIDs 3 and 4 are used, and since iters=8 the AWID port will output 4, 3, 3, 4, 4, 3, 3, 4
         # AWID=3 uses addr="seq" and bl=2
         # AWID=4 uses addr="rand" and bl=2
         *self.gencmd("wr", iters=8, id=[4, 3, 3, 4], addr=["seq", "rand"], bl=2),
         wait_writes(),
         # To read out the previously written data, we can use different IDs.
         # Here, ARIDs 5 and 6 are used, and since iters=8 the ARID port will output 5, 6, 5, 6, 5, 6, 5, 6
         # AWID=5 uses addr="seq" and bl=2
         # AWID=6 uses addr="rand" and bl=2
         # Note that although the ARIDs differ from the AWIDs in terms of their values and sequence, they
         # represent the same traffic pattern. ARID=5 outputs the same traffic pattern as AWID=3, and ARID=6
         # imitates AWID=4.
         *self.gencmd("rd", iters=8, id=[5, 6],       addr=["seq", "rand"], bl=2),
         wait_reads(),

         # Instruction resume can also be used with multiple AxIDs
         *self.gencmd("wr", iters=4, id=[0, 1], bl=[2, 4]),
         *self.gencmd("wr", iters=4, id=[0, 1], bl=[2, 4], resume=True),
         wait_writes(),
         *self.gencmd("rd", iters=8, id=[0, 1], bl=[2, 4]),
         wait_reads()
      ]

   def tut6_custom_bw(self):
      return [
         # 25% bandwidth on AW channel, 50% bandwidth on W channel, 75% bandwidth (backpressure) on B channel
         *self.gencmd("wr", iters=10, addr_bw=0.25, data_bw=0.50, resp_bw=0.75),
         wait_writes(),
         # 25% bandwidth on AR channel, 50% bandwidth (backpressure) on R channel
         *self.gencmd("rd", iters=10, addr_bw=0.25, resp_bw=0.50),
         wait_reads(),

         # NOTE: On the response channels, the custom bandwidth kicks in after a
         # certain delay from when the first response is received. If this delay
         # is undesirable, you can prelude with a dummy read/write command to
         # configure the backpressure as shown below.

         # Dummy read/write commands with a single iteration and error checking
         # disabled to configure backpressure. Inject some delay after receving
         # the responses to ensure that backpressure is active.
         *self.gencmd("wr", resp_bw=0.50, resp=None),
         *self.gencmd("rd", resp_bw=0.75, resp=None, data=None),
         wait_writes(),
         wait_reads(),
         sleep(200),

         # Longer traffic, using the same backpressure that was configured in
         # the previous dummy commands
         *self.gencmd("wr", iters=10, addr_bw=0.75, data_bw=0.50, resp_bw=0.50),
         wait_writes(),
         *self.gencmd("rd", iters=10, addr_bw=0.50, resp_bw=0.75),
         wait_reads()
      ]

   def tut7_driver_sync(self):
      all_drivers = [i for i in range(self.num_drivers) if i != self.driver_index]
      if self.driver_index & 1 == 0 and self.num_drivers > self.driver_index + 1:
         odd_driver = self.driver_index + 1

         # Even driver
         prog = [
            # Write 1s
            *self.gencmd("wr", addr=0x1000, data=0x1111111111111111),

            # The post() command accepts a list of driver objects or driver indices, to which a 'post' will be issued.
            # The other drivers consume the 'post' using a wait() command.
            # post() is a non-blocking command. However if any of the destination drivers' backlog of posts is saturated
            # then this post() command will block until the clogged driver consumes a previous post.
            #
            # In this demo, issue a 'post' to the odd_driver.
            post(odd_driver),

            # Write 2s
            *self.gencmd("wr", addr=0x2000, data=0x2222222222222222),

            # The wait() command accepts a list of driver objects or driver indices, from which a 'post' will be consumed.
            # wait() is a blocking command which waits until at least one 'post' is received from each of the destination
            # drivers.
            #
            # In this demo, wait for a 'post' from the odd_driver.
            wait(odd_driver),

            # Write 4s
            *self.gencmd("wr", addr=0x4000, data=0x4444444444444444),

            # Sync up with all drivers
            parallel([
               post(all_drivers),
               wait(all_drivers)
            ]),

            # Write 5s
            *self.gencmd("wr", addr=0x5000, data=0x5555555555555555),

            wait_writes()
         ]

      elif self.driver_index & 1 == 1 and self.num_drivers > self.driver_index - 1:
         even_driver = self.driver_index - 1

         # Odd driver
         prog = [
            # Wait for a 'post' from the even_driver.
            wait(even_driver),

            # Write 2s
            *self.gencmd("wr", addr=0x2000, data=0x2222222222222222),

            # Write 3s
            *self.gencmd("wr", addr=0x3000, data=0x3333333333333333),

            # Issue a 'post' to the even_driver.
            post(even_driver),

            # Sync up with all drivers
            parallel([
               post(all_drivers),
               wait(all_drivers)
            ]),

            # Write 5s
            *self.gencmd("wr", addr=0x5000, data=0x5555555555555555),

            wait_writes()
         ]

      else:
         # This driver doesn't have an odd/even pair to synchronize with
         prog = [
            # Sync up with all drivers
            parallel([
               post(all_drivers),
               wait(all_drivers)
            ]),

            # Write 5s
            *self.gencmd("wr", addr=0x5000, data=0x5555555555555555),

            wait_writes()
         ]

      return prog


   def adv1_basic_rw(self):
      return [
         # Write command:
         # 'iters' is number of write commands to issue.
         # READY/VALID signals are specified as (X,Y) which indicates duty-cycle, i.e. X cycles high out of Y total cycles.
         # AWID is specified as a list of values that will show up on the AWID port as is.
         # 'Workers' provide unique traffic streams for each AWID.
         write(iters=20, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[0, 1, 2, 3, 4], workers=[
            # Worker for AWID=0
            wr_worker(
               # Specify values for every signal on the AW, W command channels.
               awid=0, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=0x0000,
               wdata=0xFEEDBAADCAFEF00D, wstrb=0xFFFFFFFF,
               # Specify expected values for every signal on the B response channel.
               # If the incoming response doesn't match the expected response the error will be logged and flagged.
               bresp=xresp_okay
            ),

            # AxADDR, xDATA, xSTRB have on-chip pattern generators that produce complex patterns.
            # The following workers demonstrate their usage.

            wr_worker(
               # AxADDR = Address ALU generator:
               # 'start' is the start value, 'lo'/'hi' are the lower/upper bounds, 'alu' is a list of ALU ops to derive
               # subsequent addresses, 'align' byte-aligns the address and has identical encoding to AxSIZE. Ex: align=0
               # is 1-byte aligned, align=3 is 8-byte aligned. Hence 'align' also equals num LSBs (of AxADDR) that are zeroed.
               awid=1, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=0x1000, lo=0x1000, hi=0x1FFF, align=0, alu=[incr(self.min_awaddr_incr)]),
               # xDATA = DQ ALU generator:
               # Allows specifying a pattern per DQ pin. If insufficient DQ patterns are provided the compiler
               # replicates the pattern, i.e. if only dq0 and dq1 patterns are provided, the compiler sets
               # dq2=dq0, dq3=dq1, dq4=dq0, dq5=dq1, ... If more DQ patterns than pins are provided the
               # excess is discarded.
               wdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(7)],
                  dq1_start =0xA5A5A5A5, dq1_alu =[dq_prbs(7)],
                  dq2_start =0x5A5A5A5A, dq2_alu =[dq_prbs(7)],
                  dq3_start =0xA5A5A5A5, dq3_alu =[dq_prbs(7)],
                  dq4_start =0x5A5A5A5A, dq4_alu =[dq_prbs(7)],
                  dq5_start =0xA5A5A5A5, dq5_alu =[dq_prbs(7)],
                  dq6_start =0x5A5A5A5A, dq6_alu =[dq_prbs(7)],
                  dq7_start =0xA5A5A5A5, dq7_alu =[dq_prbs(7)],
                  dq8_start =0x5A5A5A5A, dq8_alu =[dq_prbs(7)],
                  dq9_start =0xA5A5A5A5, dq9_alu =[dq_prbs(7)],
                  dq10_start=0x5A5A5A5A, dq10_alu=[dq_prbs(7)],
                  dq11_start=0xA5A5A5A5, dq11_alu=[dq_prbs(7)],
                  dq12_start=0x5A5A5A5A, dq12_alu=[dq_prbs(7)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(7)],
                  dq14_start=0x5A5A5A5A, dq14_alu=[dq_prbs(7)],
                  dq15_start=0xA5A5A5A5, dq15_alu=[dq_prbs(7)]
               ),
               # xSTRB = DM ALU generator:
               # Similar to DQ generator, here you can specify patterns for DM pins.
               wstrb=strb_eq_dm(
                  dm0_start =0x0000FFFF, dm0_alu =[dm_rotate()],
                  dm1_start =0xFFFF0000, dm1_alu =[dm_rotate()],
                  dm2_start =0x55555555, dm2_alu =[dm_rotate()],
                  dm3_start =0xAAAAAAAA, dm3_alu =[dm_rotate()],
                  dm4_start =0x0000FFFF, dm4_alu =[dm_rotate()],
                  dm5_start =0xFFFF0000, dm5_alu =[dm_rotate()],
                  dm6_start =0x55555555, dm6_alu =[dm_rotate()],
                  dm7_start =0xAAAAAAAA, dm7_alu =[dm_rotate()]
               ),
               bresp=xresp_okay
            ),

            wr_worker(
               awid=2, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=0x2000, lo=0x2000, hi=0x2FFF, align=0, alu=[incr(self.min_awaddr_incr)]),
               # xDATA = AxADDR:
               # Data contains address which is replicated and nibble-aligned.
               # Ex: if   AxADDR[5:0] = 6'h2C
               #     then xDATA[15:0] = {padding, AxADDR, padding, AxADDR} = {2'h0, 6'h2C, 2'h0, 6'h2C} = 16'h2C_2C
               wdata=data_eq_addr(),
               wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            ),

            wr_worker(
               awid=3, awlen=3, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=0x3000,
               # xDATA = AxID:
               # Data contains ID which is replicated and nibble-aligned.
               # Ex: if     AxID[2:0] = 3'h7
               #     then xDATA[15:0] = {padding, AxID, padding, AxID, padding, AxID, padding, AxID} = {1'h0, 3'h7, 1'h0, 3'h7, 1'h0, 3'h7, 1'h0, 3'h7} = 16'h77_77
               wdata=data_eq_id(),
               wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            ),

            # Expected response can be a "don't-care", which effectively disables error checking for that signal.
            # The following worker demonstrates its usage.

            wr_worker(
               awid=4, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=0x4000,
               wdata=0xC0010FF1CED0000D, wstrb=0xFFFFFFFF,
               # BRESP is a "don't-care"
               bresp=None
            )
         ]),

         # Wait for *all* outstanding write responses
         wait_writes(),

         # Read command:
         # Similar API as write command.
         # In this example, reads are configured to be identical to writes.
         # While the worker IDs and issue order are different here, each worker reads the locations that were previously written to in the same order.
         read(iters=20, arvalid=(7,8), rready=(4,5), arid=[0x21, 0x55, 3, 3, 0x7D, 0x7D, 0x21, 0x55, 0x38, 0x38], workers=[
            rd_worker(
               # Specify values for every signal on the AR command channel.
               arid=0x21, arlen=0, arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0, araddr=0x0000,
               # Specify expected values for every signal on the R response channel.
               rdata=0xFEEDBAADCAFEF00D, rstrb=0xFFFFFFFF, rresp=xresp_okay
            ),
            rd_worker(
               arid=0x55, arlen=0, arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0, araddr=addr_gen(start=0x1000, lo=0x1000, hi=0x1FFF, align=0, alu=[incr(self.min_araddr_incr)]),
               rdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(7)],
                  dq1_start =0xA5A5A5A5, dq1_alu =[dq_prbs(7)],
                  dq2_start =0x5A5A5A5A, dq2_alu =[dq_prbs(7)],
                  dq3_start =0xA5A5A5A5, dq3_alu =[dq_prbs(7)],
                  dq4_start =0x5A5A5A5A, dq4_alu =[dq_prbs(7)],
                  dq5_start =0xA5A5A5A5, dq5_alu =[dq_prbs(7)],
                  dq6_start =0x5A5A5A5A, dq6_alu =[dq_prbs(7)],
                  dq7_start =0xA5A5A5A5, dq7_alu =[dq_prbs(7)],
                  dq8_start =0x5A5A5A5A, dq8_alu =[dq_prbs(7)],
                  dq9_start =0xA5A5A5A5, dq9_alu =[dq_prbs(7)],
                  dq10_start=0x5A5A5A5A, dq10_alu=[dq_prbs(7)],
                  dq11_start=0xA5A5A5A5, dq11_alu=[dq_prbs(7)],
                  dq12_start=0x5A5A5A5A, dq12_alu=[dq_prbs(7)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(7)],
                  dq14_start=0x5A5A5A5A, dq14_alu=[dq_prbs(7)],
                  dq15_start=0xA5A5A5A5, dq15_alu=[dq_prbs(7)]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0x0000FFFF, dm0_alu =[dm_rotate()],
                  dm1_start =0xFFFF0000, dm1_alu =[dm_rotate()],
                  dm2_start =0x55555555, dm2_alu =[dm_rotate()],
                  dm3_start =0xAAAAAAAA, dm3_alu =[dm_rotate()],
                  dm4_start =0x0000FFFF, dm4_alu =[dm_rotate()],
                  dm5_start =0xFFFF0000, dm5_alu =[dm_rotate()],
                  dm6_start =0x55555555, dm6_alu =[dm_rotate()],
                  dm7_start =0xAAAAAAAA, dm7_alu =[dm_rotate()]
               ),
               rresp=xresp_okay
            ),
            rd_worker(
               arid=0x7D, arlen=0, arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0, araddr=addr_gen(start=0x2000, lo=0x2000, hi=0x2FFF, align=0, alu=[incr(self.min_araddr_incr)]),
               rdata=data_eq_addr(),
               rstrb=0xFFFFFFFF,
               rresp=xresp_okay
            ),
            rd_worker(
               arid=3, arlen=3, arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0, araddr=0x3000,
               rdata=data_eq_id(),
               rstrb=0xFFFFFFFF,
               rresp=xresp_okay
            ),
            rd_worker(
               arid=0x38, arlen=0, arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0, araddr=0x5000,
               # RDATA and RRESP are "don't-cares". RSTRB cannot be a "don't-care".
               rdata=None, rstrb=0xFFFFFFFF, rresp=None
            )
         ]),

         # Wait for *all* outstanding read responses
         wait_reads(),

         # Sleep for 256 clock cycles
         sleep(256)
      ]

   def adv2_addr_fields(self):
      return [
         # Increment the entire address.
         write(iters=8, awvalid=(1,1), wvalid=(1,1), bready=(1,1), awid=[0], workers=[
            wr_worker(
               awid=0, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=0, lo=0, hi=self.max_awaddr, align=0, alu=[incr(self.min_awaddr_incr)]),
               wdata=0xFEEDBAADCAFEF00D, wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            )
         ]),

         # Increment the bank address.
         write(iters=8, awvalid=(1,1), wvalid=(1,1), bready=(1,1), awid=[0], workers=[
            wr_worker(
               awid=0, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=0, lo=0, hi=self.max_awaddr, align=0, alu=[incr(ba, 1)]),
               wdata=0xFEEDBAADCAFEF00D, wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            )
         ]),

         # Increment the row.
         write(iters=8, awvalid=(1,1), wvalid=(1,1), bready=(1,1), awid=[0], workers=[
            wr_worker(
               awid=0, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=0, lo=0, hi=self.max_awaddr, align=0, alu=[incr(row, 1)]),
               wdata=0xFEEDBAADCAFEF00D, wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            )
         ]),

         # Increment the column.
         # Column likely needs to be word-aligned to generate a word-aligned AXI address (example: this is the case for EMIF in IO96A architectures).
         write(iters=8, awvalid=(1,1), wvalid=(1,1), bready=(1,1), awid=[0], workers=[
            wr_worker(
               awid=0, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=0, lo=0, hi=self.max_awaddr, align=0, alu=[incr(col, self.min_col_incr)]),
               wdata=0xFEEDBAADCAFEF00D, wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            )
         ]),

         wait_writes()
      ]

   def adv3_instr_resume(self):
      return [
         # The first write command.
         write(iters=7, awvalid=(1,1), wvalid=(1,1), bready=(1,1), awid=[0, 1], workers=[
            # Worker for AWID=0
            wr_worker(
               awid=0, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=0x0000,
               wdata=0xFEEDBAADCAFEF00D, wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            ),
            # Worker for AWID=1
            # This worker will use the on-chip generators.
            # In the subsequent write command we'll instruct the on-chip generators for this worker to resume.
            wr_worker(
               awid=1, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=0x1000, lo=0x1000, hi=0x1FFF, align=self.max_awsize, alu=[rand(8), incr(self.min_awaddr_incr)]),
               wdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(7), dq_invert()],
                  dq1_start =0xA5A5A5A5, dq1_alu =[dq_prbs(7), dq_invert()],
                  dq2_start =0x5A5A5A5A, dq2_alu =[dq_prbs(7), dq_invert()],
                  dq3_start =0xA5A5A5A5, dq3_alu =[dq_prbs(7), dq_invert()],
                  dq4_start =0x5A5A5A5A, dq4_alu =[dq_prbs(7), dq_invert()],
                  dq5_start =0xA5A5A5A5, dq5_alu =[dq_prbs(7), dq_invert()],
                  dq6_start =0x5A5A5A5A, dq6_alu =[dq_prbs(7), dq_invert()],
                  dq7_start =0xA5A5A5A5, dq7_alu =[dq_prbs(7), dq_invert()],
                  dq8_start =0x5A5A5A5A, dq8_alu =[dq_prbs(7), dq_invert()],
                  dq9_start =0xA5A5A5A5, dq9_alu =[dq_prbs(7), dq_invert()],
                  dq10_start=0x5A5A5A5A, dq10_alu=[dq_prbs(7), dq_invert()],
                  dq11_start=0xA5A5A5A5, dq11_alu=[dq_prbs(7), dq_invert()],
                  dq12_start=0x5A5A5A5A, dq12_alu=[dq_prbs(7), dq_invert()],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(7), dq_invert()],
                  dq14_start=0x5A5A5A5A, dq14_alu=[dq_prbs(7), dq_invert()],
                  dq15_start=0xA5A5A5A5, dq15_alu=[dq_prbs(7), dq_invert()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0x0000FFFF, dm0_alu =[dm_invert(), dm_rotate()],
                  dm1_start =0xFFFF0000, dm1_alu =[dm_invert(), dm_rotate()],
                  dm2_start =0x55555555, dm2_alu =[dm_invert(), dm_rotate()],
                  dm3_start =0xAAAAAAAA, dm3_alu =[dm_invert(), dm_rotate()],
                  dm4_start =0x0000FFFF, dm4_alu =[dm_invert(), dm_rotate()],
                  dm5_start =0xFFFF0000, dm5_alu =[dm_invert(), dm_rotate()],
                  dm6_start =0x55555555, dm6_alu =[dm_invert(), dm_rotate()],
                  dm7_start =0xAAAAAAAA, dm7_alu =[dm_invert(), dm_rotate()]
               ),
               bresp=xresp_okay
            )
         ]),

         # The second write command.
         # Here we'll use 'instruction resume' to continue from where the previous command ended.
         write(iters=5, awvalid=(1,1), wvalid=(1,1), bready=(1,1), awid=[1], workers=[
            # We'll instruct worker for AWID=1 to resume from the previous write command.
            # This is indicated by setting certain values to None, as shown below.
            wr_worker(
               # Here both AxADDR and the ALU ops resume from the previous write command for this worker.
               # Ex: if worker for AWID=1 in the previous write command ended at AWADDR=0x1200 and the last ALU op was: alu=[incr(1), incr(2), incr(3), incr(4)]
               #                                                                                                                      ^^^
               #     then the first output from this instruction will be: AWADDR = 0x1200 * [incr(1), incr(2), incr(3), incr(4)] = 0x1200 + 3 = 0x1203
               #                                                                                               ^^^
               awid=1, awlen=0, awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0, awaddr=addr_gen(start=None, lo=0x1000, hi=0x1FFF, align=self.max_awsize, alu=None),
               # Here both dq_start and dq_alu resume from the previous write command for this worker.
               # If instruction resume is used with DQ generators, all DQ generators must resume.
               wdata=data_eq_dq(
                  dq0_start =None, dq0_alu =None,
                  dq1_start =None, dq1_alu =None,
                  dq2_start =None, dq2_alu =None,
                  dq3_start =None, dq3_alu =None,
                  dq4_start =None, dq4_alu =None,
                  dq5_start =None, dq5_alu =None,
                  dq6_start =None, dq6_alu =None,
                  dq7_start =None, dq7_alu =None,
                  dq8_start =None, dq8_alu =None,
                  dq9_start =None, dq9_alu =None,
                  dq10_start=None, dq10_alu=None,
                  dq11_start=None, dq11_alu=None,
                  dq12_start=None, dq12_alu=None,
                  dq13_start=None, dq13_alu=None,
                  dq14_start=None, dq14_alu=None,
                  dq15_start=None, dq15_alu=None
               ),
               # Here both dm_start and dm_alu resume from the previous write command for this worker.
               # If instruction resume is used with DM generators, all DM generators must resume.
               wstrb=strb_eq_dm(
                  dm0_start =None, dm0_alu =None,
                  dm1_start =None, dm1_alu =None,
                  dm2_start =None, dm2_alu =None,
                  dm3_start =None, dm3_alu =None,
                  dm4_start =None, dm4_alu =None,
                  dm5_start =None, dm5_alu =None,
                  dm6_start =None, dm6_alu =None,
                  dm7_start =None, dm7_alu =None
               ),
               bresp=xresp_okay
            )
         ]),

         # Wait for *all* outstanding write responses
         wait_writes(),

         # First let's read what worker AWID=0 wrote.
         read(iters=4, arvalid=(1,1), rready=(1,1), arid=[4], workers=[
            rd_worker(
               arid=4, arlen=0, arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0, araddr=0x0000,
               rdata=0xFEEDBAADCAFEF00D, rstrb=0xFFFFFFFF, rresp=xresp_okay
            )
         ]),

         # Next let's read what worker AWID=1 wrote, except now we'll use a single read command to verify that
         # 'instruction resume' successfully chained the two separate write commands.
         read(iters=8, arvalid=(1,1), rready=(1,1), arid=[4], workers=[
            rd_worker(
               arid=4, arlen=0, arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0, araddr=addr_gen(start=0x1000, lo=0x1000, hi=0x1FFF, align=self.max_arsize, alu=[rand(8), incr(self.min_araddr_incr)]),
               rdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(7), dq_invert()],
                  dq1_start =0xA5A5A5A5, dq1_alu =[dq_prbs(7), dq_invert()],
                  dq2_start =0x5A5A5A5A, dq2_alu =[dq_prbs(7), dq_invert()],
                  dq3_start =0xA5A5A5A5, dq3_alu =[dq_prbs(7), dq_invert()],
                  dq4_start =0x5A5A5A5A, dq4_alu =[dq_prbs(7), dq_invert()],
                  dq5_start =0xA5A5A5A5, dq5_alu =[dq_prbs(7), dq_invert()],
                  dq6_start =0x5A5A5A5A, dq6_alu =[dq_prbs(7), dq_invert()],
                  dq7_start =0xA5A5A5A5, dq7_alu =[dq_prbs(7), dq_invert()],
                  dq8_start =0x5A5A5A5A, dq8_alu =[dq_prbs(7), dq_invert()],
                  dq9_start =0xA5A5A5A5, dq9_alu =[dq_prbs(7), dq_invert()],
                  dq10_start=0x5A5A5A5A, dq10_alu=[dq_prbs(7), dq_invert()],
                  dq11_start=0xA5A5A5A5, dq11_alu=[dq_prbs(7), dq_invert()],
                  dq12_start=0x5A5A5A5A, dq12_alu=[dq_prbs(7), dq_invert()],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(7), dq_invert()],
                  dq14_start=0x5A5A5A5A, dq14_alu=[dq_prbs(7), dq_invert()],
                  dq15_start=0xA5A5A5A5, dq15_alu=[dq_prbs(7), dq_invert()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0x0000FFFF, dm0_alu =[dm_invert(), dm_rotate()],
                  dm1_start =0xFFFF0000, dm1_alu =[dm_invert(), dm_rotate()],
                  dm2_start =0x55555555, dm2_alu =[dm_invert(), dm_rotate()],
                  dm3_start =0xAAAAAAAA, dm3_alu =[dm_invert(), dm_rotate()],
                  dm4_start =0x0000FFFF, dm4_alu =[dm_invert(), dm_rotate()],
                  dm5_start =0xFFFF0000, dm5_alu =[dm_invert(), dm_rotate()],
                  dm6_start =0x55555555, dm6_alu =[dm_invert(), dm_rotate()],
                  dm7_start =0xAAAAAAAA, dm7_alu =[dm_invert(), dm_rotate()]
               ),
               rresp=xresp_okay
            )
         ]),

         # Wait for *all* outstanding read responses
         wait_reads()
      ]


   def emif_tg_emulation(self):
      emif_bl, emif_addr_range, emif_size_wrp, emif_bl_wrp, emif_addr_wrp, emif_strb_wrp, emif_axi_narr_support = self.emif_bl, self.emif_addr_range, self.emif_size_wrp, self.emif_bl_wrp, self.emif_addr_wrp, self.emif_strb_wrp, self.emif_axi_narr_support
      prog = []

      # 1 single full W+R
      seq_full_1 = [
         *self.gencmd(cmd='wr', bl=emif_bl, addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', bl=emif_bl, addr_range=emif_addr_range),
         wait_reads()
      ]
      prog.extend(seq_full_1)

      # 1 single partial W+R
      seq_part_1 = [
         *self.gencmd(cmd='wr', size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_writes(),
         *self.gencmd(cmd='rd', size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_reads()
      ]
      if emif_axi_narr_support:
         prog.extend(seq_part_1)

      # 512 sequential full write/read
      seq_full_512 = [
         *self.gencmd(cmd='wr', iters=512, bl=emif_bl, data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=512, bl=emif_bl, data='prbs7', addr_range=emif_addr_range),
         wait_reads()
      ]
      prog.extend(seq_full_512)

      # 512 sequential partial write/read
      seq_part_512 = [
         *self.gencmd("wr", iters=512, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_writes(),
         *self.gencmd("rd", iters=512, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_reads()
      ]
      if emif_axi_narr_support:
         prog.extend(seq_part_512)

      # 512 random full write/read
      rand_full_512 = [
         *self.gencmd(cmd='wr', iters=512, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=512, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range),
         wait_reads()
      ]
      prog.extend(rand_full_512)
      return prog

   def emif_tg_emulation_lite(self):
      emif_bl, emif_addr_range, emif_size_wrp, emif_bl_wrp, emif_addr_wrp, emif_strb_wrp, emif_axi_narr_support = self.emif_bl, self.emif_addr_range, self.emif_size_wrp, self.emif_bl_wrp, self.emif_addr_wrp, self.emif_strb_wrp, self.emif_axi_narr_support
      prog = []

      # 1 full write/read, looped 3 times
      seq_full_1_x3 = [
         loop(3, [
            *self.gencmd(cmd='wr', bl=emif_bl, addr_range=emif_addr_range),
            wait_writes(),
            *self.gencmd(cmd='rd', bl=emif_bl, addr_range=emif_addr_range),
            wait_reads()
         ])
      ]
      prog.extend(seq_full_1_x3)

      # 1 partial write/read, looped 3 times
      seq_part_1_x3 = [
         loop(3, [
            *self.gencmd(cmd='wr', size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, addr_range=emif_addr_range, strb=emif_strb_wrp),
            wait_writes(),
            *self.gencmd(cmd='rd', size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, addr_range=emif_addr_range, strb=emif_strb_wrp),
            wait_reads()
         ])
      ]
      if emif_axi_narr_support:
         prog.extend(seq_part_1_x3)

      # 16 sequential full write/read, looped 8 times
      seq_full_16_x8 = [
         *self.gencmd(cmd='wr', iters=16, bl=emif_bl, addr='seq', data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=16, bl=emif_bl, addr='seq', data='prbs7', addr_range=emif_addr_range),
         wait_reads(),
         loop(7, [
            *self.gencmd(cmd='wr', iters=16, bl=emif_bl, addr='seq', data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_writes(),
            *self.gencmd(cmd='rd', iters=16, bl=emif_bl, addr='seq', data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_reads()
         ])
      ]
      prog.extend(seq_full_16_x8)

      # 16 sequential partial write/read, looped 8 times
      seq_part_16_x8 = [
         *self.gencmd(cmd='wr', iters=16, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, addr_range=emif_addr_range, data='prbs7', strb=emif_strb_wrp),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=16, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, addr_range=emif_addr_range, data='prbs7', strb=emif_strb_wrp),
         wait_reads(),
         loop(7, [
            *self.gencmd(cmd='wr', iters=16, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, addr_range=emif_addr_range, data='prbs7', strb=emif_strb_wrp, resume=True),
            wait_writes(),
            *self.gencmd(cmd='rd', iters=16, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, addr_range=emif_addr_range, data='prbs7', strb=emif_strb_wrp, resume=True),
            wait_reads()
         ])
      ]
      if emif_axi_narr_support:
         prog.extend(seq_part_16_x8)

      # 16 random full write/read, looped 8 times
      rand_full_16_x8 = [
         *self.gencmd(cmd='wr', iters=16, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=16, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range),
         wait_reads(),
         loop(7, [
            *self.gencmd(cmd='wr', iters=16, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_writes(),
            *self.gencmd(cmd='rd', iters=16, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_reads()
         ])
      ]
      prog.extend(rand_full_16_x8)

      return prog

   def emif_tg_emulation_long(self):
      emif_bl, emif_addr_range, emif_size_wrp, emif_bl_wrp, emif_addr_wrp, emif_strb_wrp, emif_axi_narr_support = self.emif_bl, self.emif_addr_range, self.emif_size_wrp, self.emif_bl_wrp, self.emif_addr_wrp, self.emif_strb_wrp, self.emif_axi_narr_support
      prog = []

      # Start with 1 single full W+R
      seq_full_1 = [
         *self.gencmd(cmd='wr', bl=emif_bl, addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', bl=emif_bl, addr_range=emif_addr_range),
         wait_reads()
      ]
      prog.extend(seq_full_1)

      # 1 single partial W+R
      seq_part_1 = [
         *self.gencmd(cmd='wr', size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_writes(),
         *self.gencmd(cmd='rd', size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_reads()
      ]
      if emif_axi_narr_support:
         prog.extend(seq_part_1)

      # 4096 sequential full write/read
      seq_full_4096 = [
         *self.gencmd(cmd='wr', iters=4096, bl=emif_bl, data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=4096, bl=emif_bl, data='prbs7', addr_range=emif_addr_range),
         wait_reads()
      ]
      prog.extend(seq_full_4096)

      # 4096 sequential partial write/read
      seq_part_4096 = [
         *self.gencmd("wr", iters=4096, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_writes(),
         *self.gencmd("rd", iters=4096, size=emif_size_wrp, bl=emif_bl_wrp, addr=emif_addr_wrp, strb=emif_strb_wrp, addr_range=emif_addr_range, data='prbs7'),
         wait_reads()
      ]
      if emif_axi_narr_support:
         prog.extend(seq_part_4096)

      # 4096 random full write/read
      rand_full_4096 = [
         *self.gencmd(cmd='wr', iters=4096, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=4096, bl=emif_bl, addr='rand', data='prbs7', addr_range=emif_addr_range),
         wait_reads()
      ]
      prog.extend(rand_full_4096)
      
      return prog

   def emif_tg_emulation_inf(self):
      emif_bl, emif_bl_wrp, emif_addr_range, = self.emif_bl, self.emif_bl_wrp, self.emif_addr_range,

      rand_iters_emif_inf = 8 
      size_fraction_emif_inf = 1.0 
      max_axsize_emif_inf = min(self.max_awsize, self.max_arsize)
      axsize_emif_inf = max_axsize_emif_inf + self.clog2(size_fraction_emif_inf)
      seq_iters_emif_inf = int(4096 / (emif_bl * (2**axsize_emif_inf))) 

      return [
         # Initial seq write/read
         *self.gencmd(cmd='wr', iters=seq_iters_emif_inf, bl=emif_bl, addr='seq', id=0x0, data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=seq_iters_emif_inf, bl=emif_bl, addr='seq', id=0x0, data='prbs7', addr_range=emif_addr_range),
         wait_reads(),

         # Initial rand write/read
         *self.gencmd(cmd='wr', iters=rand_iters_emif_inf, bl=emif_bl, addr='rand', id=0x1, data='prbs7', addr_range=emif_addr_range),
         wait_writes(),
         *self.gencmd(cmd='rd', iters=rand_iters_emif_inf, bl=emif_bl, addr='rand', id=0x1, data='prbs7', addr_range=emif_addr_range),
         wait_reads(),

         loop(0, [
            # seq write/read
            *self.gencmd(cmd='wr', iters=seq_iters_emif_inf, bl=emif_bl, addr='seq', id=0x0, data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_writes(),
            *self.gencmd(cmd='rd', iters=seq_iters_emif_inf, bl=emif_bl, addr='seq', id=0x0, data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_reads(),

            # rand write/read
            *self.gencmd(cmd='wr', iters=rand_iters_emif_inf, bl=emif_bl, addr='rand', id=0x1, data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_writes(),
            *self.gencmd(cmd='rd', iters=rand_iters_emif_inf, bl=emif_bl, addr='rand', id=0x1, data='prbs7', addr_range=emif_addr_range, resume=True),
            wait_reads(),
         ])
      ]

   def emif_narrow_transfer(self):
      iters = 32
      size  = 0.25  # fraction of data width to narrow transfer
      num_bytes       = int((2 ** self.max_awsize) * size)
      narrow_strb     = (2 ** num_bytes) - 1
      num_bytes_bl4   = int((2 ** self.max_awsize) * 0.25)
      narrow_strb_bl4 = (2 ** num_bytes_bl4) - 1
      return [
         # Narrow writes + Narrow reads:
         #
         # For every word address, write/read one full data-word using a burst of narrow accesses (ex: burst-length 4
         # with narrow-access of 1/4th of data width). Data pattern is randomized for every beat, i.e. not held constant
         # within a burst.
         #
         # Write and read access patterns are identical.
         #
         # By default, gencmd() increments address by transfer size. So to ensure addresses
         # are aligned to data-width, use strided access such that: bl * size * stride >= 1.0
         #
         # This will fail if AxSIZE is stuck at max size because the bursts will overlap.
         *self.gencmd("wr", iters=iters, size=size, bl=int(1/size), addr="seq_stride1", data="prbs7"),
         wait_writes(),
         *self.gencmd("rd", iters=iters, size=size, bl=int(1/size), addr="seq_stride1", data="prbs7"),
         wait_reads(),
         sleep(128),

         # Narrow writes + Narrow reads, interplay with byte-enable:
         #
         # Narrow transfer setup is same as previous pattern.
         #
         # Byte-enable testing is done by writing twice to every address with different data
         # and a random WSTRB on the first access and inverted WSTRB on the second access.
         *self.gencmd("wr", iters=iters, size=size, bl=int(1/size), addr="seq_stride1_echo1", data="prbs15", strb="byteen_test"),
         wait_writes(),
         *self.gencmd("rd", iters=iters, size=size, bl=int(1/size), addr="seq_stride1_echo1", data="prbs15", strb="byteen_test"),
         wait_reads(),
         sleep(128),

         # Narrow writes + Regular reads:
         #
         # Write pattern is same as previous.
         #
         # Read from the same word address multiple times (ex: 4 times) and cycle the "RSTRB" to imitate narrow access
         # (RSTRB is an internal driver signal used to mask data integrity checking). This approach is necessary because
         # the data was randomized for every narrow-data-lane, so we need Hydra's golden data generator to output the
         # unique data pattern for every narrow-data-lane.
         #
         # NOTE: Burst-length is hardcoded to 4 because generalizing this for any burst-length is syntactically complex :)
         *self.gencmd("wr", iters=iters, size=0.25, bl=4, addr="seq", data="prbs23"),
         wait_writes(),
         # NOTE: we want a sequence of custom strbs, so stitch multiple commands using resume, and repeat using a loop.
         *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (0*num_bytes_bl4), resume=False),
         *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (1*num_bytes_bl4), resume=True),
         *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (2*num_bytes_bl4), resume=True),
         *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (3*num_bytes_bl4), resume=True),
         loop(iters-1, [
            *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (0*num_bytes_bl4), resume=True),
            *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (1*num_bytes_bl4), resume=True),
            *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (2*num_bytes_bl4), resume=True),
            *self.gencmd("rd", iters=1, size=1.00, bl=1, addr="seq_echo3", data="prbs23", strb=narrow_strb_bl4 << (3*num_bytes_bl4), resume=True)
         ]),
         wait_reads(),
         sleep(128),

         # Regular writes + Narrow reads:
         #
         # Write a full data-word using regular access, and read it out using a burst of narrow accesses.
         *self.gencmd("wr", iters=iters, size=1.00, bl=1, addr="seq", data="prbs31"),
         wait_writes(),
         # NOTE: data should be held constant within a burst
         *self.gencmd("rd", iters=iters, size=size, bl=int(1/size), addr="seq", data=f"prbs31_echo{int(1/size)-1}"),
         wait_reads(),
         sleep(128)
      ]

   def pve_vv_prog(self):
      axibl = 8
      return [
         # PRBS 31
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[0], workers=[
            # Worker for AWID=0
            wr_worker(
               awid=0, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x0, lo=0x0, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[0], workers=[
            rd_worker(
               arid=0, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x0, lo=0x0, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),

         wait_reads(),

         # DATA_EQ_ADDR
         write(iters=65536, awvalid=(1,1), wvalid=(1,1), bready=(2,3), awid=[1], workers=[
            # Worker for AWID=1
            wr_worker(
               awid=1, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x1000000, lo=0x1000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_addr(), wstrb=0xFFFFFFFF,
               bresp=xresp_okay
            )
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(1,1), rready=(4,5), arid=[1], workers=[
            rd_worker(
               arid=1, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x1000000, lo=0x1000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_addr(), rstrb=0xFFFFFFFF, rresp=xresp_okay
            )
         ]),
         wait_reads(),

         # CLOCK Pattern
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[2], workers=[
            # Worker for AWID=2
            wr_worker(
               awid=2, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x2000000, lo=0x2000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x55555555, dq0_alu =[dq_echo()],
                  dq1_start =0x55555555, dq1_alu =[dq_echo()],
                  dq2_start =0x55555555, dq2_alu =[dq_echo()],
                  dq3_start =0x55555555, dq3_alu =[dq_echo()],
                  dq4_start =0x55555555, dq4_alu =[dq_echo()],
                  dq5_start =0x55555555, dq5_alu =[dq_echo()],
                  dq6_start =0x55555555, dq6_alu =[dq_echo()],
                  dq7_start =0x55555555, dq7_alu =[dq_echo()],
                  dq8_start =0x55555555, dq8_alu =[dq_echo()],
                  dq9_start =0x55555555, dq9_alu =[dq_echo()],
                  dq10_start=0x55555555, dq10_alu=[dq_echo()],
                  dq11_start=0x55555555, dq11_alu=[dq_echo()],
                  dq12_start=0x55555555, dq12_alu=[dq_echo()],
                  dq13_start=0x55555555, dq13_alu=[dq_echo()],
                  dq14_start=0x55555555, dq14_alu=[dq_echo()],
                  dq15_start=0x55555555, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[2], workers=[
            rd_worker(
               arid=2, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x2000000, lo=0x2000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x55555555, dq0_alu =[dq_echo()],
                  dq1_start =0x55555555, dq1_alu =[dq_echo()],
                  dq2_start =0x55555555, dq2_alu =[dq_echo()],
                  dq3_start =0x55555555, dq3_alu =[dq_echo()],
                  dq4_start =0x55555555, dq4_alu =[dq_echo()],
                  dq5_start =0x55555555, dq5_alu =[dq_echo()],
                  dq6_start =0x55555555, dq6_alu =[dq_echo()],
                  dq7_start =0x55555555, dq7_alu =[dq_echo()],
                  dq8_start =0x55555555, dq8_alu =[dq_echo()],
                  dq9_start =0x55555555, dq9_alu =[dq_echo()],
                  dq10_start=0x55555555, dq10_alu=[dq_echo()],
                  dq11_start=0x55555555, dq11_alu=[dq_echo()],
                  dq12_start=0x55555555, dq12_alu=[dq_echo()],
                  dq13_start=0x55555555, dq13_alu=[dq_echo()],
                  dq14_start=0x55555555, dq14_alu=[dq_echo()],
                  dq15_start=0x55555555, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # Long 1's followed by 0
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[3], workers=[
            # Worker for AWID=3
            wr_worker(
               awid=3, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x3000000, lo=0x3000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0xFEFEFEFE, dq0_alu =[dq_echo()],
                  dq1_start =0xFEFEFEFE, dq1_alu =[dq_echo()],
                  dq2_start =0xFEFEFEFE, dq2_alu =[dq_echo()],
                  dq3_start =0xFEFEFEFE, dq3_alu =[dq_echo()],
                  dq4_start =0xFEFEFEFE, dq4_alu =[dq_echo()],
                  dq5_start =0xFEFEFEFE, dq5_alu =[dq_echo()],
                  dq6_start =0xFEFEFEFE, dq6_alu =[dq_echo()],
                  dq7_start =0xFEFEFEFE, dq7_alu =[dq_echo()],
                  dq8_start =0xFEFEFEFE, dq8_alu =[dq_echo()],
                  dq9_start =0xFEFEFEFE, dq9_alu =[dq_echo()],
                  dq10_start=0xFEFEFEFE, dq10_alu=[dq_echo()],
                  dq11_start=0xFEFEFEFE, dq11_alu=[dq_echo()],
                  dq12_start=0xFEFEFEFE, dq12_alu=[dq_echo()],
                  dq13_start=0xFEFEFEFE, dq13_alu=[dq_echo()],
                  dq14_start=0xFEFEFEFE, dq14_alu=[dq_echo()],
                  dq15_start=0xFEFEFEFE, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[3], workers=[
            rd_worker(
               arid=3, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x3000000, lo=0x3000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0xFEFEFEFE, dq0_alu =[dq_echo()],
                  dq1_start =0xFEFEFEFE, dq1_alu =[dq_echo()],
                  dq2_start =0xFEFEFEFE, dq2_alu =[dq_echo()],
                  dq3_start =0xFEFEFEFE, dq3_alu =[dq_echo()],
                  dq4_start =0xFEFEFEFE, dq4_alu =[dq_echo()],
                  dq5_start =0xFEFEFEFE, dq5_alu =[dq_echo()],
                  dq6_start =0xFEFEFEFE, dq6_alu =[dq_echo()],
                  dq7_start =0xFEFEFEFE, dq7_alu =[dq_echo()],
                  dq8_start =0xFEFEFEFE, dq8_alu =[dq_echo()],
                  dq9_start =0xFEFEFEFE, dq9_alu =[dq_echo()],
                  dq10_start=0xFEFEFEFE, dq10_alu=[dq_echo()],
                  dq11_start=0xFEFEFEFE, dq11_alu=[dq_echo()],
                  dq12_start=0xFEFEFEFE, dq12_alu=[dq_echo()],
                  dq13_start=0xFEFEFEFE, dq13_alu=[dq_echo()],
                  dq14_start=0xFEFEFEFE, dq14_alu=[dq_echo()],
                  dq15_start=0xFEFEFEFE, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # Long 0's followed by 1
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[4], workers=[
            # Worker for AWID=4
            wr_worker(
               awid=4, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x4000000, lo=0x4000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x00000001, dq0_alu =[dq_echo()],
                  dq1_start =0x00000001, dq1_alu =[dq_echo()],
                  dq2_start =0x00000001, dq2_alu =[dq_echo()],
                  dq3_start =0x00000001, dq3_alu =[dq_echo()],
                  dq4_start =0x00000001, dq4_alu =[dq_echo()],
                  dq5_start =0x00000001, dq5_alu =[dq_echo()],
                  dq6_start =0x00000001, dq6_alu =[dq_echo()],
                  dq7_start =0x00000001, dq7_alu =[dq_echo()],
                  dq8_start =0x00000001, dq8_alu =[dq_echo()],
                  dq9_start =0x00000001, dq9_alu =[dq_echo()],
                  dq10_start=0x00000001, dq10_alu=[dq_echo()],
                  dq11_start=0x00000001, dq11_alu=[dq_echo()],
                  dq12_start=0x00000001, dq12_alu=[dq_echo()],
                  dq13_start=0x00000001, dq13_alu=[dq_echo()],
                  dq14_start=0x00000001, dq14_alu=[dq_echo()],
                  dq15_start=0x00000001, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[4], workers=[
            rd_worker(
               arid=4, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x4000000, lo=0x4000000, hi=0xFFFFFFFF, align=0, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x00000001, dq0_alu =[dq_echo()],
                  dq1_start =0x00000001, dq1_alu =[dq_echo()],
                  dq2_start =0x00000001, dq2_alu =[dq_echo()],
                  dq3_start =0x00000001, dq3_alu =[dq_echo()],
                  dq4_start =0x00000001, dq4_alu =[dq_echo()],
                  dq5_start =0x00000001, dq5_alu =[dq_echo()],
                  dq6_start =0x00000001, dq6_alu =[dq_echo()],
                  dq7_start =0x00000001, dq7_alu =[dq_echo()],
                  dq8_start =0x00000001, dq8_alu =[dq_echo()],
                  dq9_start =0x00000001, dq9_alu =[dq_echo()],
                  dq10_start=0x00000001, dq10_alu=[dq_echo()],
                  dq11_start=0x00000001, dq11_alu=[dq_echo()],
                  dq12_start=0x00000001, dq12_alu=[dq_echo()],
                  dq13_start=0x00000001, dq13_alu=[dq_echo()],
                  dq14_start=0x00000001, dq14_alu=[dq_echo()],
                  dq15_start=0x00000001, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads()
      ]

   def pve_vv_v2_prog(self):
      axibl = 8
      Awsize = self.max_awsize
      Arsize = self.max_arsize
      Awaddr_align = Awsize + self.clog2(axibl)
      #print (Awaddr_align)
      Araddr_align = Arsize + self.clog2(axibl)
      #print (Araddr_align)
      return [
         #PRBS 31 with sequential addressing
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[0], workers=[
            # Worker for AWID=0
            wr_worker(
               awid=0, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x0, lo=0x0, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[0], workers=[
            rd_worker(
               arid=0, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x0, lo=0x0, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # DATA_EQ_ADDR
         write(iters=65536, awvalid=(1,1), wvalid=(1,1), bready=(2,3), awid=[1], workers=[
            # Worker for AWID=1
            wr_worker(
               awid=1, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x1000000, lo=0x1000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_addr(), wstrb=0xFFFFFFFF,
               bresp=xresp_okay
             )
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(1,1), rready=(4,5), arid=[1], workers=[
            rd_worker(
               arid=1, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x1000000, lo=0x1000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_addr(), rstrb=0xFFFFFFFF, rresp=xresp_okay
            )
         ]),
         wait_reads(),

         # CLOCK Pattern
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[2], workers=[
            # Worker for AWID=2
            wr_worker(
               awid=2, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x2000000, lo=0x2000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x55555555, dq0_alu =[dq_echo()],
                  dq1_start =0x55555555, dq1_alu =[dq_echo()],
                  dq2_start =0x55555555, dq2_alu =[dq_echo()],
                  dq3_start =0x55555555, dq3_alu =[dq_echo()],
                  dq4_start =0x55555555, dq4_alu =[dq_echo()],
                  dq5_start =0x55555555, dq5_alu =[dq_echo()],
                  dq6_start =0x55555555, dq6_alu =[dq_echo()],
                  dq7_start =0x55555555, dq7_alu =[dq_echo()],
                  dq8_start =0x55555555, dq8_alu =[dq_echo()],
                  dq9_start =0x55555555, dq9_alu =[dq_echo()],
                  dq10_start=0x55555555, dq10_alu=[dq_echo()],
                  dq11_start=0x55555555, dq11_alu=[dq_echo()],
                  dq12_start=0x55555555, dq12_alu=[dq_echo()],
                  dq13_start=0x55555555, dq13_alu=[dq_echo()],
                  dq14_start=0x55555555, dq14_alu=[dq_echo()],
                  dq15_start=0x55555555, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[2], workers=[
            rd_worker(
               arid=2, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x2000000, lo=0x2000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x55555555, dq0_alu =[dq_echo()],
                  dq1_start =0x55555555, dq1_alu =[dq_echo()],
                  dq2_start =0x55555555, dq2_alu =[dq_echo()],
                  dq3_start =0x55555555, dq3_alu =[dq_echo()],
                  dq4_start =0x55555555, dq4_alu =[dq_echo()],
                  dq5_start =0x55555555, dq5_alu =[dq_echo()],
                  dq6_start =0x55555555, dq6_alu =[dq_echo()],
                  dq7_start =0x55555555, dq7_alu =[dq_echo()],
                  dq8_start =0x55555555, dq8_alu =[dq_echo()],
                  dq9_start =0x55555555, dq9_alu =[dq_echo()],
                  dq10_start=0x55555555, dq10_alu=[dq_echo()],
                  dq11_start=0x55555555, dq11_alu=[dq_echo()],
                  dq12_start=0x55555555, dq12_alu=[dq_echo()],
                  dq13_start=0x55555555, dq13_alu=[dq_echo()],
                  dq14_start=0x55555555, dq14_alu=[dq_echo()],
                  dq15_start=0x55555555, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # Long 1's followed by 0
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[3], workers=[
            # Worker for AWID=3
            wr_worker(
               awid=3, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x3000000, lo=0x3000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0xFEFEFEFE, dq0_alu =[dq_echo()],
                  dq1_start =0xFEFEFEFE, dq1_alu =[dq_echo()],
                  dq2_start =0xFEFEFEFE, dq2_alu =[dq_echo()],
                  dq3_start =0xFEFEFEFE, dq3_alu =[dq_echo()],
                  dq4_start =0xFEFEFEFE, dq4_alu =[dq_echo()],
                  dq5_start =0xFEFEFEFE, dq5_alu =[dq_echo()],
                  dq6_start =0xFEFEFEFE, dq6_alu =[dq_echo()],
                  dq7_start =0xFEFEFEFE, dq7_alu =[dq_echo()],
                  dq8_start =0xFEFEFEFE, dq8_alu =[dq_echo()],
                  dq9_start =0xFEFEFEFE, dq9_alu =[dq_echo()],
                  dq10_start=0xFEFEFEFE, dq10_alu=[dq_echo()],
                  dq11_start=0xFEFEFEFE, dq11_alu=[dq_echo()],
                  dq12_start=0xFEFEFEFE, dq12_alu=[dq_echo()],
                  dq13_start=0xFEFEFEFE, dq13_alu=[dq_echo()],
                  dq14_start=0xFEFEFEFE, dq14_alu=[dq_echo()],
                  dq15_start=0xFEFEFEFE, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[3], workers=[
           rd_worker(
               arid=3, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x3000000, lo=0x3000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0xFEFEFEFE, dq0_alu =[dq_echo()],
                  dq1_start =0xFEFEFEFE, dq1_alu =[dq_echo()],
                  dq2_start =0xFEFEFEFE, dq2_alu =[dq_echo()],
                  dq3_start =0xFEFEFEFE, dq3_alu =[dq_echo()],
                  dq4_start =0xFEFEFEFE, dq4_alu =[dq_echo()],
                  dq5_start =0xFEFEFEFE, dq5_alu =[dq_echo()],
                  dq6_start =0xFEFEFEFE, dq6_alu =[dq_echo()],
                  dq7_start =0xFEFEFEFE, dq7_alu =[dq_echo()],
                  dq8_start =0xFEFEFEFE, dq8_alu =[dq_echo()],
                  dq9_start =0xFEFEFEFE, dq9_alu =[dq_echo()],
                  dq10_start=0xFEFEFEFE, dq10_alu=[dq_echo()],
                  dq11_start=0xFEFEFEFE, dq11_alu=[dq_echo()],
                  dq12_start=0xFEFEFEFE, dq12_alu=[dq_echo()],
                  dq13_start=0xFEFEFEFE, dq13_alu=[dq_echo()],
                  dq14_start=0xFEFEFEFE, dq14_alu=[dq_echo()],
                  dq15_start=0xFEFEFEFE, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # Long 0's followed by 1
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[4], workers=[
            # Worker for AWID=4
            wr_worker(
               awid=4, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x4000000, lo=0x4000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x00000001, dq0_alu =[dq_echo()],
                  dq1_start =0x00000001, dq1_alu =[dq_echo()],
                  dq2_start =0x00000001, dq2_alu =[dq_echo()],
                  dq3_start =0x00000001, dq3_alu =[dq_echo()],
                  dq4_start =0x00000001, dq4_alu =[dq_echo()],
                  dq5_start =0x00000001, dq5_alu =[dq_echo()],
                  dq6_start =0x00000001, dq6_alu =[dq_echo()],
                  dq7_start =0x00000001, dq7_alu =[dq_echo()],
                  dq8_start =0x00000001, dq8_alu =[dq_echo()],
                  dq9_start =0x00000001, dq9_alu =[dq_echo()],
                  dq10_start=0x00000001, dq10_alu=[dq_echo()],
                  dq11_start=0x00000001, dq11_alu=[dq_echo()],
                  dq12_start=0x00000001, dq12_alu=[dq_echo()],
                  dq13_start=0x00000001, dq13_alu=[dq_echo()],
                  dq14_start=0x00000001, dq14_alu=[dq_echo()],
                  dq15_start=0x00000001, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[4], workers=[
           rd_worker(
               arid=4, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x4000000, lo=0x4000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x00000001, dq0_alu =[dq_echo()],
                  dq1_start =0x00000001, dq1_alu =[dq_echo()],
                  dq2_start =0x00000001, dq2_alu =[dq_echo()],
                  dq3_start =0x00000001, dq3_alu =[dq_echo()],
                  dq4_start =0x00000001, dq4_alu =[dq_echo()],
                  dq5_start =0x00000001, dq5_alu =[dq_echo()],
                  dq6_start =0x00000001, dq6_alu =[dq_echo()],
                  dq7_start =0x00000001, dq7_alu =[dq_echo()],
                  dq8_start =0x00000001, dq8_alu =[dq_echo()],
                  dq9_start =0x00000001, dq9_alu =[dq_echo()],
                  dq10_start=0x00000001, dq10_alu=[dq_echo()],
                  dq11_start=0x00000001, dq11_alu=[dq_echo()],
                  dq12_start=0x00000001, dq12_alu=[dq_echo()],
                  dq13_start=0x00000001, dq13_alu=[dq_echo()],
                  dq14_start=0x00000001, dq14_alu=[dq_echo()],
                  dq15_start=0x00000001, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         #PRBS 31 with sequential addressing
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[0], workers=[
            # Worker for AWID=0
            wr_worker(
               awid=0, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x6000000, lo=0x6000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[0], workers=[
            rd_worker(
               arid=0, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x6000000, lo=0x6000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # DATA_EQ_ADDR
         write(iters=65536, awvalid=(1,1), wvalid=(1,1), bready=(2,3), awid=[1], workers=[
            # Worker for AWID=1
            wr_worker(
               awid=1, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x7000000, lo=0x7000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_addr(), wstrb=0xFFFFFFFF,
               bresp=xresp_okay
             )
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(1,1), rready=(4,5), arid=[1], workers=[
            rd_worker(
               arid=1, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x7000000, lo=0x7000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_addr(), rstrb=0xFFFFFFFF, rresp=xresp_okay
            )
         ]),
         wait_reads(),

         # CLOCK Pattern
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[2], workers=[
            # Worker for AWID=2
            wr_worker(
               awid=2, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x8000000, lo=0x8000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x55555555, dq0_alu =[dq_echo()],
                  dq1_start =0x55555555, dq1_alu =[dq_echo()],
                  dq2_start =0x55555555, dq2_alu =[dq_echo()],
                  dq3_start =0x55555555, dq3_alu =[dq_echo()],
                  dq4_start =0x55555555, dq4_alu =[dq_echo()],
                  dq5_start =0x55555555, dq5_alu =[dq_echo()],
                  dq6_start =0x55555555, dq6_alu =[dq_echo()],
                  dq7_start =0x55555555, dq7_alu =[dq_echo()],
                  dq8_start =0x55555555, dq8_alu =[dq_echo()],
                  dq9_start =0x55555555, dq9_alu =[dq_echo()],
                  dq10_start=0x55555555, dq10_alu=[dq_echo()],
                  dq11_start=0x55555555, dq11_alu=[dq_echo()],
                  dq12_start=0x55555555, dq12_alu=[dq_echo()],
                  dq13_start=0x55555555, dq13_alu=[dq_echo()],
                  dq14_start=0x55555555, dq14_alu=[dq_echo()],
                  dq15_start=0x55555555, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[2], workers=[
            rd_worker(
               arid=2, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x8000000, lo=0x8000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x55555555, dq0_alu =[dq_echo()],
                  dq1_start =0x55555555, dq1_alu =[dq_echo()],
                  dq2_start =0x55555555, dq2_alu =[dq_echo()],
                  dq3_start =0x55555555, dq3_alu =[dq_echo()],
                  dq4_start =0x55555555, dq4_alu =[dq_echo()],
                  dq5_start =0x55555555, dq5_alu =[dq_echo()],
                  dq6_start =0x55555555, dq6_alu =[dq_echo()],
                  dq7_start =0x55555555, dq7_alu =[dq_echo()],
                  dq8_start =0x55555555, dq8_alu =[dq_echo()],
                  dq9_start =0x55555555, dq9_alu =[dq_echo()],
                  dq10_start=0x55555555, dq10_alu=[dq_echo()],
                  dq11_start=0x55555555, dq11_alu=[dq_echo()],
                  dq12_start=0x55555555, dq12_alu=[dq_echo()],
                  dq13_start=0x55555555, dq13_alu=[dq_echo()],
                  dq14_start=0x55555555, dq14_alu=[dq_echo()],
                  dq15_start=0x55555555, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # Long 1's followed by 0
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[3], workers=[
            # Worker for AWID=3
            wr_worker(
               awid=3, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x9000000, lo=0x9000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0xFEFEFEFE, dq0_alu =[dq_echo()],
                  dq1_start =0xFEFEFEFE, dq1_alu =[dq_echo()],
                  dq2_start =0xFEFEFEFE, dq2_alu =[dq_echo()],
                  dq3_start =0xFEFEFEFE, dq3_alu =[dq_echo()],
                  dq4_start =0xFEFEFEFE, dq4_alu =[dq_echo()],
                  dq5_start =0xFEFEFEFE, dq5_alu =[dq_echo()],
                  dq6_start =0xFEFEFEFE, dq6_alu =[dq_echo()],
                  dq7_start =0xFEFEFEFE, dq7_alu =[dq_echo()],
                  dq8_start =0xFEFEFEFE, dq8_alu =[dq_echo()],
                  dq9_start =0xFEFEFEFE, dq9_alu =[dq_echo()],
                  dq10_start=0xFEFEFEFE, dq10_alu=[dq_echo()],
                  dq11_start=0xFEFEFEFE, dq11_alu=[dq_echo()],
                  dq12_start=0xFEFEFEFE, dq12_alu=[dq_echo()],
                  dq13_start=0xFEFEFEFE, dq13_alu=[dq_echo()],
                  dq14_start=0xFEFEFEFE, dq14_alu=[dq_echo()],
                  dq15_start=0xFEFEFEFE, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[3], workers=[
           rd_worker(
               arid=3, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x9000000, lo=0x9000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0xFEFEFEFE, dq0_alu =[dq_echo()],
                  dq1_start =0xFEFEFEFE, dq1_alu =[dq_echo()],
                  dq2_start =0xFEFEFEFE, dq2_alu =[dq_echo()],
                  dq3_start =0xFEFEFEFE, dq3_alu =[dq_echo()],
                  dq4_start =0xFEFEFEFE, dq4_alu =[dq_echo()],
                  dq5_start =0xFEFEFEFE, dq5_alu =[dq_echo()],
                  dq6_start =0xFEFEFEFE, dq6_alu =[dq_echo()],
                  dq7_start =0xFEFEFEFE, dq7_alu =[dq_echo()],
                  dq8_start =0xFEFEFEFE, dq8_alu =[dq_echo()],
                  dq9_start =0xFEFEFEFE, dq9_alu =[dq_echo()],
                  dq10_start=0xFEFEFEFE, dq10_alu=[dq_echo()],
                  dq11_start=0xFEFEFEFE, dq11_alu=[dq_echo()],
                  dq12_start=0xFEFEFEFE, dq12_alu=[dq_echo()],
                  dq13_start=0xFEFEFEFE, dq13_alu=[dq_echo()],
                  dq14_start=0xFEFEFEFE, dq14_alu=[dq_echo()],
                  dq15_start=0xFEFEFEFE, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         # Long 0's followed by 1
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[4], workers=[
            # Worker for AWID=4
            wr_worker(
               awid=4, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0xA000000, lo=0xA000000, hi=0xFFFFFFFF, align=Awsize, alu=[incr(axibl*(self.min_awaddr_incr))]),
               wdata=data_eq_dq(
                  dq0_start =0x00000001, dq0_alu =[dq_echo()],
                  dq1_start =0x00000001, dq1_alu =[dq_echo()],
                  dq2_start =0x00000001, dq2_alu =[dq_echo()],
                  dq3_start =0x00000001, dq3_alu =[dq_echo()],
                  dq4_start =0x00000001, dq4_alu =[dq_echo()],
                  dq5_start =0x00000001, dq5_alu =[dq_echo()],
                  dq6_start =0x00000001, dq6_alu =[dq_echo()],
                  dq7_start =0x00000001, dq7_alu =[dq_echo()],
                  dq8_start =0x00000001, dq8_alu =[dq_echo()],
                  dq9_start =0x00000001, dq9_alu =[dq_echo()],
                  dq10_start=0x00000001, dq10_alu=[dq_echo()],
                  dq11_start=0x00000001, dq11_alu=[dq_echo()],
                  dq12_start=0x00000001, dq12_alu=[dq_echo()],
                  dq13_start=0x00000001, dq13_alu=[dq_echo()],
                  dq14_start=0x00000001, dq14_alu=[dq_echo()],
                  dq15_start=0x00000001, dq15_alu=[dq_echo()]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[4], workers=[
            rd_worker(
               arid=4, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0xA000000, lo=0xA000000, hi=0xFFFFFFFF, align=Arsize, alu=[incr(axibl*(self.min_araddr_incr))]),
               rdata=data_eq_dq(
                  dq0_start =0x00000001, dq0_alu =[dq_echo()],
                  dq1_start =0x00000001, dq1_alu =[dq_echo()],
                  dq2_start =0x00000001, dq2_alu =[dq_echo()],
                  dq3_start =0x00000001, dq3_alu =[dq_echo()],
                  dq4_start =0x00000001, dq4_alu =[dq_echo()],
                  dq5_start =0x00000001, dq5_alu =[dq_echo()],
                  dq6_start =0x00000001, dq6_alu =[dq_echo()],
                  dq7_start =0x00000001, dq7_alu =[dq_echo()],
                  dq8_start =0x00000001, dq8_alu =[dq_echo()],
                  dq9_start =0x00000001, dq9_alu =[dq_echo()],
                  dq10_start=0x00000001, dq10_alu=[dq_echo()],
                  dq11_start=0x00000001, dq11_alu=[dq_echo()],
                  dq12_start=0x00000001, dq12_alu=[dq_echo()],
                  dq13_start=0x00000001, dq13_alu=[dq_echo()],
                  dq14_start=0x00000001, dq14_alu=[dq_echo()],
                  dq15_start=0x00000001, dq15_alu=[dq_echo()]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads(),

         #PRBS 31 with random addressing
         write(iters=65536, awvalid=(3,4), wvalid=(1,1), bready=(2,3), awid=[0], workers=[
            # Worker for AWID=0
            wr_worker(
               awid=0, awlen=(axibl-1), awsize=self.max_awsize, awburst=axburst_incr, awlock=0, awcache=0, awprot=0, awqos=0, awregion=0, awuser=0,
               awaddr=addr_gen(start=0x0000000, lo=0x0000000, hi=0xFFFFFFFF, align=Awaddr_align, alu=[rand(32)]),
               wdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               wstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               bresp=xresp_okay
            ),
         ]),
         wait_writes(),
         read(iters=65536, arvalid=(7,8), rready=(4,5), arid=[0], workers=[
            rd_worker(
               arid=0, arlen=(axibl-1), arsize=self.max_arsize, arburst=axburst_incr, arlock=0, arcache=0, arprot=0, arqos=0, arregion=0, aruser=0,
               araddr=addr_gen(start=0x0000000, lo=0x0000000, hi=0xFFFFFFFF, align=Araddr_align, alu=[rand(32)]),
               rdata=data_eq_dq(
                  dq0_start =0x5A5A5A5A, dq0_alu =[dq_prbs(31)],
                  dq1_start =0xFFFFFFFF, dq1_alu =[dq_prbs(31)],
                  dq2_start =0xAAAAAAAA, dq2_alu =[dq_prbs(31)],
                  dq3_start =0x55555555, dq3_alu =[dq_prbs(31)],
                  dq4_start =0x12347890, dq4_alu =[dq_prbs(31)],
                  dq5_start =0x23458901, dq5_alu =[dq_prbs(31)],
                  dq6_start =0x89071234, dq6_alu =[dq_prbs(31)],
                  dq7_start =0xABCDE123, dq7_alu =[dq_prbs(31)],
                  dq8_start =0xFFFFAAAA, dq8_alu =[dq_prbs(31)],
                  dq9_start =0x90875431, dq9_alu =[dq_prbs(31)],
                  dq10_start=0x89898989, dq10_alu=[dq_prbs(31)],
                  dq11_start=0x90213456, dq11_alu=[dq_prbs(31)],
                  dq12_start=0x5A678901, dq12_alu=[dq_prbs(31)],
                  dq13_start=0xA5A5A5A5, dq13_alu=[dq_prbs(31)],
                  dq14_start=0xBCDEFFFF, dq14_alu=[dq_prbs(31)],
                  dq15_start=0xAAAA5555, dq15_alu=[dq_prbs(31)]
               ),
               rstrb=strb_eq_dm(
                  dm0_start =0xFFFFFFFF, dm0_alu =[dm_echo()],
                  dm1_start =0xFFFFFFFF, dm1_alu =[dm_echo()],
                  dm2_start =0xFFFFFFFF, dm2_alu =[dm_echo()],
                  dm3_start =0xFFFFFFFF, dm3_alu =[dm_echo()],
                  dm4_start =0xFFFFFFFF, dm4_alu =[dm_echo()],
                  dm5_start =0xFFFFFFFF, dm5_alu =[dm_echo()],
                  dm6_start =0xFFFFFFFF, dm6_alu =[dm_echo()],
                  dm7_start =0xFFFFFFFF, dm7_alu =[dm_echo()]
               ),
               rresp=xresp_okay
            ),
         ]),
         wait_reads()
      ]


   def hbm_simulation1(self):
      ITERS, ADDR_INDEX1, ADDR_INDEX2, i_BL, = self.hbm_ITERS, self.hbm_ADDR_INDEX1, self.hbm_ADDR_INDEX2, self.hbm_i_BL,

      return [
         *self.gencmd('wr', iters=ITERS, bl=i_BL, addr_range=(ADDR_INDEX1, ADDR_INDEX2), data="prbs7"),
         wait_writes(),
         sleep(256),
         *self.gencmd('rd', iters=ITERS, bl=i_BL, addr_range=(ADDR_INDEX1, ADDR_INDEX2), data="prbs7"),
         wait_reads()
      ]

   def hbm_simulation(self):
      ITERS, ADDR_INDEX1, ADDR_INDEX2, i_BL, = self.hbm_ITERS, self.hbm_ADDR_INDEX1, self.hbm_ADDR_INDEX2, self.hbm_i_BL,

      min_addr_incr  = max(self.min_awaddr_incr, self.min_araddr_incr)
      min_addr_incr1 = min_addr_incr * i_BL

      start_addr_0_0 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 0
      start_addr_0_1 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 1 - min_addr_incr1 * ITERS
      start_addr_1_0 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 1
      start_addr_1_1 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 2 - min_addr_incr1 * ITERS
      start_addr_2_0 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 2
      start_addr_2_1 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 3 - min_addr_incr1 * ITERS
      start_addr_3_0 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 3
      start_addr_3_1 = ADDR_INDEX1 + ((ADDR_INDEX2-ADDR_INDEX1+1)//4) * 4 - min_addr_incr1 * ITERS

      # Order for block burst lengths i_BL*: 1,1,2,4,8,16,32,1
      # In case of greater than 512 data width default to BL1 in all cases
      max_size = min(self.max_awsize, self.max_arsize)
      hbm_bl   = [1, 1, 2, 4, 8, 16, 32, 1] if (max_size < 7) else [1, 1, 1, 1, 1, 1, 1, 1]

      return [
         *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[0])), bl=i_BL*hbm_bl[0], addr_range=(start_addr_0_0, ADDR_INDEX2), data="prbs7"),
         wait_writes(),
         sleep(256),

         parallel([
            *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[0])), bl=i_BL*hbm_bl[0], addr_range=(start_addr_0_0, ADDR_INDEX2), data="prbs7"),
            *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[1])), bl=i_BL*hbm_bl[1], addr_range=(start_addr_0_1, ADDR_INDEX2), data="prbs7"),
         ]),
         wait_reads(),
         wait_writes(),
         sleep(256),

         parallel([
            *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[1])), bl=i_BL*hbm_bl[1], addr_range=(start_addr_0_1, ADDR_INDEX2), data="prbs7"),
            *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[2])), bl=i_BL*hbm_bl[2], addr_range=(start_addr_1_0, ADDR_INDEX2), data="prbs7"),
         ]),
         wait_reads(),
         wait_writes(),
         sleep(256),

         parallel([
            *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[2])), bl=i_BL*hbm_bl[2], addr_range=(start_addr_1_0, ADDR_INDEX2), data="prbs7"),
            *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[3])), bl=i_BL*hbm_bl[3], addr_range=(start_addr_1_1, ADDR_INDEX2), data="prbs7"),
         ]),
         wait_reads(),
         wait_writes(),
         sleep(256),

         parallel([
            *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[3])), bl=i_BL*hbm_bl[3], addr_range=(start_addr_1_1, ADDR_INDEX2), data="prbs7"),
            *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[4])), bl=i_BL*hbm_bl[4], addr_range=(start_addr_2_0, ADDR_INDEX2), data="prbs7"),
         ]),
         wait_reads(),
         wait_writes(),
         sleep(256),

         parallel([
            *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[4])), bl=i_BL*hbm_bl[4], addr_range=(start_addr_2_0, ADDR_INDEX2), data="prbs7"),
            *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[5])), bl=i_BL*hbm_bl[5], addr_range=(start_addr_2_1, ADDR_INDEX2), data="prbs7"),
         ]),
         wait_reads(),
         wait_writes(),
         sleep(256),

         parallel([
            *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[5])), bl=i_BL*hbm_bl[5], addr_range=(start_addr_2_1, ADDR_INDEX2), data="prbs7"),
            *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[6])), bl=i_BL*hbm_bl[6], addr_range=(start_addr_3_0, ADDR_INDEX2), data="prbs7"),
         ]),
         wait_reads(),
         wait_writes(),
         sleep(256),

         parallel([
            *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[6])), bl=i_BL*hbm_bl[6], addr_range=(start_addr_3_0, ADDR_INDEX2), data="prbs7"),
            *self.gencmd('wr', iters=max(1, math.floor(ITERS/hbm_bl[7])), bl=i_BL*hbm_bl[7], addr_range=(start_addr_3_1, ADDR_INDEX2), data="prbs7"),
         ]),
         wait_reads(),
         wait_writes(),
         sleep(256),

         *self.gencmd('rd', iters=max(1, math.floor(ITERS/hbm_bl[7])), bl=i_BL*hbm_bl[7], addr_range=(start_addr_3_1, ADDR_INDEX2), data="prbs7"),
         wait_reads()
      ]

   def hbm_mem_traversal_seq(self):
      ADDR_INDEX1, ADDR_INDEX2, = self.hbm_ADDR_INDEX1, self.hbm_ADDR_INDEX2,

      bl = 128 if self.total_wdata_width < 256 else None

      return self.mem_traversal('rw', addr='seq', addr_range=(ADDR_INDEX1, ADDR_INDEX2), bl=bl, data="prbs7")

   def hbm_mem_traversal_rand(self):
      ADDR_INDEX1, ADDR_INDEX2, = self.hbm_ADDR_INDEX1, self.hbm_ADDR_INDEX2,

      bl = 128 if self.total_wdata_width < 256 else None

      return self.mem_traversal('rw', addr='rand', addr_range=(ADDR_INDEX1, ADDR_INDEX2), bl=bl, data="prbs7")


   def memss_default(self):
      return [
         # Single write/read
         *self.gencmd("wr"),
         wait_writes(),
         *self.gencmd("rd"),
         wait_reads(),

         sleep(100),

         # Bulk write/read
         *self.gencmd("wr", iters=256),
         wait_writes(),
         *self.gencmd("rd", iters=256),
         wait_reads(),

         sleep(100),

         # Bulk write/read with random access
         *self.gencmd("wr", iters=256, addr="rand"),
         wait_writes(),
         *self.gencmd("rd", iters=256, addr="rand"),
         wait_reads(),

         sleep(100),

         # Bulk write/read with random access and burst
         *self.gencmd("wr", iters=256, addr="rand", bl=2, data="prbs7"),
         wait_writes(),
         *self.gencmd("rd", iters=256, addr="rand", bl=2, data="prbs7"),
         wait_reads()


      ]



   def mem_traversal(
      self, 
      rw:         str, 
      addr:       str = 'seq', 
      addr_range: Tuple[int, int] = (0x0, 0x3FFF_FFFF), 
      bl:         Union[None, int] = None, 
      data:       str = "prbs7", 
      inspect:    bool = True
   ):

      # Helper function to throw errors/warnings
      def print_message(is_error, message):
         if is_error:
            raise Exception(message)
         else:
            print(f"Warning: {message}")

      if rw not in ['rw', 'ro', 'wo', 'r', 'w', 'rd', 'wr']:
         print_message(True, f"Unsupported option rw='{rw}' for Memory traversal! Supported options are 'rw', 'ro', and 'wo'.")
      if addr not in ['seq', 'rand']:
         print_message(True, f"Unsupported option addr='{addr}' for Memory traversal! Supported options are 'seq', and 'rand'.")

      # Check if the address range would fit within the Address ALU
      lo_addr, hi_addr = addr_range 
      address_space = hi_addr - lo_addr + 1
      if self.clog2(address_space) > self.addr_alu_arg_width + self.max_awsize:
         print_message(True, f"Address ALU Overflow detected for Memory traversal! Increase the Address ALU Argument Width to {self.clog2(address_space) - self.max_awsize} bits to fully traverse this range! (current:{self.addr_alu_arg_width} bits)")

      # If no BL has been provided, set BL to max supported value (where 4kB boundary is not crossed)
      max_bl = min(256, 4096 // self.min_awaddr_incr)
      bl = max_bl if bl is None else bl
      # Check if 4kB boundary is being crossed based on BL and data width
      if bl * self.min_awaddr_incr > 4096:
         print_message(inspect, f"AXI violation detected - 4kB boundary crossed for Memory traversal! Max possible burst length with data width of {self.min_awaddr_incr * 8}bits is BL{max_bl}! (current:BL{bl})")

      # Extra checks for sequential access
      if addr == 'seq':
         # Check if the burst length is of a power of two
         if self.clog2(bl) != self.log2(bl):
            print_message(inspect, f"AXI violation - 4kB boundary crossed for Memory traversal! Non-power-of-two burst length in sequential access will cross page boundary! Adjust the burst length to a power-of-two to avoid.")
      # Extra checks for random access
      if addr == 'rand':
         # Check if the address range is of a power of two
         if self.clog2(address_space) != self.log2(address_space):
            print_message(inspect, f"Non-power-of-two address range detected in random access for Memory traversal! Adjust the address range to cover a power-of-two address space.")
         # Check if the burst length is of a power of two
         if self.clog2(bl) != self.log2(bl):
            print_message(inspect, f"Non-power-of-two burst length detected in random access for Memory traversal! Adjust the burst length to a power-of-two for full memory coverage.")

      # Calculate the number of iterations necessary to cover the entire address space
      data_block_size = self.min_awaddr_incr * bl
      iters = address_space // data_block_size
      # Check for Instruction Memory Overflow
      num_cmds = 2*(iters//65536 + 1) if rw == 'rw' else (iters//65536 + 1) 
      if num_cmds > 512:
         print_message(True, f"Instruction Memory Overflow detected for Memory traversal! \nThe required instruction space for this address range and BL is {num_cmds} (max:512). \nPlease increase your BL or decrease your address range to reduce the instruction count.")

      prog = []
      if 'w' in rw:         
         prog.extend(self.gencmd("wr", iters=min(iters, 65536), addr_range=(lo_addr, hi_addr), addr=addr, bl=bl, data=data))
         for i in range(1, iters//65536):
            prog.extend(self.gencmd("wr", iters=min(iters-i*65536, 65536), addr_range=(lo_addr, hi_addr), addr=addr, bl=bl, data=data, resume=True))
         prog.append(wait_writes())
      if 'r' in rw:  
         prog.extend(self.gencmd("rd", iters=min(iters, 65536), addr_range=(lo_addr, hi_addr), addr=addr, bl=bl, data=data))
         for i in range(1, iters//65536):
            prog.extend(self.gencmd("rd", iters=min(iters-i*65536, 65536), addr_range=(lo_addr, hi_addr), addr=addr, bl=bl, data=data, resume=True))
         prog.append(wait_reads())

      return prog

   def gencmd(
      self,
      cmd:        str,
      iters:      int = 1,
      addr:       Union[int, List[int], str, List[str]] = "seq",
      addr_range: Union[None, Tuple[int, int]] = None,
      data:       Union[None, int, List[int], str, List[str]] = "addr",
      strb:       Union[int, List[int], str, List[str]] = -1,   # -1 translates to all 1s in binary
      bl:         Union[int, List[int]] = 1,
      size:       Union[float, List[float]] = 1.0,
      burst:      Union[int, List[int]] = axburst_incr,
      lock:       Union[int, List[int]] = 0,
      cache:      Union[int, List[int]] = 0,
      prot:       Union[int, List[int]] = 0,
      qos:        Union[int, List[int]] = 0,
      region:     Union[int, List[int]] = 0,
      auser:      Union[int, List[int]] = 0,
      resp:       Union[int, List[int]] = xresp_okay,
      id:         Union[int, List[int]] = 0,
      addr_bw:    Union[float, Tuple[int, int]] = 1.0,
      data_bw:    Union[float, Tuple[int, int]] = 1.0,
      resp_bw:    Union[float, Tuple[int, int]] = 1.0,
      resume:     Union[bool, List[bool]] = False,
      inspect:    bool = True):

      # Helper function to throw errors/warnings
      def print_message(is_error, message):
         if is_error:
            raise Exception(message)
         else:
            print(f"Warning: {message}")

      if cmd not in ['wr', 'rd']:
         raise ValueError(f'Unrecognized cmd "{cmd}"')

      max_addr      = self.max_awaddr if cmd == 'wr' else self.max_araddr
      min_addr_incr = self.min_awaddr_incr if cmd == 'wr' else self.min_araddr_incr
      max_size      = self.max_awsize if cmd == 'wr' else self.max_arsize

      # Allowed address range for this read/write command
      min_addr = 0
      if addr_range is not None:
         min_addr = addr_range[0]
         max_addr = addr_range[1]

      # Get list of unique AxIDs
      if not isinstance(id, list):
         id = [id]
      ids = sorted(list(set(id)))

      # If only a single value is provided for the below fields, replicate that for all workers
      if not isinstance(addr,    list): addr    = [addr]    * len(ids)
      if not isinstance(data,    list): data    = [data]    * len(ids)
      if not isinstance(strb,    list): strb    = [strb]    * len(ids)
      if not isinstance(bl,      list): bl      = [bl]      * len(ids)
      if not isinstance(size,    list): size    = [size]    * len(ids)
      if not isinstance(burst,   list): burst   = [burst]   * len(ids)
      if not isinstance(lock,    list): lock    = [lock]    * len(ids)
      if not isinstance(cache,   list): cache   = [cache]   * len(ids)
      if not isinstance(prot,    list): prot    = [prot]    * len(ids)
      if not isinstance(qos,     list): qos     = [qos]     * len(ids)
      if not isinstance(region,  list): region  = [region]  * len(ids)
      if not isinstance(auser,   list): auser   = [auser]   * len(ids)
      if not isinstance(resp,    list): resp    = [resp]    * len(ids)
      if not isinstance(resume,  list): resume  = [resume]  * len(ids)

      # The below loop creates the traffic pattern for each AxID by configuring the appropriate worker
      workers = []
      for worker_num, (id_i, addr_i, data_i, strb_i, bl_i, size_i, burst_i, lock_i, cache_i, prot_i, qos_i, region_i, auser_i, resp_i, resume_i) in \
         enumerate(zip(ids,  addr,   data,   strb,   bl,   size,   burst,   lock,   cache,   prot,   qos,   region,   auser,   resp,   resume)):
         # Some AXI port values
         axid     = id_i
         axlen    = bl_i - 1
         axsize   = max_size + self.clog2(size_i)   # = clog2(data_width * size / 8) = clog2(data_width / 8) + clog2(size) = max_size + clog2(size)
         axburst  = burst_i
         axlock   = lock_i
         axcache  = cache_i
         axprot   = prot_i
         axqos    = qos_i
         axregion = region_i
         axuser   = auser_i
         xresp    = resp_i

         # AXI4 spec restricts the allowed burst lengths for wrapping bursts
         axburst_wrap_bl_list = [2, 4, 8, 16]
         if axburst == axburst_wrap and bl_i not in axburst_wrap_bl_list:
            print_message(inspect, f"AXI4 spec violation! Burst length {bl_i} is not permitted for wrapping bursts. Permitted burst lengths are {axburst_wrap_bl_list}.")

         # AXI4 spec restricts that bursts shouldn't cross a 4KB boundary
         if axburst != axburst_fixed and bl_i * (2 ** axsize) > 4 * 1024:
            print_message(inspect, f"AXI4 spec violation! Burst length {bl_i} and AxSIZE={axsize} crosses 4KB boundary. Try lowering burst length or AxSIZE.")

         # Force disable RDATA error checking if expected RRESP is an error response
         if xresp in [xresp_slverr, xresp_decerr]:
            strb = 0

         # Number of byte-address locations being accessed by a single AXI command
         if axburst == axburst_fixed:
            num_byte_addrs = (2 ** axsize)
         else:
            num_byte_addrs = (2 ** axsize) * bl_i

         # Address range for this worker:
         # Evenly split address space among workers
         # Ex: addr range 0x00000000-0x3fffffff split among 4 workers is 0x00000000-0x0fffffff, 0x10000000-0x1fffffff, 0x20000000-0x2fffffff, 0x30000000-0x3fffffff
         lo_addr = min_addr + worker_num     * ((max_addr+1 - min_addr) // len(ids))
         hi_addr = min_addr + (worker_num+1) * ((max_addr+1 - min_addr) // len(ids)) - 1

         # Align address bounds to transfer size. This avoids problems such as crossing 4KB boundaries and bursts exceeding the address range.
         aligned_lo_addr = self.roundup(lo_addr, num_byte_addrs)
         aligned_hi_addr = self.rounddown(hi_addr+1, num_byte_addrs) - 1
         if (lo_addr != aligned_lo_addr) or (hi_addr != aligned_hi_addr):
            print_message(False, f"Address Range has been adjusted for Worker ID={hex(id_i)} for transfer size alignment. Before:({hex(lo_addr)},{hex(hi_addr)}), After:({hex(aligned_lo_addr)},{hex(aligned_hi_addr)})")
         if aligned_lo_addr <= aligned_hi_addr:
            lo_addr = aligned_lo_addr
            hi_addr = aligned_hi_addr
         else:
            print_message(inspect, f"Unable to align address bounds to burst size. Try expanding the address range.")

         # Start from the lower address bound.
         # We'll align the start address later after we parse the address preset.
         start_addr = lo_addr

         # Calculate Worker Iteration count, used for Address Retreading Warning Check
         worker_iters = id.count(id_i) * (iters // len(id)) + id[ : iters % len(id)].count(id_i)

         # Address pattern
         axaddr = None
         # Accessing a single address
         if isinstance(addr_i, int):
            axaddr = addr_i
         # Address pattern preset
         elif isinstance(addr_i, str):
            addr_alu = None
            # Sequential access
            # Ex: seq, seq_stride16_echo1
            m = re.match(r"^seq(_stride\d+)?(_echo\d+)?$", addr_i)
            if m:
               # Parse the args
               stride, repeat, = m.groups()
               stride = 1 if stride is None else int( stride[len("_stride"):] )  # stride = "_stride16"  -->  stride = 16
               repeat = 0 if repeat is None else int( repeat[len("_echo"):] )    # repeat = "_echo2"     -->  repeat = 2
               # Increment by number of byte-address locations accessed in a single read/write command
               addr_alu   = [incr(num_byte_addrs * stride)]
               # Align address to data word size.
               #
               # align = log2(burst_size) = AxSIZE
               addr_align = axsize
               # Repeat every address multiple times (if repeat > 0).
               # Do this by injecting echo()'s in between all the ALU ops.
               # Ex: repeat=2 and addr_alu=[opA, opB, opC] --> addr_alu=[echo, echo, opA, echo, echo, opB, echo, echo, opC]
               for i in range(0, len(addr_alu)*(repeat+1), repeat+1):
                  for j in range(repeat):
                     addr_alu.insert(i, echo())
               # Address Retreading Check
               # Determine real address range based on Address ALU Arg Width
               addr_range_i = hi_addr+1 - lo_addr
               max_offset = ( (1 << self.addr_alu_arg_width) - 1 ) << addr_align
               # If the max offset supported by the Address ALU is smaller than the address range, reduce range to max offset
               if addr_range_i > max_offset:
                  addr_range_i = max_offset
               # Calculate the data range: Real Address range + bytes covered by the highest address in range
               data_range = addr_range_i + num_byte_addrs - 1
               # Calculate number of unique addresses within the data range.
               num_unique_addr = data_range // (num_byte_addrs * stride)
               # If address is repeated multiple times, increase the number of safe iterations by the same factor
               worker_iters_max_no_retread = (repeat+1) * num_unique_addr
               if worker_iters > worker_iters_max_no_retread:
                  # Calculate the safe cmd iters to avoid retreading for this worker ID
                  # cmd_iters_max_no_retread = Command Iteration of the (n+1)th occurrence of the Worker ID minus 1, where n=worker_iters_max_no_retread
                  #                          = Number of full cycles through ID list                        + Index of the (n+1)th occurrence (this includes the minus 1)
                  cmd_iters_max_no_retread = ( (worker_iters_max_no_retread) // id.count(id_i)) * len(id) + [i for i, n in enumerate(id) if n == id_i][(worker_iters_max_no_retread % id.count(id_i))]
                  print_message(inspect, f"Address Retreading detected for Worker ID {hex(id_i)}! To avoid address repetition please use a safe value for iters: current={iters} safe={cmd_iters_max_no_retread}")
            # Random access
            # Ex: rand, rand_echo1
            m = re.match(r"^rand(_echo\d+)?$", addr_i)
            if m:
               # Parse the args
               repeat, = m.groups()
               repeat = 0 if repeat is None else int( repeat[len("_echo"):] )   # repeat = "_echo2"  -->  repeat = 2
               # LFSR width is derived based on address range (so the LFSR doesn't output numbers that
               # are larger than the address span)
               #
               # Memory AXI Driver's address bounds check for:  lo <= addr <= hi
               # n-bit LFSR generates numbers from: 0 <= lfsr output <= (2^n - 1)
               # So the output address range is:    lo <= addr <= lo + (2^n - 1)
               # Hence to avoid exceeding the address bound: lo + (2^n - 1) <= hi  -->  n = floor(log2(hi - lo + 1))
               #
               # Consequently this implies that using non-power-of-2 address span with rand pattern
               # will not cover all addresses
               #
               # To account for the aligned address bounds, add the transfer size to the calculation of the LFSR Width.
               # This accounts for the data range covered by the random address generator
               lfsr_width = math.floor(self.log2(hi_addr - lo_addr + num_byte_addrs))
               # Align address to data word size and burst length. We align address to burst length
               # to ensure the addr bits corresponding to burst index are not randomized by LFSR,
               # since that could lead to stomping on previously accessed addresses.
               # Consequently this implies that using non-power-of-2 burst length with rand pattern
               # will not cover all addresses.
               #
               # align = log2(burst_size * burst_length)
               addr_align = self.clog2(num_byte_addrs)
               # The effective LSFR width (LFSR width - align) cannot excceed the Address ALU Arg Width
               if lfsr_width - addr_align > self.addr_alu_arg_width:
                  lfsr_width = self.addr_alu_arg_width + addr_align
               addr_alu   = [rand(lfsr_width)]
               # Repeat every address multiple times (if repeat > 0).
               # Do this by injecting echo()'s in between all the ALU ops.
               # Ex: repeat=2 and addr_alu=[opA, opB, opC] --> addr_alu=[echo, echo, opA, echo, echo, opB, echo, echo, opC]
               for i in range(0, len(addr_alu)*(repeat+1), repeat+1):
                  for j in range(repeat):
                     addr_alu.insert(i, echo())
               # Address Retreading Check
               # Calculate number of unique addresses within the address bounds
               num_unique_addr = 2 ** (lfsr_width - addr_align)
               # If address is repeated multiple times, increase the number of safe iterations by the same factor
               worker_iters_max_no_retread = (repeat+1) * num_unique_addr
               if worker_iters > worker_iters_max_no_retread:
                  # Calculate the safe cmd iters to avoid retreading for this worker ID
                  # cmd_iters_max_no_retread = Command Iteration of the (n+1)th occurrence of the Worker ID minus 1, where n=worker_iters_max_no_retread
                  #                          = Number of full cycles through ID list                        + Index of the (n+1)th occurrence (this includes the minus 1)
                  cmd_iters_max_no_retread = ( (worker_iters_max_no_retread) // id.count(id_i)) * len(id) + [i for i, n in enumerate(id) if n == id_i][(worker_iters_max_no_retread % id.count(id_i))]
                  print_message(inspect, f"Address Retreading detected for Worker ID {hex(id_i)}! To avoid address repetition please use a safe value for iters: current={iters} safe={cmd_iters_max_no_retread}")
            if addr_alu is None:
               raise ValueError(f'Unrecognized address preset "{addr}"')

            # Instruction resume for address pattern
            if resume_i:
               start_addr = None
               addr_alu   = None

            # Create address op object
            axaddr = addr_gen(start=start_addr, lo=lo_addr, hi=hi_addr, align=addr_align, alu=addr_alu)

         # Data pattern
         xdata = None
         # Skip data checking
         if data_i is None:
            xdata = None
         # Raw data value
         elif isinstance(data_i, int):
            xdata = data_i
         # Data pattern preset
         elif isinstance(data_i, str):
            # Data equals address
            if data_i == "addr":
               xdata = data_eq_addr()
            # Data equals AxID
            elif data_i == "id":
               xdata = data_eq_id()
            # Clock pattern (every DQ pin alternates between 1 and 0)
            elif data_i == "clock":
               xdata = data_eq_dq(
                  dq0_start  = 0x55555555, dq0_alu  = [dq_echo()]
               )
            # Long 1s followed by 0
            elif data_i == "pulse0":
               xdata = data_eq_dq(
                  dq0_start  = 0xFEFEFEFE, dq0_alu  = [dq_echo()],
               )
            # Long 0s followed by 1
            elif data_i == "pulse1":
               xdata = data_eq_dq(
                  dq0_start  = 0x00000001, dq0_alu  = [dq_echo()],
               )
            # Walking 0s (within a single byte lane)
            elif data_i == "walking0":
               xdata = data_eq_dq(
                  dq0_start  = 0xFEFEFEFE, dq0_alu  = [dq_rotate()],
                  dq1_start  = 0xFDFDFDFD, dq1_alu  = [dq_rotate()],
                  dq2_start  = 0xFBFBFBFB, dq2_alu  = [dq_rotate()],
                  dq3_start  = 0xF7F7F7F7, dq3_alu  = [dq_rotate()],
                  dq4_start  = 0xEFEFEFEF, dq4_alu  = [dq_rotate()],
                  dq5_start  = 0xDFDFDFDF, dq5_alu  = [dq_rotate()],
                  dq6_start  = 0xBFBFBFBF, dq6_alu  = [dq_rotate()],
                  dq7_start  = 0x7F7F7F7F, dq7_alu  = [dq_rotate()],
               )
            # Walking 1s (within a single byte lane)
            elif data_i == "walking1":
               xdata = data_eq_dq(
                  dq0_start  = 0x01010101, dq0_alu  = [dq_rotate()],
                  dq1_start  = 0x02020202, dq1_alu  = [dq_rotate()],
                  dq2_start  = 0x04040404, dq2_alu  = [dq_rotate()],
                  dq3_start  = 0x08080808, dq3_alu  = [dq_rotate()],
                  dq4_start  = 0x10101010, dq4_alu  = [dq_rotate()],
                  dq5_start  = 0x20202020, dq5_alu  = [dq_rotate()],
                  dq6_start  = 0x40404040, dq6_alu  = [dq_rotate()],
                  dq7_start  = 0x80808080, dq7_alu  = [dq_rotate()]
               )
            # PRBS7
            elif data_i.startswith("prbs7"):
               m = re.match(r"^prbs7(_echo\d+)?$", data_i)
               repeat, = m.groups()
               repeat = 0 if repeat is None else int( repeat[len("_echo"):] )    # repeat = "_echo2"  -->  repeat = 2
               xdata = data_eq_dq(
                  dq0_start  = 0x5A5A5A5A, dq0_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq1_start  = 0xC3C3C3C3, dq1_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq2_start  = 0x2B2B2B2B, dq2_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq3_start  = 0x96969696, dq3_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq4_start  = 0x5A5A5A5A, dq4_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq5_start  = 0xC3C3C3C3, dq5_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq6_start  = 0x2B2B2B2B, dq6_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq7_start  = 0x96969696, dq7_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq8_start  = 0x5A5A5A5A, dq8_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq9_start  = 0xC3C3C3C3, dq9_alu  = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq10_start = 0x2B2B2B2B, dq10_alu = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq11_start = 0x96969696, dq11_alu = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq12_start = 0x5A5A5A5A, dq12_alu = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq13_start = 0xC3C3C3C3, dq13_alu = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq14_start = 0x2B2B2B2B, dq14_alu = [dq_echo()] * repeat + [dq_prbs(7)],
                  dq15_start = 0x96969696, dq15_alu = [dq_echo()] * repeat + [dq_prbs(7)]
               )
            # PRBS15
            elif data_i.startswith("prbs15"):
               m = re.match(r"^prbs15(_echo\d+)?$", data_i)
               repeat, = m.groups()
               repeat = 0 if repeat is None else int( repeat[len("_echo"):] )    # repeat = "_echo2"  -->  repeat = 2
               xdata = data_eq_dq(
                  dq0_start  = 0x5A5A5A5A, dq0_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq1_start  = 0xFFFFFFFF, dq1_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq2_start  = 0xAAAAAAAA, dq2_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq3_start  = 0x55555555, dq3_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq4_start  = 0x12347890, dq4_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq5_start  = 0x23458901, dq5_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq6_start  = 0x89071234, dq6_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq7_start  = 0xABCDE123, dq7_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq8_start  = 0xFFFFAAAA, dq8_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq9_start  = 0x90875431, dq9_alu  = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq10_start = 0x89898989, dq10_alu = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq11_start = 0x90213456, dq11_alu = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq12_start = 0x5A678901, dq12_alu = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq13_start = 0xA5A5A5A5, dq13_alu = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq14_start = 0xBCDEFFFF, dq14_alu = [dq_echo()] * repeat + [dq_prbs(15)],
                  dq15_start = 0xAAAA5555, dq15_alu = [dq_echo()] * repeat + [dq_prbs(15)]
               )
            # PRBS23
            elif data_i.startswith("prbs23"):
               m = re.match(r"^prbs23(_echo\d+)?$", data_i)
               repeat, = m.groups()
               repeat = 0 if repeat is None else int( repeat[len("_echo"):] )    # repeat = "_echo2"  -->  repeat = 2
               xdata = data_eq_dq(
                  dq0_start  = 0x5A5A5A5A, dq0_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq1_start  = 0xFFFFFFFF, dq1_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq2_start  = 0xAAAAAAAA, dq2_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq3_start  = 0x55555555, dq3_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq4_start  = 0x12347890, dq4_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq5_start  = 0x23458901, dq5_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq6_start  = 0x89071234, dq6_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq7_start  = 0xABCDE123, dq7_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq8_start  = 0xFFFFAAAA, dq8_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq9_start  = 0x90875431, dq9_alu  = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq10_start = 0x89898989, dq10_alu = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq11_start = 0x90213456, dq11_alu = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq12_start = 0x5A678901, dq12_alu = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq13_start = 0xA5A5A5A5, dq13_alu = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq14_start = 0xBCDEFFFF, dq14_alu = [dq_echo()] * repeat + [dq_prbs(23)],
                  dq15_start = 0xAAAA5555, dq15_alu = [dq_echo()] * repeat + [dq_prbs(23)]
               )
            # PRBS31
            elif data_i.startswith("prbs31"):
               m = re.match(r"^prbs31(_echo\d+)?$", data_i)
               repeat, = m.groups()
               repeat = 0 if repeat is None else int( repeat[len("_echo"):] )    # repeat = "_echo2"  -->  repeat = 2
               xdata = data_eq_dq(
                  dq0_start  = 0x5A5A5A5A, dq0_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq1_start  = 0xFFFFFFFF, dq1_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq2_start  = 0xAAAAAAAA, dq2_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq3_start  = 0x55555555, dq3_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq4_start  = 0x12347890, dq4_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq5_start  = 0x23458901, dq5_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq6_start  = 0x89071234, dq6_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq7_start  = 0xABCDE123, dq7_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq8_start  = 0xFFFFAAAA, dq8_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq9_start  = 0x90875431, dq9_alu  = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq10_start = 0x89898989, dq10_alu = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq11_start = 0x90213456, dq11_alu = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq12_start = 0x5A678901, dq12_alu = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq13_start = 0xA5A5A5A5, dq13_alu = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq14_start = 0xBCDEFFFF, dq14_alu = [dq_echo()] * repeat + [dq_prbs(31)],
                  dq15_start = 0xAAAA5555, dq15_alu = [dq_echo()] * repeat + [dq_prbs(31)]
               )

            # Instruction resume for data pattern.
            # This only works for DQ ALU, not the other data modes. Besides, the
            # other data modes don't need this feature.
            if resume_i and data_i != "addr" and data_i != "id":
               xdata = data_eq_dq(
                  dq0_start  = None, dq0_alu  = None
               )

         # Strb pattern
         xstrb = None
         # Raw strb value
         if isinstance(strb_i, int):
            xstrb = strb_i
         # Strb pattern preset
         elif isinstance(strb_i, str):
            # PRBS7
            if strb_i == "prbs7":
               xstrb = strb_eq_dm(
                  dm0_start  = 0x5A5A5A5A, dm0_alu  = [dm_prbs(7)],
                  dm1_start  = 0xC3C3C3C3, dm1_alu  = [dm_prbs(7)],
                  dm2_start  = 0x2B2B2B2B, dm2_alu  = [dm_prbs(7)],
                  dm3_start  = 0x96969696, dm3_alu  = [dm_prbs(7)],
                  dm4_start  = 0x5A5A5A5A, dm4_alu  = [dm_prbs(7)],
                  dm5_start  = 0xC3C3C3C3, dm5_alu  = [dm_prbs(7)],
                  dm6_start  = 0x2B2B2B2B, dm6_alu  = [dm_prbs(7)],
                  dm7_start  = 0x96969696, dm7_alu  = [dm_prbs(7)]
               )
            # PRBS15
            elif strb_i == "prbs15":
               xstrb = strb_eq_dm(
                  dm0_start  = 0x5A5A5A5A, dm0_alu  = [dm_prbs(15)],
                  dm1_start  = 0xFFFFFFFF, dm1_alu  = [dm_prbs(15)],
                  dm2_start  = 0xAAAAAAAA, dm2_alu  = [dm_prbs(15)],
                  dm3_start  = 0x55555555, dm3_alu  = [dm_prbs(15)],
                  dm4_start  = 0x12347890, dm4_alu  = [dm_prbs(15)],
                  dm5_start  = 0x23458901, dm5_alu  = [dm_prbs(15)],
                  dm6_start  = 0x89071234, dm6_alu  = [dm_prbs(15)],
                  dm7_start  = 0xABCDE123, dm7_alu  = [dm_prbs(15)]
               )
            # PRBS23
            elif strb_i == "prbs23":
               xstrb = strb_eq_dm(
                  dm0_start  = 0x5A5A5A5A, dm0_alu  = [dm_prbs(23)],
                  dm1_start  = 0xFFFFFFFF, dm1_alu  = [dm_prbs(23)],
                  dm2_start  = 0xAAAAAAAA, dm2_alu  = [dm_prbs(23)],
                  dm3_start  = 0x55555555, dm3_alu  = [dm_prbs(23)],
                  dm4_start  = 0x12347890, dm4_alu  = [dm_prbs(23)],
                  dm5_start  = 0x23458901, dm5_alu  = [dm_prbs(23)],
                  dm6_start  = 0x89071234, dm6_alu  = [dm_prbs(23)],
                  dm7_start  = 0xABCDE123, dm7_alu  = [dm_prbs(23)]
               )
            # PRBS31
            elif strb_i == "prbs31":
               xstrb = strb_eq_dm(
                  dm0_start  = 0x5A5A5A5A, dm0_alu  = [dm_prbs(31)],
                  dm1_start  = 0xFFFFFFFF, dm1_alu  = [dm_prbs(31)],
                  dm2_start  = 0xAAAAAAAA, dm2_alu  = [dm_prbs(31)],
                  dm3_start  = 0x55555555, dm3_alu  = [dm_prbs(31)],
                  dm4_start  = 0x12347890, dm4_alu  = [dm_prbs(31)],
                  dm5_start  = 0x23458901, dm5_alu  = [dm_prbs(31)],
                  dm6_start  = 0x89071234, dm6_alu  = [dm_prbs(31)],
                  dm7_start  = 0xABCDE123, dm7_alu  = [dm_prbs(31)]
               )
            # Byte-enable test mode. Continually generate random STRB (held constant within a burst) followed by its inverse (held constant within a burst).
            elif strb_i == "byteen_test":
               xstrb = strb_eq_dm(
                  dm0_start  = 0x5A5A5A5A, dm0_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)],
                  dm1_start  = 0xFFFFFFFF, dm1_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)],
                  dm2_start  = 0xAAAAAAAA, dm2_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)],
                  dm3_start  = 0x55555555, dm3_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)],
                  dm4_start  = 0x12347890, dm4_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)],
                  dm5_start  = 0x23458901, dm5_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)],
                  dm6_start  = 0x89071234, dm6_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)],
                  dm7_start  = 0xABCDE123, dm7_alu  = [dm_echo()] * (bl_i-1) + [dm_invert()] + [dm_echo()] * (bl_i-1) + [dm_prbs(31)]
               )

            # Instruction resume for strb pattern.
            if resume_i:
               xstrb = strb_eq_dm(
                  dm0_start  = None, dm0_alu  = None
               )

         # Create worker
         if cmd == 'wr':
            worker = wr_worker(
               awid=axid, awlen=axlen, awsize=axsize, awburst=axburst, awlock=axlock, awcache=axcache, awprot=axprot, awqos=axqos, awregion=axregion, awuser=axuser, awaddr=axaddr,
               wdata=xdata, wstrb=xstrb,
               bresp=xresp
            )
         elif cmd == 'rd':
            worker = rd_worker(
               arid=axid, arlen=axlen, arsize=axsize, arburst=axburst, arlock=axlock, arcache=axcache, arprot=axprot, arqos=axqos, arregion=axregion, aruser=axuser, araddr=axaddr,
               rdata=xdata, rstrb=xstrb, rresp=xresp
            )

         workers.append(worker)

      # Convert bandwidth percentage to duty-cycle tuple
      def percent_to_fraction(p, limit_denominator=8):
         # Max duty-cycle period = 8
         f = Fraction.from_float(p).limit_denominator(limit_denominator)
         return (f.numerator, f.denominator)

      if isinstance(addr_bw, float): addr_bw = percent_to_fraction(addr_bw, 64)
      if isinstance(data_bw, float): data_bw = percent_to_fraction(data_bw, 64)
      if isinstance(resp_bw, float): resp_bw = percent_to_fraction(resp_bw, 64)

      # Generate command
      if cmd == 'wr':
         c = write(iters=iters, awvalid=addr_bw, wvalid=data_bw, bready=resp_bw, awid=id, workers=workers)
      elif cmd == 'rd':
         c = read(iters=iters, arvalid=addr_bw, rready=resp_bw, arid=id, workers=workers)

      # Return the command(s)
      return [c]

   def log2(self, x):
      '''
      Returns log(x) / log(2)
      '''
      return math.log(x) / math.log(2)

   def clog2(self, x):
      '''
      Returns ceil(log2(x))
      '''
      return math.ceil(self.log2(x))


   def roundup(self, x, y):
      '''
      Returns x rounded up to the next multiple of y
      '''
      return ((x + y-1) // y) * y


   def rounddown(self, x, y):
      '''
      Returns x rounded down to the previous multiple of y
      '''
      return (x // y) * y



class CsrAxi4lDriverPrograms:
   '''
   An object of this class should contain traffic programs customized for the specific driver and the specific target
   it's connected to.
   '''

   def __init__(self, config, hydra_ip_name, driver_index):
      ########################################################################
      # How is the Hydra driver configured
      ########################################################################

      hydra_config = config['system']['ips'][hydra_ip_name]
      hydra_params = hydra_config['parameters']

      self.num_drivers = int(hydra_params['NUM_DRIVERS']['value'])
      self.driver_index = driver_index

      driver_type = hydra_params[f'DRIVER_{self.driver_index}_TYPE_ENUM']['value']
      if driver_type != 'DRIVER_TYPE_CSR_AXI4L':
         raise Exception(f'Driver {self.driver_index} is of type {driver_type}, this class only supports DRIVER_TYPE_CSR_AXI4L')

      # Some parameters related to AXI port widths
      self.max_awaddr = 2**int(hydra_params[f'DRIVER_{self.driver_index}_CSR_AXI4L_AWADDR_WIDTH']['value']) - 1
      self.max_araddr = 2**int(hydra_params[f'DRIVER_{self.driver_index}_CSR_AXI4L_AWADDR_WIDTH']['value']) - 1

      ########################################################################
      # How is the MemSS target configured
      # (the MemSS that is connected to this Hydra driver)
      ########################################################################

      self.memss_csr_base_addr = 2**(int(hydra_params[f'DRIVER_{self.driver_index}_CSR_AXI4L_AWADDR_WIDTH']['value'])-1)


   def hbm_simulation1(self):
      axilite_base_addr = 0x400000000

      #  Dictionary of per-channel hbm registers
      regmap_channel_hbm = {
          "INIT_CTRL"               : {"addr" : 0x00010, "data" : 0x00000000},
          "INIT_STS"                : {"addr" : 0x00014, "data" : 0x00000102},
          "THERM_STS"               : {"addr" : 0x00100, "data" : 0x30000000},
          "IRQ_CTL_PC0"             : {"addr" : 0x00434, "data" : 0x00000200},
          "IRQ_CTL_PC1"             : {"addr" : 0x00734, "data" : 0x00000200},
          "IRQ_EVNTGRP_CTRLSTS_PC0" : {"addr" : 0x00460, "data" : 0x1c7c0000},
          "IRQ_EVNTGRP_CTRLSTS_PC1" : {"addr" : 0x00760, "data" : 0x1c7c0000},
          "AXI4_ERR_STS_PC0"        : {"addr" : 0x00500, "data" : 0x00000000},
          "AXI4_ERR_STS_PC1"        : {"addr" : 0x00800, "data" : 0x00000000},
          "MEM_ERR_STS_PC0"         : {"addr" : 0x00504, "data" : 0x00000000},
          "MEM_ERR_STS_PC1"         : {"addr" : 0x00804, "data" : 0x00000000},
          "ERR_MSK_PC0"             : {"addr" : 0x00520, "data" : 0x00000606},
          "ERR_MSK_PC1"             : {"addr" : 0x00820, "data" : 0x00000606},
          "AWCMDLOG0_PC0"           : {"addr" : 0x00540, "data" : 0x00000000},
          "AWCMDLOG0_PC1"           : {"addr" : 0x00840, "data" : 0x00000000},
          "AWCMDLOG1_PC0"           : {"addr" : 0x00544, "data" : 0x00000000},
          "AWCMDLOG1_PC1"           : {"addr" : 0x00844, "data" : 0x00000000},
          "AWCMDLOG2_PC0"           : {"addr" : 0x00548, "data" : 0x00000000},
          "AWCMDLOG2_PC1"           : {"addr" : 0x00848, "data" : 0x00000000},
          "AWCMDLOG3_PC0"           : {"addr" : 0x0054c, "data" : 0x00000000},
          "AWCMDLOG3_PC1"           : {"addr" : 0x0084c, "data" : 0x00000000},
          "ARCMDLOG0_PC0"           : {"addr" : 0x00550, "data" : 0x00000000},
          "ARCMDLOG0_PC1"           : {"addr" : 0x00850, "data" : 0x00000000},
          "ARCMDLOG1_PC0"           : {"addr" : 0x00554, "data" : 0x00000000},
          "ARCMDLOG1_PC1"           : {"addr" : 0x00854, "data" : 0x00000000},
          "ARCMDLOG2_PC0"           : {"addr" : 0x00558, "data" : 0x00000000},
          "ARCMDLOG2_PC1"           : {"addr" : 0x00858, "data" : 0x00000000},
          "ARCMDLOG3_PC0"           : {"addr" : 0x0055c, "data" : 0x00000000},
          "ARCMDLOG3_PC1"           : {"addr" : 0x0085c, "data" : 0x00000000},
          "ECC_ERR_CNTRS_PC0"       : {"addr" : 0x00560, "data" : 0x00000000},
          "ECC_ERR_CNTRS_PC1"       : {"addr" : 0x00860, "data" : 0x00000000},
      }

      #  Dictionary of per-channel hbm registers
      regmap_hbm = {}
      for k, v in regmap_channel_hbm.items():
          name = k
          addr = v["addr"]
          data = v["data"]
          for ch in [0, 1]:
              name_ch = "CH{:1d}_".format(ch) + name
              ch_addr = 0 if ch == 0 else 1 << 16
              regmap_hbm[name_ch] = {"addr" : ch_addr + addr, "data" : data}

      #  Construct traffic pattern
      addr = axilite_base_addr + regmap_hbm["CH0_ERR_MSK_PC0"]["addr"]
      prog = [
         #  Read ERR_MSK_PC0, checking against default value
         read_csr(araddr=addr, rdata=0x00606),
         #  Write to ERR_MSK_PC0
         write_csr(awaddr=addr, wdata=0x10606),
         #  Read back written value from ERR_MSK_PC0
         read_csr(araddr=addr, rdata=0x10606),
      ]

      #  Read all CSRs, verifying there are no read errors
      for k, v in regmap_hbm.items():
         addr, data = v["addr"] + axilite_base_addr, v["data"]
         prog.append(read_csr(araddr=addr))

      #  Write default values to all CSRs, verifying there are no write errors
      for k, v in regmap_hbm.items():
         addr, data = v["addr"] + axilite_base_addr, v["data"]
         prog.append(write_csr(awaddr=addr, wdata=data))

      return prog


   def memss_default(self):
      memss_csr_base_addr, = self.memss_csr_base_addr,

      return [
         #  Read from DFH first
         read_csr (araddr=0x0000, rdata=0x00001000),
         read_csr (araddr=0x0004, rdata=0x30100100),
         read_csr (araddr=0x0008, rdata=0x043440d8),
         read_csr (araddr=0x000c, rdata=0x9a11c4dd),
         read_csr (araddr=0x0010, rdata=0xe9204d00),
         read_csr (araddr=0x0014, rdata=0x0f43b52e),
         read_csr (araddr=0x0018, rdata=memss_csr_base_addr),
         read_csr (araddr=0x001c, rdata=0x00000000),
         read_csr (araddr=0x0024, rdata=memss_csr_base_addr),

         #  Read and Write to MemSS Global CSR
         read_csr (araddr=memss_csr_base_addr + 0x0000, rdata=0x00010000),
         #  scratchpad
         write_csr(awaddr=memss_csr_base_addr + 0x0020, wdata=0x5a5a5a5a),
         read_csr (araddr=memss_csr_base_addr + 0x0020, rdata=0x5a5a5a5a),
      ]



class CamAxi4DriverPrograms:
   '''
   An object of this class should contain traffic programs customized for the specific driver and the specific target
   it's connected to.
   '''

   def __init__(self, config, hydra_ip_name, driver_index):
      ########################################################################
      # How is the Hydra driver configured
      ########################################################################

      hydra_config = config['system']['ips'][hydra_ip_name]
      hydra_params = hydra_config['parameters']

      self.num_drivers = int(hydra_params['NUM_DRIVERS']['value'])
      self.driver_index = driver_index

      driver_type = hydra_params[f'DRIVER_{self.driver_index}_TYPE_ENUM']['value']
      if driver_type != 'DRIVER_TYPE_CAM_AXI4ST':
         raise Exception(f'Driver {self.driver_index} is of type {driver_type}, this class only supports DRIVER_TYPE_CAM_AXI4ST')

