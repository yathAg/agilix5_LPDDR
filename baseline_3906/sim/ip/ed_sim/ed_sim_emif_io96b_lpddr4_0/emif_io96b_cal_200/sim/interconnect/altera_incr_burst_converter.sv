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






`timescale 1 ns / 1 ns

module altera_incr_burst_converter
#(
  parameter
    MAX_IN_LEN          = 16,
    MAX_OUT_LEN         = 4,
    NUM_SYMBOLS         = 4,
    ADDR_WIDTH          = 12,
    BNDRY_WIDTH         = 12,
    BURSTSIZE_WIDTH     = 3,
    IN_NARROW_SIZE      = 0,
    PURELY_INCR_AVL_SYS = 0,
    SYNC_RESET          = 0,
    LEN_WIDTH       = log2ceil(MAX_IN_LEN) + 1,
    OUT_LEN_WIDTH   = log2ceil(MAX_OUT_LEN) + 1,
    LOG2_NUMSYMBOLS = log2ceil(NUM_SYMBOLS)
)
(
    input                               clk,
    input                               reset,
    input                               enable,

    input                               is_write,
    input [LEN_WIDTH       - 1 : 0]     in_len,
    input                               in_sop,

    input [ADDR_WIDTH      - 1 : 0]     in_addr,
    input [ADDR_WIDTH      - 1 : 0]     in_addr_reg,
    input [BNDRY_WIDTH     - 1 : 0]     in_burstwrap_reg,
    input [BURSTSIZE_WIDTH - 1 : 0]     in_size_t,
    input [BURSTSIZE_WIDTH - 1 : 0]     in_size_reg,

    output reg [LEN_WIDTH  - 1 : 0]     out_len,
    output reg [LEN_WIDTH  - 1 : 0]     uncompr_out_len,
    output reg [ADDR_WIDTH - 1 : 0]     out_addr,
    output reg                          new_burst_export
);

    reg [LEN_WIDTH - 1 : 0]        remaining_len;
    reg [LEN_WIDTH - 1 : 0]        next_out_len;
    reg [LEN_WIDTH - 1 : 0]        next_rem_len;
    reg [LEN_WIDTH - 1 : 0]        uncompr_remaining_len;
    reg [LEN_WIDTH - 1 : 0]        next_uncompr_remaining_len;
    reg [LEN_WIDTH - 1 : 0]        next_uncompr_rem_len;
    reg                            new_burst;
    reg                            uncompr_sub_burst;


   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate

    wire [OUT_LEN_WIDTH - 1 : 0]   max_out_length;
    assign max_out_length  = MAX_OUT_LEN[OUT_LEN_WIDTH - 1 : 0];

    always_comb begin
        new_burst_export = new_burst;
    end


    always_comb begin : proc_uncompressed_remaining_len
        if ((in_len <= max_out_length) && is_write) begin
            uncompr_remaining_len = in_len;
        end else begin
            uncompr_remaining_len = max_out_length;
        end

        if (uncompr_sub_burst)
            uncompr_remaining_len = next_uncompr_rem_len;
    end

   always_ff @(posedge clk) begin
       if (enable) begin
           next_uncompr_rem_len  <= uncompr_remaining_len - 1'b1; 
       end
   end



    always_comb begin : proc_compressed_remaining_len
       remaining_len  = in_len;
        if (!new_burst)
            remaining_len = next_rem_len;
    end

    always_ff@(posedge clk) begin : proc_next_uncompressed_remaining_len
        if (enable) begin
            if (in_sop) begin
                next_uncompr_remaining_len <= in_len - max_out_length;
            end
            else if (!uncompr_sub_burst)
                next_uncompr_remaining_len <= next_uncompr_remaining_len - max_out_length;
        end
    end


    always_comb begin
        next_out_len = max_out_length;
        if (remaining_len < max_out_length) begin
            next_out_len = remaining_len;
        end
    end 
 

   always_ff @(posedge clk) begin
       if (enable) begin
           if (new_burst)
               next_rem_len <= in_len - max_out_length;
           else
               next_rem_len <= next_rem_len - max_out_length;
       end
   end
   
    generate 
      if (SYNC_RESET == 0) begin: async_rst3

       always_ff @(posedge clk, posedge reset) begin
           if (reset) begin
               uncompr_sub_burst <= 0;
           end
           else if (enable && is_write) begin
               uncompr_sub_burst <= (uncompr_remaining_len > 1'b1);
           end
       end
     end 
     else begin 

       always_ff @(posedge clk) begin
           if (internal_sclr) begin
               uncompr_sub_burst <= 0;
           end
           else if (enable && is_write) begin
               uncompr_sub_burst <= (uncompr_remaining_len > 1'b1);
           end
       end
     end 
    endgenerate 

    wire end_compressed_sub_burst;
    assign end_compressed_sub_burst  = (remaining_len == next_out_len);

    generate
     if (SYNC_RESET == 0) begin : async_rst4
       always_ff @(posedge clk, posedge reset) begin
           if (reset)
               new_burst   <= 1;
           else if (enable)
               new_burst   <= end_compressed_sub_burst;
       end
     end 
     else begin 
       always_ff @(posedge clk) begin
           if (internal_sclr)
               new_burst   <= 1;
           else if (enable)
               new_burst   <= end_compressed_sub_burst;
       end
     end
    endgenerate 
       always_ff @(posedge clk) begin
           if (enable) begin
               out_len <= next_out_len;
           end
       end

       always_ff @(posedge clk) begin
           if (enable) begin
               uncompr_out_len <= uncompr_remaining_len;
           end
       end




    reg [ADDR_WIDTH - 1 : 0]        addr_incr_sel;
    reg [ADDR_WIDTH - 1 : 0]        addr_incr_sel_reg;
    reg [ADDR_WIDTH - 1 : 0]        addr_incr_full_size;

    localparam [ADDR_WIDTH - 1 : 0] ADDR_INCR = MAX_OUT_LEN << LOG2_NUMSYMBOLS;

    generate
        if (IN_NARROW_SIZE) begin : narrow_addr_incr
            reg [ADDR_WIDTH - 1 : 0]    addr_incr_variable_size;
            reg [ADDR_WIDTH - 1 : 0]    addr_incr_variable_size_reg;

            assign addr_incr_variable_size = MAX_OUT_LEN << in_size_t;
            assign addr_incr_variable_size_reg = MAX_OUT_LEN << in_size_reg;

            assign addr_incr_sel  = addr_incr_variable_size;
            assign addr_incr_sel_reg  = addr_incr_variable_size_reg;
        end
        else begin : full_addr_incr
            assign addr_incr_full_size  = ADDR_INCR[ADDR_WIDTH - 1 : 0];
            assign addr_incr_sel  = addr_incr_full_size;
            assign addr_incr_sel_reg = addr_incr_full_size;
        end
    endgenerate


    reg [ADDR_WIDTH - 1 : 0]    next_out_addr;
    reg [ADDR_WIDTH - 1 : 0]    incremented_addr;

    always_ff @(posedge clk) begin
      if (enable) begin
          out_addr <=  (next_out_addr);
      end
    end


    generate
        if (!PURELY_INCR_AVL_SYS) begin : incremented_addr_normal
            always_ff @(posedge clk) begin
                if (enable) begin
                    if (new_burst) begin
                        incremented_addr <= (next_out_addr + addr_incr_sel);
                    end
                    else begin
                        incremented_addr <= (next_out_addr + addr_incr_sel_reg);
                    end
                end
            end 

          
            always_comb begin
                next_out_addr = in_addr;
                if (!new_burst) begin
                    next_out_addr = incremented_addr;
                end
            end
        end
        else begin : incremented_addr_pure_av
   
            always_ff @(posedge clk) begin
                if (enable) begin
                    incremented_addr <= (next_out_addr + addr_incr_sel_reg);
                end
            end 


  
            always_comb begin
                next_out_addr  = in_addr;
                if (!new_burst) begin
                    next_out_addr  = (incremented_addr);
                end
            end

        end
    endgenerate

    function integer log2ceil;
        input integer val;
        reg[31:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i[30:0] << 1;
            end
        end
    endfunction

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FiKhaYqqrSNY3qdBFG9sHBPMTANMRO2i7vUxt8LXMxJFLeX6DAqWooNfg3JYN27ZG7VKIOfOaquBZrljNixqQtU+Ts8B/Ud/8cxzl+AIbgQiESlD+wfvrXmBxLgKAvGJvD6PUJr83QIDl6HW38Bb0xcRPMbb8rqFeSRZDL8G4gZZXDPUCYGgnncyxKfnDwTJfzv7gxZQ/XLnvMiriU5P5TCJKuF2ZS0mNPmL76uQszLEI1uj+xIzLwFZQ/Hw/i6/jUKw9RTS0bFB/+rmjLD353vqC8MWR/2pFZSIZOiDpgc3AYSQ1C9ChiLYiitiN+atcxonIWhthf/+Tju7Il3984VyYvKYVL5jPYcIoNul/2U8g4qyQIHNkq3VINgqBxTMoFzresUHJPgZahr+Ir6mWwL0lvcY5q9edfoxfVd1R8ga+RdMxkJF0h97Yqqdxr7taOsrKoPa+4jNS3wWG11y2UQ/OkMMOdxt3GralcYlbNr7mZGWRXclpM00wxkttpg9Ug7GWRd1Hu9v9QOSXC8gMnB3LzXE/ObaStEncHtOZD7SL0NgBcTcRuqZNL2S5Fpw6bkXImtOtSfub59EF1fIqCOa+k6mJtfYQ8hDUavXkpCK4upmU0r4IZljPwmTw3kIG6p03Gw2bVPRZFXGgBRglDam+fMwYfu7by0YpmO9ikknqpdmkVA6hurn4JGxBppCSKYFvRZteY79CtXLUOyHRGFjhKfAg5LwOxjwhvI8inSLfuOA2VJreqdGameq8oRqkMywy9pzBspQ/yopwRgVgYR"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "WgQPBVH1VBdyP1GnR2LUpBzapu3xqcPGd0xGo/Q4H4WpUeO+Hjltnkr805HvMqRkWDh3DyN3peSztswEbmtfL0y+XxwNgZXD8HzMTx127Mwzcyz+hm45kBealsJBAXnHmYFlorRoaB/cee+emunA/0c48mpmEF4OlQtcwz5XqcWvwenzsvQhJKdJ/IF87NHqDP/WjB3TeL4879eoAz/zIDUkxAOJQxnV3qexrxF9wbIWKPBxM0Z/9rwiJ5J7UxO+zaMdY6Ilrpy1551tqNmHQi/T9/OMzgeHTWT4bIXLTlxBE9zf9txXQvpAEWu1E0nSpjawhseslB11gaRGcfYRmFilsYvQ2N+pFfeidufGWrA0yuDKj1R8mJSJnmSGaTM2OhkEq1+ow5LLidUgegCsSLXkQMj7EHXeHuYcOM5iuau6HStyuVb31Jl7fvpllIakYVdLeoB5cGLj+U2rDnrgV0eytG3PqLPX8bakFdQ5LJ0qDrpEj60ClvfIEwj8QHcmrb8H9o9tW6W6kAim7shrMWtsHE2ll/If9l5D3bjeGsNUfIGMHIjjdteO2u7H38j+Rg2KKHhT7b0DL3hGF84gZ8ApkPm1PY3gzvotO+WVuaaXE8IoMih+ba1shvbHRyNlt+6d/xXhI2T/u//a1aIzTMUCnqvJQSFiu5QS73Tx6vZML3drQo5KKs5qXUBw3tiEVSNTAC2gmIfeVCk0KY7tYtJbp+g7USc92NRwEmtT6kcPDNXHSfljkZ0uhYczqqg5/XPId26D7FTNT6xu27iM7eDvzIEur1Rbf2hX1SFYqM0SdkathCB+26JIubBBTB5PNOQbzGBKLoLxEh2sez+G6h3Khwz860vfpavurf2+GMiWeSCzCWcLDuikFbGvILId4eTrrcubzJBo4YCeegG4e7o9U5r2ZC9MSsBPc+4WxPnRZ452GfHOrtqSkTaPl7GSTR5tlOfouKoYgfmvXvzKqQxtV2gtw5cpvk8eNWg8OZgNcvGJrE3j+Ika+kOxkWvG"
`endif