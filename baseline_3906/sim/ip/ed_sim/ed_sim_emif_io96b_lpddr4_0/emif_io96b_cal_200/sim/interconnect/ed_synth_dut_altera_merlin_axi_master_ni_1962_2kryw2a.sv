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
 
module ed_synth_dut_altera_merlin_axi_master_ni_1962_2kryw2a
#( 
   parameter  ID_WIDTH = 2,
              ADDR_WIDTH = 32,
              RDATA_WIDTH = 32,
              WDATA_WIDTH = 32,
              ADDR_USER_WIDTH = 8,
              SAI_WIDTH = 4,
              ADDRCHK_WIDTH = 4,
              DATA_USER_WIDTH = 8,
              AXI_LOCK_WIDTH = 2,
              AXI_BURST_LENGTH_WIDTH = 4,
              WRITE_ISSUING_CAPABILITY = 16,
              READ_ISSUING_CAPABILITY = 16,
              AXI_VERSION = "AXI3",
              ACE_LITE_SUPPORT = 0,
              SYNC_RESET       = 0,                           
            PKT_THREAD_ID_H = 109,
            PKT_THREAD_ID_L = 108,
            PKT_QOS_H = 113,
            PKT_QOS_L = 110,
            PKT_BEGIN_BURST = 104,
            PKT_CACHE_H = 103,
            PKT_CACHE_L = 100,
            PKT_ADDR_SIDEBAND_H = 99,
            PKT_ADDR_SIDEBAND_L = 92,
            PKT_DATA_SIDEBAND_H = 124,
  
            PKT_DATA_SIDEBAND_L = 118,
            PKT_PROTECTION_H = 89,
            PKT_PROTECTION_L = 87,
            PKT_BURST_SIZE_H = 84, 
            PKT_BURST_SIZE_L = 82,
            PKT_BURST_TYPE_H = 86,
            PKT_BURST_TYPE_L = 85, 
            PKT_RESPONSE_STATUS_L = 106,
            PKT_RESPONSE_STATUS_H = 107,
            PKT_BURSTWRAP_H = 79,
            PKT_BURSTWRAP_L = 77,
            PKT_BYTE_CNT_H = 76,
            PKT_BYTE_CNT_L = 74,
            PKT_ADDR_H = 73,
            PKT_ADDR_L = 42,
            PKT_TRANS_EXCLUSIVE = 80,
            PKT_TRANS_LOCK = 105,
            PKT_TRANS_COMPRESSED_READ = 41,
            PKT_TRANS_POSTED = 40,
            PKT_TRANS_WRITE = 39,
            PKT_TRANS_READ = 38,
            PKT_DATA_H = 37,
            PKT_DATA_L = 6,
            PKT_BYTEEN_H = 5,
            PKT_BYTEEN_L = 2,
            PKT_SRC_ID_H = 1,
            PKT_SRC_ID_L = 1,
            PKT_DEST_ID_H = 0,
            PKT_DEST_ID_L = 0,
            PKT_ORI_BURST_SIZE_H = 127,
            PKT_ORI_BURST_SIZE_L = 125,
            PKT_DOMAIN_L = 128,
            PKT_DOMAIN_H = 129, 
            PKT_SNOOP_L = 130, 
            PKT_SNOOP_H = 133,  
            PKT_BARRIER_L = 134, 
            PKT_BARRIER_H = 135,
            PKT_WUNIQUE = 136,
            PKT_EOP_OOO =137,
            PKT_SOP_OOO =138, 
            PKT_POISON_L  = 138,
            PKT_POISON_H  = 138,
            PKT_DATACHK_L = 139,
            PKT_DATACHK_H = 139,
            PKT_ADDRCHK_L = 140,
            PKT_ADDRCHK_H = 140,
            PKT_SAI_H     = 141,
            PKT_SAI_L     = 141,
            ST_DATA_W     = 142,
            ST_CHANNEL_W  = 1,
            ROLE_BASED_USER = 0,
            ID = 1,
            USE_PKT_DATACHK       = 1,   
            USE_PKT_ADDRCHK       = 1,   
            PKT_BURSTWRAP_W = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1,
            PKT_BYTE_CNT_W = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
            PKT_ADDR_W = PKT_ADDR_H - PKT_ADDR_L + 1,
            PKT_DATA_W = PKT_DATA_H - PKT_DATA_L + 1,
            PKT_BYTEEN_W = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
            PKT_SRC_ID_W = PKT_SRC_ID_H - PKT_SRC_ID_L + 1,
            PKT_DEST_ID_W = PKT_DEST_ID_H - PKT_DEST_ID_L + 1,
            PKT_DATACHK_W     = (USE_PKT_DATACHK)? PKT_DATACHK_H - PKT_DATACHK_L + 1: 1,  
            DATACHK_WIDTH     = WDATA_WIDTH / 8,
            POISON_WIDTH      = (WDATA_WIDTH + 64 -1) / 64 , 
            PADDING_ZERO      = (ADDRCHK_WIDTH*8) - ADDR_WIDTH,
            PARITY_ADDR_WIDTH =  PADDING_ZERO + ADDR_WIDTH  
            
)
(
    input                                aclk,
    input                                aresetn,
    input [ID_WIDTH-1:0]                 awid,
    input [ADDR_WIDTH-1:0]               awaddr,
    input [AXI_BURST_LENGTH_WIDTH - 1:0] awlen, 
    input [2:0]                          awsize,
    input [1:0]                          awburst,
    input [AXI_LOCK_WIDTH-1:0]           awlock,
    input [3:0]                          awcache,
    input [2:0]                          awprot,
    input [3:0]                          awqos,
    input [3:0]                          awregion, 
    input [ADDR_USER_WIDTH-1:0]          awuser,
    input                                awvalid,
    output                               awready,
    input [ID_WIDTH-1:0]                 wid,
    input [PKT_DATA_W-1:0]               wdata,
    input [(PKT_DATA_W/8)-1:0]           wstrb,
    input                                wlast,
    input                                wvalid,
    input [DATA_USER_WIDTH-1:0]          wuser,
    output                               wready,
    output reg [ID_WIDTH-1:0]            bid,
    output reg [1:0]                     bresp,
    output                               bvalid,
    input                                bready,
    output reg [DATA_USER_WIDTH-1:0]     buser, 
    input [ID_WIDTH-1:0]                 arid,
    input [ADDR_WIDTH-1:0]               araddr,
    input [AXI_BURST_LENGTH_WIDTH - 1:0] arlen,
    input [2:0]                          arsize,
    input [1:0]                          arburst,
    input [AXI_LOCK_WIDTH-1:0]           arlock,
    input [3:0]                          arcache,
    input [2:0]                          arprot,
    input [3:0]                          arqos,
    input [3:0]                          arregion,
    input [ADDR_USER_WIDTH-1:0]          aruser,
    input                                arvalid,
    output                               arready,
 
    input [1:0]                          ardomain, 
    input [3:0]                          arsnoop,  
    input [1:0]                          arbar,   
 
    input [1:0]                          awdomain, 
    input [2:0]                          awsnoop,  
    input [1:0]                          awbar,    
    input                                awunique,
 
    output reg [ID_WIDTH-1:0]            rid,
    output reg [PKT_DATA_W-1:0]          rdata,
    output reg [1:0]                     rresp,
    output                               rlast,
    output                               rvalid,
    input                                rready,
    output reg [DATA_USER_WIDTH-1:0]     ruser,
    
    input [ADDRCHK_WIDTH-1:0]            awuser_addrchk,
    input [ADDRCHK_WIDTH-1:0]            aruser_addrchk,
    input [SAI_WIDTH-1:0]                awuser_sai,
    input [SAI_WIDTH-1:0]                aruser_sai,
    input [DATACHK_WIDTH-1:0]            wuser_datachk,
    input [POISON_WIDTH-1:0]             wuser_poison,
    output reg [DATACHK_WIDTH-1:0]            ruser_datachk,
    output reg [POISON_WIDTH-1:0]             ruser_poison,
    output reg                           write_cp_valid,
    output reg [ST_DATA_W-1:0]           write_cp_data,
    output wire                          write_cp_startofpacket,
    output wire                          write_cp_endofpacket,
    input                                write_cp_ready,
    input                                write_rp_valid,
    input [ST_DATA_W-1 : 0]              write_rp_data,
    input [ST_CHANNEL_W-1 : 0]           write_rp_channel,
    input                                write_rp_startofpacket,
    input                                write_rp_endofpacket,
    output reg                           write_rp_ready, 
    output reg                           read_cp_valid,
    output reg [ST_DATA_W-1:0]           read_cp_data,
    output wire                          read_cp_startofpacket,
    output wire                          read_cp_endofpacket,
    input                                read_cp_ready,
    input                                read_rp_valid,
    input [ST_DATA_W-1 : 0]              read_rp_data,
    input [ST_CHANNEL_W-1 : 0]           read_rp_channel,
    input                                read_rp_startofpacket,
    input                                read_rp_endofpacket,
    output reg                           read_rp_ready
        
);
 
