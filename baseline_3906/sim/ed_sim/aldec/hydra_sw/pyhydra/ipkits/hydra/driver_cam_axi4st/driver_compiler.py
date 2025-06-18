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


class CamAxi4stDriver(Driver):


   OPCODE_ADDR_ALU_ECHO = 1
   OPCODE_ADDR_ALU_INCR = 2
   OPCODE_ADDR_ALU_RAND = 3

   OPCODE_DQ_ALU_ECHO   = 1
   OPCODE_DQ_ALU_INVERT = 2
   OPCODE_DQ_ALU_ROTATE = 3
   OPCODE_DQ_ALU_PRBS7  = 4
   OPCODE_DQ_ALU_PRBS15 = 5
   OPCODE_DQ_ALU_PRBS23 = 6
   OPCODE_DQ_ALU_PRBS31 = 7

   OPCODE_DATA_EQ_RAW   = 0
   OPCODE_DATA_EQ_DQ    = 1
   OPCODE_DATA_EQ_ADDR  = 2
   OPCODE_DATA_EQ_ID    = 3

   OPCODE_STRB_EQ_RAW   = 0
   OPCODE_STRB_EQ_DM    = 1


   def __init__(self, driver_idx, ip_config):
      super().__init__(driver_idx)


      params = ip_config['parameters']

      num_drivers          = int(params['NUM_DRIVERS']['value'])

      self.num_dq_alus     = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_NUM_DQ_ALUS']['value'])
      self.num_dm_alus     = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_NUM_DM_ALUS']['value'])

      awid_width           = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_AWID_WIDTH']['value'])
      awaddr_width         = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_AWADDR_WIDTH']['value'])
      use_awlock           = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_AWLOCK']['value'].lower() == "true"
      use_awcache          = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_AWCACHE']['value'].lower() == "true"
      use_awprot           = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_AWPROT']['value'].lower() == "true"
      use_awqos            = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_AWQOS']['value'].lower() == "true"
      use_awregion         = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_AWREGION']['value'].lower() == "true"
      use_awuser           = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_AWUSER']['value'].lower() == "true"
      awuser_width         = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_AWUSER_WIDTH']['value'])

      arid_width           = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_ARID_WIDTH']['value'])
      araddr_width         = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_ARADDR_WIDTH']['value'])
      use_arlock           = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_ARLOCK']['value'].lower() == "true"
      use_arcache          = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_ARCACHE']['value'].lower() == "true"
      use_arprot           = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_ARPROT']['value'].lower() == "true"
      use_arqos            = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_ARQOS']['value'].lower() == "true"
      use_arregion         = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_ARREGION']['value'].lower() == "true"
      use_aruser           = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_ARUSER']['value'].lower() == "true"
      aruser_width         = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_ARUSER_WIDTH']['value'])

      wdata_width          = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_WDATA_WIDTH']['value'])
      rdata_width          = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_RDATA_WIDTH']['value'])

      use_buser            = params[f'DRIVER_{driver_idx}_MEM_AXI4_USE_BUSER']['value'].lower() == "true"
      buser_width          = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_BUSER_WIDTH']['value'])

      self.data_dq_ratio   = int(params[f'DRIVER_{driver_idx}_MEM_AXI4_DATA_DQ_RATIO']['value'])

      awaddr_offset_width  = 16
      araddr_offset_width  = 16

      pwm_width = 3

      self.num_wr_ids = 2 ** awid_width
      self.num_rd_ids = 2 ** arid_width

      awaddr_align_width = math.ceil(math.log2( math.ceil(math.log2(128 * 256)) ))
      araddr_align_width = awaddr_align_width

      self.bindir = f'driver{driver_idx}_mem_axi4'


      self.cmd_graph = {}
      self.rsp_graph = {}

      self.cmd_heads    = []
      self.wr_rsp_heads = []
      self.rd_rsp_heads = []


      self.aw_w__ctrl_ram     = AW_W_CtrlRam()
      self.aw_w__main_ram     = AW_W_MainRam()
      self.aw_w__issue_ram    = AW_W_IssueRam(awid_width)
      self.aw_w__worker_ram   = AW_W_WorkerRam(awaddr_width, awaddr_offset_width, awaddr_align_width,
                                               use_awlock, use_awcache, use_awprot, use_awqos, use_awregion, use_awuser, awuser_width,
                                               self.num_dq_alus, self.num_dm_alus)
      self.aw_w__addr_alu_ram = AW_W_AddrAluRam()
      self.aw_w__dq_alu_ram   = AW_W_DqAluRam(self.num_dq_alus)
      self.aw_w__dm_alu_ram   = AW_W_DmAluRam(self.num_dm_alus)

      self.ar__ctrl_ram       = AR_CtrlRam()
      self.ar__main_ram       = AR_MainRam()
      self.ar__issue_ram      = AR_IssueRam(arid_width)
      self.ar__worker_ram     = AR_WorkerRam(araddr_width, araddr_offset_width, araddr_align_width, 
                                             use_arlock, use_arcache, use_arprot, use_arqos, use_arregion, use_aruser, aruser_width)
      self.ar__addr_alu_ram   = AR_AddrAluRam()

      self.b__head_ram        = B_HeadRam(awid_width)
      self.b__ctrl_iter_ram   = B_CtrlIterRam(self.rsp_graph)
      self.b__ctrl_ram        = B_CtrlRam()
      self.b__worker_iter_ram = B_WorkerIterRam(self.rsp_graph)
      self.b__worker_ram      = B_WorkerRam(awaddr_width, awaddr_offset_width, awaddr_align_width, pwm_width)
      self.b__addr_alu_ram    = B_AddrAluRam()

      self.r__head_ram        = R_HeadRam(arid_width)
      self.r__ctrl_iter_ram   = R_CtrlIterRam(self.rsp_graph)
      self.r__ctrl_ram        = R_CtrlRam()
      self.r__worker_iter_ram = R_WorkerIterRam(self.rsp_graph)
      self.r__worker_ram      = R_WorkerRam(araddr_width, araddr_offset_width, araddr_align_width, pwm_width, self.num_dq_alus, self.num_dm_alus)
      self.r__addr_alu_ram    = R_AddrAluRam()
      self.r__dq_alu_ram      = R_DqAluRam(self.num_dq_alus)
      self.r__dm_alu_ram      = R_DmAluRam(self.num_dm_alus)

      self.orch__ctrl_ram     = Orch_CtrlRam()
      self.orch__main_ram     = Orch_MainRam(num_drivers=num_drivers, num_channels=5, pwm_width=pwm_width, timer_width=8)

   @classmethod
   def dq_alu_echo_op(cls):
      op = {
         'op':      'dq_alu_op',
         'opcode':  cls.OPCODE_DQ_ALU_ECHO
      }
      return op

   @classmethod
   def dq_alu_invert_op(cls):
      op = {
         'op':      'dq_alu_op',
         'opcode':  cls.OPCODE_DQ_ALU_INVERT
      }
      return op

   @classmethod
   def dq_alu_rotate_op(cls):
      op = {
         'op':      'dq_alu_op',
         'opcode':  cls.OPCODE_DQ_ALU_ROTATE
      }
      return op

   @classmethod
   def dq_alu_prbs_op(cls, arg):
      if arg == 7:
         opcode = cls.OPCODE_DQ_ALU_PRBS7
      elif arg == 15:
         opcode = cls.OPCODE_DQ_ALU_PRBS15
      elif arg == 23:
         opcode = cls.OPCODE_DQ_ALU_PRBS23
      elif arg == 31:
         opcode = cls.OPCODE_DQ_ALU_PRBS31
      else:
         raise ValueError(f"dq_alu_prbs_op only supports PRBS-7, 15, 23, or 31. Got unsupported value {arg}.")

      op = {
         'op':      'dq_alu_op',
         'opcode':  opcode
      }
      return op

   @classmethod
   def data_eq_dq_op(cls, **kwargs):
      all_dq_start = []
      all_dq_alu   = []
      for i in range(len(kwargs)):
         if f'dq{i}_start' in kwargs:
            all_dq_start.append( kwargs[f'dq{i}_start'] )
            all_dq_alu.append( kwargs.get(f'dq{i}_alu', [cls.dq_alu_echo_op()]) )
         else:
            break

      start_resume = 0
      if all_dq_start.count(None) == len(all_dq_start):
         start_resume = 1
         all_dq_start = [0] * len(all_dq_start)
      elif all_dq_start.count(None) > 0:
         raise ValueError(f"dq_start across all the DQ generators cannot be a mix of None and non-None values: {all_dq_start}")

      alu_resume = 0
      if all_dq_alu.count(None) == len(all_dq_alu):
         alu_resume = 1
      elif all_dq_alu.count(None) > 0:
         raise ValueError(f"dq_alu across all the DQ generators cannot be a mix of None and non-None values: {all_dq_alu}")

      op = {
         'op':                'data_eq_dq_op',
         'opcode':            cls.OPCODE_DATA_EQ_DQ,
         'data_raw':          None,          
         'all_dq_start':      all_dq_start,
         'dq_start_resume':   start_resume,
         'all_dq_alu':        all_dq_alu,
         'dq_alu_resume':     alu_resume
      }
      return op

   @classmethod
   def data_eq_raw_op(cls, val):
      op = {
         'op':                'data_eq_raw_op',
         'opcode':            cls.OPCODE_DATA_EQ_RAW,
         'data_raw':          val,
         'all_dq_start':      [ 0 ], 
         'dq_start_resume':   0,
         'all_dq_alu':        [ [cls.dq_alu_echo_op()] ], 
         'dq_alu_resume':     0
      }
      return op

   @classmethod
   def data_eq_addr_op(cls):
      op = {
         'op':                'data_eq_addr_op',
         'opcode':            cls.OPCODE_DATA_EQ_ADDR,
         'data_raw':          None,                       
         'all_dq_start':      [ 0 ],                      
         'dq_start_resume':   0,                          
         'all_dq_alu':        [ [cls.dq_alu_echo_op()] ], 
         'dq_alu_resume':     0                           
      }
      return op

   @classmethod
   def data_eq_id_op(cls):
      op = {
         'op':                'data_eq_id_op',
         'opcode':            cls.OPCODE_DATA_EQ_ID,
         'data_raw':          None,                       
         'all_dq_start':      [ 0 ],                      
         'dq_start_resume':   0,                          
         'all_dq_alu':        [ [cls.dq_alu_echo_op()] ], 
         'dq_alu_resume':     0                           
      }
      return op

   @classmethod
   def dm_alu_echo_op(cls):
      return cls.dq_alu_echo_op()

   @classmethod
   def dm_alu_invert_op(cls):
      return cls.dq_alu_invert_op()

   @classmethod
   def dm_alu_rotate_op(cls):
      return cls.dq_alu_rotate_op()

   @classmethod
   def dm_alu_prbs_op(cls, arg):
      return cls.dq_alu_prbs_op(arg)

   @classmethod
   def strb_eq_dm_op(cls, **kwargs):
      all_dm_start = []
      all_dm_alu   = []
      for i in range(len(kwargs)):
         if f'dm{i}_start' in kwargs:
            all_dm_start.append( kwargs[f'dm{i}_start'] )
            all_dm_alu.append( kwargs.get(f'dm{i}_alu', [cls.dm_alu_echo_op()]) )
         else:
            break

      start_resume = 0
      if all_dm_start.count(None) == len(all_dm_start):
         start_resume = 1
         all_dm_start = [0] * len(all_dm_start)
      elif all_dm_start.count(None) > 0:
         raise ValueError(f"dm_start across all the DM generators cannot be a mix of None and non-None values: {all_dm_start}")

      alu_resume = 0
      if all_dm_alu.count(None) == len(all_dm_alu):
         alu_resume = 1
      elif all_dm_alu.count(None) > 0:
         raise ValueError(f"dm_alu across all the DM generators cannot be a mix of None and non-None values: {all_dm_alu}")

      op = {
         'op':                'strb_eq_dm_op',
         'opcode':            cls.OPCODE_STRB_EQ_DM,
         'strb_raw':          None,          
         'all_dm_start':      all_dm_start,
         'dm_start_resume':   start_resume,
         'all_dm_alu':        all_dm_alu,
         'dm_alu_resume':     alu_resume
      }
      return op

   @classmethod
   def strb_eq_raw_op(cls, val):
      op = {
         'op':                'strb_eq_raw_op',
         'opcode':            cls.OPCODE_STRB_EQ_RAW,
         'strb_raw':          val,
         'all_dm_start':      [ 0 ], 
         'dm_start_resume':   0,
         'all_dm_alu':        [ [cls.dm_alu_echo_op()] ], 
         'dm_alu_resume':     0
      }
      return op

   @classmethod
   def addr_alu_echo_op(cls):
      op = {
         'op':      'addr_alu_op',
         'opcode':  cls.OPCODE_ADDR_ALU_ECHO,
         'field':   0,
         'arg':     0
      }
      return op

   @classmethod
   def addr_alu_incr_op(cls, *args, **kwargs):
      field, arg = 0, 0
      if len(args) == 1:
         arg, = args
      elif len(args) == 2:
         field, arg, = args
      else:
         field = kwargs.get('field', 0)
         arg   = kwargs.get('arg', 0)

      op = {
         'op':      'addr_alu_op',
         'opcode':  cls.OPCODE_ADDR_ALU_INCR,
         'field':   field,
         'arg':     arg
      }
      return op

   @classmethod
   def addr_alu_rand_op(cls, *args, **kwargs):
      field, arg = 0, 0
      if len(args) == 1:
         arg, = args
      elif len(args) == 2:
         field, arg, = args
      else:
         field = kwargs.get('field', 0)
         arg   = kwargs.get('arg', 0)

      lfsr_width = arg
      arg = (-1 >> lfsr_width) << lfsr_width

      op = {
         'op':      'addr_alu_op',
         'opcode':  cls.OPCODE_ADDR_ALU_RAND,
         'field':   field,
         'arg':     arg,
         'arg_orig':lfsr_width,
      }
      return op

   @classmethod
   def addr_op(cls, start, lo, hi, align, alu):
      resume = 1  if start is None else 0
      start  = lo if start is None else start

      assert start & ((2**align) - 1) == 0, f"align={align} requires start={hex(start)} to be aligned to {2**align} byte boundary, i.e. {align} LSBs should be 0"
      start >>= align
      lo    >>= align
      hi    >>= align
      if alu:
         for i, alu_op in enumerate(alu):
            if alu_op['opcode'] == cls.OPCODE_ADDR_ALU_INCR:
               assert alu_op['arg'] & ((2**align) - 1) == 0, f"align={align} requires incr(n={alu_op['arg']}) to be aligned to {2**align} byte boundary, i.e. {align} LSBs should be 0"
               alu[i] = cls.addr_alu_incr_op(field=alu_op['field'], arg=alu_op['arg'] >> align)
            elif alu_op['opcode'] == cls.OPCODE_ADDR_ALU_RAND:
               assert alu_op['arg_orig'] > align, f"align={align} requires rand(n={alu_op['arg_orig']}) > {align}"
               alu[i] = cls.addr_alu_rand_op(field=alu_op['field'], arg=alu_op['arg_orig'] - align)

      op = {
         'op':             'addr_op',
         'start':          start,
         'start_resume':   resume,
         'lo':             lo,
         'hi':             hi,
         'align':          align,
         'alu':            alu,
         'alu_resume':     1 if alu is None else 0
      }
      return op

   @classmethod
   def __worker_op(cls, axid, axlen, axsize, axburst, axlock, axcache, axprot, axqos, axregion, axuser, axaddr, xdata, xstrb, xresp):
      if isinstance(axaddr, numbers.Number):
         axaddr = cls.addr_op(start=axaddr, lo=0, hi=-1, align=0, alu=[cls.addr_alu_echo_op()])

      xdata_dontcare = 0
      if xdata is None:
         xdata_dontcare = 1
         xdata = cls.data_eq_raw_op(val=0) 
      elif isinstance(xdata, numbers.Number):
         xdata = cls.data_eq_raw_op(val=xdata)

      if isinstance(xstrb, numbers.Number):
         xstrb = cls.strb_eq_raw_op(val=xstrb)

      op = {
         'op':                   'worker_op',
         'axid':                 axid,
         'axlen':                axlen,
         'axsize':               axsize,
         'axburst':              axburst,
         'axlock':               axlock,
         'axcache':              axcache,
         'axprot':               axprot,
         'axqos':                axqos,
         'axregion':             axregion,
         'axuser':               axuser,

         'axaddr_min':           axaddr['lo'],
         'axaddr_max':           axaddr['hi'],
         'axaddr_offset':        axaddr['start'] - axaddr['lo'],
         'axaddr_offset_resume': axaddr['start_resume'],
         'axaddr_align':         axaddr['align'],
         'axaddr_alu':           axaddr['alu'],
         'axaddr_alu_resume':    axaddr['alu_resume'],

         'xdata_op':             xdata['opcode'],
         'data_raw':             xdata['data_raw'],
         'all_dq_start':         xdata['all_dq_start'],
         'dq_start_resume':      xdata['dq_start_resume'],
         'all_dq_alu':           xdata['all_dq_alu'],
         'dq_alu_resume':        xdata['dq_alu_resume'],

         'xstrb_op':             xstrb['opcode'],
         'strb_raw':             xstrb['strb_raw'],
         'all_dm_start':         xstrb['all_dm_start'],
         'dm_start_resume':      xstrb['dm_start_resume'],
         'all_dm_alu':           xstrb['all_dm_alu'],
         'dm_alu_resume':        xstrb['dm_alu_resume'],

         'xresp':                0 if xresp is None else xresp, 

         'xresp_dontcare':       1 if xresp is None else 0,
         'xdata_dontcare':       xdata_dontcare
      }
      return op

   @classmethod
   def write_worker_op(cls, awid, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awaddr, wdata, wstrb, bresp):
      return cls.__worker_op(axid=awid, axlen=awlen, axsize=awsize, axburst=awburst, axlock=awlock, axcache=awcache, axprot=awprot, axqos=awqos, axregion=awregion, axuser=awuser, axaddr=awaddr, xdata=wdata, xstrb=wstrb, xresp=bresp)

   @classmethod
   def read_worker_op(cls, arid, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, araddr, rdata, rstrb, rresp):
      return cls.__worker_op(axid=arid, axlen=arlen, axsize=arsize, axburst=arburst, axlock=arlock, axcache=arcache, axprot=arprot, axqos=arqos, axregion=arregion, axuser=aruser, axaddr=araddr, xdata=rdata, xstrb=rstrb, xresp=rresp)

   @classmethod
   def write_cmd(cls, iters, awvalid, wvalid, bready, awid, workers):
      return Command(driver=cls, metadata=["WRITE", [awvalid, wvalid, bready], iters, awid, workers])

   @classmethod
   def read_cmd(cls, iters, arvalid,          rready, arid, workers):
      return Command(driver=cls, metadata=["READ",  [arvalid,         rready], iters, arid, workers])

   def compile_read_write_cmd(self, cmd):
      read_or_write, pwm, iters, ids_orig, workers_orig, = cmd.metadata[:]

      assert read_or_write == "READ" or read_or_write == "WRITE", "Internal Error: Unknown command when attempting to compile read/write command"
      RW = 'R' if read_or_write == "READ" else 'W'

      workers = []
      ids     = ids_orig[:iters] if iters < len(ids_orig) else ids_orig[:]
      for w in workers_orig:
         if w['axid'] in ids:
            if w['axid'] in workers:
               raise ValueError(f'Workers must have unique IDs, but found multiple workers for A{RW}ID={w["axid"]}')
            workers.append(w)

      for w in workers:
         num_user_dq_alus = len(w['all_dq_start'])
         for dq in range(num_user_dq_alus, self.num_dq_alus):
            w['all_dq_start'].append( w['all_dq_start'][dq % num_user_dq_alus] )
            w['all_dq_alu'].append( w['all_dq_alu'][dq % num_user_dq_alus] )

         num_user_dm_alus = len(w['all_dm_start'])
         for dm in range(num_user_dm_alus, self.num_dm_alus):
            w['all_dm_start'].append( w['all_dm_start'][dm % num_user_dm_alus] )
            w['all_dm_alu'].append( w['all_dm_alu'][dm % num_user_dm_alus] )

         if w['xdata_op'] == self.OPCODE_DATA_EQ_RAW:
            val      = w['data_raw']
            bitwidth = self.aw_w__worker_ram.fields['dq0_start'].width
            mask     = (1 << bitwidth) - 1
            all_dq_start = []
            for _ in range(self.num_dq_alus):
               all_dq_start.append(val & mask)
               val = val >> bitwidth
            w['all_dq_start'] = all_dq_start


         if w['xstrb_op'] == self.OPCODE_STRB_EQ_RAW:
            val      = w['strb_raw']
            bitwidth = self.aw_w__worker_ram.fields['dm0_start'].width
            mask     = (1 << bitwidth) - 1
            all_dm_start = []
            for _ in range(self.num_dm_alus):
               all_dm_start.append(val & mask)
               val = val >> bitwidth
            w['all_dm_start'] = all_dm_start

      def get_worker_instr_dq_fields(w):
         dq_kwargs = {f'dq{dq}_start': w['all_dq_start'][dq] for dq in range(self.num_dq_alus)}
         return dq_kwargs

      def get_worker_instr_dm_fields(w):
         dm_kwargs = {f'dm{dm}_start': w['all_dm_start'][dm] for dm in range(self.num_dm_alus)}
         return dm_kwargs

      def get_alu_instr_dq_fields(w):
         num_alu_ops = lcm([len(w['all_dq_alu'][dq]) for dq in range(self.num_dq_alus)])
         for dq_alu in w['all_dq_alu']:
            dq_alu *= num_alu_ops // len(dq_alu)

         dq_kwargs_list = [ {f'dq{dq}_op': w['all_dq_alu'][dq][op]['opcode'] for dq in range(self.num_dq_alus)} for op in range(num_alu_ops) ]
         return dq_kwargs_list

      def get_alu_instr_dm_fields(w):
         num_alu_ops = lcm([len(w['all_dm_alu'][dm]) for dm in range(self.num_dm_alus)])
         for dm_alu in w['all_dm_alu']:
            dm_alu *= num_alu_ops // len(dm_alu)

         dm_kwargs_list = [ {f'dm{dm}_op': w['all_dm_alu'][dm][op]['opcode'] for dm in range(self.num_dm_alus)} for op in range(num_alu_ops) ]
         return dm_kwargs_list



      def gen_write_cmd_instrs():
         main_instr = self.aw_w__main_ram.gen_instr(worker_iters=iters-1)

         issue_instrs = []
         for i, id in enumerate(ids):
            is_first_id = id not in ids[:i]
            issue_instrs.append(self.aw_w__issue_ram.gen_instr(is_first_id=is_first_id, id=id))

         worker_instrs = []
         for w in workers:
            dq_kwargs = get_worker_instr_dq_fields(w)
            dm_kwargs = get_worker_instr_dm_fields(w)
            worker_instrs.append(self.aw_w__worker_ram.gen_instr(awlen=w['axlen'], awsize=w['axsize'], awburst=w['axburst'], awlock=w['axlock'], awcache=w['axcache'], awprot=w['axprot'], awqos=w['axqos'], awregion=w['axregion'], awuser=w['axuser'],
                                                                 awaddr_alu_resume=w['axaddr_alu_resume'], awaddr_min=w['axaddr_min'], awaddr_max=w['axaddr_max'], awaddr_offset=w['axaddr_offset'], awaddr_offset_resume=w['axaddr_offset_resume'], awaddr_align=w['axaddr_align'],
                                                                 wdata_op=w['xdata_op'], dq_alu_resume=w['dq_alu_resume'], dq_start_resume=w['dq_start_resume'], **dq_kwargs, wstrb_op=w['xstrb_op'], dm_alu_resume=w['dm_alu_resume'], dm_start_resume=w['dm_start_resume'], **dm_kwargs))

         addr_alu_instrs = []
         for w in workers:
            worker_addr_alu_instrs = []
            for a in w['axaddr_alu']:
               worker_addr_alu_instrs.append(self.aw_w__addr_alu_ram.gen_instr(op=a['opcode'], field=a['field'], arg=a['arg']))
            addr_alu_instrs.append(worker_addr_alu_instrs)

         dq_alu_instrs = []
         for w in workers:
            worker_dq_alu_instrs = []
            for dq_kwargs in get_alu_instr_dq_fields(w):
               worker_dq_alu_instrs.append(self.aw_w__dq_alu_ram.gen_instr(**dq_kwargs))
            dq_alu_instrs.append(worker_dq_alu_instrs)

         dm_alu_instrs = []
         for w in workers:
            worker_dm_alu_instrs = []
            for dm_kwargs in get_alu_instr_dm_fields(w):
               worker_dm_alu_instrs.append(self.aw_w__dm_alu_ram.gen_instr(**dm_kwargs))
            dm_alu_instrs.append(worker_dm_alu_instrs)

         return main_instr, issue_instrs, worker_instrs, addr_alu_instrs, dq_alu_instrs, dm_alu_instrs

      def gen_read_cmd_instrs():
         main_instr = self.ar__main_ram.gen_instr(worker_iters=iters-1)

         issue_instrs = []
         for i, id in enumerate(ids):
            is_first_id = id not in ids[:i]
            issue_instrs.append(self.ar__issue_ram.gen_instr(is_first_id=is_first_id, id=id))

         worker_instrs = []
         for w in workers:
            worker_instrs.append(self.ar__worker_ram.gen_instr(arlen=w['axlen'], arsize=w['axsize'], arburst=w['axburst'], arlock=w['axlock'], arcache=w['axcache'], arprot=w['axprot'], arqos=w['axqos'], arregion=w['axregion'], aruser=w['axuser'],
                                                               araddr_alu_resume=w['axaddr_alu_resume'], araddr_min=w['axaddr_min'], araddr_max=w['axaddr_max'], araddr_offset=w['axaddr_offset'], araddr_offset_resume=w['axaddr_offset_resume'], araddr_align=w['axaddr_align']))

         addr_alu_instrs = []
         for w in workers:
            worker_addr_alu_instrs = []
            for a in w['axaddr_alu']:
               worker_addr_alu_instrs.append(self.ar__addr_alu_ram.gen_instr(op=a['opcode'], field=a['field'], arg=a['arg']))
            addr_alu_instrs.append(worker_addr_alu_instrs)

         dq_alu_instrs = []
         for w in workers:
            worker_dq_alu_instrs = []
            dq_alu_instrs.append(worker_dq_alu_instrs)

         dm_alu_instrs = []
         for w in workers:
            worker_dm_alu_instrs = []
            dm_alu_instrs.append(worker_dm_alu_instrs)

         return main_instr, issue_instrs, worker_instrs, addr_alu_instrs, dq_alu_instrs, dm_alu_instrs

      if read_or_write == "READ":
         main_instr, issue_instrs, worker_instrs, addr_alu_instrs, dq_alu_instrs, dm_alu_instrs, = gen_read_cmd_instrs()
      else:
         main_instr, issue_instrs, worker_instrs, addr_alu_instrs, dq_alu_instrs, dm_alu_instrs, = gen_write_cmd_instrs()


      self.cmd_graph[main_instr] = [ issue_instrs ]
      for issue_id, issue_instr in zip(ids, issue_instrs):
         for w, worker_instr in zip(workers, worker_instrs):
            worker_id = w['axid']
            if worker_id == issue_id:
               self.cmd_graph[issue_instr] = [ [worker_instr] ]
               break
         if issue_instr not in self.cmd_graph:
            raise IndexError(f'Missing worker op for A{RW}ID={issue_id}')
      for worker_instr, worker_addr_alu_instrs, worker_dq_alu_instrs, worker_dm_alu_instrs in zip(worker_instrs, addr_alu_instrs, dq_alu_instrs, dm_alu_instrs):
         if read_or_write == "READ":
            self.cmd_graph[worker_instr] = [ worker_addr_alu_instrs ]
         else:
            self.cmd_graph[worker_instr] = [ worker_addr_alu_instrs, worker_dq_alu_instrs, worker_dm_alu_instrs ]


      cmd_head_instr = main_instr


      if read_or_write == "READ":
         rsp_head_instrs = [None for _ in range(self.num_rd_ids)]
      else:
         rsp_head_instrs = [None for _ in range(self.num_wr_ids)]

      for w in workers:


         id = w['axid']

         worker_iters = ids.count(id) * (iters // len(ids)) + ids[ : iters % len(ids)].count(id)

         def gen_write_rsp_instrs():
            b_pwm_on, b_pwm_tot = pwm[2][0]-1, pwm[2][1]-1     

            worker_iter_instr = self.b__worker_iter_ram.gen_instr(iters_unroll0=worker_iters-1)
            worker_instr      = self.b__worker_ram.gen_instr(awlen=w['axlen'], awsize=w['axsize'], awburst=w['axburst'],
                                                             awaddr_alu_resume=w['axaddr_alu_resume'], awaddr_min=w['axaddr_min'], awaddr_max=w['axaddr_max'], awaddr_offset=w['axaddr_offset'], awaddr_offset_resume=w['axaddr_offset_resume'], awaddr_align=w['axaddr_align'],
                                                             bresp=w['xresp'], bresp_dontcare=w['xresp_dontcare'],
                                                             b_pwm_on=b_pwm_on, b_pwm_tot=b_pwm_tot)

            worker_addr_alu_instrs = []
            for a in w['axaddr_alu']:
               worker_addr_alu_instrs.append(self.b__addr_alu_ram.gen_instr(op=a['opcode'], field=a['field'], arg=a['arg']))

            worker_dq_alu_instrs = []

            worker_dm_alu_instrs = []

            return worker_iter_instr, worker_instr, worker_addr_alu_instrs, worker_dq_alu_instrs, worker_dm_alu_instrs

         def gen_read_rsp_instrs():
            r_pwm_on, r_pwm_tot = pwm[1][0]-1, pwm[1][1]-1     

            dq_kwargs = get_worker_instr_dq_fields(w)
            dm_kwargs = get_worker_instr_dm_fields(w)
            worker_iter_instr = self.r__worker_iter_ram.gen_instr(iters_unroll0=worker_iters-1)
            worker_instr      = self.r__worker_ram.gen_instr(arlen=w['axlen'], arsize=w['axsize'], arburst=w['axburst'],
                                                             araddr_alu_resume=w['axaddr_alu_resume'], araddr_min=w['axaddr_min'], araddr_max=w['axaddr_max'], araddr_offset=w['axaddr_offset'], araddr_offset_resume=w['axaddr_offset_resume'], araddr_align=w['axaddr_align'],
                                                             rdata_op=w['xdata_op'], dq_alu_resume=w['dq_alu_resume'], dq_start_resume=w['dq_start_resume'], **dq_kwargs, rstrb_op=w['xstrb_op'], dm_alu_resume=w['dm_alu_resume'], dm_start_resume=w['dm_start_resume'], **dm_kwargs, rresp=w['xresp'], rresp_dontcare=w['xresp_dontcare'], rdata_dontcare=w['xdata_dontcare'],
                                                             r_pwm_on=r_pwm_on, r_pwm_tot=r_pwm_tot)

            worker_addr_alu_instrs = []
            for a in w['axaddr_alu']:
               worker_addr_alu_instrs.append(self.r__addr_alu_ram.gen_instr(op=a['opcode'], field=a['field'], arg=a['arg']))

            worker_dq_alu_instrs = []
            for dq_kwargs in get_alu_instr_dq_fields(w):
               worker_dq_alu_instrs.append(self.r__dq_alu_ram.gen_instr(**dq_kwargs))

            worker_dm_alu_instrs = []
            for dm_kwargs in get_alu_instr_dm_fields(w):
               worker_dm_alu_instrs.append(self.r__dm_alu_ram.gen_instr(**dm_kwargs))

            return worker_iter_instr, worker_instr, worker_addr_alu_instrs, worker_dq_alu_instrs, worker_dm_alu_instrs

         if read_or_write == "READ":
            worker_iter_instr, worker_instr, worker_addr_alu_instrs, worker_dq_alu_instrs, worker_dm_alu_instrs, = gen_read_rsp_instrs()
         else:
            worker_iter_instr, worker_instr, worker_addr_alu_instrs, worker_dq_alu_instrs, worker_dm_alu_instrs, = gen_write_rsp_instrs()


         self.rsp_graph[worker_iter_instr] = [[worker_instr]]
         if read_or_write == "READ":
            self.rsp_graph[worker_instr] = [ worker_addr_alu_instrs, worker_dq_alu_instrs, worker_dm_alu_instrs ]
         else:
            self.rsp_graph[worker_instr] = [ worker_addr_alu_instrs ]


         rsp_head_instrs[id] = worker_iter_instr

      return cmd_head_instr, rsp_head_instrs

   @classmethod
   def wait_writes_cmd(cls):
      return Command(driver=cls, metadata=["WAIT_WRITES"])

   @classmethod
   def wait_reads_cmd(cls):
      return Command(driver=cls, metadata=["WAIT_READS"])

   @classmethod
   def sleep_cmd(cls, cycles):
      return Command(driver=cls, metadata=["SLEEP", cycles])

   @classmethod
   def driver_post_cmd(cls, *args):
      drivers = args[0] if isinstance(args[0], list) else args
      driver_ids = [driver.driver_idx if isinstance(driver, Driver) else driver for driver in drivers]
      assert all(isinstance(i, int) for i in driver_ids), f"Found non-integer in driver_post_cmd({driver_ids}), only Driver objects or driver indices are allowed"
      return Command(driver=cls, metadata=["POST", driver_ids])

   @classmethod
   def driver_wait_cmd(cls, *args):
      drivers = args[0] if isinstance(args[0], list) else args
      driver_ids = [driver.driver_idx if isinstance(driver, Driver) else driver for driver in drivers]
      assert all(isinstance(i, int) for i in driver_ids), f"Found non-integer in driver_wait_cmd({driver_ids}), only Driver objects or driver indices are allowed"
      return Command(driver=cls, metadata=["WAIT", driver_ids])

   @classmethod
   def parallel_cmd(cls, cmds):
      return Command(driver=cls, metadata=["PARALLEL", cmds])

   def compile_parallel_cmd(self, cmd):
      inner_cmds, = cmd.metadata[1:]

      timer_num             = 0
      driver_post_mask      = 0
      driver_wait_mask      = 0
      channel_mask          = 0b00000
      aw_pwm_on, aw_pwm_tot = 0, 0
      w_pwm_on,  w_pwm_tot  = 0, 0
      ar_pwm_on, ar_pwm_tot = 0, 0
      write_cmd_head_instr  = None
      write_rsp_head_instrs = [None] * self.num_wr_ids
      read_cmd_head_instr   = None
      read_rsp_head_instrs  = [None] * self.num_rd_ids

      for inner_cmd in inner_cmds:
         op = inner_cmd.metadata[0]

         if op == "WRITE":
            assert write_cmd_head_instr is None, "Multiple write commands in a single parallel block is not allowed"
            pwm = inner_cmd.metadata[1]
            aw_pwm_on, aw_pwm_tot, w_pwm_on, w_pwm_tot = pwm[0][0]-1, pwm[0][1]-1, pwm[1][0]-1, pwm[1][1]-1
            channel_mask |= 0b00011
            write_cmd_head_instr, write_rsp_head_instrs, = self.compile_read_write_cmd(inner_cmd)

         elif op == "READ":
            assert read_cmd_head_instr is None, "Multiple read commands in a single parallel block is not allowed"
            pwm = inner_cmd.metadata[1]
            ar_pwm_on, ar_pwm_tot = pwm[0][0]-1, pwm[0][1]-1
            channel_mask |= 0b00100
            read_cmd_head_instr, read_rsp_head_instrs, = self.compile_read_write_cmd(inner_cmd)

         elif op == "WAIT_WRITES":
            channel_mask |= 0b01000

         elif op == "WAIT_READS":
            channel_mask |= 0b10000

         elif op == "SLEEP":
            cycles = inner_cmd.metadata[1]
            timer_num = cycles-1

         elif op == "POST":
            driver_ids = inner_cmd.metadata[1]
            assert self.driver_idx not in driver_ids, f"Driver (driver_index={self.driver_idx}) cannot issue driver_post_cmd() to itself"
            for driver_id in driver_ids:
               driver_post_mask |= 1 << driver_id

         elif op == "WAIT":
            driver_ids = inner_cmd.metadata[1]
            assert self.driver_idx not in driver_ids, f"Driver (driver_index={self.driver_idx}) cannot issue driver_wait_cmd() to itself"
            for driver_id in driver_ids:
               driver_wait_mask |= 1 << driver_id

         else:
            raise ValueError(f'Error: Unknown command op={op}')

      orch_instr = self.orch__main_ram.gen_instr(timer_num=timer_num, driver_post_mask=driver_post_mask, driver_wait_mask=driver_wait_mask, channel_mask=channel_mask,
                                                 aw_pwm_on=aw_pwm_on, aw_pwm_tot=aw_pwm_tot, w_pwm_on=w_pwm_on, w_pwm_tot=w_pwm_tot, ar_pwm_on=ar_pwm_on, ar_pwm_tot=ar_pwm_tot)

      return orch_instr, write_cmd_head_instr, write_rsp_head_instrs, read_cmd_head_instr, read_rsp_head_instrs

   @classmethod
   def loop_cmd(cls, iters, cmds):
      return Command(driver=cls, metadata=["LOOP", iters, cmds])

   def compile_loop_cmd(self, cmd):
      iters, inner_cmds, = cmd.metadata[1:]

      orch_head_instr_list       = []
      write_cmd_head_instr_list  = []
      write_rsp_head_instrs_list = []
      read_cmd_head_instr_list   = []
      read_rsp_head_instrs_list  = []

      for inner_cmd in inner_cmds:
         assert inner_cmd.metadata[0] == "PARALLEL", "Program was not correctly annotated with parallel commands"
         orch_head_instr, write_cmd_head_instr, write_rsp_head_instrs, read_cmd_head_instr, read_rsp_head_instrs, = self.compile_parallel_cmd(inner_cmd)
         orch_head_instr_list       += [orch_head_instr]       if orch_head_instr      is not None else []
         write_cmd_head_instr_list  += [write_cmd_head_instr]  if write_cmd_head_instr is not None else []
         write_rsp_head_instrs_list += [write_rsp_head_instrs] if any(instr is not None for instr in write_rsp_head_instrs) else []
         read_cmd_head_instr_list   += [read_cmd_head_instr]   if read_cmd_head_instr  is not None else []
         read_rsp_head_instrs_list  += [read_rsp_head_instrs]  if any(instr is not None for instr in read_rsp_head_instrs)  else []


      def gen_loop_instr(ax__ctrl_ram, x__ctrl_iter_ram, x__ctrl_ram, rsp_heads, cmd_head_instr_list, rsp_head_instrs_list):         
         if cmd_head_instr_list:
            ctrl_instr = ax__ctrl_ram.gen_instr(ctrl_op=1, iter_inf=iters==0, iter_num=iters-2)  
            self.cmd_graph[ctrl_instr] = [ cmd_head_instr_list ]
            self.cmd_heads.append(ctrl_instr)

         if rsp_heads:
            for id in range(len(rsp_heads)):
               rsp_head_instrs_for_this_id = []
               for rsp_head_instrs in rsp_head_instrs_list:
                  if rsp_head_instrs[id] is not None:
                     rsp_head_instrs_for_this_id.append(rsp_head_instrs[id])
               if len(rsp_head_instrs_for_this_id) > 0:
                  resp_iters = sum(instr.fields['iters_unroll0'].val + 1 for instr in rsp_head_instrs_for_this_id)
                  ctrl_iter_instr = x__ctrl_iter_ram.gen_instr(iters_unroll0=iters*resp_iters-1) 
                  ctrl_instr      = x__ctrl_ram.gen_instr()
                  if rsp_heads[id] not in self.rsp_graph:
                     self.rsp_graph[ rsp_heads[id] ] = [[]]
                  self.rsp_graph[ rsp_heads[id] ][0].append( ctrl_iter_instr )
                  self.rsp_graph[ctrl_iter_instr] = [[ctrl_instr]]
                  self.rsp_graph[ctrl_instr] = [ rsp_head_instrs_for_this_id ]

      gen_loop_instr(self.aw_w__ctrl_ram, self.b__ctrl_iter_ram, self.b__ctrl_ram, self.wr_rsp_heads, write_cmd_head_instr_list, write_rsp_head_instrs_list)
      gen_loop_instr(self.ar__ctrl_ram,   self.r__ctrl_iter_ram, self.r__ctrl_ram, self.rd_rsp_heads, read_cmd_head_instr_list,  read_rsp_head_instrs_list)
      gen_loop_instr(self.orch__ctrl_ram, None,                  None,             None,              orch_head_instr_list,      None)

   def compile(self):
      prog = copy.deepcopy(self.prog)


      def parallelify(cmd):
         if cmd.metadata[0] == "PARALLEL":
            return cmd
         new_cmd = self.parallel_cmd([cmd])
         return new_cmd

      for i, cmd in enumerate(prog):
         if cmd.metadata[0] == "LOOP":
            for j, cmd_inner in enumerate(cmd.metadata[2]):
               cmd.metadata[2][j] = parallelify(cmd_inner)
         else:
            prog[i] = parallelify(cmd)

      def loopify(cmds):
         new_cmd = self.loop_cmd(1, cmds)
         return new_cmd

      i = 0
      new_prog = []
      while i < len(prog):
         new_loop = []
         while i < len(prog) and prog[i].metadata[0] != "LOOP":
            new_loop.append(prog[i])
            i += 1
         if len(new_loop) > 0:
            new_prog.append(loopify(new_loop))
         else:
            assert prog[i].metadata[0] == "LOOP", "Failed to loopify the program"
            new_prog.append(prog[i])
            i += 1

      prog = new_prog


      prev_worker_write_cmd = [None] * self.num_wr_ids
      prev_worker_read_cmd  = [None] * self.num_rd_ids
      for cmd in prog:
         assert cmd.metadata[0] == "LOOP"
         iters, inner_cmds, = cmd.metadata[1:]
         for inner_cmd in inner_cmds:
            assert inner_cmd.metadata[0] == "PARALLEL"
            inner_pcmds, = inner_cmd.metadata[1:]
            for inner_pcmd in inner_pcmds:
               if inner_pcmd.metadata[0] == "WRITE" or inner_pcmd.metadata[0] == "READ":
                  prev_worker_cmd = prev_worker_write_cmd if inner_pcmd.metadata[0] == "WRITE" else prev_worker_read_cmd
                  RW              = 'W'                   if inner_pcmd.metadata[0] == "WRITE" else 'R'
                  read_or_write, pwm, iters, ids, workers, = inner_pcmd.metadata[:]
                  for w in workers:
                     axid = w['axid']
                     if w['axaddr_offset_resume']:
                        if prev_worker_cmd[axid]:
                           assert prev_worker_cmd[axid]['axaddr_align'] == w['axaddr_align'], f"A{RW}ADDR 'start' resume requires 'align' to be unchanged, for A{RW}ID={axid} align={w['axaddr_align']} but previous command's align={prev_worker_cmd[axid]['axaddr_align']}"

                     if w['axaddr_alu_resume']:
                        assert prev_worker_cmd[axid] is not None, f"A{RW}ADDR 'alu' resume requires at least one preceeding command without ALU resume, for A{RW}ID={axid}"
                        assert prev_worker_cmd[axid]['axaddr_align'] == w['axaddr_align'], f"A{RW}ADDR 'start' resume requires 'align' to be unchanged, for A{RW}ID={axid} align={w['axaddr_align']} but previous command's align={prev_worker_cmd[axid]['axaddr_align']}"
                        w['axaddr_alu'] = prev_worker_cmd[axid]['axaddr_alu']

                     if w['dq_alu_resume']:
                        assert prev_worker_cmd[axid] is not None, f"DQ 'alu' resume requires at least one preceeding command without ALU resume, for A{RW}ID={axid}"
                        w['all_dq_alu'] = prev_worker_cmd[axid]['all_dq_alu']

                     if w['dm_alu_resume']:
                        assert prev_worker_cmd[axid] is not None, f"DM 'alu' resume requires at least one preceeding command without ALU resume, for A{RW}ID={axid}"
                        w['all_dm_alu'] = prev_worker_cmd[axid]['all_dm_alu']

                     prev_worker_cmd[axid] = w



      self.cmd_graph.clear()
      self.rsp_graph.clear()
      del self.cmd_heads[:]
      del self.wr_rsp_heads[:]
      del self.rd_rsp_heads[:]

      for id in range(self.num_wr_ids):
         head_instr = self.b__head_ram.gen_instr()
         self.wr_rsp_heads.append(head_instr)
      for id in range(self.num_rd_ids):
         head_instr = self.r__head_ram.gen_instr()
         self.rd_rsp_heads.append(head_instr)

      for cmd in prog:
         assert isinstance(self, cmd.driver), f'Error: commands for {cmd.driver} cannot be compiled by {self}'
         assert cmd.metadata[0] == "LOOP", 'Program was not correctly annotated with loop commands'
         self.compile_loop_cmd(cmd)

      def gen_eof_instr(ax__ctrl_ram, ax__main_ram):
         ctrl_instr = ax__ctrl_ram.gen_instr(ctrl_op=0, iter_inf=1, iter_num=10) 
         if ax__main_ram is self.orch__main_ram:
            main_instr = ax__main_ram.gen_instr(timer_num=0, driver_post_mask=0, driver_wait_mask=0, channel_mask=0, aw_pwm_on=0, aw_pwm_tot=0, w_pwm_on=0, w_pwm_tot=0, ar_pwm_on=0, ar_pwm_tot=0)
         else:
            main_instr = ax__main_ram.gen_instr(worker_iters=0)
         self.cmd_graph[ctrl_instr] = [[main_instr]]
         self.cmd_heads.append(ctrl_instr)

      gen_eof_instr(self.aw_w__ctrl_ram, self.aw_w__main_ram)
      gen_eof_instr(self.ar__ctrl_ram,   self.ar__main_ram)
      gen_eof_instr(self.orch__ctrl_ram, self.orch__main_ram)

      '''
      pp = pprint.PrettyPrinter(indent=2)
      pp.pprint(self.cmd_graph)

      def drawgraph(d):
         G = nx.DiGraph()
         G.add_nodes_from(d.keys())
         for k,v in d.items():
            for vv in v:
               G.add_edges_from([(k,vvv) for vvv in vv])
         nx.draw_planar(G)
         plt.savefig('test.png')

      if nx and plt:
         drawgraph(self.cmd_graph)
      '''

      graph = {}
      graph.update(self.cmd_graph)
      graph.update(self.rsp_graph)
      graph_heads = self.cmd_heads + self.wr_rsp_heads + self.rd_rsp_heads
      super().compile(graph, graph_heads)


