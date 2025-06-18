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


// --------------------------------------------------------------------------------
//| Avalon ST Idle Remover 
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps
module altera_avalon_st_idle_remover (

      // Interface: clk
      input              clk,
      input              reset_n,
      // Interface: ST in
      output reg         in_ready,
      input              in_valid,
      input      [7: 0]  in_data,

      // Interface: ST out 
      input              out_ready,
      output reg         out_valid,
      output reg [7: 0]  out_data
);

   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------

   reg  received_esc;
   wire escape_char, idle_char;

   // ---------------------------------------------------------------------
   //| Thingofamagick
   // ---------------------------------------------------------------------

   assign idle_char = (in_data == 8'h4a);
   assign escape_char = (in_data == 8'h4d);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         received_esc <= 0; 
      end else begin
         if (in_valid & in_ready) begin
            if (escape_char & ~received_esc) begin
                 received_esc <= 1;
            end else if (out_valid) begin
                 received_esc <= 0;
            end
         end
      end
   end

   always @* begin
      in_ready = out_ready;
      //out valid when in_valid.  Except when we get idle or escape
      //however, if we have received an escape character, then we are valid
      out_valid = in_valid & ~idle_char & (received_esc | ~escape_char);
      out_data = received_esc ? (in_data ^ 8'h20) : in_data;
   end
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "c4gADhq5LKlTj4t9pT5ZoGD8hdS6zguTTpIWD+v0ts8ckIq0iU2Ub1Qr10SOiCOCSlJdrdwa4QrEMTU54pSqLbdGRVzHnQaSXw4YF+NX16m/akeI64JDh19p0Yf/IUQcdxXGowTyYNtv0/aE3ProV1D4A2phx4Tav5iccSPNAo1YKqf4/8m+JwqT6N5VCrBLiGQ7JYeByRCXP4VE+qFZuWK9E1884tesfwo4ECtcLK7iBMU487qwj0md9Xd7F1q4BW+DjgmhsSQER0heDUnuvgvm5EcZDMBzozkKCyvEmgBgV5paO6hvOQstI9AoS6COddpPVv88E2lQY5ZDwLb028riIa4V0O4u4vghBS/+oSNIQfZsQeZ7KeHdy0KRckIKAwuf/MEnWEG1vgQkR/wqpdsLhh3ULxEmBhfS+kQbCpzanOhfHEtSyIGwq5Spr8VxPHPrIiDijEtuvKRIDjG744S5v3DPhXtx+kioDBc+Fe3dBoP6avVVuiC9LIqIYHu76U9Vci0Ck2A8hClvgkXToxt2ETraZ7sxOJue7NqGEyVkLyQGB6RSMB1fLaZSBg+hqiZWnxdJ9Dz6WkuLuoNE2rOU/G+Jmo+ydN84K9inBYQecOIshzoCqpjFLlfl/imkN13HFQbmZFbdv4GIiFIUiRorIZk1/7G93C9nrBGHsBLTmZCnDbPe8MZcglhDGTm39TBek7orw+21jBQprsVl1gU1gXRXpqPMkk7qr83C6d+9VJhlGumWp1tG9saHrtG0mXUErvwBXHndY7inBK4CMuKx5opvObLbXy5v2C9uESOdEtlDwMYBFenknqzr9X/o/o2f9ktlVSFLO/s+xioVYQ24pwjUBnO1qBlMFi0xuot8vWffwAQ+iezaj7erAXZvfet6Vns6CYTPsZ/7vCsZf88Sd+Zrhyx0VKdQi8Oru/hbiOlFohHSiTeb7y5pECD1jrLlZfwXV1vFmdZUYtYQMSFc25OuiWx+HFn/O9c89UITkaqv2Y2kRl81piPnwz34"
`endif