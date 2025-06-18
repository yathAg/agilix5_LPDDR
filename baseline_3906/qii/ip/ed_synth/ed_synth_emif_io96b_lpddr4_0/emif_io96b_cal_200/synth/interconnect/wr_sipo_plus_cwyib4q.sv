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

module wr_sipo_plus_cwyib4q #(
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
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFlcq5s2hEBZnZcCjO3YUnVCrFyyA8M4F0mqysKNYNUF8yB8X2onWWItkBtG92RN71BO3YIieXQxlvr22AOqUlEmeSa8QIgE6Q2I6cBmJSEixpX+cFOhImBBdpZ+naga8ki3hWSTzJW0uwPDdH4ezBvMh+oQlzksXP9NunlohEHAjmd2iq3WrM4tjBwt0Gk+06EKfTD/kOVr3toNM5Y2kigMWnv5DjtsFvXqgs+9iXtbndmCJicaiOj909pH6ESETb9AxyzR8TIeWVlYMuNphFs/u8+Pfz2iDFKV8bLCK1XVCz6sAVPn8ocXBXkZ9IYxYA19hzmS5sPPLjPjLcHhdDw8h4io8d4/RK0XpFEu5H30MOzJKgTz12DVXaF3vDqqR/yhdIeE5Qp3dJpCfiWqf9O7mlEZUY5IdFHB3k/k8IZefeF+PiUcwU9TLA2pUZUU5eVyZ4E6bAF6oWEtiIoY+SERIiglRqrhqhajAmFinZdODdIP94c14FnS4ost9NnzhBUyhKmxcQvQjBMFDUQph8+8liiqx1N4XObRD/pe/dGxAnMq1jM33J3q352VWhPSLPrFPdiODWyMKOm6IxrJdpK6hdCG6VgmLogO6aTf6KfS8x4qLtASYE+0cKbl77/fAhtR7HF6FH9Ji7EcNaDPEa8s4x3sHD6Q0ECDEJOXJJXU0UGgQR0GYIXcWogJOVZ3UAiwyV3vzecsT1RfgkjvDi6yQklffroR0fujUsWhbb7LzhyEK1nEqwF7ESOT7Ev5PY3rx+everyArIjzQVW+w62lj"
`endif