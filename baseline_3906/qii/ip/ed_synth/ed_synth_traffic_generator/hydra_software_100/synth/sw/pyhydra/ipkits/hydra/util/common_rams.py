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

from .compiler_backend import Ram, Field


class OooIterRam(Ram):
   def __init__(self, capacity, csr_baseaddr, csr_datawidth,
                iters_width, next_pc_width, graph):
      fields = OrderedDict([
         ('inf_iters_unroll0',Field(width=1,             derived=False)),
         ('inf_iters_unroll1',Field(width=1,             derived=True)),
         ('inf_iters_unroll2',Field(width=1,             derived=True)),
         ('iters_unroll0',    Field(width=iters_width,   derived=False)),
         ('iters_unroll1',    Field(width=iters_width,   derived=True)),
         ('iters_unroll2',    Field(width=iters_width,   derived=True)),
         ('next_pc_unroll0',  Field(width=next_pc_width, derived=True)),
         ('next_pc_unroll1',  Field(width=next_pc_width, derived=True)),
         ('next_pc_unroll2',  Field(width=next_pc_width, derived=True))
      ])

      self.graph = graph

      super().__init__(fields, capacity, csr_baseaddr, csr_datawidth)

   def update_child_pcs(self, ram_name, instr, child_pcs):
      assert len(child_pcs) == 1, "Internal Error: {} instr needs to have exactly 1 child instr, but received {} child instrs".format(ram_name, len(child_pcs))

   def compile(self):


      for parent, childs_list in self.graph.items():
         for childs in childs_list:
            if len(childs) > 0 and childs[0].ram is self:
               for i, child in enumerate(childs):
                  assert child.ram is self, f"Internal Error: found instrs in the same list belonging to multiple RAMs, {childs}"

                  curr_instr   = childs[ (i+0) % len(childs) ]  
                  next_instr_0 = childs[ (i+1) % len(childs) ]
                  next_instr_1 = childs[ (i+2) % len(childs) ]
                  next_instr_2 = childs[ (i+3) % len(childs) ]

                  curr_inf_mode   = bool(curr_instr.fields['inf_iters_unroll0'].val)
                  next_inf_mode_0 = bool(next_instr_0.fields['inf_iters_unroll0'].val)
                  next_inf_mode_1 = bool(next_instr_1.fields['inf_iters_unroll0'].val)

                  curr_instr.fields['inf_iters_unroll1'].val = next_instr_0.fields['inf_iters_unroll0'].val
                  curr_instr.fields['inf_iters_unroll2'].val = next_instr_1.fields['inf_iters_unroll0'].val
                  if curr_inf_mode:
                     curr_instr.fields['inf_iters_unroll0'].val = 1
                     curr_instr.fields['inf_iters_unroll1'].val = 1
                     curr_instr.fields['inf_iters_unroll2'].val = 1
                  elif next_inf_mode_0:
                     curr_instr.fields['inf_iters_unroll1'].val = 1
                     curr_instr.fields['inf_iters_unroll2'].val = 1
                  elif next_inf_mode_1:
                     curr_instr.fields['inf_iters_unroll2'].val = 1

                  curr_instr.fields['iters_unroll1'].val = next_instr_0.fields['iters_unroll0'].val
                  curr_instr.fields['iters_unroll2'].val = next_instr_1.fields['iters_unroll0'].val
                  if curr_inf_mode:
                     curr_instr.fields['iters_unroll0'].val = -1
                     curr_instr.fields['iters_unroll1'].val = -1
                     curr_instr.fields['iters_unroll2'].val = -1
                  elif next_inf_mode_0:
                     curr_instr.fields['iters_unroll1'].val = -1
                     curr_instr.fields['iters_unroll2'].val = -1
                  elif next_inf_mode_1:
                     curr_instr.fields['iters_unroll2'].val = -1

                  curr_instr.fields['next_pc_unroll0'].val = next_instr_0.pc
                  curr_instr.fields['next_pc_unroll1'].val = next_instr_1.pc
                  curr_instr.fields['next_pc_unroll2'].val = next_instr_2.pc
                  if curr_inf_mode:
                     curr_instr.fields['next_pc_unroll0'].val = curr_instr.pc
                     curr_instr.fields['next_pc_unroll1'].val = curr_instr.pc
                     curr_instr.fields['next_pc_unroll2'].val = curr_instr.pc
                  elif next_inf_mode_0:
                     curr_instr.fields['next_pc_unroll1'].val = next_instr_0.pc
                     curr_instr.fields['next_pc_unroll2'].val = next_instr_0.pc
                  elif next_inf_mode_1:
                     curr_instr.fields['next_pc_unroll2'].val = next_instr_1.pc

      super().compile()

