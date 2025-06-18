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

module altera_merlin_burst_uncompressor
#(
    parameter ADDR_W      = 16,
    parameter BURSTWRAP_W = 3,
    parameter BYTE_CNT_W  = 4,
    parameter PKT_SYMBOLS = 4,
    parameter BURST_SIZE_W = 3,
    parameter SYNC_RESET   = 0
)
(
    input clk,
    input reset,
   
    input sink_startofpacket,
    input sink_endofpacket,
    input sink_valid,
    output sink_ready,
   
    input [ADDR_W - 1: 0] sink_addr,
    input [BURSTWRAP_W - 1 : 0] sink_burstwrap,
    input [BYTE_CNT_W - 1 : 0] sink_byte_cnt,
    input sink_is_compressed,
    input [BURST_SIZE_W-1 : 0] sink_burstsize,
   
    output source_startofpacket,
    output source_endofpacket,
    output source_valid,
    input source_ready,
   
    output [ADDR_W - 1: 0] source_addr,
    output [BURSTWRAP_W - 1 : 0] source_burstwrap,
    output [BYTE_CNT_W - 1 : 0] source_byte_cnt,
   
    output source_is_compressed,
    output [BURST_SIZE_W-1 : 0] source_burstsize
);

function reg[63:0] bytes_in_transfer;
    input [BURST_SIZE_W-1:0] axsize;
    case (axsize)
        4'b0000: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000000000001;
        4'b0001: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000000000010;
        4'b0010: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000000000100;
        4'b0011: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000000001000;
        4'b0100: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000000010000;
        4'b0101: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000000100000;
        4'b0110: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000001000000;
        4'b0111: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000010000000;
        4'b1000: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000100000000;
        4'b1001: bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000001000000000;
        default:bytes_in_transfer = 64'b0000000000000000000000000000000000000000000000000000000000000001;
    endcase

