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




`timescale 1ps/1ps

module rd_sipo_plus_cwyib4q #(
    parameter DEPTH = 1, 
    parameter TOTAL_W = 35,
    parameter ID_W    =10
) (
    input clk,
    input rst,
    input in_valid,
    input [TOTAL_W-2:0] in_data, 
    output in_ready,
    input [DEPTH-1:0] clr, 
    output [DEPTH-1:0] shift_occurred, 
    output [TOTAL_W-1:0] dout0

);

logic [TOTAL_W-1:0] mem[DEPTH-1:0];




logic shift_in;



assign shift_in  = in_ready & in_valid;




always @ (posedge clk) begin
    if (shift_in)
        mem[1-1][TOTAL_W-2:0] <= in_data[TOTAL_W-2:0];

end

always @ (posedge clk) begin

    if (rst)
        mem[0][TOTAL_W-1] <= 0;
    else if (shift_in)
        mem[0][TOTAL_W-1] <= 1 & (! clr[0]);
    else if (clr[0])
        mem[0][TOTAL_W-1] <= 0;

end

assign in_ready = !(  mem[0][TOTAL_W-1]  );

assign dout0 = mem[0];

endmodule
    


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOxZGkRHpNGT3vV2wxfMNqH0CIAHfRsWq6A1fJmZEUi/tFoF5v9rRkRbxhj5YcV2b7WOtWruwi1R38FEzjqfoeDZ1XfwQ3sLNvvmsN9r7oJ/yirCB0DpoGSHihXhVp9Tr4hbmu4Rrwt90umet83PJrBfhIepdO5pIlmRvcn5kdFxHBmMLynIaLA3FJui3MT8B7f17XSaUo+Pt40ZMzV/PwHT16LrWuuihmIPaBJJ5RznAxocg28UrQLswfRL8xo0rB/BN9xY1W80UTSg4sei0x5gDEg4Uz+8kjidTprqih80dm8cPX1er93WdL4rt9QSfICMs3b3vBqImS5HKpYcwSH8TC2l8toU4l1z80bDN76TOOHXCQQXN6CL6NLOpQMqreulykz0M9Q3ieEKjYxDm97aVzhYSUlp8uCYX256lWyRRynb3/kQrKejt6foBFFU3GmJrc4buMF4At8rzI+36nBcLz7w1+SOUE1B/KFba7CfHmhPXIQixJbA3RMXT0f825FZIqFQ2d5AaK3aKXNbSGe6hc1Pbpik6DCGu4AXZqP8/FWm4Yu3xPagNDyhgWqvjhgkVXEqlNk5dlwQn8/+b4smW8pC7QJEbVlciTcg1veu8gjWBczE+8+v8+Lw0goFwdLYIseu8pkibn8YdgGQisPl3gB0B2lhUJnY94un6vjUcZ8kBUyezuuq8MA9XA0OvzYGC7jIf+PV+oFa0fZO8oWtjsWDjD7PC8yx3W62hF6N6fDSn0Rw9Htw5DmHhMXn3+wSYKeQxyrFjGRdw0khDxVy"
`endif