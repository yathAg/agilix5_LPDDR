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

module rd_sipo_plus_kt2puei #(
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
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOxv/NE+n7KQdud+58W3BlniP3s8l/TOKquyzrMGLmwtsTm27S+dE5BV/coQK8zeLS3khUzbdkettheQHCEDuRm8jRYGA5CK7kka5sBYoSx9WKFxwYDElCg8RZ0cdg8ZcJc/V6YvXL53d+WeApPY2E2FZMAHfPdqhEsAwyc+Gt4Yi0TKWVhy4ONs1SL8Qzc9xW1sZOSY5WKOvzQYo54IZx+FAkzX5RuUTc8jZ5iLJQ6xwCZbQrXJvj6Qtg7QbBTYKvDX0XudyXtoYsC+/+5NLNE/2lZliYX9A5SYSYTWGui7Yvs+r/LXpb6e8xn6qaBAxGWm3tKrI0V7NYTRNPRvCm8eRZVpxtzw30vXK8NQi+xA+wuefPCV6vkGahtv7R26SyVY3pbPng9p0CU/luGteQ+8ZQm+DBlGUA7nEhrPgpm0w0xQY3BEELl4g4pCiV/F3lmgSxiExHR7M8xmHGPttixPN/ZRFe6Y9jM10C84/eu/+ytOUJ7Ssizpg7mDUw2dnbYmM3yTKWZhtGnB0azyBAbEq9PIvxspNtMfAgsuAko6XcNGk5bfTAXVCul9KOSEmU/EOq1nwBhrDMd6vI9YbqOT8RW0rBCnAuJH+FklQrn7zAHramxOzqZ+S0tLK9+mzQbkFOFaKrOW9Nm5ViFtOFCwYOy96cQCyPG3jBkGhPh4w2Zq2hIohvgtwje5lTG6NjWFm672wuCu7PMRIL5xrShT+XPg6+EYoaJ9+jyxtUCz/ltn5m7V8s0OSkCdEPLs/oHDuXwExFxksiauoU1QScqm"
`endif