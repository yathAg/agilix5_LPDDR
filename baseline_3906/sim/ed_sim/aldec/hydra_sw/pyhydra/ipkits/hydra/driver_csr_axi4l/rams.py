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


from collections import OrderedDict

from ..util.compiler_backend import Ram
from ..util.compiler_backend import Field
from ..util.common_rams import *


csr_datawidth = 32

csr_ram_addr_width = 18
def get_csr_baseaddr(i):
   return i * (1 << csr_ram_addr_width)

ctrl_pc_width   = 9
main_pc_width   = 9


class CSR_CtrlRam(Ram):
   def __init__(self):
      fields = OrderedDict([
         ('ctrl_op',    Field(width=1, derived=False)),
         ('iter_inf',   Field(width=1, derived=False)),
         ('iter_num',   Field(width=8, derived=False)),
         ('start_pc',   Field(width=9, derived=True)),
         ('end_pc',     Field(width=9, derived=True))
      ])

      super().__init__(fields, capacity=1 << ctrl_pc_width, csr_baseaddr=get_csr_baseaddr(0x1B), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['start_pc'].val = child_pcs[0][0]
      instr.fields['end_pc'].val   = child_pcs[0][1]


class CSR_MainRam(Ram):
   def __init__(self, num_drivers=1, num_channels=1, pwm_width=1, timer_width=1):
      fields = OrderedDict([
         ('data',             Field(width=32,     derived=False)),
         ('addr',             Field(width=48,     derived=False)),
         ('opcode',           Field(width=8,      derived=False))
      ])

      super().__init__(fields, capacity=1 << main_pc_width, csr_baseaddr=get_csr_baseaddr(0x1C), csr_datawidth=csr_datawidth)

