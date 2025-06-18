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

module compare_eq #(
    parameter WIDTH=10
) (
    input [WIDTH-1:0]  in_a,
    input [WIDTH-1:0]  in_b,
    output             equal
);

assign equal = (in_a==in_b);

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "YhH6PGYVoenEE7S8VcGktyZSI1C0as9hhWpkDVFoMerVMrGF+LJXcnB1kt86uLR5FfOvO1UGAwrdYfIrl3U9twFOsehaO27J5A8ppUZa28mirkCERAx8MhnZ5wnIFJtIMEhw2eDgfO/5gJy9YxGg1c3y/l8e2kzKYyfsj42ubldS1xZw+AUIBsJG8C6tHpW011NFcLT+taBVEoomxWb2F5mvBhtjCl+Qc9z3LJuz1Zoq3ztKXsPWY1KNvW1bGoKOGyCsp0jEn9bQ4cqVbhKMy79TH6cXkvfqJ+J2LMbMttZ13OgCEgwhe4+6Dd0aYawh3+XGU94+cOnV/cTUKeBRqwPfqIIdj4SxIsxDN+eIRpO24eDZ4aYz4IIUzkrhCPw8m5FiwTxUXvztcok8LrqM5yFGzoy5KnzC6KtbHyYx2R3dzagb/1E8uk8GQdy9r5qrRIoD190Ce32iDLT76Bl7D4RTCY3jYArN9HfpLvC2E+Q3Ujh0QtxnNNcuqj9D+oU7qjdukxd311aDIsQv0i+F5f0ddCwc1lHTOy+Qy3P06s2qVNijO0SXfxvU+5aaUIHCurY+K5W1bWQKNxsxIWEgMuMgfxG81rESFssV+Z6SIO1CaEfPNoeYmcaMyC5eeV6V+Myf1pRE7IPm2utV/gWvMcDrRpS6eKTBgtX2U+l+WwFswLv9WxoAJ9ymyQNs6wg/nOz3EAn7iU0Boc8YsgT3VmGdAyis3rY+3mcPglG45MEKDDWxgwBKm1IH+KMVwcUhhrpby7mylhOkIiWp0WlOmAzit3xav7EQJEP6n2TQyeXmc6WlIKU/ucvw7K9LGvrfYwE6n+pAFz0J2LZaXArs/gdPNelBtEe9kcq/LRYsyseesmT5CM1cGGGmnDxi+EFaS8917FPjItUY9bWy9q7CvJ3UiXztRmuO1V+vPVUVPyKxVp1TFFqw6jmzsKSa8KmoyWNYHbqrhC9I7Db/qcULtcTxyugWPhcf2Xql1HmmYe14t8/DeCgv1sEek6GdFJOn"
`endif