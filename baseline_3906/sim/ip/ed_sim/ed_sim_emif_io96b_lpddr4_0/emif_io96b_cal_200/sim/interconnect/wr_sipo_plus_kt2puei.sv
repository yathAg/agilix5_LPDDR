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

module wr_sipo_plus_kt2puei #(
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
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFlfZfsOd2cCkp35z22E7v9GOX7YJ/sWPLPLtfg+SxdUgnBCJHdx9u0iSJ94f1tcMSyCZTGB6UR5TVHDevfkG+PaHgBnjrXOMw+1r0AUW3ql0ew+PbZdfRIFTSSTW2SehvN6LEVMEv46bRQzq8zseVV3hDyGFtIyFd0kmUUZ7EVn/FzDZnIDqEDPrP9si1WnBkUkO2yfzK6duhFqo2ypk6wOMNAJprweynWIF507McZS7wMRuQPEi6uLa9ptlEWg58Cv6RmnpOc25/kNhwHAHu0yKomCiAjRDqE0oKIf8bVJUP0WhhejWi4hmMqeVyTV/i7ttSsXI3Yf6VGJ5I1C81WsfhqicCamtcO/+iZtHiv9a7UwtGB7+P5BuXy4kQlspDDPHbbBcmnAgeEgDSMsWLCzA7tFljYD+KUvWJ5Zp2G3UT3fkJBMh0DlEo/xeQ70HxHxBFBOwgbXptrf3OAhWd7/wP7FVEZo8dCnhkmXFPo9S3z1HPv4RJg4zR120PTLnDc32BOl0pRdvjTsOnwuAa9tbupM4nN4KW1w/4yo6UxsCXwwjLNQjrs1U/0LKqL/pjwJwFnfHTiuwdJtliUajvqh+sFPNbQX3JkPM/aHoSZEZJTj36MglaTRJ99YZBk1yuYKxknrDfh0HyXYOpdSZGzoA3INys/c5sX2P3k9+K/fDdMRxMflvGKdSI3NPO4g/nmv89+6r/+nTpGIZ8kQsg8ZEehaDrv9HmSPzq3f8UEpKPsDO0fxaC7WexagNatpvSxuAjhEHy68iku1uIpVB0Pzl"
`endif