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
issue_pc_width  = 9
worker_pc_width = 9
alu_pc_width    = 9


class AW_W_CtrlRam(Ram):
   def __init__(self):
      fields = OrderedDict([
         ('ctrl_op',    Field(width=1, derived=False)),
         ('iter_inf',   Field(width=1, derived=False)),
         ('iter_num',   Field(width=8, derived=False)),
         ('start_pc',   Field(width=9, derived=True)),
         ('end_pc',     Field(width=9, derived=True))
      ])

      super().__init__(fields, capacity=1 << ctrl_pc_width, csr_baseaddr=get_csr_baseaddr(0x1), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['start_pc'].val = child_pcs[0][0]
      instr.fields['end_pc'].val   = child_pcs[0][1]

class AR_CtrlRam(Ram):
   def __init__(self):
      fields = OrderedDict([
         ('ctrl_op',    Field(width=1, derived=False)),
         ('iter_inf',   Field(width=1, derived=False)),
         ('iter_num',   Field(width=8, derived=False)),
         ('start_pc',   Field(width=9, derived=True)),
         ('end_pc',     Field(width=9, derived=True))
      ])

      super().__init__(fields, capacity=1 << ctrl_pc_width, csr_baseaddr=get_csr_baseaddr(0x8), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['start_pc'].val = child_pcs[0][0]
      instr.fields['end_pc'].val   = child_pcs[0][1]

class Orch_CtrlRam(Ram):
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




class AW_W_MainRam(Ram):
   def __init__(self):
      fields = OrderedDict([
         ('issue_start_pc',   Field(width=9,  derived=True)),
         ('issue_end_pc',     Field(width=9,  derived=True)),
         ('worker_iters',     Field(width=16, derived=False))
      ])

      super().__init__(fields, capacity=1 << main_pc_width, csr_baseaddr=get_csr_baseaddr(0x2), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['issue_start_pc'].val = child_pcs[0][0]
      instr.fields['issue_end_pc'].val   = child_pcs[0][1]

class AR_MainRam(Ram):
   def __init__(self):
      fields = OrderedDict([
         ('issue_start_pc',   Field(width=9,  derived=True)),
         ('issue_end_pc',     Field(width=9,  derived=True)),
         ('worker_iters',     Field(width=16, derived=False))
      ])

      super().__init__(fields, capacity=1 << main_pc_width, csr_baseaddr=get_csr_baseaddr(0x9), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['issue_start_pc'].val = child_pcs[0][0]
      instr.fields['issue_end_pc'].val   = child_pcs[0][1]

class Orch_MainRam(Ram):
   def __init__(self, num_drivers, num_channels, pwm_width, timer_width):
      fields = OrderedDict([
         ('timer_num',        Field(width=timer_width,   derived=False)),
         ('driver_post_mask', Field(width=num_drivers,   derived=False)),
         ('driver_wait_mask', Field(width=num_drivers,   derived=False)),
         ('channel_mask',     Field(width=num_channels,  derived=False)),
         ('aw_pwm_on',        Field(width=pwm_width,     derived=False)),
         ('aw_pwm_tot',       Field(width=pwm_width,     derived=False)),
         ('w_pwm_on',         Field(width=pwm_width,     derived=False)),
         ('w_pwm_tot',        Field(width=pwm_width,     derived=False)),
         ('ar_pwm_on',        Field(width=pwm_width,     derived=False)),
         ('ar_pwm_tot',       Field(width=pwm_width,     derived=False))
      ])

      super().__init__(fields, capacity=1 << main_pc_width, csr_baseaddr=get_csr_baseaddr(0x1C), csr_datawidth=csr_datawidth)




class AW_W_IssueRam(Ram):
   def __init__(self, awid_width):
      fields = OrderedDict([
         ('is_first_id',   Field(width=1,          derived=False)),
         ('id',            Field(width=awid_width, derived=False)),
         ('worker_pc',     Field(width=9,          derived=True))
      ])

      super().__init__(fields, capacity=1 << issue_pc_width, csr_baseaddr=get_csr_baseaddr(0x3), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['worker_pc'].val = child_pcs[0][0]

class AR_IssueRam(Ram):
   def __init__(self, arid_width):
      fields = OrderedDict([
         ('is_first_id',   Field(width=1,          derived=False)),
         ('id',            Field(width=arid_width, derived=False)),
         ('worker_pc',     Field(width=9,          derived=True))
      ])

      super().__init__(fields, capacity=1 << issue_pc_width, csr_baseaddr=get_csr_baseaddr(0xA), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['worker_pc'].val = child_pcs[0][0]




class AW_W_WorkerRam(Ram):
   def __init__(self, awaddr_width, awaddr_offset_width, awaddr_align_width,
                use_awlock, use_awcache, use_awprot, use_awqos, use_awregion, use_awuser, awuser_width,
                num_dq_alus, num_dm_alus):
      fields = OrderedDict([
         ('awaddr_alu_pc_start',    Field(width=9,                                   derived=True)),
         ('awaddr_alu_pc_end',      Field(width=9,                                   derived=True)),
         ('awaddr_alu_resume',      Field(width=1,                                   derived=False)),
         ('awaddr_min',             Field(width=awaddr_width,                        derived=False)),
         ('awaddr_max',             Field(width=awaddr_width,                        derived=False)),
         ('awaddr_offset',          Field(width=awaddr_offset_width,                 derived=False)),
         ('awaddr_offset_resume',   Field(width=1,                                   derived=False)),
         ('awaddr_align',           Field(width=awaddr_align_width,                  derived=False)),
         ('awlen',                  Field(width=8,                                   derived=False)),
         ('awsize',                 Field(width=3,                                   derived=False)),
         ('awburst',                Field(width=2,                                   derived=False)),
         ('awlock',                 Field(width=1            if use_awlock   else 0, derived=False)),
         ('awcache',                Field(width=4            if use_awcache  else 0, derived=False)),
         ('awprot',                 Field(width=3            if use_awprot   else 0, derived=False)),
         ('awqos',                  Field(width=4            if use_awqos    else 0, derived=False)),
         ('awregion',               Field(width=4            if use_awregion else 0, derived=False)),
         ('awuser',                 Field(width=awuser_width if use_awuser   else 0, derived=False)),
         ('wdata_op',               Field(width=2,                                   derived=False)),
         ('dq_alu_pc_start',        Field(width=9,                                   derived=True)),
         ('dq_alu_pc_end',          Field(width=9,                                   derived=True)),
         ('dq_alu_resume',          Field(width=1,                                   derived=False)),
         ('dq_start_resume',        Field(width=1,                                   derived=False))
      ] + [
         (f'dq{i}_start',           Field(width=32,                                  derived=False)) for i in range(num_dq_alus)
      ] + [
         ('wstrb_op',               Field(width=1,                                   derived=False)),
         ('dm_alu_pc_start',        Field(width=9,                                   derived=True)),
         ('dm_alu_pc_end',          Field(width=9,                                   derived=True)),
         ('dm_alu_resume',          Field(width=1,                                   derived=False)),
         ('dm_start_resume',        Field(width=1,                                   derived=False))
      ] + [
         (f'dm{i}_start',           Field(width=32,                                  derived=False)) for i in range(num_dm_alus)
      ])

      super().__init__(fields, capacity=1 << worker_pc_width, csr_baseaddr=get_csr_baseaddr(0x4), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['awaddr_alu_pc_start'].val = child_pcs[0][0]
      instr.fields['awaddr_alu_pc_end'].val   = child_pcs[0][1]

      instr.fields['dq_alu_pc_start'].val = child_pcs[1][0]
      instr.fields['dq_alu_pc_end'].val   = child_pcs[1][1]

      instr.fields['dm_alu_pc_start'].val = child_pcs[2][0]
      instr.fields['dm_alu_pc_end'].val   = child_pcs[2][1]

class AR_WorkerRam(Ram):
   def __init__(self, araddr_width, araddr_offset_width, araddr_align_width,
                use_arlock, use_arcache, use_arprot, use_arqos, use_arregion, use_aruser, aruser_width):
      fields = OrderedDict([
         ('araddr_alu_pc_start',    Field(width=9,                                   derived=True)),
         ('araddr_alu_pc_end',      Field(width=9,                                   derived=True)),
         ('araddr_alu_resume',      Field(width=1,                                   derived=False)),
         ('araddr_min',             Field(width=araddr_width,                        derived=False)),
         ('araddr_max',             Field(width=araddr_width,                        derived=False)),
         ('araddr_offset',          Field(width=araddr_offset_width,                 derived=False)),
         ('araddr_offset_resume',   Field(width=1,                                   derived=False)),
         ('araddr_align',           Field(width=araddr_align_width,                  derived=False)),
         ('arlen',                  Field(width=8,                                   derived=False)),
         ('arsize',                 Field(width=3,                                   derived=False)),
         ('arburst',                Field(width=2,                                   derived=False)),
         ('arlock',                 Field(width=1            if use_arlock   else 0, derived=False)),
         ('arcache',                Field(width=4            if use_arcache  else 0, derived=False)),
         ('arprot',                 Field(width=3            if use_arprot   else 0, derived=False)),
         ('arqos',                  Field(width=4            if use_arqos    else 0, derived=False)),
         ('arregion',               Field(width=4            if use_arregion else 0, derived=False)),
         ('aruser',                 Field(width=aruser_width if use_aruser   else 0, derived=False)),
      ])

      super().__init__(fields, capacity=1 << worker_pc_width, csr_baseaddr=get_csr_baseaddr(0xB), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['araddr_alu_pc_start'].val = child_pcs[0][0]
      instr.fields['araddr_alu_pc_end'].val   = child_pcs[0][1]

class B_WorkerRam(Ram):
   def __init__(self, awaddr_width, awaddr_offset_width, awaddr_align_width, pwm_width):
      fields = OrderedDict([
         ('awaddr_alu_pc_start',    Field(width=9,                   derived=True)),
         ('awaddr_alu_pc_end',      Field(width=9,                   derived=True)),
         ('awaddr_alu_resume',      Field(width=1,                   derived=False)),
         ('awaddr_min',             Field(width=awaddr_width,        derived=False)),
         ('awaddr_max',             Field(width=awaddr_width,        derived=False)),
         ('awaddr_offset',          Field(width=awaddr_offset_width, derived=False)),
         ('awaddr_offset_resume',   Field(width=1,                   derived=False)),
         ('awaddr_align',           Field(width=awaddr_align_width,  derived=False)),
         ('awlen',                  Field(width=8,                   derived=False)),
         ('awsize',                 Field(width=3,                   derived=False)),
         ('awburst',                Field(width=2,                   derived=False)),
         ('bresp',                  Field(width=2,                   derived=False)),
         ('bresp_dontcare',         Field(width=1,                   derived=False)),
         ('b_pwm_on',               Field(width=pwm_width,           derived=False)),
         ('b_pwm_tot',              Field(width=pwm_width,           derived=False)),
      ])

      super().__init__(fields, capacity=1 << worker_pc_width, csr_baseaddr=get_csr_baseaddr(0x11), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['awaddr_alu_pc_start'].val = child_pcs[0][0]
      instr.fields['awaddr_alu_pc_end'].val   = child_pcs[0][1]

class R_WorkerRam(Ram):
   def __init__(self, araddr_width, araddr_offset_width, araddr_align_width, pwm_width, num_dq_alus, num_dm_alus):
      fields = OrderedDict([
         ('araddr_alu_pc_start',    Field(width=9,                   derived=True)),
         ('araddr_alu_pc_end',      Field(width=9,                   derived=True)),
         ('araddr_alu_resume',      Field(width=1,                   derived=False)),
         ('araddr_min',             Field(width=araddr_width,        derived=False)),
         ('araddr_max',             Field(width=araddr_width,        derived=False)),
         ('araddr_offset',          Field(width=araddr_offset_width, derived=False)),
         ('araddr_offset_resume',   Field(width=1,                   derived=False)),
         ('araddr_align',           Field(width=araddr_align_width,  derived=False)),
         ('arlen',                  Field(width=8,                   derived=False)),
         ('arsize',                 Field(width=3,                   derived=False)),
         ('arburst',                Field(width=2,                   derived=False)),
         ('rresp',                  Field(width=2,                   derived=False)),
         ('rresp_dontcare',         Field(width=1,                   derived=False)),
         ('rdata_dontcare',         Field(width=1,                   derived=False)),
         ('r_pwm_on',               Field(width=pwm_width,           derived=False)),
         ('r_pwm_tot',              Field(width=pwm_width,           derived=False)),
         ('rdata_op',               Field(width=2,                   derived=False)),
         ('dq_alu_pc_start',        Field(width=9,                   derived=True)),
         ('dq_alu_pc_end',          Field(width=9,                   derived=True)),
         ('dq_alu_resume',          Field(width=1,                   derived=False)),
         ('dq_start_resume',        Field(width=1,                   derived=False))
      ] + [
         (f'dq{i}_start',           Field(width=32,                  derived=False)) for i in range(num_dq_alus)
      ] + [
         ('rstrb_op',               Field(width=1,                   derived=False)),
         ('dm_alu_pc_start',        Field(width=9,                   derived=True)),
         ('dm_alu_pc_end',          Field(width=9,                   derived=True)),
         ('dm_alu_resume',          Field(width=1,                   derived=False)),
         ('dm_start_resume',        Field(width=1,                   derived=False))
      ] + [
         (f'dm{i}_start',           Field(width=32,                  derived=False)) for i in range(num_dm_alus)
      ])

      super().__init__(fields, capacity=1 << worker_pc_width, csr_baseaddr=get_csr_baseaddr(0x17), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['araddr_alu_pc_start'].val = child_pcs[0][0]
      instr.fields['araddr_alu_pc_end'].val   = child_pcs[0][1]

      instr.fields['dq_alu_pc_start'].val = child_pcs[1][0]
      instr.fields['dq_alu_pc_end'].val   = child_pcs[1][1]

      instr.fields['dm_alu_pc_start'].val = child_pcs[2][0]
      instr.fields['dm_alu_pc_end'].val   = child_pcs[2][1]




class AW_W_AddrAluRam(Ram):
   def __init__(self, alu_arg_width):
      fields = OrderedDict([
         ('op',    Field(width=2,               derived=False)),
         ('field', Field(width=3,               derived=False)),
         ('arg',   Field(width=alu_arg_width,   derived=False))
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0x5), csr_datawidth=csr_datawidth)

class AR_AddrAluRam(Ram):
   def __init__(self, alu_arg_width):
      fields = OrderedDict([
         ('op',    Field(width=2,               derived=False)),
         ('field', Field(width=3,               derived=False)),
         ('arg',   Field(width=alu_arg_width,   derived=False))
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0xC), csr_datawidth=csr_datawidth)

class B_AddrAluRam(Ram):
   def __init__(self, alu_arg_width):
      fields = OrderedDict([
         ('op',    Field(width=2,               derived=False)),
         ('field', Field(width=3,               derived=False)),
         ('arg',   Field(width=alu_arg_width,   derived=False))
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0x12), csr_datawidth=csr_datawidth)

class R_AddrAluRam(Ram):
   def __init__(self, alu_arg_width):
      fields = OrderedDict([
         ('op',    Field(width=2,               derived=False)),
         ('field', Field(width=3,               derived=False)),
         ('arg',   Field(width=alu_arg_width,   derived=False))
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0x18), csr_datawidth=csr_datawidth)




class AW_W_DqAluRam(Ram):
   def __init__(self, num_dq_alus):
      fields = OrderedDict([
         (f'dq{i}_op',  Field(width=3, derived=False)) for i in range(num_dq_alus)
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0x6), csr_datawidth=csr_datawidth)

class R_DqAluRam(Ram):
   def __init__(self, num_dq_alus):
      fields = OrderedDict([
         (f'dq{i}_op',  Field(width=3, derived=False)) for i in range(num_dq_alus)
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0x19), csr_datawidth=csr_datawidth)




class AW_W_DmAluRam(Ram):
   def __init__(self, num_dm_alus):
      fields = OrderedDict([
         (f'dm{i}_op',  Field(width=3, derived=False)) for i in range(num_dm_alus)
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0x7), csr_datawidth=csr_datawidth)

class R_DmAluRam(Ram):
   def __init__(self, num_dm_alus):
      fields = OrderedDict([
         (f'dm{i}_op',  Field(width=3, derived=False)) for i in range(num_dm_alus)
      ])

      super().__init__(fields, capacity=1 << alu_pc_width, csr_baseaddr=get_csr_baseaddr(0x1A), csr_datawidth=csr_datawidth)




class B_HeadRam(Ram):
   def __init__(self, bid_width):
      fields = OrderedDict([
         ('ctrl_start_pc', Field(width=9, derived=True)),
         ('ctrl_end_pc',   Field(width=9, derived=True))
      ])

      super().__init__(fields, capacity=2**bid_width, csr_baseaddr=get_csr_baseaddr(0xD), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['ctrl_start_pc'].val = child_pcs[0][0]
      instr.fields['ctrl_end_pc'].val   = child_pcs[0][1]

class R_HeadRam(Ram):
   def __init__(self, rid_width):
      fields = OrderedDict([
         ('ctrl_start_pc', Field(width=9, derived=True)),
         ('ctrl_end_pc',   Field(width=9, derived=True))
      ])

      super().__init__(fields, capacity=2**rid_width, csr_baseaddr=get_csr_baseaddr(0x13), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['ctrl_start_pc'].val = child_pcs[0][0]
      instr.fields['ctrl_end_pc'].val   = child_pcs[0][1]




class B_CtrlIterRam(OooIterRam):
   def __init__(self, graph):
      super().__init__(capacity=1 << ctrl_pc_width, csr_baseaddr=get_csr_baseaddr(0xE), csr_datawidth=csr_datawidth,
                       iters_width=16, next_pc_width=9, graph=graph)

   def update_child_pcs(self, instr, child_pcs):
      super().update_child_pcs(str(self), instr, child_pcs)

class R_CtrlIterRam(OooIterRam):
   def __init__(self, graph):
      super().__init__(capacity=1 << ctrl_pc_width, csr_baseaddr=get_csr_baseaddr(0x14), csr_datawidth=csr_datawidth,
                       iters_width=16+8, next_pc_width=9, graph=graph) 

   def update_child_pcs(self, instr, child_pcs):
      super().update_child_pcs(str(self), instr, child_pcs)




class B_CtrlRam(Ram):
   def __init__(self):
      fields = OrderedDict([
         ('worker_start_pc',  Field(width=9, derived=True)),
         ('worker_end_pc',    Field(width=9, derived=True))
      ])

      super().__init__(fields, capacity=1 << ctrl_pc_width, csr_baseaddr=get_csr_baseaddr(0xF), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['worker_start_pc'].val = child_pcs[0][0]
      instr.fields['worker_end_pc'].val   = child_pcs[0][1]

class R_CtrlRam(Ram):
   def __init__(self):
      fields = OrderedDict([
         ('worker_start_pc',  Field(width=9, derived=True)),
         ('worker_end_pc',    Field(width=9, derived=True))
      ])

      super().__init__(fields, capacity=1 << ctrl_pc_width, csr_baseaddr=get_csr_baseaddr(0x15), csr_datawidth=csr_datawidth)

   def update_child_pcs(self, instr, child_pcs):
      instr.fields['worker_start_pc'].val = child_pcs[0][0]
      instr.fields['worker_end_pc'].val   = child_pcs[0][1]




class B_WorkerIterRam(OooIterRam):
   def __init__(self, graph):
      super().__init__(capacity=1 << worker_pc_width, csr_baseaddr=get_csr_baseaddr(0x10), csr_datawidth=csr_datawidth,
                       iters_width=16, next_pc_width=9, graph=graph)

   def update_child_pcs(self, instr, child_pcs):
      super().update_child_pcs("B_WorkerIterRam", instr, child_pcs)

class R_WorkerIterRam(OooIterRam):
   def __init__(self, graph):
      super().__init__(capacity=1 << worker_pc_width, csr_baseaddr=get_csr_baseaddr(0x16), csr_datawidth=csr_datawidth,
                       iters_width=16+8, next_pc_width=9, graph=graph)  

   def update_child_pcs(self, instr, child_pcs):
      super().update_child_pcs("R_WorkerIterRam", instr, child_pcs)


