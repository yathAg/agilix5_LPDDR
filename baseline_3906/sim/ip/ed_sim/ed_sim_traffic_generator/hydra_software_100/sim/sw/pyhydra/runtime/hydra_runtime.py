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


import os

from ..util.files import parse_qsys_file, parse_ip_file, read_json


class HydraRuntime(object):
   def __init__(self, files):

      self.config = {
         'system': {
            'parameters': {},
            'ips': {},
            'connections': []
         }
      }

      qsys_files = [fil for fil in files if fil.endswith('.qsys')]
      ip_files   = [fil for fil in files if fil.endswith('.ip')]
      for fil in qsys_files:
         parse_qsys_file(fil, self.config)
      for fil in ip_files:
         parse_ip_file(fil, self.config)

      __location__    = os.path.realpath( os.path.join(os.getcwd(), os.path.dirname(__file__)) )
      config_json_fil = os.path.join(__location__, 'config.json')
      config_json     = read_json(config_json_fil)

      num_hydra_ips = 0
      hydra_ip_name = None
      for ip_name, ip_dict in self.config['system']['ips'].items():
         ip_type = ip_dict['type']
         if ip_type == 'hydra':
            num_hydra_ips += 1
            hydra_ip_name = ip_name

      if num_hydra_ips > 1:
         print("Info: Multiple Hydra IPs detected, internal parameters will not be available for these IPs in config dict")
      elif num_hydra_ips == 1:
         for param_name, param_dict in config_json['parameters'].items():
            param_val    = param_dict['value']
            hydra_params = self.config['system']['ips'][hydra_ip_name]['parameters']
            if param_name not in hydra_params:
               hydra_params[param_name] = {
                  'value': param_val
               }

   def get_config(self):
      return self.config

