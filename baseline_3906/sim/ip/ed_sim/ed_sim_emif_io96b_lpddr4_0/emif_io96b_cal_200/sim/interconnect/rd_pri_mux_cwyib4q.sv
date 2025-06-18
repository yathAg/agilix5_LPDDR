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


module rd_pri_mux_cwyib4q (
input in0,
input [1-1:0] clr, 
input [1-1:0] shift_index_out, 
output logic sel,
output logic [1-1:0] sel_index
);

always @ * begin
    if (in0 && !clr[0]) begin
        sel = in0;
        sel_index=0;
    end
end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOxjoAdlE889J4yc1vjK6367PeZuvFgENHt9PRDSe5U0gL4/7xT9FFNOvfg4SWmJSxVGYxXd9CI+FIjX4j1Ht3yCqq62kiBjpMwBde5IBF47u88T7n8ZfusNDyILjjEqjUQsjO38KmTlLDFAq4PbKTk9WXxUhSX9IJcyphz7O+JBvUNDyzkkrec7UHkbM3fJeuf7QOT94oH12ijxDW71SXj4YjXMrmgdtUz+nBwnRyXhhWIowQDsN+iGgtVMrCnP0LxES+MvzQd4GaffkbkcZw8egrdDf1OvSnC9dqSTBc8UPgR1f7ePOMEC26uH9SzqX/CSGAaL3umUuO26a9gWrLyaevUR/wH6j8DahZ3m6XaRYLVAoTy2aUF9UiSY9lQYXpNXl7nUUtzjdxeNBv/yP1xEsZZGtoELfOVzo8k9bkfbfUxzUaAnR6G67NMH42XtuDMrq8rf+BH5P1AbqRTKKjUp3Wl5+oYcFo7D4YBN8VK548dYMarcQNzQ5TZAlJI2JiSSzB0Xot7Bkzbxf+ARVh+VDI84yF9Y3i0PO3yz2i5f7hVwQ5TQdWgNwtXB9e3AZhzWLVZfdOgjiw8X3Cnt4UsPXIfElLKAKSrawXInnQvjFWteS4j4cJSWNN19RAmTef4Sg0x679d8beWfyvITdCF2yx9HdKqoj9eRAPQr3vB9enYlq0iskVT7aItCUFAhOyMr9J3LJ/sdOKywx5EnF8jwnnkYqk+AD6aeTvQWevFzYcTcsgV8BTYAtfJdL5+8X6RHLtmG7uIZIMvDfzX64heB"
`endif