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

module altera_merlin_burst_adapter_new
#(
    parameter 
    PKT_BEGIN_BURST             = 81,
    PKT_ADDR_H                  = 79,
    PKT_ADDR_L                  = 48,
    PKT_BYTE_CNT_H              = 5,
    PKT_BYTE_CNT_L              = 0,
    PKT_BURSTWRAP_H             = 11,
    PKT_BURSTWRAP_L             = 6,
    PKT_TRANS_COMPRESSED_READ   = 14,
    PKT_TRANS_WRITE             = 13,
    PKT_TRANS_READ              = 12,
    PKT_BYTEEN_H                = 83,
    PKT_BYTEEN_L                = 80,
    PKT_BURST_TYPE_H            = 88,
    PKT_BURST_TYPE_L            = 87,
    PKT_BURST_SIZE_H            = 86,
    PKT_BURST_SIZE_L            = 84,
    PKT_SAI_H                   = 89,
    PKT_SAI_L                   = 89,
    PKT_EOP_OOO                 = 90,
    PKT_SOP_OOO                 = 91,
    ENABLE_OOO                  = 0,    
    ST_DATA_W                   = 92,
    ST_CHANNEL_W                = 8,
    ROLE_BASED_USER             = 0,

    OUT_BYTE_CNT_H              = 5,
    OUT_BURSTWRAP_H             = 11,

    IN_NARROW_SIZE              = 0,

    OUT_NARROW_SIZE             = 0,

    OUT_FIXED                   = 0,

    OUT_COMPLETE_WRAP           = 0,

    BYTEENABLE_SYNTHESIS        = 0,

    BURSTWRAP_CONST_MASK        = 0,

    BURSTWRAP_CONST_VALUE       = -1,

    NO_WRAP_SUPPORT             = 0,
    INCOMPLETE_WRAP_SUPPORT     = 1,

    PIPE_INPUTS                 = 0,
    PIPE_INTERNAL               = 0,
    SYNC_RESET                  = 0
)
(
    input                           clk,
    input                           reset,

    input                           sink0_valid,
    input [ST_DATA_W    - 1 : 0]    sink0_data,
    input [ST_CHANNEL_W - 1 : 0]    sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    output reg                        source0_valid,
    output reg [ST_DATA_W    - 1 : 0] source0_data,
    output reg [ST_CHANNEL_W - 1 : 0] source0_channel,
    output reg                        source0_startofpacket,
    output reg                        source0_endofpacket,
    input                             source0_ready
);

    localparam
    PKT_SAI_W             = PKT_SAI_H - PKT_SAI_L + 1,
    PKT_BYTE_CNT_W        = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
    PKT_ADDR_W            = PKT_ADDR_H - PKT_ADDR_L + 1,
    PKT_BYTEEN_W          = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
    OUT_BYTE_CNT_W        = OUT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
    OUT_BURSTWRAP_W       = OUT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1,
    PKT_BURSTWRAP_W       = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1,
    PKT_BURST_SIZE_W      = PKT_BURST_SIZE_H - PKT_BURST_SIZE_L + 1,
    PKT_BURST_TYPE_W      = PKT_BURST_TYPE_H - PKT_BURST_TYPE_L + 1,
    SOP_EOP_W             = PKT_SOP_OOO - PKT_EOP_OOO + 1,
    OUT_MAX_BYTE_CNT        = 1 << (OUT_BYTE_CNT_W - 1);  

    localparam
    NUM_SYMBOLS           = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
    LOG2_NUM_SYMBOLS      = log2ceil(NUM_SYMBOLS),
    ADDR_MASK_SEL         = (NUM_SYMBOLS == 1) ? 1 : log2ceil(NUM_SYMBOLS);
    
    localparam
    IN_LEN_W              = PKT_BYTE_CNT_W - LOG2_NUM_SYMBOLS,
    MAX_IN_LEN            = 1 << (IN_LEN_W - 1),
    OUT_LEN_W             = OUT_BYTE_CNT_W - LOG2_NUM_SYMBOLS,
    MAX_OUT_LEN           = 1 << (OUT_LEN_W - 1),

    BNDRY_WIDTH           = PKT_BURSTWRAP_W,
    OUT_BOUNDARY          = MAX_OUT_LEN * NUM_SYMBOLS,
    BYTE_TO_WORD_SHIFT    = log2ceil(NUM_SYMBOLS),
    BYTE_TO_WORD_SHIFT_W  = log2ceil(BYTE_TO_WORD_SHIFT) + 1;

    localparam
    AXI_SLAVE             = OUT_FIXED & OUT_NARROW_SIZE & OUT_COMPLETE_WRAP,
    IS_WRAP_AVALON_SLAVE  = !AXI_SLAVE & (PKT_BURSTWRAP_H != OUT_BURSTWRAP_H),
    IS_INCR_SLAVE         = !AXI_SLAVE & !IS_WRAP_AVALON_SLAVE,
    NON_BURSTING_SLAVE    = (MAX_OUT_LEN == 1),
    INCR_AVALON_SYS       = IS_INCR_SLAVE && (PKT_BURSTWRAP_W == 1) && (OUT_BURSTWRAP_W == 1) && (IN_NARROW_SIZE == 0);

    typedef enum bit [1:0] {

        ST_IDLE         = 2'b00,

        ST_COMP_TRANS   = 2'b01,

        ST_UNCOMP_TRANS = 2'b10
    } t_state;

    t_state state, next_state;

    typedef enum bit[1:0]
    {
        FIXED       = 2'b00,
        INCR        = 2'b01,
        WRAP        = 2'b10,
        REP_WRAP    = 2'b11
    } BurstType;

    wire                         sink0_pipe_valid;
    wire [ST_DATA_W    - 1 : 0]  sink0_pipe_data;
    wire [ST_CHANNEL_W - 1 : 0]  sink0_pipe_channel;
    wire                         sink0_pipe_sop;
    wire                         sink0_pipe_eop;
    wire                         sink0_pipe_ready;

   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate
    
   assign sink0_pipe_valid   = sink0_valid;
   assign sink0_pipe_data    = sink0_data;
   assign sink0_pipe_channel = sink0_channel;
   assign sink0_pipe_sop     = sink0_startofpacket;
   assign sink0_pipe_eop     = sink0_endofpacket;
   assign sink0_ready        = sink0_pipe_ready;

    wire [PKT_BURST_TYPE_W - 1 : 0]  in_bursttype         = sink0_pipe_data[PKT_BURST_TYPE_H : PKT_BURST_TYPE_L];
    wire [PKT_BYTE_CNT_W   - 1 : 0]  in_bytecount         = sink0_pipe_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L];
    wire [PKT_ADDR_W       - 1 : 0]  in_addr              = sink0_pipe_data[PKT_ADDR_H : PKT_ADDR_L];
    wire [63 : 0]                    log2_numsymbols      = log2ceil(NUM_SYMBOLS);
    wire [PKT_BYTE_CNT_W   - 1 : 0]  in_burstcount        = in_bytecount >> log2_numsymbols[PKT_BYTE_CNT_W - 1 : 0];
    wire [IN_LEN_W         - 1 : 0]  in_len               = in_burstcount[IN_LEN_W - 1 : 0];
    wire [PKT_BURST_SIZE_W - 1 : 0]  in_size              = sink0_pipe_data[PKT_BURST_SIZE_H : PKT_BURST_SIZE_L];
    wire                             in_write             = sink0_pipe_data[PKT_TRANS_WRITE];
    wire                             in_compressed_read   = sink0_pipe_data[PKT_TRANS_COMPRESSED_READ];
    wire                             in_read              = sink0_pipe_data[PKT_TRANS_READ];
    wire                             in_uncompressed_read = in_read & ~sink0_pipe_data[PKT_TRANS_COMPRESSED_READ];
    wire                             in_sop               = sink0_pipe_sop;
    wire                             in_eop               = sink0_pipe_eop;
    wire [PKT_BYTEEN_W     - 1 : 0]  in_byteen            = sink0_pipe_data[PKT_BYTEEN_H : PKT_BYTEEN_L];
    wire                             in_passthru          = in_burstcount <= 16;
    wire [PKT_SAI_W-1:0]             in_sai               = sink0_pipe_data[PKT_SAI_H:PKT_SAI_L];
    wire [SOP_EOP_W-1:0]             in_sop_eop_chunks    = sink0_data[PKT_SOP_OOO:PKT_EOP_OOO]; 

    reg  [SOP_EOP_W-1:0]             sop_eop_chunks_reg;
    reg                              sop_eop_chunk_enable;    
      
    wire [SOP_EOP_W-1:0] nxt_sop_eop_chunks;
    reg  [SOP_EOP_W-1:0] d1_sop_eop_chunks;

    wire                             in_valid;
    reg                              in_ready_hold;
    wire                             in_narrow;
    wire [PKT_BURSTWRAP_W  - 1 : 0]  in_burstwrap;
    wire [PKT_ADDR_W       - 1 : 0]  in_aligned_addr;
    wire [PKT_BURSTWRAP_W  - 1 : 0]  in_boundary;

    generate
    if (SYNC_RESET == 0) begin : async_rst0
       always_ff @(posedge clk or posedge reset) begin
           if (reset) begin
               in_ready_hold <= '0;
           end else begin
               in_ready_hold <= '1;
           end
       end
   end 
   else begin 
       always_ff @(posedge clk ) begin
           if (internal_sclr) begin
               in_ready_hold <= '0;
           end else begin
               in_ready_hold <= '1;
           end
       end
    end 
    endgenerate

    assign in_valid = sink0_pipe_valid & in_ready_hold;
    assign in_narrow = in_size < log2_numsymbols[PKT_BYTE_CNT_W - 1 : 0];

    genvar i;
    generate
        for (i = 0; i < PKT_BURSTWRAP_W; i = i+1) begin: assign_burstwrap_bit
            if (BURSTWRAP_CONST_MASK[i]) begin
                assign in_burstwrap[i] = BURSTWRAP_CONST_VALUE[i];
            end
            else begin
                assign in_burstwrap[i] = sink0_pipe_data[PKT_BURSTWRAP_L + i];
            end
        end
    endgenerate

    
    wire [PKT_ADDR_W + LOG2_NUM_SYMBOLS - 1 : 0] out_mask_and_aligned_addr;
    altera_merlin_address_alignment
    #(
        .ADDR_W             (PKT_ADDR_W),
        .BURSTWRAP_W        (1), 
        .TYPE_W             (0), 
        .SIZE_W             (PKT_BURST_SIZE_W),
        .INCREMENT_ADDRESS  (0),
        .NUMSYMBOLS         (NUM_SYMBOLS),
        .SYNC_RESET         (SYNC_RESET)
    ) align_address_to_size
    (
        .clk       (1'b0), 
        .reset     (1'b0), 
        .in_valid  (1'b0), 
        .in_sop    (1'b0), 
        .in_eop    (1'b0), 
        .out_ready (),

        .in_data   ({ in_addr, in_size }),
        .out_data  (out_mask_and_aligned_addr)
    );

    assign in_aligned_addr = out_mask_and_aligned_addr[PKT_ADDR_W - 1 : 0];

    altera_merlin_burst_adapter_burstwrap_increment 
    #(
        .WIDTH (PKT_BURSTWRAP_W)
    ) the_burstwrap_increment
    (
        .mask (in_burstwrap),
        .inc  (in_boundary)
    );

    localparam OUT_BNDRY_ADDR_SEL_W = log2ceil(OUT_BOUNDARY);
    localparam OUT_BOUNDARY_WIDTH   = OUT_BNDRY_ADDR_SEL_W + 1;

    wire [PKT_ADDR_W           - 1 : 0]     in_bndry_addr_sel;

    wire [IN_LEN_W             - 1 : 0]     len_to_in_bndry;

    wire [OUT_BOUNDARY_WIDTH   - 1 : 0]     len_to_out_bndry;

    reg  [IN_LEN_W             - 1 : 0]     first_len;
    wire [BYTE_TO_WORD_SHIFT_W - 1 : 0]     byte_to_word_shift;
    assign byte_to_word_shift = BYTE_TO_WORD_SHIFT[BYTE_TO_WORD_SHIFT_W - 1 : 0];


    assign in_bndry_addr_sel = in_addr & in_burstwrap;
    assign len_to_in_bndry =(in_boundary  - in_bndry_addr_sel [PKT_BURSTWRAP_W-1:0]) >> byte_to_word_shift;
    
    generate

        if (OUT_BNDRY_ADDR_SEL_W > 0) begin : len_to_out_bndry_calc
            wire [OUT_BNDRY_ADDR_SEL_W - 1 : 0] out_bndry_addr_sel;

            assign out_bndry_addr_sel = in_aligned_addr[OUT_BNDRY_ADDR_SEL_W - 1 : 0];
            assign len_to_out_bndry   = (OUT_BOUNDARY [OUT_BOUNDARY_WIDTH-1 :0] - out_bndry_addr_sel) >> byte_to_word_shift;
        end 
        
        else begin : len_to_out_bndry_calc_corner
            assign len_to_out_bndry = OUT_BOUNDARY >> byte_to_word_shift;
        end

    endgenerate

    reg                             in_sop_reg;
    reg                             in_eop_reg;
    reg                             in_valid_reg;
    reg                             in_compressed_read_reg;
    reg                             in_uncompressed_read_reg;
    reg                             in_write_reg;
    reg                             in_passthru_reg;
    reg [PKT_BURST_SIZE_W - 1 : 0]  in_size_reg;
    reg [ST_DATA_W        - 1 : 0]  in_data_reg;
    reg [ST_CHANNEL_W     - 1 : 0]  in_channel_reg;
    reg [PKT_BURST_TYPE_W - 1 : 0]  in_bursttype_reg;
    reg [PKT_BURSTWRAP_W  - 1 : 0]  in_burstwrap_reg;
    reg [PKT_BYTEEN_W     - 1 : 0]  in_byteen_reg;
    reg [PKT_ADDR_W       - 1 : 0]  in_addr_reg;
    reg [PKT_ADDR_W       - 1 : 0]  in_aligned_addr_reg;
    reg [IN_LEN_W         - 1 : 0]  in_len_reg;
    reg                             in_narrow_reg;
    reg [PKT_SAI_W-1:0]             in_sai_reg;

    reg [PKT_ADDR_W       - 1 : 0]  d0_in_addr;
    reg [PKT_ADDR_W       - 1 : 0]  d0_in_aligned_addr;
    reg                             d0_in_sop;
    reg                             d0_in_compressed_read;
    reg                             d0_in_uncompressed_read;
    reg                             d0_in_write;
    reg [PKT_BURST_TYPE_W - 1 : 0]  d0_in_bursttype;
    reg [PKT_BURSTWRAP_W  - 1 : 0]  d0_in_burstwrap;
    reg [PKT_BURSTWRAP_W  - 1 : 0]  d0_in_burstwrap_value;
    reg [PKT_BURST_SIZE_W - 1 : 0]  d0_in_size;
    reg [PKT_BURST_SIZE_W - 1 : 0]  d0_in_size_value;
    reg [IN_LEN_W         - 1 : 0]  d0_in_len;
    reg                             d0_in_valid;
        
    reg                             d1_in_narrow;
    reg [PKT_ADDR_W       - 1 : 0]  d1_in_aligned_addr;
    reg                             d1_in_eop;
    reg                             d1_in_compressed_read;
    reg                             d1_in_uncompressed_read;
    reg [ST_DATA_W        - 1 : 0]  d1_in_data;
    reg [ST_CHANNEL_W     - 1 : 0]  d1_in_channel;
    reg                             d1_in_write;
    reg [PKT_BURST_TYPE_W - 1 : 0]  d1_in_bursttype;
    reg [PKT_BURSTWRAP_W  - 1 : 0]  d1_in_burstwrap;
    reg                             d1_in_passthru;
    reg [PKT_BURST_SIZE_W - 1 : 0]  d1_in_size;
    reg [PKT_BYTEEN_W     - 1 : 0]  d1_in_byteen;
    reg [PKT_SAI_W-1:0]             d1_in_sai;    

    reg                             nb;

    generate
        if (PIPE_INTERNAL == 0) begin : no_internal_pipeline
            always_ff @(posedge clk) begin
               if (sink0_pipe_valid & sink0_pipe_ready) begin
                   in_data_reg              <= sink0_pipe_data;
                   in_channel_reg           <= sink0_pipe_channel;
                   in_bursttype_reg         <= in_bursttype;
                   in_burstwrap_reg         <= in_burstwrap;
                   in_size_reg              <= in_size;
                   in_byteen_reg            <= in_byteen;
                   in_aligned_addr_reg      <= in_aligned_addr;
               end
            end 


          if ( SYNC_RESET == 0) begin : async_rst1
            always_ff @(posedge clk or posedge reset) begin
                if (reset) begin
                    in_eop_reg               <= '0;
                    in_compressed_read_reg   <= '0;
                    in_uncompressed_read_reg <= '0;
                    in_write_reg             <= '0;
                    in_passthru_reg          <= '0;
                    in_narrow_reg            <= '0;
                    in_sai_reg               <= '0;
                end else begin
                    if (sink0_pipe_valid & sink0_pipe_ready) begin
                        in_eop_reg               <= in_eop;
                        in_compressed_read_reg   <= in_compressed_read;
                        in_uncompressed_read_reg <= in_uncompressed_read;
                        in_write_reg             <= in_write;
                        in_narrow_reg            <= in_narrow;
                        if(in_sop)begin
                            if(ROLE_BASED_USER)
                            in_sai_reg           <= in_sai;
                            else
                            in_sai_reg           <= '0;
                        end
                    end
                    if (sink0_pipe_valid & sink0_pipe_ready & in_sop) begin
                        in_passthru_reg <= in_passthru;
                    end
                end 
            end 
          end 

          else begin 
            always_ff @(posedge clk ) begin
                if (internal_sclr) begin
                    in_eop_reg               <= '0;
                    in_compressed_read_reg   <= '0;
                    in_uncompressed_read_reg <= '0;
                    in_write_reg             <= '0;
                    in_passthru_reg          <= '0;
                    in_narrow_reg            <= '0;
                    in_sai_reg               <= '0;
                end else begin
                    if (sink0_pipe_valid & sink0_pipe_ready) begin
                        in_eop_reg               <= in_eop;
                        in_compressed_read_reg   <= in_compressed_read;
                        in_uncompressed_read_reg <= in_uncompressed_read;
                        in_write_reg             <= in_write;
                        in_narrow_reg            <= in_narrow;
                        if(in_sop)begin 
                           if(ROLE_BASED_USER)
                           in_sai_reg           <= in_sai;
                            else
                            in_sai_reg           <= '0;
                        end  
                    end
                    if (sink0_pipe_valid & sink0_pipe_ready & in_sop) begin
                        in_passthru_reg <= in_passthru;
                    end
                end 
            end 
          end 

            always_comb begin
                d0_in_sop                = in_sop;
                d0_in_compressed_read    = in_compressed_read;
                d0_in_uncompressed_read  = in_uncompressed_read;
                d0_in_write              = in_write;
                d0_in_burstwrap          = in_burstwrap;
                d0_in_size               = in_size;
                d0_in_addr               = in_addr;
                d0_in_aligned_addr       = in_aligned_addr;
                d0_in_len                = in_len;
                d0_in_valid              = in_valid;

                d1_in_eop                = in_eop_reg;
                d1_in_compressed_read    = in_compressed_read_reg;
                d1_in_uncompressed_read  = in_uncompressed_read_reg;
                d1_in_write              = in_write_reg;
                d1_in_burstwrap          = in_burstwrap_reg;
                d1_in_size               = in_size_reg;
                d1_in_aligned_addr       = in_aligned_addr_reg;
                d1_in_data               = in_data_reg;
                d1_in_channel            = in_channel_reg;
                d1_in_bursttype          = in_bursttype_reg;
                d1_in_passthru           = in_passthru_reg;
                d1_in_byteen             = in_byteen_reg;
                d1_in_narrow             = in_narrow_reg;
                if (ENABLE_OOO) 
                   d1_sop_eop_chunks        = sop_eop_chunks_reg; 
                if (ROLE_BASED_USER) begin
                d1_in_sai                = in_sai_reg;
                end

                d0_in_size_value         = nb ? d0_in_size : d1_in_size;
                d0_in_burstwrap_value    = nb ? d0_in_burstwrap : d1_in_burstwrap;
            end

        end 
        else begin : internal_pipeline

            reg [PKT_BURST_SIZE_W - 1 : 0] d0_in_size_dl;
            reg [PKT_BURSTWRAP_W - 1 : 0]  d0_in_burstwrap_dl;

            always_ff @(posedge clk) begin
               if (sink0_pipe_valid & sink0_pipe_ready) begin
                   in_data_reg              <= sink0_pipe_data;
                   in_channel_reg           <= sink0_pipe_channel;
                   in_bursttype_reg         <= in_bursttype;
                   in_burstwrap_reg         <= in_burstwrap;
                   in_size_reg              <= in_size;
                   in_byteen_reg            <= in_byteen;
                   in_addr_reg              <= in_addr;
                   in_aligned_addr_reg      <= in_aligned_addr;
                   in_len_reg               <= in_len;
                   if(in_sop && ROLE_BASED_USER)begin
                      in_sai_reg            <= in_sai;
                   end   
               end
               if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                   ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) )) begin
                   d1_in_data              <= in_data_reg;
                   d1_in_channel           <= in_channel_reg;
                   d1_in_bursttype         <= in_bursttype_reg;
                   d1_in_burstwrap         <= in_burstwrap_reg;
                   d0_in_burstwrap_dl      <= in_burstwrap_reg;
                   d1_in_size              <= in_size_reg;
                   d0_in_size_dl           <= in_size_reg;
                   d1_in_byteen            <= in_byteen_reg;
                   d1_in_aligned_addr      <= in_aligned_addr_reg;
                   if (ENABLE_OOO) 
                     d1_sop_eop_chunks       <= sop_eop_chunks_reg;
                   if(ROLE_BASED_USER)
                   d1_in_sai               <= in_sai_reg;
               end 
            end 
        
            if (SYNC_RESET == 0) begin : async_rst2 
               always_ff @(posedge clk or posedge reset) begin
                   if (reset) begin
                       in_eop_reg               <= '0;
                       in_sop_reg               <= '0;
                       in_compressed_read_reg   <= '0;
                       in_uncompressed_read_reg <= '0;
                       in_write_reg             <= '0;
                       in_passthru_reg          <= '0;
                       in_narrow_reg            <= '0;
                       in_valid_reg             <= '0;
                       
                       d1_in_eop                <= '0;
                       d1_in_compressed_read    <= '0;
                       d1_in_write              <= '0;
                       d1_in_passthru           <= '0;
                       d1_sop_eop_chunks        <= '0;
                   end else begin
                       if (sink0_pipe_valid & sink0_pipe_ready) begin
                           in_eop_reg               <= in_eop;
                           in_sop_reg               <= in_sop;
                           in_compressed_read_reg   <= in_compressed_read;
                           in_uncompressed_read_reg <= in_uncompressed_read;
                           in_write_reg             <= in_write;
                           in_narrow_reg            <= in_narrow;
                       end
                       if (in_valid & sink0_pipe_ready & in_sop)
                           in_passthru_reg <= in_passthru;
                       if (sink0_pipe_ready)
                           in_valid_reg <= in_valid;
                       if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                           ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) )) begin
                           d1_in_eop               <= in_eop_reg;
                           d1_in_compressed_read   <= in_compressed_read_reg;
                           d1_in_write             <= in_write_reg;
                           d1_in_passthru          <= in_passthru_reg;
                           d1_in_narrow            <= in_narrow_reg;
                           d1_in_uncompressed_read <= in_uncompressed_read_reg;
                           if (ENABLE_OOO) 
                             d1_sop_eop_chunks       <= sop_eop_chunks_reg;
                       end 
                   end 
               end 
            end 

            else begin 
               always_ff @(posedge clk ) begin
                   if (internal_sclr) begin
                       in_eop_reg               <= '0;
                       in_sop_reg               <= '0;
                       in_compressed_read_reg   <= '0;
                       in_uncompressed_read_reg <= '0;
                       in_write_reg             <= '0;
                       in_passthru_reg          <= '0;
                       in_narrow_reg            <= '0;
                       in_valid_reg             <= '0;
                       
                       d1_in_eop                <= '0;
                       d1_in_compressed_read    <= '0;
                       d1_in_write              <= '0;
                       d1_in_passthru           <= '0;
                   end else begin
                       if (sink0_pipe_valid & sink0_pipe_ready) begin
                           in_eop_reg               <= in_eop;
                           in_sop_reg               <= in_sop;
                           in_compressed_read_reg   <= in_compressed_read;
                           in_uncompressed_read_reg <= in_uncompressed_read;
                           in_write_reg             <= in_write;
                           in_narrow_reg            <= in_narrow;
                       end
                       if (in_valid & sink0_pipe_ready & in_sop)
                           in_passthru_reg <= in_passthru;
                       if (sink0_pipe_ready)
                           in_valid_reg <= in_valid;
                       if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                           ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) )) begin
                           d1_in_eop               <= in_eop_reg;
                           d1_in_compressed_read   <= in_compressed_read_reg;
                           d1_in_write             <= in_write_reg;
                           d1_in_passthru          <= in_passthru_reg;
                           d1_in_narrow            <= in_narrow_reg;
                           d1_in_uncompressed_read <= in_uncompressed_read_reg;
                           if (ENABLE_OOO) 
                             d1_sop_eop_chunks       <= sop_eop_chunks_reg;
                       end 
                   end 
               end 
            end 
 
            always_comb begin
                d0_in_valid             = in_valid_reg;
                d0_in_sop               = in_sop_reg;
                d0_in_compressed_read   = in_compressed_read_reg;
                d0_in_uncompressed_read = in_uncompressed_read_reg;
                d0_in_write             = in_write_reg;
                d0_in_burstwrap         = in_burstwrap_reg;
                d0_in_size              = in_size_reg;
                d0_in_size_value        = nb ? in_size_reg : d0_in_size_dl;
                d0_in_burstwrap_value   = nb ? in_burstwrap_reg : d0_in_burstwrap_dl;
                d0_in_addr              = in_addr_reg;
                d0_in_aligned_addr      = in_aligned_addr_reg;
                d0_in_len               = in_len_reg;
            end 
        end 

    endgenerate


    generate
    if (SYNC_RESET == 0) begin : async_rst3
       always_ff @(posedge clk or posedge reset) begin
           if (reset)  begin
               state <= ST_IDLE;
           end else begin
               if (~source0_valid | source0_ready) begin
                   state <= next_state;
               end
           end
       end
    end 
    else begin 
      always_ff @(posedge clk   ) begin
           if (internal_sclr)  begin
               state <= ST_IDLE;
           end else begin
               if (~source0_valid | source0_ready) begin
                   state <= next_state;
               end
           end
       end
    end 
    endgenerate

    always_comb begin : state_transition
        next_state = ST_IDLE;   
        case (state)
            ST_IDLE : begin
                next_state = ST_IDLE;

                if (d0_in_valid) begin
                    if (d0_in_write | d0_in_uncompressed_read)  next_state = ST_UNCOMP_TRANS;
                    if (d0_in_compressed_read)                  next_state = ST_COMP_TRANS;
                end
            end

            ST_UNCOMP_TRANS : begin
                next_state = ST_UNCOMP_TRANS;

                if (source0_endofpacket) begin
                    if (!d0_in_valid) next_state = ST_IDLE;
                    else begin
                        if (d0_in_write | d0_in_uncompressed_read)  next_state = ST_UNCOMP_TRANS;
                        if (d0_in_compressed_read)                  next_state = ST_COMP_TRANS;
                    end
                end
            end
            ST_COMP_TRANS : begin
                next_state = ST_COMP_TRANS;

                if (source0_endofpacket) begin
                    if (!d0_in_valid) begin
                        next_state = ST_IDLE;
                    end
                    else begin
                        if (d0_in_write | d0_in_uncompressed_read) next_state = ST_UNCOMP_TRANS;
                        if (d0_in_compressed_read)                 next_state = ST_COMP_TRANS;
                    end
                end
            end
        endcase
    end

    wire [PKT_BYTE_CNT_W  - 1 : 0]  out_byte_cnt;
    wire [IN_LEN_W        - 1 : 0]  incr_out_len;
    wire [IN_LEN_W        - 1 : 0]  wrap_out_len;
    wire [IN_LEN_W        - 1 : 0]  incr_uncompr_out_len;
    wire [IN_LEN_W        - 1 : 0]  wrap_uncompr_out_len;
    wire [PKT_ADDR_W      - 1 : 0]  incr_out_addr;
    wire [PKT_ADDR_W      - 1 : 0]  wrap_out_addr;
    wire [PKT_ADDR_W      - 1 : 0]  fixed_out_addr;
    reg  [PKT_ADDR_W      - 1 : 0]  uncompr_out_addr;
    wire [IN_LEN_W        - 1 : 0]  fixed_out_len;
    wire [PKT_ADDR_W      - 1 : 0]  out_addr;

    wire                    in_full_size_write_wrap;
    wire                    in_full_size_read_wrap;
    wire                    in_default_converter;
    wire                    in_full_size_incr;
    reg                     in_default_converter_reg;
    reg                     in_full_size_incr_reg;
    reg                     in_full_size_write_wrap_reg;
    reg                     in_full_size_read_wrap_reg;

    wire                    new_burst;
    wire                    fixed_new_burst;
    wire                    wrap_new_burst;
    wire                    incr_new_burst;

    wire                    next_out_sop;
    wire                    next_out_eop;
    wire                    is_passthru;
    wire                    enable_incr_converter;
    wire                    enable_fixed_converter;
    wire                    enable_write_wrap_converter;
    wire                    enable_read_wrap_converter;
    wire                    enable_incr_write_converter;
    wire                    enable_incr_read_converter;
    reg [IN_LEN_W - 1 : 0]  d0_first_len;


    generate
        if (NON_BURSTING_SLAVE) begin : non_bursting_converter_control
            wire [PKT_BYTE_CNT_W  - 1 : 0]  fixed_out_byte_cnt;
            assign fixed_out_byte_cnt = fixed_out_len << log2_numsymbols;

            if (PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                always_comb begin
                    d0_in_bursttype            = nb ? in_bursttype : in_bursttype_reg;
                end
            end
            else begin : PIPELINE_INPUT
                reg [PKT_BURST_TYPE_W - 1 :0]  d0_in_bursttype_dl;

                always_ff @(posedge clk) begin
                  if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                      ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                      d0_in_bursttype_dl        <= in_bursttype_reg;
                  end
                end 
 
                always_comb begin
                    d0_in_bursttype            = nb ? in_bursttype_reg : d0_in_bursttype_dl;
                end
            end

            assign nb                        =  fixed_new_burst;

            assign enable_fixed_converter = (d0_in_valid  && (source0_ready | !source0_valid) || (source0_endofpacket ?  1'b0 :(state == ST_COMP_TRANS) && (!source0_valid | source0_ready)));
           
            assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(fixed_new_burst)) ? 1'b0 : d0_in_sop;
            assign next_out_eop = (state == ST_COMP_TRANS) ?  fixed_new_burst  : d1_in_eop;
            
            assign out_byte_cnt  = fixed_out_byte_cnt;
            assign out_addr      = fixed_out_addr;
        end
        else if (INCR_AVALON_SYS) begin : incr_avalon_converter_control
            wire [PKT_BYTE_CNT_W  - 1 : 0]  incr_out_byte_cnt;
            assign incr_out_byte_cnt  = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;

            assign nb                        =  incr_new_burst;
            
            assign enable_incr_converter = (d0_in_valid  && (source0_ready | !source0_valid) || (source0_endofpacket ?  1'b0 :(state == ST_COMP_TRANS) && (!source0_valid | source0_ready)));
            
            assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(incr_new_burst)) ? 1'b0 : d0_in_sop;
            assign next_out_eop = (state == ST_COMP_TRANS) ?  incr_new_burst  : d1_in_eop;
            
            assign out_byte_cnt  = incr_out_byte_cnt;
            assign out_addr  =  incr_out_addr;
        end
        else begin : other_converter_control
            if (IS_WRAP_AVALON_SLAVE) begin
                wire                    in_narrow_or_fixed;
                wire                    in_read_but_not_fixed_or_narrow;
                wire                    in_write_but_not_fixed_or_narrow;
                reg                     in_read_but_not_fixed_or_narrow_reg;
                reg                     in_write_but_not_fixed_or_narrow_reg;
                reg                     in_narrow_or_fixed_reg;
                reg                     d0_in_read_but_not_fixed_or_narrow;
                reg                     d0_in_write_but_not_fixed_or_narrow;
                reg                     d0_in_default_converter;
                reg                     d1_in_narrow_or_fixed;
                reg                     d1_in_read_but_not_fixed_or_narrow;
                reg                     d1_in_write_but_not_fixed_or_narrow;
                reg                     d1_in_default_converter;
                reg [IN_LEN_W - 1 : 0]  first_len_reg;

                wire [PKT_BYTE_CNT_W - 1 : 0]  fixed_out_byte_cnt;
                wire [PKT_BYTE_CNT_W - 1 : 0]  incr_out_byte_cnt;
                wire                    in_fixed = (in_bursttype == 2'b00) || (in_bursttype == 2'b11);

                assign nb                               = (d1_in_narrow_or_fixed ? fixed_new_burst : new_burst);
                assign in_read_but_not_fixed_or_narrow  = in_compressed_read & !in_narrow_or_fixed;
                assign in_write_but_not_fixed_or_narrow = in_write & !in_narrow_or_fixed;
                assign in_narrow_or_fixed               = in_narrow || in_fixed;
                assign in_default_converter             = in_fixed || in_narrow || in_uncompressed_read;
                assign incr_out_byte_cnt                = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;
                assign fixed_out_byte_cnt               = fixed_out_len << log2_numsymbols;

                if (PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                  if ( SYNC_RESET == 0) begin : async_rst5
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_narrow_or_fixed_reg               <= '0;
                            in_read_but_not_fixed_or_narrow_reg  <= '0;
                            in_write_but_not_fixed_or_narrow_reg <= '0;
                            in_default_converter_reg             <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_narrow_or_fixed_reg               <= in_narrow_or_fixed;
                                in_read_but_not_fixed_or_narrow_reg  <= in_read_but_not_fixed_or_narrow;
                                in_write_but_not_fixed_or_narrow_reg <= in_write_but_not_fixed_or_narrow;
                                in_default_converter_reg             <= in_default_converter;
                            end 
                        end 
                    end 
                   end 
                   else begin  
                    always_ff @(posedge clk  ) begin
                        if (internal_sclr) begin
                            in_narrow_or_fixed_reg               <= '0;
                            in_read_but_not_fixed_or_narrow_reg  <= '0;
                            in_write_but_not_fixed_or_narrow_reg <= '0;
                            in_default_converter_reg             <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_narrow_or_fixed_reg               <= in_narrow_or_fixed;
                                in_read_but_not_fixed_or_narrow_reg  <= in_read_but_not_fixed_or_narrow;
                                in_write_but_not_fixed_or_narrow_reg <= in_write_but_not_fixed_or_narrow;
                                in_default_converter_reg             <= in_default_converter;
                            end 
                        end 
                    end 
                   end 

                    always_comb begin
                        d0_first_len                         = first_len;
                        d0_in_read_but_not_fixed_or_narrow   = in_read_but_not_fixed_or_narrow;
                        d0_in_write_but_not_fixed_or_narrow  = in_write_but_not_fixed_or_narrow;
                        d0_in_default_converter              = in_default_converter;
                        d1_in_narrow_or_fixed                = in_narrow_or_fixed_reg;
                        d1_in_read_but_not_fixed_or_narrow   = in_read_but_not_fixed_or_narrow_reg;
                        d1_in_write_but_not_fixed_or_narrow  = in_write_but_not_fixed_or_narrow_reg;
                        d1_in_default_converter              = in_default_converter_reg;
                    end 
                end 
                else begin : PIPELINE_INPUT
                  if (SYNC_RESET == 0 ) begin : async_rst6
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_narrow_or_fixed_reg               <= '0;
                            in_read_but_not_fixed_or_narrow_reg  <= '0;
                            in_write_but_not_fixed_or_narrow_reg <= '0;
                            in_default_converter_reg             <= '0;
                            d1_in_narrow_or_fixed                <= '0;
                            d1_in_read_but_not_fixed_or_narrow   <= '0;
                            d1_in_write_but_not_fixed_or_narrow  <= '0;
                            d1_in_default_converter              <= '0;
                            first_len_reg                        <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_narrow_or_fixed_reg               <= in_narrow_or_fixed;
                                in_read_but_not_fixed_or_narrow_reg  <= in_read_but_not_fixed_or_narrow;
                                in_write_but_not_fixed_or_narrow_reg <= in_write_but_not_fixed_or_narrow;
                                in_default_converter_reg             <= in_default_converter;
                            end 
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                first_len_reg                       <= first_len;
                                d1_in_narrow_or_fixed               <= in_narrow_or_fixed_reg;
                                d1_in_read_but_not_fixed_or_narrow  <= in_read_but_not_fixed_or_narrow_reg;
                                d1_in_write_but_not_fixed_or_narrow <= in_write_but_not_fixed_or_narrow_reg;
                                d1_in_default_converter             <= in_default_converter_reg;
                            end
                        end 
                    end 
                  end 
                  else begin 

                    always_ff @(posedge clk ) begin
                        if (internal_sclr) begin
                            in_narrow_or_fixed_reg               <= '0;
                            in_read_but_not_fixed_or_narrow_reg  <= '0;
                            in_write_but_not_fixed_or_narrow_reg <= '0;
                            in_default_converter_reg             <= '0;
                            d1_in_narrow_or_fixed                <= '0;
                            d1_in_read_but_not_fixed_or_narrow   <= '0;
                            d1_in_write_but_not_fixed_or_narrow  <= '0;
                            d1_in_default_converter              <= '0;
                            first_len_reg                        <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_narrow_or_fixed_reg               <= in_narrow_or_fixed;
                                in_read_but_not_fixed_or_narrow_reg  <= in_read_but_not_fixed_or_narrow;
                                in_write_but_not_fixed_or_narrow_reg <= in_write_but_not_fixed_or_narrow;
                                in_default_converter_reg             <= in_default_converter;
                            end 
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                first_len_reg                       <= first_len;
                                d1_in_narrow_or_fixed               <= in_narrow_or_fixed_reg;
                                d1_in_read_but_not_fixed_or_narrow  <= in_read_but_not_fixed_or_narrow_reg;
                                d1_in_write_but_not_fixed_or_narrow <= in_write_but_not_fixed_or_narrow_reg;
                                d1_in_default_converter             <= in_default_converter_reg;
                            end
                        end 
                    end 
                  end 
 
                    always_comb begin
                        d0_in_default_converter              = in_default_converter_reg;
                        d0_first_len                         = first_len_reg;
                        d0_in_read_but_not_fixed_or_narrow   = in_read_but_not_fixed_or_narrow_reg;
                        d0_in_write_but_not_fixed_or_narrow  = in_write_but_not_fixed_or_narrow_reg;
                    end
                end 

                wire same_boundary;
                if (OUT_BNDRY_ADDR_SEL_W <= PKT_BURSTWRAP_W - 1) begin
                    assign same_boundary = (in_boundary[OUT_BNDRY_ADDR_SEL_W] == 1);
                end else begin
                    assign same_boundary = 0;
                end

                wire in_len_smaller_not_cross_out_bndry;
                wire in_len_smaller_not_cross_in_bndry;

                assign in_len_smaller_not_cross_out_bndry  = (in_len <= len_to_out_bndry);
                assign in_len_smaller_not_cross_in_bndry   = (in_len <= len_to_in_bndry);
                always_comb begin
                    if ((in_boundary > OUT_BOUNDARY) || (in_burstwrap[BNDRY_WIDTH - 1] == 1)) begin
                        first_len  = len_to_out_bndry;
                        if (in_len_smaller_not_cross_out_bndry || same_boundary)
                            first_len = in_len;
                    end
                    else begin
                        first_len  = len_to_in_bndry;
                        if (in_len_smaller_not_cross_in_bndry || same_boundary)
                            first_len = in_len;
                    end
                end 

                assign enable_incr_write_converter = (d0_in_valid && d0_in_write_but_not_fixed_or_narrow && fixed_new_burst && new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_write_but_not_fixed_or_narrow && !nb));
                assign enable_incr_read_converter  = (d0_in_valid && d0_in_read_but_not_fixed_or_narrow && fixed_new_burst && (source0_ready || !source0_valid) || (( state == ST_COMP_TRANS) && source0_ready && d1_in_read_but_not_fixed_or_narrow && !nb));
                assign enable_fixed_converter      = (d0_in_valid && d0_in_default_converter && new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !nb));

                assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : new_burst)) ? 1'b0 : d0_in_sop;
                assign next_out_eop  = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : new_burst)  : d1_in_eop;
                
                assign out_byte_cnt  = d1_in_default_converter ? fixed_out_byte_cnt : incr_out_byte_cnt;
                assign out_addr      = d1_in_default_converter ? fixed_out_addr : incr_out_addr;
            end 

            if (AXI_SLAVE) begin
                reg [IN_LEN_W - 1 : 0]   first_len_reg;
                reg                      d0_in_incr;
                reg                      d1_in_incr;
                reg                      in_incr_reg;
                wire                     in_read_wrap_conveter;
                wire                     in_write_wrap_conveter;
                reg                      in_read_wrap_conveter_reg;
                reg                      in_write_wrap_conveter_reg;

                reg                      d0_in_read_wrap_conveter;
                reg                      d0_in_write_wrap_conveter;
                reg                      d0_in_default_converter;
                reg                      d1_in_read_wrap_conveter;
                reg                      d1_in_write_wrap_conveter;
                reg                      d1_in_default_converter;

                wire                     in_incr                          = (in_bursttype == 2'b01) && !in_uncompressed_read;
                wire                     in_wrap                          = (in_bursttype == 2'b10);
                wire                     in_fixed                         = (in_bursttype == 2'b00) || (in_bursttype == 2'b11);
                wire                     in_narrow_read_wrap_smaller_16   = in_narrow && in_wrap && is_passthru && in_compressed_read;
                wire                     in_narrow_write_wrap_smaller_16  = in_narrow && in_wrap && is_passthru && in_write;
                wire                     in_narrow_wrap_larger_16         = in_narrow && in_wrap && !is_passthru;
                
                wire [PKT_BYTE_CNT_W  - 1 : 0]  wrap_out_byte_cnt;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  fixed_out_byte_cnt;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  incr_out_byte_cnt;

                assign incr_out_byte_cnt  = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;
                assign wrap_out_byte_cnt  = (d1_in_compressed_read ? wrap_out_len : wrap_uncompr_out_len) << log2_numsymbols;
                assign fixed_out_byte_cnt = fixed_out_len << log2_numsymbols;

                assign in_full_size_read_wrap  = in_compressed_read & in_wrap & !in_narrow;
                assign in_full_size_write_wrap = in_write & in_wrap & !in_narrow;
                assign in_read_wrap_conveter   = in_full_size_read_wrap  || in_narrow_read_wrap_smaller_16;
                assign in_write_wrap_conveter  = in_full_size_write_wrap || in_narrow_write_wrap_smaller_16;
                assign in_default_converter    = in_narrow_wrap_larger_16 || in_fixed || in_uncompressed_read;

                assign nb                       = (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst));
                assign is_passthru = in_sop ? (in_passthru) : in_passthru_reg;
                
                if(PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                 if (SYNC_RESET == 0) begin : async_rst7
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_write_wrap_conveter_reg <= '0;
                            in_read_wrap_conveter_reg  <= '0;
                            in_default_converter_reg   <= '0;
                            in_incr_reg                <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_write_wrap_conveter_reg <= in_write_wrap_conveter;
                                in_read_wrap_conveter_reg  <= in_read_wrap_conveter;
                                in_default_converter_reg   <= in_default_converter;
                                in_incr_reg                <= in_incr;
                            end
                        end 
                    end 
                  end 
                  else begin 
                    always_ff @(posedge clk ) begin
                        if (internal_sclr) begin
                            in_write_wrap_conveter_reg <= '0;
                            in_read_wrap_conveter_reg  <= '0;
                            in_default_converter_reg   <= '0;
                            in_incr_reg                <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_write_wrap_conveter_reg <= in_write_wrap_conveter;
                                in_read_wrap_conveter_reg  <= in_read_wrap_conveter;
                                in_default_converter_reg   <= in_default_converter;
                                in_incr_reg                <= in_incr;
                            end
                        end 
                    end 
                  end 

                    always_comb begin
                        d0_in_incr                 = in_incr;
                        d0_in_default_converter    = in_default_converter;
                        d0_in_read_wrap_conveter   = in_read_wrap_conveter;
                        d0_in_write_wrap_conveter  = in_write_wrap_conveter;
                        d0_first_len               = first_len;
                        d1_in_default_converter    = in_default_converter_reg;
                        d1_in_read_wrap_conveter   = in_read_wrap_conveter_reg;
                        d1_in_write_wrap_conveter  = in_write_wrap_conveter_reg;
                        d1_in_incr                 = in_incr_reg;
                        d0_in_bursttype            = nb ? in_bursttype : in_bursttype_reg;
                    end
                end
                else begin : PIPELINE_INPUT
                        reg [PKT_BURST_TYPE_W - 1 :0]  d0_in_bursttype_dl;
                  if (SYNC_RESET == 0) begin : async_rst8
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_write_wrap_conveter_reg <= '0;
                            in_read_wrap_conveter_reg  <= '0;
                            in_default_converter_reg   <= '0;
                            d1_in_default_converter    <= '0;
                            d1_in_read_wrap_conveter   <= '0;
                            d1_in_write_wrap_conveter  <= '0;
                            first_len_reg              <= '0;
                            in_incr_reg                <= '0;
                            d0_in_bursttype_dl         <= '0;
                        end else begin
                            if (sink0_pipe_ready & in_valid) begin
                                in_write_wrap_conveter_reg <= in_write_wrap_conveter;
                                in_read_wrap_conveter_reg  <= in_read_wrap_conveter;
                                in_default_converter_reg   <= in_default_converter;
                                first_len_reg              <= first_len;
                                in_incr_reg                <= in_incr;
                            end
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                d1_in_default_converter   <= in_default_converter_reg;
                                d1_in_read_wrap_conveter  <= in_read_wrap_conveter_reg;
                                d1_in_write_wrap_conveter <= in_write_wrap_conveter_reg;
                                d1_in_incr                <= in_incr_reg;
                                d0_in_bursttype_dl        <= in_bursttype_reg;
                            end
                        end 
                    end 
                  end 

                  else begin 
                    always_ff @(posedge clk ) begin
                        if (internal_sclr) begin
                            in_write_wrap_conveter_reg <= '0;
                            in_read_wrap_conveter_reg  <= '0;
                            in_default_converter_reg   <= '0;
                            d1_in_default_converter    <= '0;
                            d1_in_read_wrap_conveter   <= '0;
                            d1_in_write_wrap_conveter  <= '0;
                            first_len_reg              <= '0;
                            in_incr_reg                <= '0;
                            d0_in_bursttype_dl         <= '0;
                        end else begin
                            if (sink0_pipe_ready & in_valid) begin
                                in_write_wrap_conveter_reg <= in_write_wrap_conveter;
                                in_read_wrap_conveter_reg  <= in_read_wrap_conveter;
                                in_default_converter_reg   <= in_default_converter;
                                first_len_reg              <= first_len;
                                in_incr_reg                <= in_incr;
                            end
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                d1_in_default_converter   <= in_default_converter_reg;
                                d1_in_read_wrap_conveter  <= in_read_wrap_conveter_reg;
                                d1_in_write_wrap_conveter <= in_write_wrap_conveter_reg;
                                d1_in_incr                <= in_incr_reg;
                                d0_in_bursttype_dl        <= in_bursttype_reg;
                            end
                        end 
                    end 
                  end 

                    always_comb begin
                        d0_in_incr                 = in_incr_reg;
                        d0_in_default_converter    = in_default_converter_reg;
                        d0_in_read_wrap_conveter   = in_read_wrap_conveter_reg;
                        d0_in_write_wrap_conveter  = in_write_wrap_conveter_reg;
                        d0_first_len               = first_len_reg;
                        d0_in_bursttype            = nb ? in_bursttype_reg : d0_in_bursttype_dl;
                    end
                end

                always_comb begin
                    if (in_boundary > OUT_BOUNDARY) begin
                        first_len = is_passthru ? in_len : len_to_out_bndry;
                    end else begin
                        first_len = is_passthru ? in_len : len_to_in_bndry;
                    end
                end 

                assign new_burst                   = incr_new_burst && wrap_new_burst;
                assign enable_incr_converter       = (d0_in_valid && d0_in_incr && fixed_new_burst && wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_incr && !nb));
                assign enable_write_wrap_converter = (d0_in_valid && d0_in_write_wrap_conveter && fixed_new_burst && new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_write_wrap_conveter && !nb));
                assign enable_read_wrap_converter  = (d0_in_valid && d0_in_read_wrap_conveter && fixed_new_burst && new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_read_wrap_conveter && !nb));
                assign enable_fixed_converter      = (d0_in_valid && d0_in_default_converter && new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !nb));
                
                assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))) ? 1'b0 : d0_in_sop;
                assign next_out_eop = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))  : d1_in_eop;

                assign out_byte_cnt  = d1_in_default_converter ? fixed_out_byte_cnt : (d1_in_incr ? incr_out_byte_cnt : wrap_out_byte_cnt);
                assign out_addr      = d1_in_default_converter ? fixed_out_addr : (d1_in_incr ? incr_out_addr : wrap_out_addr);
            end 

            if (IS_INCR_SLAVE) begin
                reg [IN_LEN_W - 1 : 0]   first_len_reg;
                reg                      d0_in_default_converter;
                reg                      d0_in_full_size_incr;
                reg                      d0_in_full_size_write_wrap;
                reg                      d0_in_full_size_read_wrap;
                reg                      d1_in_default_converter;
                reg                      d1_in_full_size_incr;
                reg                      d1_in_full_size_write_wrap;
                reg                      d1_in_full_size_read_wrap;
                reg                      d1_in_incr;
                reg                      in_incr_reg;
                wire                     in_incr  = (in_bursttype == 2'b01);
                wire                     in_wrap  = (in_bursttype == 2'b10);

                wire [PKT_BYTE_CNT_W  - 1 : 0]  incr_out_byte_cnt;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  fixed_out_byte_cnt;

                assign incr_out_byte_cnt  = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;
                assign fixed_out_byte_cnt = fixed_out_len << log2_numsymbols;

                if (NO_WRAP_SUPPORT) begin
                    assign in_default_converter      = !in_full_size_incr;
                    assign nb   = d1_in_default_converter ? fixed_new_burst : incr_new_burst;
                end
                else begin
                    wire    in_narrow_incr;
                    wire    in_fixed = (in_bursttype == 2'b00) || (in_bursttype == 2'b11);

                    assign in_narrow_incr       = in_incr & in_narrow;
                    assign in_default_converter = in_fixed || in_narrow || in_narrow_incr || in_uncompressed_read;
                    assign nb                   = (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst));
                end

                assign in_full_size_incr         = in_incr & !in_narrow & !in_uncompressed_read;
                assign in_full_size_write_wrap   = in_write & in_wrap & !in_narrow;
                assign in_full_size_read_wrap    = in_compressed_read & in_wrap & !in_narrow;
                
                if(PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                   if (SYNC_RESET == 0) begin : async_rst9
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_full_size_write_wrap_reg <= '0;
                            in_full_size_read_wrap_reg  <= '0;
                            in_full_size_incr_reg       <= '0;
                            in_default_converter_reg    <= '0;
                            in_incr_reg                 <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_incr_reg                 <= in_incr;
                                in_full_size_incr_reg       <= in_full_size_incr;
                                in_full_size_write_wrap_reg <= in_full_size_write_wrap;
                                in_full_size_read_wrap_reg  <= in_full_size_read_wrap;
                                in_default_converter_reg    <= in_default_converter;
                            end
                        end 
                    end 
                   end 
               
                   else begin 
                    always_ff @(posedge clk ) begin
                        if (internal_sclr) begin
                            in_full_size_write_wrap_reg <= '0;
                            in_full_size_read_wrap_reg  <= '0;
                            in_full_size_incr_reg       <= '0;
                            in_default_converter_reg    <= '0;
                            in_incr_reg                 <= '0;
                        end else begin
                            if (sink0_pipe_ready & sink0_pipe_valid) begin
                                in_incr_reg                 <= in_incr;
                                in_full_size_incr_reg       <= in_full_size_incr;
                                in_full_size_write_wrap_reg <= in_full_size_write_wrap;
                                in_full_size_read_wrap_reg  <= in_full_size_read_wrap;
                                in_default_converter_reg    <= in_default_converter;
                            end
                        end 
                    end 
                  end 

                    always_comb begin
                        d0_in_default_converter     = in_default_converter;
                        d0_in_full_size_incr        = in_full_size_incr;
                        d0_in_full_size_write_wrap  = in_full_size_write_wrap;
                        d0_in_full_size_read_wrap   = in_full_size_read_wrap;
                        d0_first_len                = first_len;
                        d1_in_incr                  = in_incr_reg;
                        d1_in_default_converter     = in_default_converter_reg;
                        d1_in_full_size_incr        = in_full_size_incr_reg;
                        d1_in_full_size_write_wrap  = in_full_size_write_wrap_reg;
                        d1_in_full_size_read_wrap   = in_full_size_read_wrap_reg;
                        d0_in_bursttype             = nb ? in_bursttype : in_bursttype_reg;
                    end
                end
                else begin : PIPELINE_INPUT
                    reg [PKT_BURST_TYPE_W - 1 :0]  d0_in_bursttype_dl;
                    always_ff @(posedge clk) begin
                            if (sink0_pipe_ready & in_valid) begin
                                first_len_reg               <= first_len;
                            end
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                d0_in_bursttype_dl         <= in_bursttype_reg;
                            end
                    end 

                  if (SYNC_RESET == 0) begin : async_rst10
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_full_size_write_wrap_reg <= '0;
                            in_full_size_read_wrap_reg  <= '0;
                            in_full_size_incr_reg       <= '0;
                            in_default_converter_reg    <= '0;
                            d1_in_default_converter     <= '0;
                            d1_in_full_size_incr        <= '0;
                            d1_in_full_size_write_wrap  <= '0;
                            d1_in_full_size_read_wrap   <= '0;
                            d1_in_incr                  <= '0;
                            in_incr_reg                 <= '0;
                        end else begin
                            if (sink0_pipe_ready & in_valid) begin
                                in_full_size_incr_reg       <= in_full_size_incr;
                                in_full_size_write_wrap_reg <= in_full_size_write_wrap;
                                in_full_size_read_wrap_reg  <= in_full_size_read_wrap;
                                in_default_converter_reg    <= in_default_converter;
                                in_incr_reg                 <= in_incr;
                            end
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                d1_in_default_converter    <= in_default_converter_reg;
                                d1_in_full_size_incr       <= in_full_size_incr_reg;
                                d1_in_full_size_write_wrap <= in_full_size_write_wrap_reg;
                                d1_in_full_size_read_wrap  <= in_full_size_read_wrap_reg;
                                d1_in_incr                 <= in_incr_reg;
                            end
                        end 
                    end 
                  end 
                  else begin 
                     always_ff @(posedge clk ) begin
                        if (internal_sclr) begin
                            in_full_size_write_wrap_reg <= '0;
                            in_full_size_read_wrap_reg  <= '0;
                            in_full_size_incr_reg       <= '0;
                            in_default_converter_reg    <= '0;
                            d1_in_default_converter     <= '0;
                            d1_in_full_size_incr        <= '0;
                            d1_in_full_size_write_wrap  <= '0;
                            d1_in_full_size_read_wrap   <= '0;
                            d1_in_incr                  <= '0;
                            in_incr_reg                 <= '0;
                        end 
                        else begin
                            if (sink0_pipe_ready & in_valid) begin
                                in_full_size_incr_reg       <= in_full_size_incr;
                                in_full_size_write_wrap_reg <= in_full_size_write_wrap;
                                in_full_size_read_wrap_reg  <= in_full_size_read_wrap;
                                in_default_converter_reg    <= in_default_converter;
                                in_incr_reg                 <= in_incr;
                            end

                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                d1_in_default_converter    <= in_default_converter_reg;
                                d1_in_full_size_incr       <= in_full_size_incr_reg;
                                d1_in_full_size_write_wrap <= in_full_size_write_wrap_reg;
                                d1_in_full_size_read_wrap  <= in_full_size_read_wrap_reg;
                                d1_in_incr                 <= in_incr_reg;
                            end
                        end 
                     end 
                  end 

                  always_comb begin
                      d0_in_default_converter     = in_default_converter_reg;
                      d0_in_full_size_incr        = in_full_size_incr_reg;
                      d0_in_full_size_write_wrap  = in_full_size_write_wrap_reg;
                      d0_in_full_size_read_wrap   = in_full_size_read_wrap_reg;
                      d0_first_len                = first_len_reg;
                      d0_in_bursttype             = nb ? in_bursttype_reg : d0_in_bursttype_dl;
                  end
                end
                
                if (!NO_WRAP_SUPPORT) begin : HAVE_WRAP_BURSTING_SUPPORT
                    if (!INCOMPLETE_WRAP_SUPPORT) begin : no_incomplete_wrap_support
                        assign first_len = (in_boundary > OUT_BOUNDARY) ? len_to_out_bndry : len_to_in_bndry;
                    end
                    else begin : incomplete_wrap_support
                        wire in_len_smaller_aligned_out_bdry = (in_len <= len_to_out_bndry);
                        wire in_len_smaller_aligned_in_bdry  = (in_len <= len_to_in_bndry);
                        always_comb begin
                            if (in_boundary > OUT_BOUNDARY) begin
                                first_len = (in_len_smaller_aligned_out_bdry) ? in_len : len_to_out_bndry;
                            end
                            else begin
                                first_len = (in_len_smaller_aligned_in_bdry) ? in_len : len_to_in_bndry;
                            end
                        end
                    end 
                end

                if (NO_WRAP_SUPPORT) begin
                    assign enable_incr_converter        = (d0_in_valid && d0_in_full_size_incr && fixed_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_incr && !nb));
                    assign enable_fixed_converter       = (d0_in_valid && d0_in_default_converter && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !nb));
                    
                    assign next_out_sop  = (state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : incr_new_burst) ? 1'b0 : d0_in_sop;
                    assign next_out_eop = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : incr_new_burst)  : d1_in_eop;
                    
                    assign out_byte_cnt  = d1_in_default_converter ? fixed_out_byte_cnt : incr_out_byte_cnt;
                    assign out_addr  = d1_in_default_converter ? fixed_out_addr : incr_out_addr;
                end
                else begin
                    assign new_burst                    = incr_new_burst && wrap_new_burst;
                    assign enable_incr_converter        = (d0_in_valid && d0_in_full_size_incr && fixed_new_burst && wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_incr && !nb));
                    assign enable_fixed_converter       = (d0_in_valid && d0_in_default_converter && new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !nb));
                    assign enable_write_wrap_converter  = (d0_in_valid && d0_in_full_size_write_wrap && fixed_new_burst && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_write_wrap && !nb));
                    assign enable_read_wrap_converter   = (d0_in_valid && d0_in_full_size_read_wrap  && fixed_new_burst && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_read_wrap && !nb));

                    assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))) ? 1'b0 : d0_in_sop;
                    assign next_out_eop = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))  : d1_in_eop;
                    
                    wire [PKT_BYTE_CNT_W  - 1 : 0]  wrap_out_byte_cnt;
                    assign wrap_out_byte_cnt    = (d1_in_compressed_read ? wrap_out_len : wrap_uncompr_out_len) << log2_numsymbols;
                    
                    assign out_byte_cnt  = d1_in_default_converter ? fixed_out_byte_cnt : (d1_in_incr ? incr_out_byte_cnt : wrap_out_byte_cnt);
                    assign out_addr  = d1_in_default_converter ? fixed_out_addr : (d1_in_incr ? incr_out_addr : wrap_out_addr);
                end
            end
        end
    endgenerate

    reg   source0_valid_reg;
    wire  next_source0_valid;
    reg   source0_startofpacket_reg;

    wire  is_write;
    assign is_write  = nb ? (d0_in_write) : d1_in_write;

    assign next_source0_valid  = ((state == ST_COMP_TRANS) & !source0_endofpacket) ? 1'b1 : d0_in_valid;

    assign sink0_pipe_ready  = (state == ST_UNCOMP_TRANS) ? source0_ready || !source0_valid : (state == ST_COMP_TRANS) ? nb && source0_ready || !source0_valid : in_ready_hold;
    if (ENABLE_OOO) begin
       assign nxt_sop_eop_chunks = (state == ST_COMP_TRANS) ? {source0_startofpacket_reg ,next_out_eop} : d1_sop_eop_chunks;
    end
    
    generate
     if (SYNC_RESET == 0) begin : async_rst11
       always_ff @(posedge clk or posedge reset) begin
           if (reset)  begin
               source0_valid_reg         <= '0;
               source0_startofpacket_reg <= '1;
           end else begin
               if (~source0_valid | source0_ready) begin
                   source0_valid_reg         <= next_source0_valid;
                   source0_startofpacket_reg <= next_out_sop;
               end
           end 
       end 
      end 
      else begin 
       always_ff @(posedge clk ) begin
           if (internal_sclr)  begin
               source0_valid_reg         <= '0;
               source0_startofpacket_reg <= '1;
           end else begin
               if (~source0_valid | source0_ready) begin
                   source0_valid_reg         <= next_source0_valid;
                   source0_startofpacket_reg <= next_out_sop;
               end
           end 
       end 
      end 
    endgenerate

    always_comb begin
        source0_endofpacket    = next_out_eop;
        source0_startofpacket  = source0_startofpacket_reg;
        source0_valid          = source0_valid_reg;
    end

    generate
        if (NON_BURSTING_SLAVE) begin : non_bursting_slave_converters_sel
            altera_default_burst_converter
            #(
             .PKT_BURST_TYPE_W    (PKT_BURST_TYPE_W),
             .PKT_ADDR_W          (PKT_ADDR_W),
             .PKT_BURSTWRAP_W     (PKT_BURSTWRAP_W),
             .PKT_BURST_SIZE_W    (PKT_BURST_SIZE_W),
             .LEN_W               (IN_LEN_W),
             .IS_AXI_SLAVE        (AXI_SLAVE),
             .SYNC_RESET          (SYNC_RESET)
            )
            the_default_burst_converter
            (
             .clk                       (clk),
             .reset                     (reset),
             .enable                    (enable_fixed_converter), 
             .in_addr                   (d0_in_aligned_addr),
             .in_addr_reg               (d1_in_aligned_addr),
             .in_bursttype              (d0_in_bursttype),
             .in_burstwrap_reg          (d1_in_burstwrap),
             .in_burstwrap_value        (d0_in_burstwrap_value),
             .in_len                    (d0_in_len),
             .in_size_value             (d0_in_size_value),
             .in_is_write               (is_write),
             .out_len                   (fixed_out_len),
             .out_addr                  (fixed_out_addr),
             .new_burst                 (fixed_new_burst)
            );
        end
        else if (INCR_AVALON_SYS) begin : system_purely_avalon_converter_sel
            altera_incr_burst_converter
            #(
             .MAX_IN_LEN          (MAX_IN_LEN),
             .MAX_OUT_LEN         (MAX_OUT_LEN),
             .ADDR_WIDTH          (PKT_ADDR_W),
             .BNDRY_WIDTH         (PKT_BURSTWRAP_W),
             .BURSTSIZE_WIDTH     (PKT_BURST_SIZE_W),
             .IN_NARROW_SIZE      (IN_NARROW_SIZE),
             .NUM_SYMBOLS         (NUM_SYMBOLS),
             .PURELY_INCR_AVL_SYS (INCR_AVALON_SYS),
             .SYNC_RESET          (SYNC_RESET)
            )
            the_converter_for_avalon_incr_slave
            (
             .clk                     (clk),
             .reset                   (reset),
             .enable                  (enable_incr_converter),
             .in_len                  (d0_in_len),
             .in_sop                  (d0_in_sop),
             .in_burstwrap_reg        (d1_in_burstwrap),
             .in_size_t               (d0_in_size),
             .in_size_reg             (d1_in_size),
             .in_addr                 (d0_in_aligned_addr),
             .in_addr_reg             (d1_in_aligned_addr),
             .is_write                (is_write),
             .out_len                 (incr_out_len),
             .uncompr_out_len         (incr_uncompr_out_len),
             .out_addr                (incr_out_addr),
             .new_burst_export        (incr_new_burst)
            );
        end
        else begin : converters_selection
            if (IS_WRAP_AVALON_SLAVE) begin : wrapping_avalon_slave_converter_sel
                altera_wrap_burst_converter
                #(
                 .MAX_IN_LEN            (MAX_IN_LEN),
                 .MAX_OUT_LEN           (MAX_OUT_LEN),
                 .ADDR_WIDTH            (PKT_ADDR_W),
                 .BNDRY_WIDTH           (PKT_BURSTWRAP_W),
                 .AXI_SLAVE             (AXI_SLAVE),
                 .NUM_SYMBOLS           (NUM_SYMBOLS),
                 .OPTIMIZE_WRITE_BURST  (0),
                 .SYNC_RESET          (SYNC_RESET)
                )
                the_converter_for_avalon_wrap_slave
                (
                 .clk                               (clk),
                 .reset                             (reset),
                 .enable_read                       (enable_incr_read_converter),
                 .enable_write                      (enable_incr_write_converter),
                 .in_len                            (d0_in_len),
                 .first_len                         (d0_first_len),
                 .in_sop                            (d0_in_sop),
                 .in_burstwrap                      (d0_in_burstwrap),
                 .in_burstwrap_reg                  (d1_in_burstwrap),
                 .in_boundary                       (in_boundary),
                 .in_addr                           (d0_in_aligned_addr),
                 .in_addr_reg                       (d1_in_aligned_addr),
                 .out_len                           (incr_out_len),
                 .uncompr_out_len                   (incr_uncompr_out_len),
                 .out_addr                          (incr_out_addr),
                 .new_burst_export                  (new_burst)
                );

                altera_default_burst_converter
                #(
                 .PKT_BURST_TYPE_W    (PKT_BURST_TYPE_W),
                 .PKT_ADDR_W          (PKT_ADDR_W),
                 .PKT_BURSTWRAP_W     (PKT_BURSTWRAP_W),
                 .PKT_BURST_SIZE_W    (PKT_BURST_SIZE_W),
                 .LEN_W               (IN_LEN_W),
                 .IS_AXI_SLAVE        (AXI_SLAVE),
                 .SYNC_RESET          (SYNC_RESET)
                )
                the_default_burst_converter
                (
                 .clk                       (clk),
                 .reset                     (reset),
                 .enable                    (enable_fixed_converter), 
                 .in_addr                   (d0_in_aligned_addr),
                 .in_addr_reg               (d1_in_aligned_addr),
                 .in_bursttype              (d0_in_bursttype),
                 .in_burstwrap_reg          (d1_in_burstwrap),
                 .in_burstwrap_value        (d0_in_burstwrap_value),
                 .in_len                    (d0_in_len),
                 .in_size_value             (d0_in_size_value),
                 .in_is_write               (is_write),
                 .out_len                   (fixed_out_len),
                 .out_addr                  (fixed_out_addr),
                 .new_burst                 (fixed_new_burst)
                );
            end
            if (AXI_SLAVE) begin : axi_slave_converter_sel
                altera_wrap_burst_converter
                #(
                 .MAX_IN_LEN              (MAX_IN_LEN),
                 .MAX_OUT_LEN             (MAX_OUT_LEN),
                 .ADDR_WIDTH              (PKT_ADDR_W),
                 .BNDRY_WIDTH             (PKT_BURSTWRAP_W),
                 .NUM_SYMBOLS             (NUM_SYMBOLS),
                 .AXI_SLAVE               (AXI_SLAVE),
                 .OPTIMIZE_WRITE_BURST    (0),
                 .SYNC_RESET          (SYNC_RESET)
                )
                the_converter_for_avalon_wrap_slave
                (
                 .clk                               (clk),
                 .reset                             (reset),
                 .enable_read                       (enable_read_wrap_converter),
                 .enable_write                      (enable_write_wrap_converter),
                 .in_len                            (d0_in_len),
                 .first_len                         (d0_first_len),
                 .in_sop                            (d0_in_sop),
                 .in_burstwrap                      (d0_in_burstwrap),
                 .in_burstwrap_reg                  (d1_in_burstwrap),
                 .in_boundary                       (in_boundary),
                 .in_addr                           (d0_in_aligned_addr),
                 .in_addr_reg                       (d1_in_aligned_addr),
                 .out_len                           (wrap_out_len),
                 .uncompr_out_len                   (wrap_uncompr_out_len),
                 .out_addr                          (wrap_out_addr),
                 .new_burst_export                  (wrap_new_burst)
                );

                altera_incr_burst_converter
                #(
                 .MAX_IN_LEN          (MAX_IN_LEN),
                 .MAX_OUT_LEN         (MAX_OUT_LEN),
                 .ADDR_WIDTH          (PKT_ADDR_W),
                 .BNDRY_WIDTH         (PKT_BURSTWRAP_W),
                 .BURSTSIZE_WIDTH     (PKT_BURST_SIZE_W),
                 .IN_NARROW_SIZE      (IN_NARROW_SIZE),
                 .NUM_SYMBOLS         (NUM_SYMBOLS),
                 .PURELY_INCR_AVL_SYS (INCR_AVALON_SYS),
                 .SYNC_RESET          (SYNC_RESET)
                )
                the_converter_for_avalon_incr_slave
                (
                 .clk                (clk),
                 .reset              (reset),
                 .enable             (enable_incr_converter),
                 .in_len             (d0_in_len),
                 .in_sop             (d0_in_sop),
                 .in_burstwrap_reg   (d1_in_burstwrap),
                 .in_size_t          (d0_in_size),
                 .in_size_reg        (d1_in_size),
                 .in_addr            (d0_in_aligned_addr),
                 .in_addr_reg        (d1_in_aligned_addr),
                 .is_write           (is_write),
                 .out_len            (incr_out_len),
                 .uncompr_out_len    (incr_uncompr_out_len),
                 .out_addr           (incr_out_addr),
                 .new_burst_export   (incr_new_burst)
                );

                altera_default_burst_converter
                #(
                 .PKT_BURST_TYPE_W    (PKT_BURST_TYPE_W),
                 .PKT_ADDR_W          (PKT_ADDR_W),
                 .PKT_BURSTWRAP_W     (PKT_BURSTWRAP_W),
                 .PKT_BURST_SIZE_W    (PKT_BURST_SIZE_W),
                 .LEN_W               (IN_LEN_W),
                 .IS_AXI_SLAVE        (AXI_SLAVE),
                 .SYNC_RESET          (SYNC_RESET)
                )
                the_default_burst_converter
                (
                 .clk                       (clk),
                 .reset                     (reset),
                 .enable                    (enable_fixed_converter), 
                 .in_addr                   (d0_in_aligned_addr),
                 .in_addr_reg               (d1_in_aligned_addr),
                 .in_bursttype              (d0_in_bursttype),
                 .in_burstwrap_reg          (d1_in_burstwrap),
                 .in_burstwrap_value        (d0_in_burstwrap_value),
                 .in_len                    (d0_in_len),
                 .in_size_value             (d0_in_size_value),
                 .in_is_write               (is_write),
                 .out_len                   (fixed_out_len),
                 .out_addr                  (fixed_out_addr),
                 .new_burst                 (fixed_new_burst)
                );
            end
            if (IS_INCR_SLAVE) begin : incr_slave_converter_sel
                if (NO_WRAP_SUPPORT) begin : no_wrap_incr_slave_converter_sel
                    altera_incr_burst_converter
                    #(
                     .MAX_IN_LEN          (MAX_IN_LEN),
                     .MAX_OUT_LEN         (MAX_OUT_LEN),
                     .ADDR_WIDTH          (PKT_ADDR_W),
                     .BNDRY_WIDTH         (PKT_BURSTWRAP_W),
                     .BURSTSIZE_WIDTH     (PKT_BURST_SIZE_W),
                     .IN_NARROW_SIZE      (0), 
                     .NUM_SYMBOLS         (NUM_SYMBOLS),
                     .PURELY_INCR_AVL_SYS (INCR_AVALON_SYS),
                     .SYNC_RESET          (SYNC_RESET)
                    )
                    the_converter_for_avalon_incr_slave
                    (
                     .clk                (clk),
                     .reset              (reset),
                     .enable             (enable_incr_converter),
                     .in_len             (d0_in_len),
                     .in_sop             (d0_in_sop),
                     .in_burstwrap_reg   (d1_in_burstwrap),
                     .in_size_t          (d0_in_size),
                     .in_size_reg        (d1_in_size),
                     .in_addr            (d0_in_aligned_addr),
                     .in_addr_reg        (d1_in_aligned_addr),
                     .is_write           (is_write),
                     .out_len            (incr_out_len),
                     .uncompr_out_len    (incr_uncompr_out_len),
                     .out_addr           (incr_out_addr),
                     .new_burst_export   (incr_new_burst)
                    );
  
                    altera_default_burst_converter
                    #(
                     .PKT_BURST_TYPE_W    (PKT_BURST_TYPE_W),
                     .PKT_ADDR_W          (PKT_ADDR_W),
                     .PKT_BURSTWRAP_W     (PKT_BURSTWRAP_W),
                     .PKT_BURST_SIZE_W    (PKT_BURST_SIZE_W),
                     .LEN_W               (IN_LEN_W),
                     .IS_AXI_SLAVE        (AXI_SLAVE),
                     .SYNC_RESET          (SYNC_RESET)
                    )
                    the_default_burst_converter
                    (
                     .clk                       (clk),
                     .reset                     (reset),
                     .enable                    (enable_fixed_converter), 
                     .in_addr                   (d0_in_aligned_addr),
                     .in_addr_reg               (d1_in_aligned_addr),
                     .in_bursttype              (d0_in_bursttype),
                     .in_burstwrap_reg          (d1_in_burstwrap),
                     .in_burstwrap_value        (d0_in_burstwrap_value),
                     .in_len                    (d0_in_len),
                     .in_size_value             (d0_in_size_value),
                     .in_is_write               (is_write),
                     .out_len                   (fixed_out_len),
                     .out_addr                  (fixed_out_addr),
                     .new_burst                 (fixed_new_burst)
                    );
                end
                else begin : wrap_incr_slave_conveter_sel
                    altera_wrap_burst_converter
                    #(
                     .MAX_IN_LEN              (MAX_IN_LEN),
                     .MAX_OUT_LEN             (MAX_OUT_LEN),
                     .ADDR_WIDTH              (PKT_ADDR_W),
                     .BNDRY_WIDTH             (PKT_BURSTWRAP_W),
                     .NUM_SYMBOLS             (NUM_SYMBOLS),
                     .AXI_SLAVE               (AXI_SLAVE),
                     .OPTIMIZE_WRITE_BURST    (0),
                     .SYNC_RESET          (SYNC_RESET)
                    )
                    the_converter_for_avalon_wrap_slave
                    (
                     .clk                               (clk),
                     .reset                             (reset),
                     .enable_read                       (enable_read_wrap_converter),
                     .enable_write                      (enable_write_wrap_converter),
                     .in_len                            (d0_in_len),
                     .first_len                         (d0_first_len),
                     .in_sop                            (d0_in_sop),
                     .in_burstwrap                      (d0_in_burstwrap),
                     .in_burstwrap_reg                  (d1_in_burstwrap),
                     .in_boundary                       (in_boundary),
                     .in_addr                           (d0_in_aligned_addr),
                     .in_addr_reg                       (d1_in_aligned_addr),
                     .out_len                           (wrap_out_len),
                     .uncompr_out_len                   (wrap_uncompr_out_len),
                     .out_addr                          (wrap_out_addr),
                     .new_burst_export                  (wrap_new_burst)
                    );

                    altera_incr_burst_converter
                    #(
                     .MAX_IN_LEN          (MAX_IN_LEN),
                     .MAX_OUT_LEN         (MAX_OUT_LEN),
                     .ADDR_WIDTH          (PKT_ADDR_W),
                     .BNDRY_WIDTH         (PKT_BURSTWRAP_W),
                     .BURSTSIZE_WIDTH     (PKT_BURST_SIZE_W),
                     .IN_NARROW_SIZE      (IN_NARROW_SIZE),
                     .NUM_SYMBOLS         (NUM_SYMBOLS),
                     .PURELY_INCR_AVL_SYS (INCR_AVALON_SYS),
                     .SYNC_RESET          (SYNC_RESET)
                    )
                    the_converter_for_avalon_incr_slave
                    (
                     .clk                     (clk),
                     .reset                   (reset),
                     .enable                  (enable_incr_converter),
                     .in_len                  (d0_in_len),
                     .in_sop                  (d0_in_sop),
                     .in_burstwrap_reg        (d1_in_burstwrap),
                     .in_size_t               (d0_in_size),
                     .in_size_reg             (d1_in_size),
                     .in_addr                 (d0_in_aligned_addr),
                     .in_addr_reg             (d1_in_aligned_addr),
                     .is_write                (is_write),
                     .out_len                 (incr_out_len),
                     .uncompr_out_len         (incr_uncompr_out_len),
                     .out_addr                (incr_out_addr),
                     .new_burst_export        (incr_new_burst)
                    );
                    
                    altera_default_burst_converter
                    #(
                     .PKT_BURST_TYPE_W    (PKT_BURST_TYPE_W),
                     .PKT_ADDR_W          (PKT_ADDR_W),
                     .PKT_BURSTWRAP_W     (PKT_BURSTWRAP_W),
                     .PKT_BURST_SIZE_W    (PKT_BURST_SIZE_W),
                     .LEN_W               (IN_LEN_W),
                     .IS_AXI_SLAVE        (AXI_SLAVE),
                     .SYNC_RESET          (SYNC_RESET)
                    )
                    the_default_burst_converter
                    (
                     .clk                       (clk),
                     .reset                     (reset),
                     .enable                    (enable_fixed_converter), 
                     .in_addr                   (d0_in_aligned_addr),
                     .in_addr_reg               (d1_in_aligned_addr),
                     .in_bursttype              (d0_in_bursttype),
                     .in_burstwrap_reg          (d1_in_burstwrap),
                     .in_burstwrap_value        (d0_in_burstwrap_value),
                     .in_len                    (d0_in_len),
                     .in_size_value             (d0_in_size_value),
                     .in_is_write               (is_write),
                     .out_len                   (fixed_out_len),
                     .out_addr                  (fixed_out_addr),
                     .new_burst                 (fixed_new_burst)
                    );
                end
            end
        end
    endgenerate

    function unsigned[63:0] log2ceil;
        input reg [63:0] val;
        reg [63:0]       i;
        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

    wire load_next_output_pck  = source0_ready | !source0_valid;

    always_ff @(posedge clk ) begin
        if (load_next_output_pck) begin
            uncompr_out_addr <= d0_in_addr;
        end
    end

    wire [PKT_BURST_TYPE_W - 1 : 0] out_bursttype;
    generate
        if (AXI_SLAVE) begin : AXI_SLAVE_out_bursttype
            assign out_bursttype = (!d1_in_passthru || d1_in_bursttype == REP_WRAP) ? INCR : d1_in_bursttype;
        end
        else begin : others_slave_out_bursttype
           assign out_bursttype =  INCR;
        end
    endgenerate

    wire [PKT_ADDR_W - 1 : 0] out_addr_read;
    assign out_addr_read = source0_startofpacket_reg ? uncompr_out_addr : out_addr;

    wire [PKT_ADDR_W - 1 : 0] out_addr_assigned_to_packet;
    assign out_addr_assigned_to_packet = (d1_in_write || d1_in_uncompressed_read) ?  uncompr_out_addr : out_addr_read;

    reg  [PKT_BYTEEN_W - 1 : 0 ]     out_byteen;
    reg  [ADDR_MASK_SEL - 1 : 0 ]    out_addr_masked;
    wire [511:0] initial_byteen = set_byteenable_based_on_size(d1_in_size); 

    always_comb begin
        out_addr_masked = out_addr[ADDR_MASK_SEL-1:0];
    end

    always_comb begin
    if (BYTEENABLE_SYNTHESIS == 1 && d1_in_narrow == 1 && (state == ST_COMP_TRANS))
        out_byteen     = initial_byteen[NUM_SYMBOLS-1:0] << out_addr_masked;
    else
        out_byteen  = d1_in_byteen;
    end

    always_comb begin : source0_out_assignments
        source0_data                                       = d1_in_data;
        source0_channel                                    = d1_in_channel;
        if(ROLE_BASED_USER)
        source0_data[PKT_SAI_H        : PKT_SAI_L       ]  = d1_in_sai;        
        source0_data[PKT_BURST_TYPE_H : PKT_BURST_TYPE_L]  = out_bursttype;
        source0_data[PKT_BYTE_CNT_H   : PKT_BYTE_CNT_L  ]  = out_byte_cnt;
        source0_data[PKT_ADDR_H       : PKT_ADDR_L      ]  = out_addr_assigned_to_packet;
        source0_data[PKT_BYTEEN_H     : PKT_BYTEEN_L    ]  = out_byteen;
        if (ENABLE_OOO) begin
          source0_data[PKT_SOP_OOO      : PKT_EOP_OOO     ]  = nxt_sop_eop_chunks;
        end          
    end

    function [PKT_BURSTWRAP_W - 1 : 0] altera_merlin_burst_adapter_burstwrap_min;
        input [PKT_BURSTWRAP_W - 1 : 0] a, b;
        begin
            altera_merlin_burst_adapter_burstwrap_min  = a & b;
        end
    endfunction

    function reg[511:0] set_byteenable_based_on_size;
        input [3:0] axsize;
        begin
            case (axsize)
                4'b0000: set_byteenable_based_on_size = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
                4'b0001: set_byteenable_based_on_size = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003;
                4'b0010: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000F;
                4'b0011: set_byteenable_based_on_size = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FF;
                4'b0100: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFF;
                4'b0101: set_byteenable_based_on_size = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFF;
                4'b0110: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF;
                4'b0111: set_byteenable_based_on_size = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                4'b1000: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                4'b1001: set_byteenable_based_on_size = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                default: set_byteenable_based_on_size = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
            endcase
        end
    endfunction

