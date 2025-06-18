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



import math


def dec2bin(x, width):
   if width <= 0: return ''
   s = x & int("1" * width, 2)
   return format(s, '0' + str(width) + 'b')


def dec2hex(x, width):
   if width <= 0: return ''
   s = x & int("1" * width, 2)
   return format(s, '0' + str(width // 4) + 'x')


def roundup(x, multiple):
   return int( ((x + multiple - 1) // multiple) * multiple )


def find_lcm(a, b):
   return abs(a*b) // math.gcd(a, b)


def lcm(l):
   if len(l) < 2:
      return l[0]

   lcm = find_lcm(l[0], l[1])

   for i in range(2, len(l)):
      lcm = find_lcm(lcm, l[i])

   return lcm