localparam NUMSYMBOLS           = PKT_DATA_W/8;
localparam BITS_PER_SYMBOL      = 8;
 
typedef enum bit [1:0] 
{
    FIXED       = 2'b00,
    INCR        = 2'b01,
    WRAP        = 2'b10,
    RESERVED    = 2'b11
} AxiBurstType;
 
function reg[7:0] bytes_in_transfer;
    input [2:0] axsize;
 
    case (axsize)
        3'b000: bytes_in_transfer = 8'b00000001;
        3'b001: bytes_in_transfer = 8'b00000010;
        3'b010: bytes_in_transfer = 8'b00000100;
        3'b011: bytes_in_transfer = 8'b00001000;
        3'b100: bytes_in_transfer = 8'b00010000;
        3'b101: bytes_in_transfer = 8'b00100000;
        3'b110: bytes_in_transfer = 8'b01000000;
        3'b111: bytes_in_transfer = 8'b10000000;
        default:bytes_in_transfer = 8'b00000001;
    endcase
 
endfunction
 
 
 
 
    function integer log2ceil;
 
        input reg[62:0] val;
        reg [63:0] i;
        begin
            i = 1;
            log2ceil = 0;
            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction
 
function reg [PKT_DATACHK_W-1:0] calcParity (
    input [WDATA_WIDTH-1:0] data
 );
    for (int i=0; i<PKT_DATACHK_W; i++)
        calcParity[i] = ~(^ data[i*8 +:8]);
endfunction
 
AxiBurstType write_burst_type, read_burst_type;
 
function AxiBurstType burst_type_decode 
(
    input [1:0] axburst
);
    AxiBurstType burst_type;
    begin
        case (axburst)
            2'b00    : burst_type = FIXED;
            2'b01    : burst_type = INCR;
            2'b10    : burst_type = WRAP;
            2'b11    : burst_type = RESERVED;
            default  : burst_type = INCR;
        endcase
        return burst_type;
    end
endfunction
 
   reg internal_sclr;
 
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge aclk) begin
         internal_sclr <= ~aresetn;
      end
   end
   endgenerate
 
 
