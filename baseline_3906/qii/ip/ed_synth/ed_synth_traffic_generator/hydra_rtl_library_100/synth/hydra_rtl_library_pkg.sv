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



package hydra_rtl_library_pkg;

   function automatic string get_param_from_str;
      input string str;
      input string param;

      integer str_len;
      integer param_len;
      integer val_start;
      integer val_end;
      string  sub;
   begin
      str_len   = str.len();
      param_len = param.len();
      val_start = 0;
      val_end   = 0;

      get_param_from_str = "0";

      for (int i = 0; i < str_len; i++) begin
         sub = str.substr(i, i + param_len - 1);
         if(sub.compare(param) == 0) begin
            val_start = i + param_len;
            for (int j = val_start; j < str_len; j++) begin
               if (val_start >= val_end && (str[j] == " " || str[j] == "="))
                  val_start = val_start + 1;
               val_end = j;
               if (str[j] == "," || (val_start < val_end && str[j] == " ")) begin
                  val_end = val_end - 1;
                  break;
               end
            end

            if (val_start <= val_end)
               get_param_from_str = str.substr(val_start, val_end);
         end
      end
   end
   endfunction

   function automatic integer str_to_int;
      input string str;

      integer str_len;
      integer val;
   begin
      str_len = str.len();
      val = 0;
      for (int i = 0; i < str_len; i++) begin
         case (str.getc(i))
            "0":     val = val*10 + 0;
            "1":     val = val*10 + 1;
            "2":     val = val*10 + 2;
            "3":     val = val*10 + 3;
            "4":     val = val*10 + 4;
            "5":     val = val*10 + 5;
            "6":     val = val*10 + 6;
            "7":     val = val*10 + 7;
            "8":     val = val*10 + 8;
            "9":     val = val*10 + 9;
            default: $fatal(1, "Found non-digit character %s in string %s", str[i], str);
         endcase
      end
      str_to_int = val;
   end
   endfunction

   localparam CTRL_INSTR_OP_EOL = 0;


endpackage

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "iNycF91rGQ10Zp8x1Kl1zlSLup7GB1vT7UwORxIO22UuA3HsB3MD+WHW9tezWrOFymO8GyTqegwFqHh87nPB3GzE0QKUZS5yC7ocXLddyfmST+TfepSqlBdTl73VI1zyaPrd1YvLXPTDe8bswmAuStBIhKimC0iOiMe3TCwTNKh/gtwYu8bHS8fbTiV2DkxcSwZ66pZL3zUeZFybMS60gnwFgYmtgZlxkZpJaeamNmRx9yEvRSOauL82QWpPqCuKxieEsoilziskq60jAtEYTqkseNuypTcJbBWuXRRBr7Ufl/+7y3PNgfa0Zu86DdiX8RXqmx1Riv09h7okuiIsGqqRtKywpfEvkZYMHmH6mSKwXBLaR7N0JEXkZnF4H+L0NbsKQ2DbjcnB3+J0eyYAYi2gh0vne9oo19rC1JIDuzu25V05DvS1Ue3uEQlmFn/rgaBGcWkV8s4PTNWWNZ21tR1HHhWc2PpiW/AYnJ4YZZzV6GRcF3p30DQlcc2BhSfMgSGS1dcE7QdfdAKioV8px4Vl8fITZC+xSW8T7/4pjGTJzBh/Rj9dlTNBi6hMTmQWNPd4MLLP9riAHDjmh8DgYWZmsfO5aZ+tE+GoVpIIFf5+okgkLTG5yU80qFbY1bl3nLVDMwND1HlGV8oUiuZ+bMW//qhhYoppcnyQLV2p0ubr9uP/OP3a74rnqWYcqfsGPWpsrANPhAqTX6WrFx8DR5URbg2UEDoSXk1NMuOMflp7gLY8RHxOnUBwJDO7LGM0sDyToMEQfCwlF5QSQ2b7m0HJmDw52yoDgbZyuw3oFfySpZj5o1KWiaOkzupJHkiKWj+4Ar6ytnh0/XdMPJWXKkqtcdboasOauFzw7sqoHIhD1DQCgApWmrsFVk+WtnfzGoz0o/ixNXVBK9+KSpN34N5eSD2k2JeRQRjAtU/NyYg6sKVdTU0zzV2W4BfgYeTUhhKErWigB2iNxVPXLs/XytoT9J96kkTiNDNnXvNc16QJPfvuk76QLQdyw/k7poTP"
`endif