generate
 if(ENABLE_OOO == 1) begin 
      if (PKT_BYTE_CNT_W != OUT_BYTE_CNT_W)begin  
          always @(posedge clk) begin
             if (sink0_ready && sink0_valid && sink0_startofpacket)begin          
                if(in_bytecount > OUT_MAX_BYTE_CNT)begin
                   sop_eop_chunks_reg   <= 2'b10;
                   sop_eop_chunk_enable <= 1;
                end
                else begin
                  sop_eop_chunks_reg <= 2'b11;  
                end  
             end         
             else if(sop_eop_chunk_enable)begin
                if( sink0_ready && sink0_valid && sink0_endofpacket )begin
                   sop_eop_chunks_reg   <=2'b01;
                   sop_eop_chunk_enable <=0;
                end               
                else if (source0_ready) begin
                   sop_eop_chunks_reg <= 2'b00;
                end
             end   
             else if (source0_ready) begin
                sop_eop_chunks_reg <= 2'b11;
             end
          end
      end    
      else begin 
        always @(posedge clk) begin
           if(sink0_ready && sink0_valid && sink0_startofpacket)begin
                   sop_eop_chunks_reg <= 2'b10;
           end else if (source0_ready) begin
                   sop_eop_chunks_reg <= in_sop_eop_chunks;         
           end
        end 
      end
  end