reg [ID_WIDTH-1:0]                      awid_q0;  
reg [ADDR_WIDTH-1:0]                  awaddr_q0;
reg [AXI_BURST_LENGTH_WIDTH - 1:0]     awlen_q0;
reg [2:0]                             awsize_q0;
reg [1:0]                            awburst_q0;
reg [AXI_LOCK_WIDTH-1:0]              awlock_q0;
reg [3:0]                            awcache_q0;
reg [2:0]                             awprot_q0;
reg [3:0]                              awqos_q0;
reg [3:0]                           awregion_q0;
reg [ADDR_USER_WIDTH-1:0]             awuser_q0;
reg                                  awvalid_q0;
reg [1:0]                           awdomain_q0; 
reg [2:0]                            awsnoop_q0;  
reg [1:0]                              awbar_q0;   
reg                                 awunique_q0;
reg [ADDRCHK_WIDTH-1:0]       awuser_addrchk_q0;
reg [SAI_WIDTH-1:0]               awuser_sai_q0;
 
reg [ID_WIDTH-1:0]                       wid_q0; 
reg [PKT_DATA_W-1:0]                   wdata_q0;
reg [(PKT_DATA_W/8)-1:0]               wstrb_q0;
reg                                    wlast_q0;
reg [DATA_USER_WIDTH-1:0]              wuser_q0;
reg                                   wvalid_q0;
reg [DATACHK_WIDTH-1:0]        wuser_datachk_q0;
reg [POISON_WIDTH-1:0]          wuser_poison_q0;
 
reg [ID_WIDTH-1:0]                      arid_q0;
reg [ADDR_WIDTH-1:0]                  araddr_q0;
reg [AXI_BURST_LENGTH_WIDTH - 1:0]     arlen_q0;
reg [2:0]                             arsize_q0;
reg [1:0]                            arburst_q0;
reg [AXI_LOCK_WIDTH-1:0]              arlock_q0;
reg [3:0]                            arcache_q0;
reg [2:0]                             arprot_q0;
reg [3:0]                              arqos_q0;
reg [3:0]                           arregion_q0;
reg [ADDR_USER_WIDTH-1:0]             aruser_q0;
reg                                  arvalid_q0;
reg [1:0]                           ardomain_q0; 
reg [3:0]                            arsnoop_q0;
reg [1:0]                              arbar_q0;
reg [ADDRCHK_WIDTH-1:0]       aruser_addrchk_q0;
reg [SAI_WIDTH-1:0]               aruser_sai_q0;   
 
 
wire network_ready;
 
generate 
   if(SYNC_RESET == 0) begin 
 
      always @ (posedge aclk, negedge aresetn) begin
         if(~aresetn) begin
            awvalid_q0 <= 1'b0;
         end
         else if(~awvalid_q0 || (wvalid_q0 & wlast_q0 & network_ready)) begin
            awvalid_q0 <= awvalid;
         end
      end
 
      always @ (posedge aclk, negedge aresetn) begin
         if(~aresetn) begin
            wvalid_q0 <= 1'b0;
         end
         else if((network_ready && awvalid_q0) || ~wvalid_q0) begin
            wvalid_q0 <= wvalid;
         end
      end
 
      always @ (posedge aclk, negedge aresetn) begin
         if(~aresetn) begin
            arvalid_q0 <= 1'b0;
         end
         else if(read_cp_ready || ~arvalid_q0) begin
            arvalid_q0 <= arvalid;
         end
      end
 
   end   
   else begin  
 
      always @ (posedge aclk) begin
         if(internal_sclr) begin
            awvalid_q0 <= 1'b0;
         end
         else if(~awvalid_q0 || (wvalid_q0 & wlast_q0 & network_ready)) begin
            awvalid_q0 <= awvalid;
         end
      end
 
      always @ (posedge aclk) begin
         if(internal_sclr) begin
            wvalid_q0 <= 1'b0;
         end
         else if((network_ready && awvalid_q0) || ~wvalid_q0) begin
            wvalid_q0 <= wvalid;
         end
      end
 
      always @ (posedge aclk) begin
         if(internal_sclr) begin
            arvalid_q0 <= 1'b0;
         end
         else if(read_cp_ready || ~arvalid_q0) begin
            arvalid_q0 <= arvalid;
         end
      end
 
   end   
endgenerate
 
always @ (posedge aclk) begin
   if(~awvalid_q0 || (wvalid_q0 & wlast_q0 & network_ready)) begin 
      awid_q0       <=        awid;
      awaddr_q0     <=      awaddr;
      awlen_q0      <=       awlen; 
      awsize_q0     <=      awsize;
      awburst_q0    <=     awburst;
      awlock_q0     <=      awlock;
      awcache_q0    <=     awcache;
      awprot_q0     <=      awprot;
      awqos_q0      <=       awqos;
      awregion_q0   <=    awregion; 
      awuser_q0     <=      awuser;
      awdomain_q0   <=    awdomain;
      awsnoop_q0    <=     awsnoop;
      awbar_q0      <=       awbar;
      awunique_q0   <=    awunique;
      if (ROLE_BASED_USER) begin
         awuser_addrchk_q0 <=   awuser_addrchk;
         awuser_sai_q0     <=   awuser_sai;
      end else begin
         awuser_addrchk_q0 <=  '0; 
         awuser_sai_q0     <=  '0;
      end
   end
