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



from .driver_mem_axi4 import MemAxi4Driver
from .driver_csr_axi4l import CsrAxi4lDriver


class HydraIpkit(object):
   def __init__(self, config, ip_name):
      self.config  = config
      self.ip_name = ip_name
      self.drivers = []

      ip_config = config['system']['ips'][ip_name]
      params = ip_config['parameters']

      num_drivers = int(params['NUM_DRIVERS']['value'])
      for i in range(num_drivers):
         driver_type = params[f'DRIVER_{i}_TYPE_ENUM']['value']

         if driver_type == 'DRIVER_TYPE_MEM_AXI4':
            self.drivers.append( MemAxi4Driver(i, ip_config) )
         elif driver_type == 'DRIVER_TYPE_MEM_RESET':
            self.drivers.append( None )
         elif driver_type == 'DRIVER_TYPE_MEM_STATUS':
            self.drivers.append( None )
         elif driver_type == 'DRIVER_TYPE_CSR_AXI4L':
            self.drivers.append( CsrAxi4lDriver(i, ip_config) )
         elif driver_type == 'DRIVER_TYPE_CAM_AXI4ST':
            self.drivers.append( None )
         else:
            raise Exception(f"Internal Error: no software support for driver type {driver_type}")

   def get_drivers(self):
      return self.drivers

   def attach(self, prog, driver):
      driver.prog = prog

   def dump(self, outdir):
      self.__compile()
      for driver in self.drivers:
         if driver is not None:
            driver.dump(outdir)         

   def __compile(self):
      for driver in self.drivers:
         if driver is not None:
            driver.compile()