endfunction  

   localparam LG_PKT_SYMBOLS = $clog2(PKT_SYMBOLS);

   wire [31:0] int_num_symbols = PKT_SYMBOLS;
   wire [BYTE_CNT_W-1:0] num_symbols = int_num_symbols[BYTE_CNT_W-1:0];
  
  
   reg burst_uncompress_busy;
   reg [BYTE_CNT_W : LG_PKT_SYMBOLS] burst_uncompress_byte_counter;
   wire [BYTE_CNT_W-1:0] burst_uncompress_byte_counter_lint;
   wire first_packet_beat;
   wire last_packet_beat;

   assign first_packet_beat = sink_valid & ~burst_uncompress_busy;
   assign burst_uncompress_byte_counter_lint = {burst_uncompress_byte_counter[BYTE_CNT_W - 1 : LG_PKT_SYMBOLS], {LG_PKT_SYMBOLS{1'b0}}};

   assign source_byte_cnt =
     first_packet_beat ? sink_byte_cnt : burst_uncompress_byte_counter_lint;
   assign source_valid = sink_valid;
  
   assign last_packet_beat = ~sink_is_compressed |
     (
     burst_uncompress_busy ?
       (sink_valid & (burst_uncompress_byte_counter_lint == num_symbols)) :
         sink_valid & (sink_byte_cnt == num_symbols)
     );
 

  reg internal_sclr;
  generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
  end
  endgenerate

    generate
    if (SYNC_RESET == 0) begin : async_rst0 
      always @(posedge clk or posedge reset) begin
         if (reset) begin
            burst_uncompress_busy <= '0;
         end
         else begin
            if (source_valid & source_ready & sink_valid) begin
               if (last_packet_beat) begin
                  burst_uncompress_busy <= '0;
               end
               else begin
                  burst_uncompress_busy <= 1'b1;
               end
            end
         end
      end
     end 
     else begin 
      always @(posedge clk ) begin
         if (internal_sclr) begin
            burst_uncompress_busy <= '0;
         end
         else begin
            if (source_valid & source_ready & sink_valid) begin
               if (last_packet_beat) begin
                  burst_uncompress_busy <= '0;
               end
               else begin
                  burst_uncompress_busy <= 1'b1;
               end
            end
         end
      end
     end 
   endgenerate
   
   always @ (posedge clk) begin
      if (source_valid & source_ready & sink_valid) begin
         if (burst_uncompress_busy) begin
            burst_uncompress_byte_counter <= (burst_uncompress_byte_counter_lint[BYTE_CNT_W-1:LG_PKT_SYMBOLS] - num_symbols[BYTE_CNT_W-1:LG_PKT_SYMBOLS]) ;
         end
         else begin 
            burst_uncompress_byte_counter <= sink_byte_cnt[BYTE_CNT_W-1:LG_PKT_SYMBOLS] - num_symbols[BYTE_CNT_W-1:LG_PKT_SYMBOLS];
         end
      end
   end
  
   reg [ADDR_W - 1 : 0 ] burst_uncompress_address_base;
   reg [ADDR_W - 1 : 0] burst_uncompress_address_offset;

   wire [63:0] decoded_burstsize_wire;
   wire [ADDR_W-1:0] decoded_burstsize;


   localparam ADD_BURSTWRAP_W = (ADDR_W > BURSTWRAP_W) ? ADDR_W : BURSTWRAP_W;
   wire [ADD_BURSTWRAP_W-1:0] addr_width_burstwrap;
   generate
      if (ADDR_W > BURSTWRAP_W) begin : addr_sign_extend
            assign addr_width_burstwrap[ADDR_W - 1 : BURSTWRAP_W] =
                {(ADDR_W - BURSTWRAP_W) {sink_burstwrap[BURSTWRAP_W - 1]}};
            assign addr_width_burstwrap[BURSTWRAP_W-1:0] = sink_burstwrap [BURSTWRAP_W-1:0];
      end
      else begin
            assign addr_width_burstwrap[BURSTWRAP_W-1 : 0] = sink_burstwrap;
      end
   endgenerate

   always @(posedge clk) begin
     if (first_packet_beat & source_ready) begin
       burst_uncompress_address_base <= sink_addr & ~addr_width_burstwrap[ADDR_W-1:0];
     end
   end


   assign decoded_burstsize_wire = bytes_in_transfer(sink_burstsize);  
   assign decoded_burstsize = decoded_burstsize_wire[ADDR_W-1:0];      

   wire [ADDR_W : 0] p1_burst_uncompress_address_offset =
   (
     (first_packet_beat ?
       sink_addr :
       burst_uncompress_address_offset) + decoded_burstsize
    ) &
    addr_width_burstwrap[ADDR_W-1:0];
    wire [ADDR_W-1:0] p1_burst_uncompress_address_offset_lint = p1_burst_uncompress_address_offset [ADDR_W-1:0];

   always @ (posedge clk) begin
       if (source_ready & source_valid) begin
         burst_uncompress_address_offset <= p1_burst_uncompress_address_offset_lint;
       end
   end

  
   assign source_addr = first_packet_beat ? sink_addr :
       burst_uncompress_address_base | burst_uncompress_address_offset;
   assign source_burstwrap = sink_burstwrap;
   assign source_burstsize = sink_burstsize;
  
   assign source_startofpacket = sink_startofpacket & ~burst_uncompress_busy;
   assign source_endofpacket   = sink_endofpacket & last_packet_beat;
   assign sink_ready = source_valid & source_ready & last_packet_beat;
  
   assign source_is_compressed = 1'b0;
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjCZ6EOCE8nGqnpNm7MFeLT3VsJGcOKET65CTIU/DyqHNIiknt0v+j5m0Lti6cjKQPS0454Wvq4G8xVDDmv9Qw357JkDz4Wa0fnla+hAeR+t6tAFcYV1ll+W3Jab/+TWhtNNVMcWtFAIr2E1tqubmGB412amTRsTpiSoytOueMC6KMd0Hzs2Da/oXc5sY89rsZ8s5ecFZSq9qf+na8CYLyUH6PCyMSKYVYRPNbLfdwltC/Rur/p0UGVFIkD26Li0I1TWra9pjpSuMlp05aZL0eeV+72LMPP2I7Iy1CeFyN8uZO6G1xSbFCT++LJNYK/whi+ODkbpCn8w5vZBUfUllvVejYrtzkEsu4SCIf5P+FsUn8PSvjtaZiQN44lXsTW12/ThPnUSh3e0qXVUuOa3RI8YKJuu4FVgpeFbYtkhUdE3672+Aq22EbP61O+Zt1Zx9NDYqTw6ETUT9CMI9/ekta1cCeyinKX92ITDjfd6D8goJhtD7J/Ii/Ip056gpO4cRJIB2pq/22f3B2dOs0Y4ggSZcEvwp/UAv6kj/fMjvxTqcYCIfX0/LhjNkckLlRc/vB8xWjtGWeD4+dJzXGxwgCNFOpbx0n+PIIHgPM2cxKoUVja199t8ORGrxeFc0Ln6kZfif0K57ayp/Zr/9uFHTT39fnBvGwFmCwptHIhWlwY77Hftbch+Z4/mhGFmljcZXynR+eyxUrhihRKPzOLo8vVa6JuGJ935I3iPDIpQA4BV0K1JuhpNgg83WLgeBDwnstCNfAgQE8RrBvMyNYLarI2"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOw2QNOu66SVRqP+ofLR3FpDn/KCBCbBB5tP2j3+Aca17lvOFpDHlE/J/Eec1f70SBI+Onk+WaQAcjum/xfuUEhvJtG2RT34Y0nWHq9cPBkpSXsmL1CDGroYug/n8cc7qkzWCseG1FDCCM/gTwbtE5lFkQb9Wb//bPWWXX0M+tI5A5OsLVcrR+hp6TDsk5NKj6zyUzbPqjPaQGwwBJ0/aRAzQoJOorW3ePwzWA4rtqOoCwlxbhZRV4PEg4k4wmnqimmDGY9ns9PiHbMUW7IWy2j5UpV/E0UIqlVfX7Y/GLoCGKf0GrQOGNcVOQ3deVN4PFe0dbYFsU9Pnk8yo7tcPTTYGzTQPdGdgk+FmTKZJ0+/h7ilqlRyBaQMQ1hDrhd4i3CE1GeoXO+by31pYPmvs4dGSSt+WUpjRMNlzToUCXFqBjJcBNvFOlOwJ9nUSW6K+fPht4zjeHo8cB7po4o9sz8/X0q8KnBO/p/zLUjHKRaYuNMrAaVoclQHWwf9TRSBgYKSoRHzyVBF3IM9w52e9j6yoyBuG8JUPf8qJpHFlldyXC4fBXA/kvtfQSaTAemrajkcuqBMeWTJa8F/EBu2UV/L0kaZtrfdZQ0iSeYJr9qv63o0aNDoXP40bYco7zJ2z+MPKanVv+MR/fUdGtM9ppfPT6/9T5N1EMeVrG2d80WEeMFHUJXPhkxlErLHm6aVI7pMtIKhDScaPDs24Ghm1fnruiGT2293M0JAelIp2o2pc86A+mhYf2KPnI/8haw6uTAUXdSEGuYDrP6bAfR/7p6E"
`endif