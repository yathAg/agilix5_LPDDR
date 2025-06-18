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





 


`timescale 1ns / 100ps



module ed_synth_dut_timing_adapter_1940_5ju4ddy #(parameter SYNC_RESET = 0)
(  
 input               in_valid,
 input     [8-1: 0]  in_data,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 input              clk,
 input              reset_n

 /*AUTOARG*/);

   
   reg [8-1:0]   in_payload;
   reg [8-1:0]   out_payload;
   reg [1-1:0]   ready;   
   reg           in_ready;
   always @(negedge in_ready) begin
      $display("%m: The downstream component is backpressuring by deasserting ready, but the upstream component can't be backpressured.");
   end

   always @* begin
     in_payload = {in_data};
     {out_data} = out_payload;
   end

   always_comb begin
     ready[0]    = out_ready;
     out_valid = in_valid;
     out_payload = in_payload;
     in_ready    = ready[0];
   end

generate if(SYNC_RESET == 0) begin

end
else begin
reg internal_sclr;
always @ (posedge clk) begin
internal_sclr <= reset_n;
end

end
endgenerate

endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOyo8J+g1ggiLpyy8pzMC7inOi2YBoYwvlGfLN8B8LOcqrkMlGaHsQ81MKtlW6Ugv1R7WAbw1u1QO9j/J21J/jTYJjAgclwMkirJhWrKH09xJdEUlXNOiHQvfWbWAIZmBRyOMIdibmwwqDYVNzSfRhEpn/jo3wjBrRAurH3b26/01rAapW9iUdYCRamTIfdLEmOrfoiOfF9YkZIj391zF2IRrGoiolnQBza+n9QGqAi4oHJ8kRdP387kv6SpTAg4RvWsf/pf7QXr1QZb8FhYohYQMhjy5rmZrdeag3XvwbesjOOBfsoKoDwuO3fkKjkoEQzCoF78EiYu3nB6LWV2qZ5zv5aapQlIaVU8Kl4nfXic1e1aXBypy8Ocva2S0qY/+eg1HMOOgHdktWD79f3Sd9PlqIiq/1s8nKLWeAqb/3akHY8WQ4f81meJMTRQxkG3IS4B2fCEqdVz8JF6wgnV8jZgsCUqhubs3ID3irjmZQAdJLMbBE+FSVUAn/jq3buEILXOtzYRYtOamqNGhKLYhskVd5uGcPuGaS8nWts6YHsGQJ1oDq3jy5w2llr7rUbCbLc4riZQwz+W2jZ0MqKtygX8B6nHoGIQvehxq0a73u1mBHmymrGzwlisKoChQ8/VxMTc68CdpFbu9Vxo9IP14rw0d61uPjWnHewvdWakNB6OawDLzD9A4qAMQkPGA5F6oEqoAs1DAjKz50id8GeeIyg+/RMp1vnbkt3zinzQkjLWFt5RE6D8yVmdgpEfK5WwKvas4xgjpZK0L+6S1/Dex+8N"
`endif