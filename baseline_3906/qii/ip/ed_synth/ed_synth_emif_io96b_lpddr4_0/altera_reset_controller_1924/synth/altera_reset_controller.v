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


// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/24.3.1/ip/iconnect/merlin/altera_reset_controller/altera_reset_controller.v#1 $
// $Revision: #1 $
// $Date: 2024/10/24 $

// --------------------------------------
// Reset controller
//
// Combines all the input resets and synchronizes
// the result to the clk.
// ACDS13.1 - Added reset request as part of reset sequencing
// --------------------------------------

`timescale 1 ns / 1 ns

module altera_reset_controller
#(
    parameter NUM_RESET_INPUTS              = 6,
    parameter USE_RESET_REQUEST_IN0 = 0,
    parameter USE_RESET_REQUEST_IN1 = 0,
    parameter USE_RESET_REQUEST_IN2 = 0,
    parameter USE_RESET_REQUEST_IN3 = 0,
    parameter USE_RESET_REQUEST_IN4 = 0,
    parameter USE_RESET_REQUEST_IN5 = 0,
    parameter USE_RESET_REQUEST_IN6 = 0,
    parameter USE_RESET_REQUEST_IN7 = 0,
    parameter USE_RESET_REQUEST_IN8 = 0,
    parameter USE_RESET_REQUEST_IN9 = 0,
    parameter USE_RESET_REQUEST_IN10 = 0,
    parameter USE_RESET_REQUEST_IN11 = 0,
    parameter USE_RESET_REQUEST_IN12 = 0,
    parameter USE_RESET_REQUEST_IN13 = 0,
    parameter USE_RESET_REQUEST_IN14 = 0,
    parameter USE_RESET_REQUEST_IN15 = 0,
    parameter OUTPUT_RESET_SYNC_EDGES       = "deassert",
    parameter SYNC_DEPTH                    = 2,
    parameter RESET_REQUEST_PRESENT         = 0,
    parameter RESET_REQ_WAIT_TIME           = 3,
    parameter MIN_RST_ASSERTION_TIME        = 11,
    parameter RESET_REQ_EARLY_DSRT_TIME     = 4,
    parameter ADAPT_RESET_REQUEST          = 0
)
(
    // --------------------------------------
    // We support up to 16 reset inputs, for now
    // --------------------------------------
    input reset_in0,
    input reset_in1,
    input reset_in2,
    input reset_in3,
    input reset_in4,
    input reset_in5,
    input reset_in6,
    input reset_in7,
    input reset_in8,
    input reset_in9,
    input reset_in10,
    input reset_in11,
    input reset_in12,
    input reset_in13,
    input reset_in14,
    input reset_in15,
    input reset_req_in0,
    input reset_req_in1,
    input reset_req_in2,
    input reset_req_in3,
    input reset_req_in4,
    input reset_req_in5,
    input reset_req_in6,
    input reset_req_in7,
    input reset_req_in8,
    input reset_req_in9,
    input reset_req_in10,
    input reset_req_in11,
    input reset_req_in12,
    input reset_req_in13,
    input reset_req_in14,
    input reset_req_in15,


    input  clk,
    output reg reset_out,
    output reg reset_req
);

   // Always use async reset synchronizer if reset_req is used
   localparam ASYNC_RESET = (OUTPUT_RESET_SYNC_EDGES == "deassert");

   // --------------------------------------
   // Local parameter to control the reset_req and reset_out timing when RESET_REQUEST_PRESENT==1
   // --------------------------------------
   localparam MIN_METASTABLE = 3;
   localparam RSTREQ_ASRT_SYNC_TAP = MIN_METASTABLE + RESET_REQ_WAIT_TIME;

   localparam LARGER = RESET_REQ_WAIT_TIME > RESET_REQ_EARLY_DSRT_TIME ? RESET_REQ_WAIT_TIME : RESET_REQ_EARLY_DSRT_TIME;

   localparam ASSERTION_CHAIN_LENGTH =  (MIN_METASTABLE > LARGER) ? 
                                            MIN_RST_ASSERTION_TIME + 1 :
                                        (
                                        (MIN_RST_ASSERTION_TIME > LARGER)? 
                                            MIN_RST_ASSERTION_TIME + (LARGER - MIN_METASTABLE + 1) + 1 :
                                            MIN_RST_ASSERTION_TIME + RESET_REQ_EARLY_DSRT_TIME + RESET_REQ_WAIT_TIME - MIN_METASTABLE + 2
                                        );

   localparam RESET_REQ_DRST_TAP = RESET_REQ_EARLY_DSRT_TIME + 1;
   // --------------------------------------

   wire merged_reset;
   wire merged_reset_req_in;
   wire reset_out_pre;
   reg reset_out_pre_reg;
   wire reset_req_pre;

   // Registers and Interconnect
   (*preserve*) reg  [RSTREQ_ASRT_SYNC_TAP: 0]  altera_reset_synchronizer_int_chain;
   reg [ASSERTION_CHAIN_LENGTH-1: 0]            r_sync_rst_chain;
   reg                                          r_sync_rst;
   reg                                          r_early_rst;

    // --------------------------------------
    // "Or" all the input resets together
    // --------------------------------------
    assign merged_reset = (  
                              reset_in0 | 
                              reset_in1 | 
                              reset_in2 | 
                              reset_in3 | 
                              reset_in4 | 
                              reset_in5 | 
                              reset_in6 | 
                              reset_in7 | 
                              reset_in8 | 
                              reset_in9 | 
                              reset_in10 | 
                              reset_in11 | 
                              reset_in12 | 
                              reset_in13 | 
                              reset_in14 | 
                              reset_in15
                          );

    assign merged_reset_req_in = (
                              ( (USE_RESET_REQUEST_IN0 == 1) ? reset_req_in0 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN1 == 1) ? reset_req_in1 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN2 == 1) ? reset_req_in2 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN3 == 1) ? reset_req_in3 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN4 == 1) ? reset_req_in4 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN5 == 1) ? reset_req_in5 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN6 == 1) ? reset_req_in6 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN7 == 1) ? reset_req_in7 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN8 == 1) ? reset_req_in8 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN9 == 1) ? reset_req_in9 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN10 == 1) ? reset_req_in10 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN11 == 1) ? reset_req_in11 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN12 == 1) ? reset_req_in12 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN13 == 1) ? reset_req_in13 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN14 == 1) ? reset_req_in14 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN15 == 1) ? reset_req_in15 : 1'b0) 
                            );


    // --------------------------------------
    // And if required, synchronize it to the required clock domain,
    // with the correct synchronization type
    // --------------------------------------
    generate if (OUTPUT_RESET_SYNC_EDGES == "none" && (RESET_REQUEST_PRESENT==0)) begin

        assign reset_out_pre = merged_reset;
        assign reset_req_pre = merged_reset_req_in;

    end else begin

        altera_reset_synchronizer
        #(
            .DEPTH      (SYNC_DEPTH),
            .ASYNC_RESET(RESET_REQUEST_PRESENT? 1'b1 : ASYNC_RESET)
        )
        alt_rst_sync_uq1
        (
            .clk        (clk),
            .reset_in   (merged_reset),
            .reset_out  (reset_out_pre)
        );

        altera_reset_synchronizer
        #(
            .DEPTH      (SYNC_DEPTH),
            .ASYNC_RESET(0)
        )
        alt_rst_req_sync_uq1
        (
            .clk        (clk),
            .reset_in   (merged_reset_req_in),
            .reset_out  (reset_req_pre)
        );

    end
    endgenerate

    generate if ( ( (RESET_REQUEST_PRESENT == 0) && (ADAPT_RESET_REQUEST==0) )|
                  ( (ADAPT_RESET_REQUEST == 1) && (OUTPUT_RESET_SYNC_EDGES != "deassert") ) ) begin
        always @* begin
            reset_out = reset_out_pre;
            reset_req = reset_req_pre;
        end
    end else if ( (RESET_REQUEST_PRESENT == 0) && (ADAPT_RESET_REQUEST==1) ) begin

        wire reset_out_pre2;

        altera_reset_synchronizer
        #(
            .DEPTH      (SYNC_DEPTH+1),
            .ASYNC_RESET(0)
        )
        alt_rst_sync_uq2
        (
            .clk        (clk),
            .reset_in   (reset_out_pre),
            .reset_out  (reset_out_pre2)
        );

        always @* begin
            reset_out = reset_out_pre2;
            reset_req = reset_req_pre;
        end

    end
    else begin

    // 3-FF Metastability Synchronizer
    //synthesis translate_off
    initial
    begin
        altera_reset_synchronizer_int_chain <= {RSTREQ_ASRT_SYNC_TAP{1'b1}};
    end

    // Synchronous reset pipe
    initial
    begin
        r_sync_rst_chain <= {ASSERTION_CHAIN_LENGTH{1'b1}};
    end
    //synthesis translate_on
    
     always @(posedge clk or posedge reset_out_pre)
    begin
        if (reset_out_pre)
            reset_out_pre_reg <= 1'h1;
        else 
            reset_out_pre_reg <= reset_out_pre; 
    end


    always @(posedge clk)
    begin
        altera_reset_synchronizer_int_chain[RSTREQ_ASRT_SYNC_TAP:0] <= 
            {altera_reset_synchronizer_int_chain[RSTREQ_ASRT_SYNC_TAP-1:0], reset_out_pre_reg}; 
    end

    always @(posedge clk)
    begin
        if (altera_reset_synchronizer_int_chain[MIN_METASTABLE-1] == 1'b1)
        begin
            r_sync_rst_chain <= {ASSERTION_CHAIN_LENGTH{1'b1}};
    end
    else
    begin
        r_sync_rst_chain <= {1'b0, r_sync_rst_chain[ASSERTION_CHAIN_LENGTH-1:1]};
    end
    end

    // Standard synchronous reset output.  From 0-1, the transition lags the early output.  For 1->0, the transition
    // matches the early input.
if (OUTPUT_RESET_SYNC_EDGES != "deassert" ) begin
    always @(posedge clk)
    begin
        case ({altera_reset_synchronizer_int_chain[RSTREQ_ASRT_SYNC_TAP], r_sync_rst_chain[1], r_sync_rst})
            3'b000:   r_sync_rst <= 1'b0; // Not reset
            3'b001:   r_sync_rst <= 1'b0;
            3'b010:   r_sync_rst <= 1'b0;
            3'b011:   r_sync_rst <= 1'b1;
            3'b100:   r_sync_rst <= 1'b1; 
            3'b101:   r_sync_rst <= 1'b1;
            3'b110:   r_sync_rst <= 1'b1;
            3'b111:   r_sync_rst <= 1'b1; // In Reset
            default:  r_sync_rst <= 1'b1;
        endcase

        case ({r_sync_rst_chain[1], r_sync_rst_chain[RESET_REQ_DRST_TAP] | reset_req_pre})
            2'b00:   r_early_rst <= 1'b0; // Not reset
            2'b01:   r_early_rst <= 1'b1; // Coming out of reset
            2'b10:   r_early_rst <= 1'b0; // Spurious reset - should not be possible via synchronous design.
            2'b11:   r_early_rst <= 1'b1; // Held in reset
            default: r_early_rst <= 1'b1;
        endcase
    end
end 
else begin
    always @(posedge clk)
    begin
        case ({altera_reset_synchronizer_int_chain[RSTREQ_ASRT_SYNC_TAP], r_sync_rst_chain[1], r_sync_rst})
            3'b000:   r_sync_rst <= 1'b0; // Not reset
            3'b001:   r_sync_rst <= 1'b0;
            3'b010:   r_sync_rst <= 1'b0;
            3'b011:   r_sync_rst <= 1'b1;
            3'b100:   r_sync_rst <= 1'b1; 
            3'b101:   r_sync_rst <= 1'b1;
            3'b110:   r_sync_rst <= 1'b1;
            3'b111:   r_sync_rst <= 1'b1; // In Reset
            default:  r_sync_rst <= 1'b1;
        endcase
    end    
        
    always @(posedge clk or posedge reset_out_pre )
    begin
        if(reset_out_pre) begin 
           r_early_rst <= 1'b1;
        end
        else begin
             case ({r_sync_rst_chain[1], r_sync_rst_chain[RESET_REQ_DRST_TAP] | reset_req_pre})
                 2'b00:   r_early_rst <= 1'b0; // Not reset
                 2'b01:   r_early_rst <= 1'b1; // Coming out of reset
                 2'b10:   r_early_rst <= 1'b0; // Spurious reset - should not be possible via synchronous design.
                 2'b11:   r_early_rst <= 1'b1; // Held in reset
                 default: r_early_rst <= 1'b1;
             endcase
        end
    end

end

    always @* begin
        reset_out = r_sync_rst;
        reset_req = r_early_rst;
    end

    end
    endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "YhH6PGYVoenEE7S8VcGktyZSI1C0as9hhWpkDVFoMerVMrGF+LJXcnB1kt86uLR5FfOvO1UGAwrdYfIrl3U9twFOsehaO27J5A8ppUZa28mirkCERAx8MhnZ5wnIFJtIMEhw2eDgfO/5gJy9YxGg1c3y/l8e2kzKYyfsj42ubldS1xZw+AUIBsJG8C6tHpW011NFcLT+taBVEoomxWb2F5mvBhtjCl+Qc9z3LJuz1ZqrT6mCiH4EsrPEFlehS9KkGiKnZ43CF1GWLUK+agJGvKQnmYlunkuJVBcdtz7pnoVTuwxrgoDy7JgDyf15C6fkdNLHrAUCMBk0896zjH8LFbmpYY6xRdqtN5kBRCd0ZhBmMGxYxN383ZLKUgFRikCLSqw6wRp+Xy7jUBRcAUmzQECH8G1k57SzGV6NiXXbQaDjAo9DOxEIEzTIXtIjOor5DkgXybeQ0qmpXgJ3JCXgUNX2jhN8g8bnlTrszf4Oq0kTEFWKOLCMIPWfZ1zfmmpaPr0PwEG8KvDn6dYdLUqzB/V0kU1EA/8GP1rwIhPsZ85DkYCXyoZEL+PauBq5ORb7qvdJCBCHm55ymE2YMjsxViaVax4bnsBB1pnwnbWVEx9m7R37FqInC+LOA2S+TLBiRaFVqYbZYaULvNUBPbUZjLoyzYowQrAGNHTmTaDhpbyAAD+8QMyGttKyyivaUMH7EwnbGTRxkz9lid8E8WEZ3v/Newu9QFOxRlyLGpYg1bwXtj+/T0xCm/d+k/YqQpa9p4jUAJZxoDuLCp9NgXVO3g07XZKrPcIGrXnBr8sMct8Fq6/w+36DTy53jXDXw5vMUWzZOLEGiPq2vZE+eA2NABMlGIQDLEzk+ipxjpVUDtXDUFhr2/+jcQecofoq9FaNleBbuBiXdr4fv1Mdug7Hz1TiDWxUD1GG26d/f5y8+FndQezBbKtIiaHto8+UUggKm0tqmHOGmUKhrX7jsCRw0UhDcJbDpGQeG6xcpTUM9LZQmdl9QDEdxFe+DN2YlSCi"
`endif