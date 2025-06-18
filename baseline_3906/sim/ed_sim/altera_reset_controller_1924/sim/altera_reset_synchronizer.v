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


// $Id: //acds/rel/24.3.1/ip/iconnect/merlin/altera_reset_controller/altera_reset_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2024/10/24 $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // 
    // We omit the "preserve" attribute on the final
    // output register, so that the synthesis tool can
    // duplicate it where needed.
    // -----------------------------------------------
    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "YhH6PGYVoenEE7S8VcGktyZSI1C0as9hhWpkDVFoMerVMrGF+LJXcnB1kt86uLR5FfOvO1UGAwrdYfIrl3U9twFOsehaO27J5A8ppUZa28mirkCERAx8MhnZ5wnIFJtIMEhw2eDgfO/5gJy9YxGg1c3y/l8e2kzKYyfsj42ubldS1xZw+AUIBsJG8C6tHpW011NFcLT+taBVEoomxWb2F5mvBhtjCl+Qc9z3LJuz1ZrnC1AsDnOpIK1JLRmTAZCi2cd/DibKRrNhiumWgeJEPR0S0ed8YxFXHyAdEbgkRfGzrUHE15LL1rdAwIlRk0hl0OnfUD8wrYGXqiNPZfLQeUPf9vj1VGZGviTqiQQyPHfi2wU+8mxfeINkGE54aoEMBy+KrfuV+H9ZNtz+y15iFjk7TKoP8AgHHRO2Js5w/3V5BVUdWGsiG+CduKsM6yXz2q7xZjmSlaVLkauP8+eM5+JoBHN9ip8tAUcvHiyJBJLDAfujU4mj9nzrH+i5lLjcZxVHlEwBaPkNS45le2ry5Eij76bx3bQMlrMyJG2Liaec9DWwCgfD2WX7dMqbgAnca227qgZw4GGukWWpKegsPP1mEWkpZO0xK888sS/6LNwkvpQP+zA3v5+e3xtyAbPtq6ebPJNDhbdceDcAWZn05VuM6WxBISTqJyFenoNAsOCmJb1q5CdwCQGoZFnA17gnkcPJYlQcEJlio/Un6IRRWwM584jb9UMtQdKOYGXo9RAPCWmWOah7aXdfAKnSPopBZPSRQ3IFEDeX1CcTMGGBkQSQErzUVlKKR4pU1E5ZpLllFLeSAS6MzHCR4NGJYFDKsEV/Wsjp018vORVxTpomEdwU1DinqysnjNzaic3U2wqCpJZib1XRhzgD0Hqrg0rVS80AuEenlnPEqL2QHf2UGDMVlRH84qb7iDpgBLAuaYuKmxRPAiQJwcEzfcbLinTVJmDzV1MfqxnuCzzH5ijL9tEH8XwpV10Qb5095dwqAGc2VpmpjK/Su6OZMp5L8XFZ"
`endif