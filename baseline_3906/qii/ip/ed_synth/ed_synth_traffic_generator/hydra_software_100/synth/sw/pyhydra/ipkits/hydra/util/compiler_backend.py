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
import os
import sys

from collections import OrderedDict

from ....util.math import *

try:
   # tabulate is not shipped with quartus_py yet :(
   # So for internal use, use internally available Python modules
   # Need to manually update this path to closely match quartus_py's version
   if os.path.isdir('/p/psg/ctools/python/3.7.9/6/linux64/suse12/lib/python3.7/site-packages'):
      sys.path.append('/p/psg/ctools/python/3.7.9/6/linux64/suse12/lib/python3.7/site-packages')
   from tabulate import tabulate
except ImportError:
   tabulate = None


class Command:
   def __init__(self, driver, metadata):
      self.driver = driver
      self.metadata = metadata

class Driver:
   def __init__(self, driver_idx):
      self.driver_idx = driver_idx

      self.__rams = OrderedDict()

      self.prog = None

      self.bindir = None

      self.rams_csr_baseaddr = None

   def __setattr__(self, attr, val):
      super().__setattr__(attr, val)

      if callable(val):
         pass
      else:

         if (isinstance(val, Ram)):
            self.__rams[attr] = val

      return val

   def __repr__(self):
      return type(self).__name__

   def optimize_graph(self, graph, graph_heads):

      all_childs = []
      for parent, childs_list in graph.items():
         for childs in childs_list:
            if childs:
               if str(childs[0].ram) == 'B_CtrlRam' or str(childs[0].ram) == 'B_WorkerRam' or \
                  str(childs[0].ram) == 'R_CtrlRam' or str(childs[0].ram) == 'R_WorkerRam':
                  continue
               all_childs.append(childs)

      def is_instr_list_equiv(instrs_a, instrs_b):
         match = True

         if len(instrs_a) == len(instrs_b):
            for instr_a, instr_b in zip(instrs_a, instrs_b):
               if instr_a.ram == instr_b.ram:
                  for (i1_fieldname, i1_field), (i2_fieldname, i2_field) in zip(instr_a.fields.items(), instr_b.fields.items()):
                     assert i1_fieldname == i2_fieldname, f"Internal Error: Two instructions belonging to {instr_a.ram} have different properties, fieldname {i1_fieldname} vs {i2_fieldname}"
                     assert i1_field.width == i2_field.width, f"Internal Error: Two instructions belonging to {instr_a.ram} have different properties, width {i1_field.width} vs {i2_field.width}"
                     match &= i1_field.val == i2_field.val

                  child_t = graph.get(instr_a, None)
                  child   = graph.get(instr_b, None)
                  match  &= child_t is child
               else:
                  match = False
         else:
            match = False

         return match

      all_childs_copy = []
      for childs in all_childs:
         if not any(is_instr_list_equiv(childs, childs_t) for childs_t in all_childs_copy):
            all_childs_copy.append(childs)
      all_childs = all_childs_copy

      def traverse(instrs):
         for instr in instrs:
            childs_list = graph.get(instr, None)
            if childs_list:
               for i, childs in enumerate(childs_list):
                  new_childs = traverse(childs)
                  if new_childs:
                     childs_list[i] = new_childs

         for instrs_t in all_childs:
            if is_instr_list_equiv(instrs, instrs_t):
               return instrs_t

         return None

      traverse(graph_heads)

   def compile_graph(self, graph, graph_heads):
      def compile_graph_helper(node):
         pc = None
         child_pcs = []

         if node.get_pc() is not None:
            return node.get_pc()

         if node is not None and node in graph:
            for child_list in graph[node]:   
               if len(child_list) > 0:
                  child_pcs_temp = []
                  for child in child_list:
                     child_pcs_temp.append( compile_graph_helper(child) )
                  child_pcs.append( (child_pcs_temp[0], child_pcs_temp[-1]) )

         if node is not None:
            if len(child_pcs) > 0:
               node.ram.update_child_pcs(node, child_pcs)
            pc = node.ram.insert_instr(node)

         assert pc is not None, f"Internal Error: instruction {node} could not be compiled"
         return pc

      for head in graph_heads:
         compile_graph_helper(head)

   def compile(self, graph, graph_heads):
      for _, ram in self.__rams.items():
         ram.clear()

      orig_str = sorted(str(kv) for kv in graph.items())
      self.optimize_graph(graph, graph_heads)
      new_str  = sorted(str(kv) for kv in graph.items())
      assert orig_str == new_str, f"Graph optimization changed contents of the graph\nBefore:\n{orig_str}\nAfter:\n{new_str}"

      self.compile_graph(graph, graph_heads)

      for _, ram in self.__rams.items():
         ram.compile()

   def dump(self, outdir):
      hexdir = os.path.join(outdir, self.bindir, 'hex')
      mifdir = os.path.join(outdir, self.bindir, 'mif')
      csrdir = os.path.join(outdir, self.bindir, 'csr')
      rawdir = os.path.join(outdir, self.bindir, 'raw')
      os.makedirs(hexdir, exist_ok=True)
      os.makedirs(mifdir, exist_ok=True)
      os.makedirs(csrdir, exist_ok=True)
      os.makedirs(rawdir, exist_ok=True)
      for _, ram in self.__rams.items():
         ram.dump_hex(os.path.join(hexdir, str(ram) + '.hex'))
         ram.dump_mif(os.path.join(mifdir, str(ram) + '.mif'))
         ram.dump_csr(os.path.join(csrdir, str(ram) + '.txt'))
         ram.dump_raw(os.path.join(rawdir, str(ram) + '.csv'), os.path.join(rawdir, str(ram) + '.txt'))
         ram.print_usage()