end 
 
 
always @ (posedge aclk) begin
   if((network_ready && awvalid_q0) || ~wvalid_q0) begin
      wid_q0    <=      wid;     
      wdata_q0  <=    wdata;
      wstrb_q0  <=    wstrb;
      wlast_q0  <=    wlast;
      wuser_q0  <=    wuser;
      if (ROLE_BASED_USER) begin
          wuser_datachk_q0 <= wuser_datachk;
          wuser_poison_q0  <= wuser_poison;
      end else begin
          wuser_datachk_q0 <= '0;
          wuser_poison_q0  <= '0;
      end
   end
end
 
 
always @ (posedge aclk) begin
   if(read_cp_ready || ~arvalid_q0) begin
      arid_q0     <=     arid;
      araddr_q0   <=   araddr;
      arlen_q0    <=    arlen;
      arsize_q0   <=   arsize;
      arburst_q0  <=  arburst;
      arlock_q0   <=   arlock;
      arcache_q0  <=  arcache;
      arprot_q0   <=   arprot;
      arqos_q0    <=    arqos;
      arregion_q0 <= arregion;
      aruser_q0   <=   aruser;
      ardomain_q0 <= ardomain;
      arsnoop_q0  <=  arsnoop;
      arbar_q0    <=    arbar;
      if (ROLE_BASED_USER) begin
          aruser_addrchk_q0 <= aruser_addrchk;
          aruser_sai_q0 <= aruser_sai;
      end else begin
          aruser_addrchk_q0 <= '0; 
          aruser_sai_q0     <= '0;
      end
   end
end
 
 
 
always_comb
    begin
        write_burst_type = burst_type_decode(awburst_q0);
        read_burst_type  = burst_type_decode(arburst_q0);
    end

wire [31:0] id_int      = ID;
 
 
wire write_addr_data_both_valid;
 
assign write_addr_data_both_valid = awvalid_q0 && wvalid_q0;
assign network_ready = write_cp_ready;
 
 
reg [PKT_ADDR_W-1       : 0]    start_address;
reg [PKT_BYTE_CNT_W-1   : 0]    total_write_bytecount;
reg [PKT_BYTE_CNT_W-1   : 0]    total_read_bytecount;
reg [PKT_BYTE_CNT_W-1   : 0]    write_burst_bytecount;
 
reg [PKT_ADDR_W-1       : 0]    burst_address;
reg [PKT_BYTE_CNT_W-1   : 0]    burst_bytecount;
 
 
reg     [PKT_BYTE_CNT_W-1 : 0]  total_bytecount_left;
 
reg    [31:0]                   total_write_bytecount_wire;  
reg    [31:0]                   total_read_bytecount_wire;   
reg    [31:0]                   total_bytecount_left_wire;   
 
always_comb
begin
    total_write_bytecount_wire  = (awlen_q0 + 1) << $clog2(NUMSYMBOLS);
    total_read_bytecount_wire   = (arlen_q0 + 1) << $clog2(NUMSYMBOLS);
    total_write_bytecount       = total_write_bytecount_wire[PKT_BYTE_CNT_W-1:0];
    total_read_bytecount        = total_read_bytecount_wire[PKT_BYTE_CNT_W-1:0];
    start_address               = awaddr_q0; 
