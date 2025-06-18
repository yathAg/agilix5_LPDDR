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

module altera_default_burst_converter
#(
    parameter PKT_BURST_TYPE_W  = 2,
    parameter PKT_BURSTWRAP_W   = 5,
    parameter PKT_ADDR_W        = 12,
    parameter PKT_BURST_SIZE_W  = 3,
    parameter IS_AXI_SLAVE      = 0,
    parameter LEN_W             = 2,
    parameter SYNC_RESET        = 0
)
(
    input                                    clk,
    input                                    reset,
    input                                    enable,

    input      [PKT_BURST_TYPE_W - 1 : 0]    in_bursttype,
    input      [PKT_BURSTWRAP_W  - 1 : 0]    in_burstwrap_reg,
    input      [PKT_BURSTWRAP_W  - 1 : 0]    in_burstwrap_value,
    input      [PKT_ADDR_W       - 1 : 0]    in_addr,
    input      [PKT_ADDR_W       - 1 : 0]    in_addr_reg,
    input      [LEN_W            - 1 : 0]    in_len,
    input      [PKT_BURST_SIZE_W - 1 : 0]    in_size_value,

    input                                    in_is_write,

    output reg [PKT_ADDR_W       - 1 : 0]    out_addr,
    output reg [LEN_W            - 1 : 0]    out_len,

    output reg                               new_burst
);

    typedef enum bit  [1:0]
    {
     FIXED       = 2'b00,
     INCR        = 2'b01,
     WRAP        = 2'b10,
     RESERVED    = 2'b11
    } AxiBurstType;

    wire [LEN_W - 1 : 0]    unit_len = {{LEN_W - 1 {1'b0}}, 1'b1};
    reg  [LEN_W - 1 : 0]    next_len;
    reg  [LEN_W - 1 : 0]    remaining_len;
    reg  [PKT_ADDR_W       - 1 : 0]    next_incr_addr;
    reg  [PKT_ADDR_W       - 1 : 0]    incr_wrapped_addr;
    reg  [PKT_ADDR_W       - 1 : 0]    extended_burstwrap_value;
    reg  [PKT_ADDR_W       - 1 : 0]    addr_incr_variable_size_value;


   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate

    generate if (IS_AXI_SLAVE == 1)
        begin : axi_slave_out_len
          always_ff @(posedge clk) begin
              if (enable) begin
                  out_len <= (in_bursttype == FIXED) ? in_len : unit_len;
              end
          end

        end
    else 
        begin : non_axi_slave_out_len
            always_comb begin
                out_len = unit_len;
            end
        end
    endgenerate


    always_comb begin : proc_extend_burstwrap
        extended_burstwrap_value = {{(PKT_ADDR_W - PKT_BURSTWRAP_W){in_burstwrap_reg[PKT_BURSTWRAP_W - 1]}}, in_burstwrap_value};
        addr_incr_variable_size_value = {{(PKT_ADDR_W - 1){1'b0}}, 1'b1} << in_size_value;
    end

    always_ff @(posedge clk) begin
        if (enable) begin
            next_incr_addr <= next_incr_addr + addr_incr_variable_size_value;
            if (new_burst) begin
                next_incr_addr <= in_addr + addr_incr_variable_size_value;
            end
            out_addr <= incr_wrapped_addr;
        end
    end


    
    always_comb begin
        incr_wrapped_addr = in_addr;
        if (!new_burst) begin
            incr_wrapped_addr = (in_addr_reg & ~extended_burstwrap_value) | (next_incr_addr & extended_burstwrap_value);
        end
    end


    wire [LEN_W  - 1 : 0] min_len;
    generate if (IS_AXI_SLAVE == 1)
        begin : axi_slave_min_len
            assign min_len = (!in_is_write && (in_bursttype == FIXED)) ? in_len : unit_len;
        end
    else 
        begin : non_axi_slave_min_len
            assign min_len = unit_len;
        end
    endgenerate

    wire last_beat = (remaining_len == min_len);

    always_comb begin
        remaining_len = in_len;
        if (!new_burst) remaining_len = next_len;
    end

    always_ff @(posedge clk) begin
        if (enable) begin
            next_len <= remaining_len - unit_len;
        end
    end

    generate 
    if (SYNC_RESET == 0) begin : async_rst3

        always_ff @(posedge clk, posedge reset) begin
           if (reset) begin
                new_burst <= 1'b1;
            end
         else if (enable) begin
             new_burst <= last_beat;
         end
        end
     end 
     else begin 

       always_ff @(posedge clk) begin
            if (internal_sclr) begin
                new_burst <= 1'b1;
            end
            else if (enable) begin
                new_burst <= last_beat;
            end
       end
     end 
     endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1Fi3emJ/3DhUHBwp+viQ8wX7rfUszlzZvPgXm/L0/Au+4wai5tm2rGGkx7EO5ADdZS8WfpqCP/8Gp68p+C4qSbOZgYGRt5a7lDmV2azCku2hSb9BYEJ2qA95AOKoXmWn969v9aGj6kye2uSQgvjHdlQfzac4rXIXX+lH2hQbFJEib7oLDoarAhMbEut9Tfa0NerYk8d0+3EqLqaS9UuEhe5zVnme6K7hdME8FcLiB6MUltWm8Ih5QKSi/klOl2GunuCzSCM0gPWHSlhFHA4/WIcosxCMsOaesvxtejS5Uw+JISm65HBAo2viB4QB3oYnVjQdRt3YmEIY7TznnVDA5y6dimG5vkgmwtwqYciD0+PUwpy/YT1Msoxd225DKZU74n+/jJ4g4CAzx5/Jh/GOW+9Y1ts1g2Yxa/IVZLikIo2alpYXTx2u5GUqC7xAdh6G5f7icvR+xYU6v+gb0e5XVMO4c46KAJ3vhBZzQ9MIip5tjS2Rl4k9h94okEhpYVOE0tTXYRcUNwnThy0uWgU3+rV23ePyBEW8and42rnUgyPxG7jGNu8LolU/tCEjdzGQRGkPtiwB4U2B/P76HMj+6IufuMG3SXoB88fQvh36oZEumqoUNhv6WAbPNNHd5+IXOWSILGlTZLMsRYQbAXW3hfNvP1MfIJXWjD5OiEBVTYO3DUrxC5KrJq9qki8lf2KcNiLdoa+XAe8OirVvvxfBOixdFb5+4eL4Yf4VhkOApBIz4zcK0e+L/xdX5IMjlo6vI2AMuFNYwpb3vBVJ1+nDZqQA"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "WgQPBVH1VBdyP1GnR2LUpBzapu3xqcPGd0xGo/Q4H4WpUeO+Hjltnkr805HvMqRkWDh3DyN3peSztswEbmtfL0y+XxwNgZXD8HzMTx127Mwzcyz+hm45kBealsJBAXnHmYFlorRoaB/cee+emunA/0c48mpmEF4OlQtcwz5XqcWvwenzsvQhJKdJ/IF87NHqDP/WjB3TeL4879eoAz/zIDUkxAOJQxnV3qexrxF9wbIrUSoQrFP9uD/mm6GyF4uNi5ULm7Jku6voBjZa3/We6lz++Lu+0doY/nutoaJRXW5SMFlodU2eUpCWBI4GkjHoq4DabH76kRGqXsKIHRWBUT7ifKY9iyCdftIis6W2oVtynToCwk+NjS5VIB7AJC7zS61lhFsE3nyahdd5CiNG2szs8ML7v/vJ0fALvbYceNiTMf6zXv0Fc2qxy84IyNKguWcR1kBupG9/thT0EH8tvcDyzLI2uf0bpge5x7n5RiICHDmEqtMd2c0gqdoYC0RjxN7nQU4KPvxEWMjSsqJoX6EGlSxQJr9Rl3aeXHbTWyNvpq7GonuIXvTgoyBiyBT/Vzi1BMRRUfAvbshEsXHwZdm+PQ9zmcEoQu6elhgPFWGqWlifhkmLuDGH7c0mBKiF60j9ekAyAJvp5CAQcMQQsW5nTFzImMUhMOiRUNlcsKC3VD3khFHerKl8VpDay30zG1HZlvbZm7ncMf2XoF8TggkyvQiBmRTpU1a10/JeeeYmhnACkaFbzbMctQ1d28jLOs5BB52LBJWsp7WafZjPrnjfrOB/194M8k2JhIHwU8w5Z234NJU/2o07q3VxbbLKhhsAeqBGPzWdThP2bk2ObsPq9p2c4SMv5nfOROXgSTNHpqI3pVmk57HuSllcSu3wBJmgYfLqmkQLKR8HdPRGjXdIY5BtChCfQu72EG0ARSUo7MQC0YLXgVBpPQVhf7oiOebLjCdjNE7/cgU47/A3f9EkL1p3aoYoAwCuDBsogZxIWuLixmogIsMTIeU+0ue7"
`endif