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



import argparse
import glob
import json
import os

from pyhydra.runtime import HydraRuntime
from pyhydra.ipkits import HydraIpkit

from traffic_patterns import MemAxi4DriverPrograms, CsrAxi4lDriverPrograms

def main():
   '''
   Parse the .qsys and .ip files of a Platform Designer system containing Test Engine IP,
   select the software program for each driver, and dump the compiled binary.
   '''


   # Location of this script
   __location__ = os.path.realpath( os.path.join(os.getcwd(), os.path.dirname(__file__)) )

   # Parse user args
   parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='Design Example software for Test Engine traffic generation.')
   parser.add_argument('--ipdir', default=__location__, help='Directory containing .qsys and .ip files. (Default: This script\'s location)')
   parser.add_argument('--prog', default='tut1_block_rw', 
                       help="Name of traffic program to use for all Memory AXI4 Drivers. (Default: tut1_block_rw)\n\n" +
                            "You can also provide a comma-delimited list of traffic to select a program per driver.\n" +
                            "Example: --prog=my_prog0,my_prog1,my_prog2,...\n" +
                            "Using the example above, per-driver traffic pattern selection will map to each driver as follows:\n" +
                            "- Driver 0:my_prog0, Driver 1:my_prog1, Driver 2:my_prog2, etc.\n\n" +
                            "An error will occur in the following cases:\n" +
                            "  - A comma-delimited list of programs does not match the number of drivers\n" + 
                            "  - A program does not exist for a driver type")
   parser.add_argument('--outdir', default='./bin', help='Output directory path for generated files (Default: ./bin)')
   args = parser.parse_args()

   # Discover Qsys files: .qsys, .ip
   files = []
   for fil_regexp in ['*.qsys', '*.ip']:
      files_ = glob.glob(os.path.join(args.ipdir, '**', fil_regexp), recursive=True)
      files.extend(files_)
   assert any(fil.endswith('.ip') for fil in files), f"Couldn't find any .ip files in {args.ipdir}. At a minimum Test Engine IP's .ip file is needed."
   # Get absolute filepaths of every file
   files = [os.path.realpath(fil) for fil in files]
   # Remove files whose path contains "BAK"
   files = [fil for fil in files if "BAK" not in fil]

   # Initialize runtime to discover the Qsys system and interact with device (later)
   rt = HydraRuntime(files)

   # 'config' is a JSON-style dict containing info about the entire system: IPs, parameters, connections, ...
   # This can be useful to discover which Test Engine driver is connected to which IP interface, how
   # the IP is configured, ...
   config = rt.get_config()
   #print(config)
   #print(json.dumps(config, indent=3, sort_keys=True))
   #print(config['system'].keys())
   #print(json.dumps(config['system']['connections'], indent=3, sort_keys=True))
   #print(config['system']['ips'].keys())
   #print(config['system']['ips']['mem_ss_fm_0'].keys())
   #print(json.dumps(config['system']['ips']['mem_ss_fm_0'], indent=3, sort_keys=True))

   # Find Test Engine IP instance
   hydra_ip_name = None
   for ip in config['system']['ips']:
      if config['system']['ips'][ip]['type'] == 'hydra':
         if hydra_ip_name is not None:
            print(f"Warning: Multiple Test Engine IPs found, only the first instance {hydra_ip_name} will be used and {ip} will be ignored")
         else:
            hydra_ip_name = str(ip)
   if not hydra_ip_name:
      print("Error: Test Engine IP not found in system, aborting")
      exit()

   # Instantiate IP Kits
   hydrakit = HydraIpkit(config=config, ip_name=hydra_ip_name)

   # Test Engine is essentially a multi-processor system, wherein each "processor" (i.e. driver)
   # requires its own kernel (i.e. software instructions).
   drivers = hydrakit.get_drivers()

   # Helper object (per driver) that stores various traffic programs
   ip_config = config['system']['ips'][hydra_ip_name]
   params = ip_config['parameters']

   num_drivers = int(params['NUM_DRIVERS']['value'])

   # Handle selection of traffic programs
   arg_prog_list = args.prog.split(',')
   if len(arg_prog_list) == 1:
      arg_prog_list = num_drivers * arg_prog_list
   elif len(arg_prog_list) != num_drivers:
      print(f"Error: The number of traffic programs provided does not match the number of drivers (Programs:{len(arg_prog_list)}, Drivers:{num_drivers})")
      exit()

   driver_progs_list = []

   for i in range(num_drivers):
      driver_type = params[f'DRIVER_{i}_TYPE_ENUM']['value']
      if driver_type == 'DRIVER_TYPE_MEM_AXI4':
         driver_progs_list.append(MemAxi4DriverPrograms(config=config, hydra_ip_name=hydra_ip_name, driver_index=i))
      elif driver_type == 'DRIVER_TYPE_MEM_RESET':
         driver_progs_list.append(None)
      elif driver_type == 'DRIVER_TYPE_MEM_STATUS':
         driver_progs_list.append(None)
      elif driver_type == 'DRIVER_TYPE_CSR_AXI4L':
         driver_progs_list.append(CsrAxi4lDriverPrograms(config=config, hydra_ip_name=hydra_ip_name, driver_index=i))
      elif driver_type == 'DRIVER_TYPE_CAM_AXI4ST':
         driver_progs_list.append(None)
      else:
         raise Exception("Internal Error: unhandled driver type " + driver_type)

   # Pick a program and attach to driver
   for i, (driver, driver_progs, arg_prog) in enumerate(zip(drivers, driver_progs_list, arg_prog_list)):
      if driver_progs is not None:
         prog = getattr(driver_progs, arg_prog, None)
         assert callable(prog), f"Traffic program '{arg_prog}' does not exist for driver {i} ({driver})"
         print(f"Using {arg_prog} program for driver {i} ({driver})")
         hydrakit.attach(prog=prog(), driver=driver)
         #hydrakit.attach(prog=progs.tut1_block_rw(), driver=driver)

   # Dump the compiled binary
   hydrakit.dump(args.outdir)


if __name__ == "__main__":
   main()