end
 
    
reg [PKT_ADDR_W-1 : 0]  address_aligned;
reg [31 : 0]            burstwrap_value_write;
reg [31 : 0]            burstwrap_value_read;
 
    generate
        if (AXI_VERSION != "AXI4Lite") begin
          reg     [PKT_BURSTWRAP_W - 2 : 0]       burstwrap_boundary_write;
          reg     [PKT_BURSTWRAP_W - 2 : 0]       burstwrap_boundary_read;
          wire    [31 : 0]                        burstwrap_boundary_width_write;
          wire    [31 : 0]                        burstwrap_boundary_width_read;
          
          reg     [PKT_ADDR_W-1 : 0]              incremented_burst_address;
          reg     [PKT_ADDR_W-1 : 0]              burstwrap_mask;
          reg     [PKT_ADDR_W-1 : 0]              burst_address_high;
          reg     [PKT_ADDR_W-1 : 0]              burst_address_low;
          reg [PKT_ADDR_W + (PKT_BURSTWRAP_W-1) + 4 : 0] address_for_alignment;
          reg [PKT_ADDR_W+$clog2(NUMSYMBOLS)-1 :0]  address_after_alignment;
          wire    [31:0]  bytes_in_transfer_minusone_write_wire;     
          wire    [31:0]  bytes_in_transfer_minusone_read_wire;     
          
          assign burstwrap_boundary_width_write   =    awsize_q0 + log2ceil(awlen_q0 + 1);
          assign burstwrap_boundary_width_read    =    arsize_q0 + log2ceil(arlen_q0 + 1);
          
          function reg [PKT_BURSTWRAP_W - 2 : 0] burstwrap_boundary_calculation
          (
              input [31 : 0]  burstwrap_boundary_width,
              input int       width = PKT_BURSTWRAP_W - 1
          );
              integer i;
          
              burstwrap_boundary_calculation = 0;
              for (i = 0; i < width; i++) begin
                  if (burstwrap_boundary_width > i)
                      burstwrap_boundary_calculation[i] = 1;
              end
          
          endfunction 
          
          assign burstwrap_boundary_write = burstwrap_boundary_calculation(burstwrap_boundary_width_write, PKT_BURSTWRAP_W - 1);
          assign burstwrap_boundary_read  = burstwrap_boundary_calculation(burstwrap_boundary_width_read, PKT_BURSTWRAP_W - 1);
          
          
          
          assign  bytes_in_transfer_minusone_write_wire = bytes_in_transfer(awsize_q0) - 1;
          assign  bytes_in_transfer_minusone_read_wire  = bytes_in_transfer(arsize_q0) - 1; 
          
          always_comb
          begin
              burstwrap_value_write = 0;
              case (write_burst_type)
                  INCR:    
                  begin
                      burstwrap_value_write[PKT_BURSTWRAP_W - 1 : 0]    = {PKT_BURSTWRAP_W {1'b1}};
                  end 
                  WRAP:
                  begin
                      burstwrap_value_write[PKT_BURSTWRAP_W - 1 : 0]    = {1'b0, burstwrap_boundary_write};
                  end
                  FIXED:
                  begin
                      burstwrap_value_write[PKT_BURSTWRAP_W - 1 : 0]    = bytes_in_transfer_minusone_write_wire[PKT_BURSTWRAP_W -1 : 0];
                  end
                  default:
                  begin
                      burstwrap_value_write[PKT_BURSTWRAP_W - 1 : 0]    = {PKT_BURSTWRAP_W {1'b1}};
                  end
              endcase
          end
          
          always_comb
          begin
              burstwrap_value_read = 0;
              case (read_burst_type)
                  INCR:    
                  begin
                      burstwrap_value_read[PKT_BURSTWRAP_W - 1 : 0] = {PKT_BURSTWRAP_W {1'b1}};
                  end 
                  WRAP:
                  begin
                      burstwrap_value_read[PKT_BURSTWRAP_W - 1 : 0] = {1'b0, burstwrap_boundary_read};
                  end
                  FIXED:
                  begin
                      burstwrap_value_read[PKT_BURSTWRAP_W - 1 : 0] = bytes_in_transfer_minusone_read_wire[PKT_BURSTWRAP_W -1 : 0];    
                  end
                  default:
                  begin
                      burstwrap_value_read[PKT_BURSTWRAP_W - 1 : 0] = {PKT_BURSTWRAP_W {1'b1}};
                  end
              endcase
          end
            assign address_aligned          = address_after_alignment[PKT_ADDR_W - 1 : 0];
            assign address_for_alignment  = {burstwrap_boundary_write,awburst_q0, start_address, awsize_q0};
 
            altera_merlin_address_alignment
                #(
                  .ADDR_W (PKT_ADDR_W),
                  .BURSTWRAP_W (PKT_BURSTWRAP_W),
                  .INCREMENT_ADDRESS (1),
                  .NUMSYMBOLS (NUMSYMBOLS),
                  .SYNC_RESET (SYNC_RESET)
                  ) align_address_to_size
            (
             .clk (aclk),
             .reset (aresetn),
             .in_data (address_for_alignment),
             .in_valid (write_addr_data_both_valid),
             .in_sop (write_cp_startofpacket),
             .in_eop (wlast_q0),
 
             .out_data (address_after_alignment),
             .out_ready (write_cp_ready)
             );
        end else begin
           assign address_aligned = start_address; 
        end
    endgenerate
    
     
 
assign total_bytecount_left_wire    =   write_burst_bytecount - NUMSYMBOLS;
assign total_bytecount_left         =   total_bytecount_left_wire[PKT_BYTE_CNT_W-1:0];
 
always_comb
begin
    if (write_cp_startofpacket)
        begin
            write_burst_bytecount   =    total_write_bytecount;
        end
    else 
        begin
            write_burst_bytecount   =    burst_bytecount;
        end
end
 
generate
if (SYNC_RESET == 0) begin : async_rst0
  always_ff @(posedge aclk, negedge aresetn)
  begin
      if (!aresetn)
          begin
              burst_bytecount     <= {PKT_BYTE_CNT_W{1'b0}};
          end
      else
          begin
              if (write_addr_data_both_valid && write_cp_ready)
                  begin
                      burst_bytecount     <=    total_bytecount_left;
                  end
          end
  
  end
end : async_rst0  
 
else begin : sync_rst0  
  always_ff @(posedge aclk)
  begin
      if (internal_sclr)
          begin
              burst_bytecount     <= {PKT_BYTE_CNT_W{1'b0}};
          end
      else
          begin
              if (write_addr_data_both_valid && write_cp_ready)
                  begin
                      burst_bytecount     <=    total_bytecount_left;
                  end
          end
  
  end
end : sync_rst0
endgenerate
reg sop_enable;
 
generate
 if (SYNC_RESET == 0) begin : async_rst1
   always_ff @(posedge aclk, negedge aresetn)
   begin
       if (!aresetn)
           begin
               sop_enable <= 1'b1;
           end
       else
           begin
               if (write_addr_data_both_valid && write_cp_ready)
                   begin
                       sop_enable <= 1'b0;
                       if (wlast_q0)
                           sop_enable <= 1'b1;
                   end
           end
   end
 end : async_rst1
 
 else begin : sync_rst1   
   always_ff @(posedge aclk)
   begin
       if (internal_sclr)
           begin
               sop_enable <= 1'b1;
           end
       else
           begin
               if (write_addr_data_both_valid && write_cp_ready)
                   begin
                       sop_enable <= 1'b0;
                       if (wlast_q0)
                           sop_enable <= 1'b1;
                   end
           end
   end
 end : sync_rst1 
endgenerate          
assign write_cp_startofpacket       = sop_enable;
assign write_cp_endofpacket         = wlast_q0;   
assign read_cp_startofpacket        = 1'b1;
assign read_cp_endofpacket          = 1'b1;   
 
 
 
assign awready = awvalid_q0 ? (wvalid_q0 & wlast_q0 & network_ready) : 1'b1;
assign wready = wvalid_q0 ? (awvalid_q0 & network_ready) : 1'b1;
 
assign write_cp_valid    = write_addr_data_both_valid;
 
assign bvalid            = write_rp_valid;
assign write_rp_ready    = bready;
 
always_comb  
    begin
        write_cp_data                                       = '0;
        write_cp_data[PKT_BYTE_CNT_H :PKT_BYTE_CNT_L ]      = write_burst_bytecount; 
        write_cp_data[PKT_TRANS_EXCLUSIVE            ]      = awlock_q0[0];
        write_cp_data[PKT_TRANS_LOCK                 ]      = '0;
        write_cp_data[PKT_TRANS_COMPRESSED_READ      ]      = '0;
        write_cp_data[PKT_TRANS_READ                 ]      = '0;
        write_cp_data[PKT_TRANS_WRITE                ]      = 1'b1; 
        write_cp_data[PKT_TRANS_POSTED               ]      = '0;
        write_cp_data[PKT_BURSTWRAP_H:PKT_BURSTWRAP_L]      = (AXI_VERSION == "AXI4Lite") ? 0 : burstwrap_value_write[PKT_BURSTWRAP_W - 1 : 0];
        write_cp_data[PKT_ADDR_H     :PKT_ADDR_L     ]      = address_aligned;
        write_cp_data[PKT_DATA_H     :PKT_DATA_L     ]      = wdata_q0;
        write_cp_data[PKT_BYTEEN_H   :PKT_BYTEEN_L   ]      = wstrb_q0;
        write_cp_data[PKT_BURST_SIZE_H :PKT_BURST_SIZE_L]   = awsize_q0;
        write_cp_data[PKT_BURST_TYPE_H :PKT_BURST_TYPE_L]   = awburst_q0;
        write_cp_data[PKT_SRC_ID_H   :PKT_SRC_ID_L   ]      = id_int[PKT_SRC_ID_W-1:0];
        write_cp_data[PKT_PROTECTION_H :PKT_PROTECTION_L]   = awprot_q0;
        write_cp_data[PKT_THREAD_ID_H :PKT_THREAD_ID_L]     = awid_q0;
        write_cp_data[PKT_CACHE_H :PKT_CACHE_L]             = awcache_q0;
        write_cp_data[PKT_ADDR_SIDEBAND_H:PKT_ADDR_SIDEBAND_L] = awuser_q0;
        write_cp_data[PKT_ORI_BURST_SIZE_H :PKT_ORI_BURST_SIZE_L] = awsize_q0;
        if (ROLE_BASED_USER) begin
            write_cp_data[PKT_POISON_H:PKT_POISON_L]            = wuser_poison_q0;
            write_cp_data[PKT_SAI_H:PKT_SAI_L]                  = awuser_sai_q0;        
            if(USE_PKT_DATACHK == 0)
                    write_cp_data[PKT_DATACHK_H:PKT_DATACHK_L]          = '0;               
            else
                    write_cp_data[PKT_DATACHK_H:PKT_DATACHK_L]          = wuser_datachk_q0;
            if(USE_PKT_ADDRCHK == 0)
                    write_cp_data[PKT_ADDRCHK_H:PKT_ADDRCHK_L]          = '0;               
            else
                    write_cp_data[PKT_ADDRCHK_H:PKT_ADDRCHK_L]          = awuser_addrchk_q0;        
        end
 
        if(ACE_LITE_SUPPORT == 1) begin
            write_cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L] = awdomain_q0;
            write_cp_data[PKT_SNOOP_H : PKT_SNOOP_L]   = {1'b0, awsnoop_q0};  
            write_cp_data[PKT_BARRIER_H : PKT_BARRIER_L]       = awbar_q0;
            write_cp_data[PKT_WUNIQUE]                 = awunique_q0;
        end
        else begin
            write_cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L] = 2'b11;    
            write_cp_data[PKT_SNOOP_H : PKT_SNOOP_L]   = {1'b0, 3'b000};  
            write_cp_data[PKT_BARRIER_H : PKT_BARRIER_L]       = 2'b00;    
            write_cp_data[PKT_WUNIQUE]                 = 'b0;
        end
        
        if (AXI_VERSION == "AXI4") begin
            write_cp_data[PKT_QOS_H : PKT_QOS_L]                     = awqos_q0;
            write_cp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L] = wuser_q0;
        end else begin 
            write_cp_data[PKT_QOS_H : PKT_QOS_L]                     = '0;
            write_cp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L] = '0;
        end
        
        bresp = write_rp_data[PKT_RESPONSE_STATUS_H : PKT_RESPONSE_STATUS_L];
        bid   = write_rp_data[PKT_THREAD_ID_H : PKT_THREAD_ID_L];
        buser = write_rp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L];
    end
 
always_comb  
    begin
        read_cp_data                                        = '0;
        read_cp_data[PKT_BYTE_CNT_H :PKT_BYTE_CNT_L ]       = total_read_bytecount;
        read_cp_data[PKT_TRANS_EXCLUSIVE            ]       = arlock_q0[0];
        read_cp_data[PKT_TRANS_LOCK                 ]       = '0;
        if (AXI_VERSION != "AXI4Lite") begin
            read_cp_data[PKT_TRANS_COMPRESSED_READ] = 1'b1;
        end else begin
            read_cp_data[PKT_TRANS_COMPRESSED_READ] = '0;
        end
        read_cp_data[PKT_TRANS_READ                 ]       = '1;
        read_cp_data[PKT_TRANS_WRITE                ]       = '0;
        read_cp_data[PKT_TRANS_POSTED               ]       = '0;
        read_cp_data[PKT_BURSTWRAP_H:PKT_BURSTWRAP_L]       = (AXI_VERSION == "AXI4Lite") ? 0 : burstwrap_value_read[PKT_BURSTWRAP_W - 1 : 0];
        read_cp_data[PKT_ADDR_H     :PKT_ADDR_L     ]       = araddr_q0;
        read_cp_data[PKT_DATA_H     :PKT_DATA_L     ]       = '0;
        read_cp_data[PKT_BYTEEN_H   :PKT_BYTEEN_L   ]       = {PKT_BYTEEN_W{1'b1}};
        read_cp_data[PKT_SRC_ID_H   :PKT_SRC_ID_L   ]       = id_int[PKT_SRC_ID_W-1:0];
        read_cp_data[PKT_BURST_SIZE_H :PKT_BURST_SIZE_L]    = arsize_q0;
        read_cp_data[PKT_ORI_BURST_SIZE_H :PKT_ORI_BURST_SIZE_L] = arsize_q0;
        read_cp_data[PKT_BURST_TYPE_H :PKT_BURST_TYPE_L]    = arburst_q0;
        read_cp_data[PKT_PROTECTION_H : PKT_PROTECTION_L]   = arprot_q0;
        read_cp_data[PKT_THREAD_ID_H  : PKT_THREAD_ID_L]    = arid_q0;
        read_cp_data[PKT_CACHE_H  : PKT_CACHE_L]            = arcache_q0;
 
        read_cp_data[PKT_ADDR_SIDEBAND_H:PKT_ADDR_SIDEBAND_L] = aruser_q0;
        read_cp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L] = '0;
 
        if (AXI_VERSION == "AXI4") begin
            read_cp_data[PKT_QOS_H : PKT_QOS_L]                     = arqos_q0;
        end else begin
            read_cp_data[PKT_QOS_H : PKT_QOS_L]                     = '0;
        end
 
        if(ROLE_BASED_USER) begin
            read_cp_data[PKT_SAI_H:PKT_SAI_L]                   = aruser_sai_q0;
            if(USE_PKT_ADDRCHK == 0)
               read_cp_data[PKT_ADDRCHK_H : PKT_ADDRCHK_L ]   = '0;
            else         
               read_cp_data [PKT_ADDRCHK_H   : PKT_ADDRCHK_L ] = aruser_addrchk_q0;           
        end
 
            if(ACE_LITE_SUPPORT == 1) begin
                read_cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L] = ardomain_q0;
                read_cp_data[PKT_SNOOP_H : PKT_SNOOP_L]   = arsnoop_q0;
                read_cp_data[PKT_BARRIER_H : PKT_BARRIER_L] = arbar_q0;
                read_cp_data[PKT_WUNIQUE]                 = 'b0;      
            end
            else begin
                read_cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L] = 2'b11;    
                read_cp_data[PKT_SNOOP_H : PKT_SNOOP_L]   = 4'b0000;  
                read_cp_data[PKT_BARRIER_H : PKT_BARRIER_L] = 2'b00;  
                read_cp_data[PKT_WUNIQUE]                 = 'b0;
            end
            
            rdata    = read_rp_data[PKT_DATA_H     :PKT_DATA_L];
            rresp    = read_rp_data[PKT_RESPONSE_STATUS_H : PKT_RESPONSE_STATUS_L];
            rid      = read_rp_data[PKT_THREAD_ID_H : PKT_THREAD_ID_L];
            ruser    = read_rp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L];
            if(ROLE_BASED_USER) begin
            ruser_poison   = read_rp_data[PKT_POISON_H : PKT_POISON_L];
            if (USE_PKT_DATACHK==0)
               ruser_datachk  = calcParity(read_rp_data[PKT_DATA_H:PKT_DATA_L]);
            else
               ruser_datachk  = read_rp_data[PKT_DATACHK_H : PKT_DATACHK_L];
 
            end
    end
 
assign    read_cp_valid                 = arvalid_q0;
assign    arready                       = read_cp_ready || ~arvalid_q0;
 
assign rvalid                   = read_rp_valid;
assign read_rp_ready            = rready;
assign rlast                    = read_rp_endofpacket;
 
// synthesis translate_off
    generate
        if (WRITE_ISSUING_CAPABILITY == 1) begin
            wire write_cmd_accepted;
            wire write_response_accepted;
            wire write_response_count_is_1;
            reg [$clog2(WRITE_ISSUING_CAPABILITY+1)-1:0] pending_write_response_count;
            reg [$clog2(WRITE_ISSUING_CAPABILITY+1)-1:0] next_pending_write_response_count;
    
            assign write_cmd_accepted  = write_cp_valid && write_cp_ready && write_cp_endofpacket;
            assign write_response_accepted  = write_rp_valid && write_rp_ready && write_rp_endofpacket;
    
            always_comb
                begin
                    next_pending_write_response_count  = pending_write_response_count;
                    if (write_cmd_accepted)
                        next_pending_write_response_count  = pending_write_response_count + 1'b1;
                    if (write_response_accepted)
                        next_pending_write_response_count  = pending_write_response_count - 1'b1;
                    if (write_cmd_accepted && write_response_accepted)
                        next_pending_write_response_count  = pending_write_response_count;
                end
 
            if (SYNC_RESET == 0) begin : async_rst2
               always_ff @(posedge aclk, negedge aresetn)
                   begin
                       if (!aresetn) begin
                           pending_write_response_count <= '0;
                       end else begin
                           pending_write_response_count <= next_pending_write_response_count;
                       end
                   end
            end : async_rst2
 
            else begin : sync_rst2    
               always_ff @(posedge aclk)
                   begin
                       if (internal_sclr) begin
                           pending_write_response_count <= '0;
                       end else begin
                           pending_write_response_count <= next_pending_write_response_count;
                       end
                   end
            end : sync_rst2   
 
            
            assign write_response_count_is_1  = (pending_write_response_count == 1);
            ERROR_WRITE_ISSUING_CAPABILITY_equal_1_but_master_sends_more_commands_or_switch_slave_before_response_back_please_visit_the_parameter:
                assert property (@(posedge aclk)
                    disable iff (!aresetn || $isunknown(aresetn)) !(write_response_count_is_1 && write_cmd_accepted));
            end 
        
        if (READ_ISSUING_CAPABILITY == 1) begin
            wire read_cmd_accepted;
            wire read_response_accepted;
            wire read_response_count_is_1;
    
            reg [$clog2(READ_ISSUING_CAPABILITY+1)-1:0]  pending_read_response_count;
            reg [$clog2(READ_ISSUING_CAPABILITY+1)-1:0]  next_pending_read_response_count;
    
            assign read_cmd_accepted  = read_cp_valid && read_cp_ready && read_cp_endofpacket;
            assign read_response_accepted  = read_rp_valid && read_rp_ready && read_rp_endofpacket;
    
            always_comb
                begin
                    next_pending_read_response_count   = pending_read_response_count;
                    if (read_cmd_accepted)
                        next_pending_read_response_count  = pending_read_response_count + 1'b1;
                    if (read_response_accepted)
                        next_pending_read_response_count  = pending_read_response_count - 1'b1;
                    if (read_cmd_accepted && read_response_accepted)
                        next_pending_read_response_count  = pending_read_response_count;
                end
 
            if (SYNC_RESET == 0) begin : async_rst3
              always_ff @(posedge aclk, negedge aresetn)
                  begin
                      if (!aresetn) begin
                          pending_read_response_count  <= '0;
                      end else begin
                          pending_read_response_count  <= next_pending_read_response_count;
                      end
                  end
            end : async_rst3
 
            else begin : sync_rst3 
              always_ff @(posedge aclk)
                  begin
                      if (internal_sclr) begin
                          pending_read_response_count  <= '0;
                      end else begin
                          pending_read_response_count  <= next_pending_read_response_count;
                      end
                  end 
            end : sync_rst3
            assign read_response_count_is_1 = (pending_read_response_count == 1);
            ERROR_READ_ISSUING_CAPABILITY_equal_1_but_master_sends_more_commands_or_switch_slave_before_response_back_please_visit_the_parameter:
                assert property (@(posedge aclk)
                    disable iff (!aresetn || $isunknown(aresetn)) !(read_response_count_is_1 && read_cmd_accepted));
        end 
    endgenerate
 
    generate 
    reg[4:0] count;
 
        always @ (posedge aclk, negedge aresetn)
            begin
                if (!aresetn) begin
                    count <= '0;
                end
                else begin
                    if (count < 20) begin
                        count <= count + 1'b1;
                    end
                    else begin
                        count <= count;
                    end
                end
            end
 
        always @(*) 
            begin 
                if (count >= 15) begin
                   ERROR_awlock_reserved_value:
                       assert property (@(posedge aclk)
                           disable iff (!aresetn || $isunknown(aresetn)) ( !(awvalid_q0 && awlock_q0 == 2'b11) ));
 
                   ERROR_arlock_reserved_value:
                       assert property (@(posedge aclk)
                           disable iff (!aresetn || $isunknown(aresetn)) ( !(arvalid_q0 && arlock_q0 == 2'b11) ));
                end
            end
    endgenerate
// synthesis translate_on
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOy9WzHxIQ4FwD7uQ0fZDFTV2EVj3Tf/87c3ETA7JHSEMREqVw/0UA7OK2BYUa6jm+YZcp8AsbZzJKaYek7p4XestyFXBJf03+rZqC9FLIgrodBTC4k0w1xiKo1YR0cbYP0i6TqOJZV0ZeQ/KCDlKf6FnT75SEBz4k0Iin8Pvb3jPkurne4GSa2xJMwV6vO+Co5ytqS+NciWXcuc7DzvJsSOfg3RSE4OFzlpGOvx2GMPKos2Ta2XAoFRPo4WbrV+LHf9KFYPyvVdKfqmEpLrj3FmPkq4UB9e6/n1uSKoOImTXTEqFipzME5T8GLdn0vMX9pBwyiAK5dVImzL8T8c7xUwxuJaU8CkNUdU4Af5ZMhekho1WdAgwffxDdUDnbkBRjJxLUudb9x+Abi7he39jdhfZ7zcz4ZR2abN3Xb11VUFSLRQCOmjRhOkRjX1vUET5yCYCeC1FsxEXh7xM39o3Xey387rQXcMvBQk/Hp7+P8GFzExjkWcaRLXXpI4OzWug/Ayx85/YKLW7Z95dV0gYOR6M8lH1WcJW00qnTJR58UWmezckqJ5eOA2+CRM75OQqHtyJ6c0HbKNAKOjQ8EPOEBDcghpxhou5DZOmBSYnY9WMZjsI55UJfAeGQjmViLh6QsYIDrT0UIc60/qlspkcIUgre8t6OfV1MBq3SOTvfseek7D9Tmn5KeLvHBRjfuaBD5HUmEJg5a/PYAn7/gm1Tv3FwbFeQ88arD33Mu+df6oZWcSzP5Zhlx9P634LXpuF7v2Yn4j4TYQAP9qBiLgFC3g"
`endif