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

try:
   import simplejson as json
except ImportError:
   import json as json


def read_json(filepath):
   with open(filepath, 'r') as fp:
      data = json.load(fp)
   return data

def parse_qsys_file(filepath, config):
   import xml.etree.ElementTree as ET

   tree = ET.parse(filepath)
   root = tree.getroot()

   ns = {'ipxact': 'http://www.accellera.org/XMLSchema/IPXACT/1685-2014',
         'altera': 'http://www.altera.com/XMLSchema/IPXact2014/extensions'}

   for item in root.findall("ipxact:vendorExtensions/altera:altera_system_parameters/ipxact:parameters/ipxact:parameter", ns):
      name        = item.find("ipxact:name", ns).text
      displayName = item.find("ipxact:displayName", ns).text
      value       = item.find("ipxact:value", ns).text
      if name in ["board", "device", "deviceFamily", "deviceSpeedGrade"]: 
         config["system"]["parameters"][name] = {
            "displayName": displayName,
            "value": value
         }

   for item in root.findall("ipxact:vendorExtensions/altera:modules/altera:module", ns):
      ip_inst = item.find("altera:entity_info/ipxact:library", ns).text
      config["system"]["ips"][ip_inst] = {
         "ip_filepath": None,
         "parameters": {}
      }
      for subitem in item.findall("altera:altera_module_parameters/ipxact:parameters/ipxact:parameter", ns):
         name = subitem.find("ipxact:name", ns).text
         value = subitem.find("ipxact:value", ns).text
         if name == "logicalView":
            ip_filepath = value
            if not os.path.isabs(ip_filepath):
               ip_filepath = os.path.realpath(os.path.join(os.path.dirname(filepath), ip_filepath))
            config["system"]["ips"][ip_inst]["ip_filepath"] = ip_filepath

   for item in root.findall("ipxact:vendorExtensions/altera:connections/altera:connection", ns):
      start = item.attrib["{" + ns['altera'] + "}start"]
      end   = item.attrib["{" + ns['altera'] + "}end"]
      kind  = item.attrib["{" + ns['altera'] + "}kind"]
      config["system"]["connections"].append( {
         "start": start,
         "end": end,
         "kind": kind
      } )

   return config

def parse_ip_file(filepath, config):
   import xml.etree.ElementTree as ET

   tree = ET.parse(filepath)
   root = tree.getroot()

   ns = {'ipxact': 'http://www.accellera.org/XMLSchema/IPXACT/1685-2014',
         'altera': 'http://www.altera.com/XMLSchema/IPXact2014/extensions'}

   ip_inst = root.find("ipxact:name", ns).text
   ip_type = root.find("ipxact:vendorExtensions/altera:entity_info/ipxact:name", ns).text
   ip_version = root.find("ipxact:vendorExtensions/altera:entity_info/ipxact:version", ns).text

   found = False
   for ip_inst_k, ip_inst_v in config["system"]["ips"].items():
      if "ip_filepath" in ip_inst_v and os.path.samefile(ip_inst_v["ip_filepath"], filepath):
         ip_inst = ip_inst_k
         found   = True
         break
   if not found:
      config["system"]["ips"][ip_inst] = {}

   config["system"]["ips"][ip_inst].update({
      "type": ip_type,
      "version": ip_version,
      "parameters": {},
      "interfaces": {}
   })

   for item in root.findall("ipxact:vendorExtensions/altera:altera_module_parameters/ipxact:parameters/*", ns):
      name        = item.find("ipxact:name", ns).text
      displayName = item.find("ipxact:displayName", ns).text
      value       = item.find("ipxact:value", ns).text
      config["system"]["ips"][ip_inst]["parameters"][name] = {
         "displayName": displayName,
         "value": value
      }

   for item in root.findall("ipxact:busInterfaces/*", ns):
      name        = item.find("ipxact:name", ns).text
      config["system"]["ips"][ip_inst]["interfaces"][name] = {
         "properties": {},
         "assignments": {}
      }

      for subitem in item.findall("ipxact:parameters/*", ns):
         prop_name        = subitem.find("ipxact:name", ns).text
         prop_displayName = subitem.find("ipxact:displayName", ns).text
         prop_value       = subitem.find("ipxact:value", ns).text
         config["system"]["ips"][ip_inst]["interfaces"][name]['properties'][prop_name] = {
            "displayName": prop_displayName,
            "value": prop_value
         }

      for subitem in item.findall("ipxact:vendorExtensions/altera:altera_assignments/ipxact:parameters/*", ns):
         prop_name        = subitem.find("ipxact:name", ns).text
         prop_value       = subitem.find("ipxact:value", ns).text
         config["system"]["ips"][ip_inst]["interfaces"][name]['assignments'][prop_name] = {
            "value": prop_value
         }

   return config