endgenerate 



endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FgGnqXUtd53yrImwIcH+YRjJHIg56SjJACEZa1A+hKJZGZ0OIcQauFzbO/kmxt+GHvN/adeqsxMbCsnmwSkZu8vc+dsU4vrdpdQNTdDuNfQu1T+UjFOvfVYVTL/vUk2pQzZdp5q4X8zlYvCRXbQgK2RjO0Z2aGkvFGLzum3qbRCRU71CCRffPwSBVM3UAUd+o2qb+j/WdPcDhFTOse6dnCrNC34SvVjwP2zbl5j84Cd17h9dBiWsJgiVvXswrvk9HqJ3k+2xM6hItKGMdWRsFnVjol7ORKa98EOEMtPkz+YtzVwtTV9tQ5LptEpPIX276GtIDOO8k4iLF+cjvzqpdrEYJ5yGLTiQRoyQeRREdObgFoXkSDQwHZZz6K0sAuL7l+IQN6tK2l2qocZslmqAfc3p9I0Rz0YPOV1AHViONx7EtTK2ikcNv4I6nkozOw46SdfpwiA8sjrtFl3bdhDhxCoq+fI/CgQCXYi9ZMbIl3iwmbVpN9I9MI4CoeUlO3y53s4nnAFWR/yP3Gz5Q9xdBFiMu96vvBuczEDhyGLckIVPyA1cB6J7tyzWCdTUWphgowaxCY92xBPuLY7fHE7J0Jg84BbuRLh8CDaMsA2+z6vworm4rZ/amAmc80U+xv+wbQsC/OzyRh1FO0yyl/rksZY1IOADbfet9WKuQRy8+oBuNb9+zXtJBDW3KuH9fAoKfRtoFcEBU7/FPURDMcNPD/l3tMuBHG3d2DqOCGP8RU51Zl5O5bWO5apj+tCRdkeoQCVsuH3fvSYxIUcZEWPbI1O"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "WgQPBVH1VBdyP1GnR2LUpBzapu3xqcPGd0xGo/Q4H4WpUeO+Hjltnkr805HvMqRkWDh3DyN3peSztswEbmtfL0y+XxwNgZXD8HzMTx127Mwzcyz+hm45kBealsJBAXnHmYFlorRoaB/cee+emunA/0c48mpmEF4OlQtcwz5XqcWvwenzsvQhJKdJ/IF87NHqDP/WjB3TeL4879eoAz/zIDUkxAOJQxnV3qexrxF9wbJDuxHf3RRO1uFZDianqBF3FiEe+DDxeWeRtsuSWPyKjsQ9WAWS9RXiQ11AS/dfK1EHYavbwLr0RY3kqIpySUDQGVjy8GNtd28bv78AHkyvBHIGHx3Py61MJYC17QrAfqzqDp8dd3TQmeaUlJp6mZEtKly4w5QSUOoFPuXAbVn/3ImQuChiWBKfwDmDzPmnqus4r2IbOrcUBRLv2k8fGfwgNLybmjDkKc+RUprGPnKiG7XCtMlv1SBp36L0INgp6st8OQ2TYbZQhxPP91QRQf+z3AfqkrPRWP4TOKNlxskIpCyDgBmjb9NMhHh2Ab/dny82vlkKm8Mnx41986/umHxBS1JJcnndsTQifimFKHv5DUKVIRD6ASLefTOdRYHrX5oCScDuzJFWEVQKQswHfkLg0I0XavK+UEbsfZas5cIa4tZn/TOI9kgE9RPTOxCm1lZ2gDImeiihYxVfajqaZF/mT0PJeg82Fom6iTvuje5SQV+0c3DNIwm30sqlXteVeBArjARORGPIB5xm6ucDMb9MEAZLuYDphdnHLh0ULcZK1WXfs4KMlEGUkc42TJJPnrDoZzoddvaPLcJ9xAdd/fPt0ThxXPFI/mbR8b4MYuLLmRLlJJA9hjuwJyhuXjwTViNIGcr+Qd/0VIFscKFvgREOjhLf0TKbQ/dSwRhl5jcBkVkY8MZPkXHV1n6pqq6qUhgcGWjBx4AKln+/2NMkFBA5fVEh3qunqw/1Rt5767ha1ERfNuOswhwllRwECT4E05vf3Mw92yBdTBNMvmgYyrCr"
`endif