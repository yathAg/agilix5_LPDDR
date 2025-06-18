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


module wr_pri_mux_cwyib4q (
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
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFldI/EHbpvu90Zk6wYlmfBCtBEv7TdLdRMHoUdPS88mB1NG5yx4TL+doOh+lsKoMFxPtzDRclj8c6Wbm3/iM2EeMIl278nKVChEOOfbSpYkg1piOW5/SMPQRY3ugm75Hr82T/4ISrvzDbK2axDrwEjrV2vH86l/4qhFtjJCgQGC7f0HqRZTVVtWrqTdFMc0/n3LZ8LYE1qemWnqW/EKnXhZRyxPPsh/k3y2APa66ALDg414evn19gU0E9D4BqOVI0fFJl/UZoLLfBCCr+aQGpvJO2+doq4I1NlGY37xAj87zUmtj3Yyfflpt7zSipxEX7aKFfBcOu4ugFtOKZVRuu1yQS5IdVgPfrzCKaflOd68Izi9DCujgNL4rwY92syYN3TOa4o3jOAfz+mYmXHfwE3Pc1U7YNmhPc6yXUqGMyMODLtPLDv7K4tgY9H9F+szdDr8z22Eo8MQH+r1nape7aJDzgCrRkFTXb/U2PHxdvW+q+uOrQ8ZMydO8kjZ1uexKmvdNygql709vMwG/K2h7e3upM+lZsCbPkg6UJkGMnsHPJJoOvM+1xT4PZ7mBFBc07LOqPcYbqFVeoO30q7qiFBWtVQFj1qgLmN6uonmO3ZWoYV7IYX8vsh0ymHUUVlCfZKcyk6EsJ/3Lc7x9EKrp0ZK6nvIajggfhgTwo6qyBAAk0RD+bsGsGYHg9vnOvuW6jsoDX9unLjbXoNMf8v8ifBepdBzQjfZKGiMxXidEdm2uisLk2IcUNDUGmatP12OsxI++rIJZNJIp5bxQbKquMJ5w"
`endif