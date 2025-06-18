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





`timescale 1ns / 1ns

module altera_std_synchronizer_nocut (
                                clk, 
                                reset_n, 
                                din, 
                                dout
                                );

   parameter depth = 3; 
   parameter rst_value = 0;

   parameter retiming_reg_en = 0;
     
   input   clk;
   input   reset_n;    
   input   din;
   output  dout;
   

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON  "} *) reg din_s1;

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [depth-2:0] dreg;    

   `ifndef QUARTUS_CDC
   initial begin
     if (retiming_reg_en == 0 ) begin
       if (depth <2) begin 
         $display("%m: Error: synchronizer length: %0d less than 2.", depth);
       end
      end
     else begin
       if (depth <4) begin 
         $display("%m: Error: synchronizer length: %0d less than 4 with retiming enabled.", depth);
       end
     end
   end
   `endif 

   
`ifdef __ALTERA_STD__METASTABLE_SIM

   reg[31:0]  RANDOM_SEED = 123456;      
   wire  next_din_s1;
   wire  dout;
   reg   din_last;
   reg          random;
   event metastable_event; 

   initial begin
      $display("%m: Info: Metastable event injection simulation mode enabled");
      random = $random;
   end
   
   always @(posedge clk) begin
      if (reset_n == 0)
        random <= $random(RANDOM_SEED);
      else
        random <= $random;
   end

   assign next_din_s1 = (din_last ^ din) ? random : din;   

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
         din_last <= (rst_value == 0)? 1'b0 : 1'b1;
       else
         din_last <= din;
   end

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
         din_s1 <= (rst_value == 0)? 1'b0 : 1'b1;
       else
         din_s1 <= next_din_s1;
   end
   
`else 

   generate if (rst_value == 0)
       always @(posedge clk or negedge reset_n) begin
           if (reset_n == 0) 
             din_s1 <= 1'b0;
           else
             din_s1 <= din;
       end
   endgenerate
   
   generate if (rst_value == 1)
       always @(posedge clk or negedge reset_n) begin
           if (reset_n == 0) 
             din_s1 <= 1'b1;
           else
             din_s1 <= din;
       end
   endgenerate

`endif