class Field:
   def __init__(self, width, derived, val=0):
      self.val     = val
      self.width   = width
      self.derived = derived


class Ram:
   def __init__(self, fields, capacity, csr_baseaddr, csr_datawidth):
      self.fields        = fields
      self.capacity      = capacity
      self.csr_baseaddr  = csr_baseaddr
      self.csr_datawidth = csr_datawidth

      self.instrs   = []
      self.compiled_instrs = []

      self.ram_data_width = roundup( sum(field.width for _, field in self.fields.items()), 8 )
      self.padded_ram_data_width = roundup(self.ram_data_width, self.csr_datawidth)
      self.beat_addr_width = math.ceil(math.log2(self.padded_ram_data_width // self.csr_datawidth))
      self.byte_addr_width = math.ceil(math.log2(self.csr_datawidth // 8))
      self.min_csr_addr_width = math.ceil(math.log2(self.capacity)) + self.beat_addr_width + self.byte_addr_width

      assert self.csr_baseaddr & ((1 << self.min_csr_addr_width) - 1) == 0, \
         f"Internal Error: For RAM={str(self)} csr_baseaddr=0x{format(self.csr_baseaddr, 'x')} must have lower {self.min_csr_addr_width} bits set to 0"

   def __repr__(self):
      return type(self).__name__

   def dump_csr(self, file):
      words = self.partram_compiled_instrs

      with open(file, "w") as fp:
         for addr, word in enumerate(words):

            padded_word = dec2hex(int(word, 16), self.padded_ram_data_width)

            n = self.csr_datawidth // 4   
            beats = len(padded_word) // n  
            for beat in range(beats):
               i = beats-1 - beat
               csr_data = padded_word[i*n : i*n + n]

               csr_addr = self.csr_baseaddr + (((addr << self.beat_addr_width) | beat) << self.byte_addr_width)

               line = '0x' + format(csr_addr, 'x') + ' 0x' + csr_data + '\n'
               fp.write(line)

   def dump_hex(self, file):
      words = self.fullram_compiled_instrs

      with open(file, "w") as fp:
         for addr, word in enumerate(words):
            addr_str = format(addr, '04x')
            if len(addr_str) > 4:
               raise ValueError("Address overflow in .hex file, 0x" + addr_str + " exceeds max address of 0xffff")

            byte_cnt = format(len(word) // 2, '02x') 
            if len(byte_cnt) > 2:
               raise ValueError("Data overflow in .hex file, 0x" + byte_cnt + " exceeds max byte count of 0xff")

            line = ':' + byte_cnt + addr_str + '00' + word

            sum = 0
            for i in range(len(line) // 2):
               sum += int(line[(2 * i + 1):(2 * i + 3)], 16)
            sum = hex(sum)[2:]  
            if (len(sum) > 2):
               sum = sum[-2:]
            checksum = 2 ** 8 - int(sum, 16)  
            checksum = hex(checksum)[2:]
            if (len(checksum) > 2):
               checksum = checksum[-2:]
            checksum = "{0:0{1}x}".format(int(checksum, 16), 2)

            line += checksum + '\n'
            fp.write(line)

         line = ':00000001ff'
         fp.write(line)

   def dump_mif(self, file):

      words = self.fullram_compiled_instrs

      lines = [
         f"DEPTH = {len(words)};",
         f"WIDTH = {self.ram_data_width};",  
         f"ADDRESS_RADIX = HEX;",            
         f"DATA_RADIX = HEX;",               
         "CONTENT",
         "BEGIN"
      ] + [
         f"{format(addr, 'x')} : {word};" for addr, word in enumerate(words)
      ] + [
         "END;"
      ]

      with open(file, "w") as fp:
         fp.write('\n'.join(lines))

   def dump_raw(self, csv_file, txt_file):
      with open(csv_file, 'w') as csv_fp, open(txt_file, 'wb') as txt_fp:
         if self.instrs is None or len(self.instrs) == 0:
            csv_fp.write("empty")
            txt_fp.write("empty".encode('utf-8'))
         else:
            rows = []

            lsb = 0
            header = []
            for name, field in self.instrs[0].fields.items():
               header.append( f"{name} [{lsb + field.width - 1}:{lsb}] ({field.width})" )
               lsb += field.width
            rows.append(header)

            for instr in self.instrs:
               row = []
               for name, field in instr.fields.items():
                  row.append( f"0x{dec2hex(field.val, field.width)}" )
               rows.append(row)

            table = ""
            for row in rows:
               for cell in row:
                  table += f"{cell},"
               table += "\n"
            csv_fp.write(table)

            if tabulate:
               table = tabulate(rows, headers='firstrow', tablefmt='fancy_grid', showindex=True)
               txt_fp.write(table.encode('utf-8'))

   def clear(self):
      del self.instrs[:]

   def print_usage(self):
      print(f"{self} usage = {len(self.instrs)}/{self.capacity} (" + str((len(self.instrs)*100)//self.capacity) + "%)")

   def gen_instr(self, **kwargs):
      fields = copy.deepcopy(self.fields)
      for name, field in fields.items():
         if name in kwargs:
            field.val = kwargs[name]
         else:
            assert field.derived, f"Internal Error: {self}.{name} is not set"
      for name in kwargs:
         assert name in fields, f"Internal Error: {self} received instr field {name} which doesn't exist in {fields.keys()}"
      return Instr(self, fields)

   def insert_instr(self, instr):
      instr.set_pc( len(self.instrs) )
      self.instrs.append(instr)
      return instr.get_pc()

   def compile(self):
      assert len(self.instrs) <= self.capacity, f"{self} instructions exceed capacity ({len(self.instrs)}/{self.capacity})! Please reduce the number of instructions in your kernel."

      self.partram_compiled_instrs = [instr.compile() for instr in self.instrs]

      self.fullram_compiled_instrs = self.partram_compiled_instrs + [dec2hex(0, self.ram_data_width) for _ in range(len(self.instrs), self.capacity)]

   def update_child_pcs(self, instr, child_pcs):
      raise Exception("Internal Error: " + str(self) + " doesn't have children")


class Instr:
   def __init__(self, ram, fields):
      self.ram    = ram
      self.fields = fields
      self.pc     = None

   def __repr__(self):
      s  = f"<ram={self.ram}: "
      s += ", ".join(f"{name}={field.val}" for name, field in self.fields.items())
      s += ">"
      return s

   def __str__(self):
      return self.__repr__()

   def set_pc(self, pc):
      assert self.pc is None, f"Internal Error: PC already set for instr {self}"
      self.pc = pc

   def get_pc(self):
      return self.pc

   def compile(self):
      totalbits  = sum(field.width for _, field in self.fields.items())
      instrwidth = roundup(totalbits, 8)
      instrpad   = instrwidth - totalbits

      instr = ""
      for name, field in self.fields.items():
         max_val = (1<<field.width) - 1
         if field.val > max_val:
            raise ValueError(f"Error: {self.ram}.{name}={field.val} exceeds max val of {max_val}")
         if field.width > 0:
            instr = dec2bin(field.val, field.width) + instr
      instr = dec2bin(0, instrpad) + instr
      instr_hex = dec2hex(int(instr, 2), instrwidth)
      return instr_hex


