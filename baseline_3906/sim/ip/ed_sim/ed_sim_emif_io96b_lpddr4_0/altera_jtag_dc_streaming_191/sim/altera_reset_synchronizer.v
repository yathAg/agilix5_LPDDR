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
`pragma questa_oem_00 "c4gADhq5LKlTj4t9pT5ZoGD8hdS6zguTTpIWD+v0ts8ckIq0iU2Ub1Qr10SOiCOCSlJdrdwa4QrEMTU54pSqLbdGRVzHnQaSXw4YF+NX16m/akeI64JDh19p0Yf/IUQcdxXGowTyYNtv0/aE3ProV1D4A2phx4Tav5iccSPNAo1YKqf4/8m+JwqT6N5VCrBLiGQ7JYeByRCXP4VE+qFZuWK9E1884tesfwo4ECtcLK4F5/ipLmjeiAAYGRPKYbxlwskQHEZsOPxbQAlXInoJ/yvEjnhAVKNRaXotw1RZB2hwQqIAzJ5b5wgQoECntf8S7nuWBMlhu2jfbk9ZXaEwmiGmh4tnELp/7UNll2f+wDOashFulzlJ0x8VClYyvWR45ME7QoUmpMaMvPv84rlFgLLUtriTqvHMnIy389CipotoB5I/YfTgWeVwNW4QQn2BM1T+mUrJrdg3ww/Enmakzmj+BSfrgUzqGStHT5koB9msqy8Tg+1jroHToubfV+eA30Dkh/ZiHQgKPx38Mgu2ed1bpFoYQrcwCG2HF6KBVfafDIBZ+h7LjBv9HNaVQVZg4KyWoXSpL0WqZJaVLFny+mDhI67tsBXVHIDZv5+cWEYQ81EnSc0NzYAJvjOXb2cW+4SK6b37MAaS4kUDOzbuG3zQ4J6IqFARpFntWyrrpF2h/RJsX/S5rFv0fIF+UHZHFBeubbl2V57USJ62goIO/vaKikVWqBqwnwHWQ0AnjbppYnjPrexy4N8xuzB8NZ5MHyLuUBJnz9fdRz7GndKNwo7j8jOap4R7KEH/vYcofydGQzvrbJxwlQs0O5tCMbnHm/pqxcQ7i4bsZuUUZFOXac4S+yfB8jRMDU6ftJAZBPmuY2pRNcgx9RF8W5M0ERx0c2/EFvZwFP71cNdueZOkpxIQfzBXRhRjP1qBdGY591DxYUSEaldfJ0tI0MiGAc2sMFlvGfy3AThQJET0iuZRdkVCiUoTdo6U9ENSQqUw9t13X7K8VJ3e6TfDLbVJIMrb"
`endif