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



import copy
import math
import numbers
import os
import pprint
import sys

from .rams import *
from ..util.compiler_backend import Command
from ..util.compiler_backend import Driver
from ....util.math import *

'''
try:
   # Some modules are not shipped with quartus_py yet :(
   # So for internal use, use internally available Python modules
   # Need to manually update this path to closely match quartus_py's version
   if os.path.isdir('/p/psg/ctools/python/3.7.9/6/linux64/suse12/lib/python3.7/site-packages'):
      sys.path.append('/p/psg/ctools/python/3.7.9/6/linux64/suse12/lib/python3.7/site-packages')
   if os.path.isdir(f"{os.environ['QUARTUS_ROOTDIR']}/common/python/lib"):
      sys.path.append(f"{os.environ['QUARTUS_ROOTDIR']}/common/python/lib")

   import networkx as nx
   import matplotlib.pyplot as plt
except ImportError:
   nx = None
   plt = None
'''

class CsrAxi4lDriver(Driver):

   OPCODE_READ       = 0
   OPCODE_READ_CHECK = 1
   OPCODE_WRITE      = 2

   def __init__(self, driver_idx, ip_config):
      super().__init__(driver_idx)

      params = ip_config['parameters']

      num_drivers = int(params['NUM_DRIVERS']['value'])

      self.bindir = f'driver{driver_idx}_csr_axi4l'

 
      self.csr__ctrl_ram = CSR_CtrlRam()
      self.csr__main_ram = CSR_MainRam()

   @classmethod
   def read_cmd(cls, araddr, rdata=None):
      if rdata is None:
         return Command(driver=cls, metadata=["READ", araddr, 0x0])
      else:
         return Command(driver=cls, metadata=["READ_CHECK", araddr, rdata])

   @classmethod
   def write_cmd(cls, awaddr, wdata=0):
      return Command(driver=cls, metadata=["WRITE", awaddr, wdata])
      
   def compile(self):
      prog = copy.deepcopy(self.prog)

      graph = {}
      graph_heads = []

      main_instrs = []
      for cmd in prog:
         opcode_string, addr, data = cmd.metadata[0], cmd.metadata[1], cmd.metadata[2]
         if opcode_string == "READ":
            main_instrs.append(self.csr__main_ram.gen_instr(opcode=self.OPCODE_READ, addr=addr, data=data))
         elif opcode_string == "READ_CHECK":
            main_instrs.append(self.csr__main_ram.gen_instr(opcode=self.OPCODE_READ_CHECK, addr=addr, data=data))
         elif opcode_string == "WRITE":
            main_instrs.append(self.csr__main_ram.gen_instr(opcode=self.OPCODE_WRITE, addr=addr, data=data))
         else:
            raise ValueError(f'Error: Unknown command op={opcode_string}')

      ctrl_instr = self.csr__ctrl_ram.gen_instr(ctrl_op=1, iter_inf=0, iter_num=0)
      graph[ctrl_instr] = [main_instrs]
      graph_heads.append(ctrl_instr)

      ctrl_eof_instr = self.csr__ctrl_ram.gen_instr(ctrl_op=0, iter_inf=1, iter_num=10)
      main_eof_instr = self.csr__main_ram.gen_instr(opcode=0, addr=0, data=0)
      graph[ctrl_eof_instr] = [[main_eof_instr]]
      graph_heads.append(ctrl_eof_instr)

      super().compile(graph, graph_heads)
