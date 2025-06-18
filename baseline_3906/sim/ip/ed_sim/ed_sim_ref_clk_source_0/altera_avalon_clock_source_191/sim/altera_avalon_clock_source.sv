// (C) 2001-2025 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $File: //acds/rel/24.3.1/ip/iconnect/verification/altera_avalon_clock_source/altera_avalon_clock_source.sv $
// $Revision: #1 $
// $Date: 2024/10/24 $
// $Author: psgswbuild $
//------------------------------------------------------------------------------
// Clock generator

`timescale 1ps / 1ps

module altera_avalon_clock_source (clk);
   output clk;

   parameter int unsigned CLOCK_RATE = 10;           // clock rate in MHz / kHz / Hz depends on the clock unit
   parameter              CLOCK_UNIT = 1000000;      // clock unit MHz / kHz / Hz

// synthesis translate_off
   import verbosity_pkg::*;

   localparam time HALF_CLOCK_PERIOD = 1000000000000.000000/(CLOCK_RATE*CLOCK_UNIT*2); // half clock period in ps
   
   logic clk = 1'b0;

   string message   = "*uninitialized*";
   string freq_unit = (CLOCK_UNIT == 1)? "Hz" : 
                      (CLOCK_UNIT == 1000)? "kHz" : "MHz";
   bit    run_state = 1'b1;
   
   function automatic void __hello();
      $sformat(message, "%m: - Hello from altera_clock_source.");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Date: 2024/10/24 $");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   CLOCK_RATE = %0d %s", CLOCK_RATE, freq_unit);      
      print(VERBOSITY_INFO, message);
      print_divider(VERBOSITY_INFO);      
   endfunction

   function automatic string get_version();  // public
      // Return BFM version as a string of three integers separated by periods.
      // For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "19.1";
      return ret_version;
   endfunction
   
   task automatic clock_start();  // public
      // Turn the clock on. By default the clock is initially turned on.
      $sformat(message, "%m: Clock started");
      print(VERBOSITY_INFO, message);       
      run_state = 1;
   endtask

   task automatic clock_stop();  // public
      // Turn the clock off.
      $sformat(message, "%m: Clock stopped");
      print(VERBOSITY_INFO, message);       
      run_state = 0;      
   endtask

   function automatic get_run_state();  // public
      // Return the state of the clock source: running=1, stopped=0
      return run_state;
   endfunction      

   initial begin
      __hello();
   end

   always begin
      #HALF_CLOCK_PERIOD;      
      clk = run_state;      

      #HALF_CLOCK_PERIOD;
      clk = 1'b0; 
   end
// synthesis translate_on

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "kPk1f/gu8ExOYF5emrEoxIjNWLzf+DvZPl6dmbdTxvFa1sWsWcofgfO3vw6rSL05vOgZjSRkxXu4OnDmaquRb1IpyWY0D/D6sMu+kgQHOD8kCVKQ1X95v2NsKUKdVuVnLRdvLrZhgS6Xgp8kQwdRRu+KoT0yhderwQeTwsYW2+YMUMFyHdEeMYrA/cAqIAWu7edjaakY18/bVFK4fSiUdgLpM1UmRGNh/ywkkTxTsCfey68I3Vv6ZUI3+6saCnVI5Fhjs1RKPbffITY4QiUmUbkQy6vaNXOsjQO5PiVc+NgOj3PKCYfhsRcPgO8LMraf31EwuhW1Gzf3TaMA3jRnEbj+9+GyrhP+ZzlP4gxPMn6f8Hzua0jQkg84dYI54oUh2fpRq4X8lm3Dluzog69N9M5onHskC2G30I5b9H2iKNeBlohAlSr57cu8KtAC+7ldhtrHBovM6glbzXTfedu8tAzuGLd8+KVEchWFI0VzYl0yfzQTLUv2004jM10H/VQ/yYJSzerHCztj+bcas/qZLBNG7z+b8/HbjpvUNXiXHMma4SDTu562kFnRPd0Hjt8qDkBQxt/EtLgG+38W9xY94I76S+2HnBlc4KG0TvEHhzR2zkW47bb2nqn0oqKNc2ccZG7fpHLbL8ZkXECe0V9kEB1+fsxM+u95rUtAjF83nfRdLfiyw9HKub58PHSNg6dXKfOmEA00fMzPDKzJ+E6EkD5FzEmmMmUUMX6Jl7Ix8bU80B+5bLKsrSHUQLjWOaaecQHapywYES+J6/ZKv2iFmg3vd33JS+YtY38jpez6sfPUq0AgxV6wQh5Cvj2/r57kKGUCtL3+3ODuU7LTtVphxPgpFYuI8mfuyzXMrHtphQoR95Q0pwNjA+K41bSms3Ksy/JwyxxK2/ocwXjRAvg7Pn44aj3C1njjz2dbKwzXvWVJTEET4VZpnq31Bgs39Ach5npmJvZGjj51ePpriwhVrfQwzvSGnAoMMnWt30xiG/LF1BemFn/aMJVY5Csy1XR/"
`endif