`ifdef __ALTERA_STD__METASTABLE_SIM_VERBOSE
   always @(*) begin
      if (reset_n && (din_last != din) && (random != din)) begin
         $display("%m: Verbose Info: metastable event @ time %t", $time);
         ->metastable_event;
      end
   end      
`endif


   generate if (rst_value == 0) begin
      if (retiming_reg_en == 0) begin
         if (depth < 3) begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b0}};            
               else
                 dreg <= din_s1;
            end         
         end else begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b0}};
               else
                 dreg <= {dreg[depth-3:0], din_s1};
            end
         end

         assign dout = dreg[depth-2];
       end

       else begin 
          (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [1:0] dreg1;
          reg [depth-4:0] dreg2;
          wire [depth-2:0] dreg3;

          assign dreg3 = {dreg2,dreg1};

          if (depth <= 3) begin
             always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0)
                  dreg1 <= {depth-1{1'b0}};
                else
                  dreg1 <= din_s1;
               end
           end
           else begin
              always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0)
                  {dreg2,dreg1} <= {depth-1{1'b0}};
                else
                  {dreg2,dreg1} <= {dreg3[depth-3:0], din_s1};
              end
           end
           assign dout = dreg3[depth-2];
       end
    end

   
   else begin
      if (retiming_reg_en == 0) begin
         if (depth < 3) begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b1}};            
               else
                 dreg <= din_s1;
             end         
         end else begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b1}};
               else
                 dreg <= {dreg[depth-3:0], din_s1};
            end
         end
       assign dout = dreg[depth-2];
    end

      else begin
         (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [1:0] dreg1;
         reg [depth-4:0] dreg2;
         wire [depth-2:0] dreg3;

         assign dreg3 = {dreg2,dreg1};

           if (depth <= 3) begin
               always @(posedge clk or negedge reset_n) begin
                  if (reset_n == 0)
                    dreg1 <= {depth-1{1'b1}};
                  else
                    dreg1 <= din_s1;
               end
           end
           else begin
               always @(posedge clk or negedge reset_n) begin
                  if (reset_n == 0)
                    {dreg2,dreg1} <= {depth-1{1'b1}};
                  else
                    {dreg2,dreg1} <= {dreg3[depth-3:0], din_s1};
               end
            end  
          assign dout = dreg3[depth-2];
        end
     end
   endgenerate

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nATEpDWf3CgajPjgH0t9FI3P3v7c7W2p1Bjo8KPiWXptDDKP83tHlZV4/kOjbfP5B3iPKq3r9UGmKAo7uM5E+NrMJJrWKQHFxNhuD9YH7WIm4w92BUZP4bPiPCFjEfA8Gg2F5To+TwSe7HVsQs+/7MZQj0QmDr2hjiVbFLL88xfR21RarRUIjnXzluc0JvTFFI13vcHyvhug/HSbBYjOOLVxyFVn/zaj46Yp0VXaMOw1nlZhJnKcXQsJx0gJoXbJzhqXMAEUYlyGq9c1wdgQSBXE8l1jREheSOvQ0cfeRX88+8g4+XINHMQVcPl0OjfoyRZ3JmyxFBhhTKaBFTuwa9JPGjKsP23EId66pNJyNHw+kx9hfuti4zKPh+4qDKzImqe3EvW9LvOpRFmLrX2Uxvpo1FTEMNxGrXb1ke0Z7vcuC95O72ct3MSS89UfL7tYbP1vXYWRLQ8C82nSl0K+WK6SnZZVbZLDHRpCCYtfelsLw7JJdfz2uhT+702K/cMywBt9oqHNmoTZubqV7787HlJwx1FqO2KI+EJorlVBtLfK7PJ4fOhDL7SQ23Tmb67gx0VsXcDYP/832+fsZsVMzSvS/3CiJjMDZAG0NuCMdvDXLySCkFUgqtHyScmaaundWnVAa+e66Sx7mp7VFD2d91rm0/mT6kUthgdXh1QRF/0/Ip6hP5huj45XBDVGZvX1ZQluQO/BXZXjyiuHXjM+ciVm9ZSPvoSKLFn9QolBYAEnDPQ3meQJpCkgBKNo6sG2vgaH89bYRlanB14+4Oqf7bAr3180nN8Z9LDTJRFfw0lWJ3OGhrRI1NyQ5YEzAsUO+H029+cDiasAmGbTULVUCBCkqyPlboA6mBIxBGWHngeFhEu5HagTbe2Xbew0EmTDW/5vz/BCGK4o27Md24EDRxAKVS/gyU4yVrE2LtGN26kHjxWvloc59PFbZL7EjLB+5tx8lFaZU+DwmAVNAwauX4DQYtDhS9XUFO0Pzj7ryCBHw0ifW2bHRF/R/fHkbo30"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzZ1LxzrxmxpHgNeZSLdo5NH4e+CAkKusd4OsU8TjwR1I5d+WdSj/+S8HytK8K2YPigvBtEY9XgofkGiqrzKAwfbVwL8iggHPAXULtIEEf81aDQcffs8YcGJnarrHiuLXHY9sS5aWGrYMxww2carU1V4S+/2Dfh392/Ngw6Wenlj3N8Az6aIsyAhqgRBpBRZpV+WOHJd2UjgC6iRQMcKsP6HBZdKnCyjOciwbngIzmdy4grQlt7jsJcOZdADlzuCBMUI61/kvpm1UnTh26u2Fb1G1Tpld3vDAKuPG3sl9I+1ny8OIOI3NOpNKfHIf942D95exeiEtjiUhbLIOfhyCokBbK0aHNdcqbIjQQCc9S5ht9xK8QBJRGL6yG39HN5sXeNJFPz4Lt0+Sq8QYT2Y+BpiBnwoPb28TFDNZyueqzobB2eiuI8tMtyTrU6nayLx9Y1U5jKQD3g1lY6avuXXosoNj9Sh/tVVLxDJX8quuyMcOummjEMLrmQSideqi9Ys5C06vWGDYiPGgl7R0MZxmZXHa+h34xhIr6VgAyDA7mx++MdirN7Ezw4q0+cIKQ0CnZuqdZr7XE4Xa+PtXG6YQ/lNWykrEA/rl4iuALKM/s/NWYOdEE36AuU6Ee4z5zkTQOMFS89gnRUfjrNayyYm9typrjUVU4j3ONiyT/1h81Y1vrxMXnW7raM4QfN2+97plyLvs/w6EQkEdiSdB1FFzzVlN0raxaeNnh8D1L7xBUDOhnw2z8CALQsvYm+MbaZIRiGlwqgkE/vaSQ/9WEE+NRi"
`endif