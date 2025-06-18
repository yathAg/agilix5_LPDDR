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
//| Avalon ST Idle Inserter 
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps
module altera_avalon_st_idle_inserter (

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
         if (in_valid & out_ready) begin
            if ((idle_char | escape_char) & ~received_esc & out_ready) begin
                 received_esc <= 1;
            end else begin
                 received_esc <= 0;
            end
         end
      end
   end

   always @* begin
      //we are always valid
      out_valid = 1'b1;
      in_ready = out_ready & (~in_valid | ((~idle_char & ~escape_char) | received_esc));
      out_data = (~in_valid) ? 8'h4a :    //if input is not valid, insert idle
                 (received_esc) ? in_data ^ 8'h20 : //escaped once, send data XOR'd
                 (idle_char | escape_char) ? 8'h4d : //input needs escaping, send escape_char
                 in_data; //send data
   end
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "c4gADhq5LKlTj4t9pT5ZoGD8hdS6zguTTpIWD+v0ts8ckIq0iU2Ub1Qr10SOiCOCSlJdrdwa4QrEMTU54pSqLbdGRVzHnQaSXw4YF+NX16m/akeI64JDh19p0Yf/IUQcdxXGowTyYNtv0/aE3ProV1D4A2phx4Tav5iccSPNAo1YKqf4/8m+JwqT6N5VCrBLiGQ7JYeByRCXP4VE+qFZuWK9E1884tesfwo4ECtcLK6jsgwtc6YulSjU1ticF4kK1+p9Eo93btwuEiS7RdjhsDRT0QwKPExjPj3sUSrKpDXAd9VHJQQmB04tABnlKT+QTsw2kkHL7sdAiVRTcHppEkNUrNss4wQb8GvaS7MF0JJVlyy3829Zj8EaPJelRR8qB5GqjR8ordeo/QFpLmuNoRbjNZ79OSFM+lxVADgHUM6QsSCumXrfMH8py8J75ZPVSLkZOS1Yg4yZ7CDzVJ6FJ2F5/aaHhBgLdEpe90dyJEj4kmYWsTIEk1FV5N64SUVYt8IdOnl3edqG53I0n02v9ycGxIJawGbvFhvLjklwrRIf39jWjxeF/1LIRACGKAHWcnRKv4AbWk3v8XaOtntf4JBVLZ3VbfW338xD/vvbtOz7j7vWqiULuW+HJugANaF7G8LOpDXYXXzk6AKHMnT8ZGT+7bzeZoszH/2hf+alxUoE+ABj6O8695I5wZahk9LXZvQZcokYSD3dMpoaBisulO4iPPB/5G/dAFRVzLXQI0ZMWoY3JAPU0fbzkWluyy7Tfc7IesZWT7VdLGHtF6O/D6TZxxRIUQY1jTtIPgte5LYXeSf0DgwZlMEtz3UWH0na75xioSvGmntkIjOuaDgMmajDP9p1Lqrra3CHFfzSv8pSJCrVCzQP8RfeDNf/ZmLYFSad85qLEfZWxCMWLLKQ8n+9oF6VlemFDF8W93IVMKkLIzf5MB4cZAZKf/8g2e8dI14VrZcoS+4Wk8KpTU4d/IRtaLR/lvy0yEprNX+5XcejuPCq4qDdxQFQx6mOiVgv"
`endif