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


// $Id: //acds/main/ip/merlin/altera_merlin_axi_master_ni/address_alignment.sv#3 $
// $Revision: #3 $
// $Date: 2012/07/11 $    

//-----------------------------------------
// Address alignment: 
// This component will aglin input address with input size
// Support address increment with butst type and burstwrap value
//-----------------------------------------
`timescale 1 ns / 1 ns

module  altera_merlin_address_alignment
#( 
   parameter 
            ADDR_W            = 12,
            BURSTWRAP_W       = 12,
            TYPE_W            = 2,
            SIZE_W            = 3,
            INCREMENT_ADDRESS = 1,
            NUMSYMBOLS        = 8,
            SELECT_BITS       = log2(NUMSYMBOLS),
            IN_DATA_W         = ADDR_W + (BURSTWRAP_W-1) + TYPE_W + SIZE_W,
            OUT_DATA_W        = ADDR_W + SELECT_BITS,
            SYNC_RESET        = 0 
)
(
    input                       clk,
    input                       reset,
 
    input [IN_DATA_W-1:0]       in_data, // in_data = {wrap_boundary, address, type, size}
    input                       in_valid,
    //output                      in_ready,
    input                       in_sop,
    input                       in_eop,

    output reg [OUT_DATA_W-1:0] out_data,
    input                       out_ready
    //output                      out_valid
        
);
typedef enum bit [1:0] 
{
    FIXED       = 2'b00,
    INCR        = 2'b01,
    WRAP        = 2'b10,
    RESERVED    = 2'b11
} AxiBurstType;
    //----------------------------------------------------
    // AXSIZE decoding
    //
    // Turns the axsize value into the actual number of bytes
    // being transferred.
    // ---------------------------------------------------

function reg[9:0] bytes_in_transfer;
    input [SIZE_W-1:0] axsize;
    case (axsize)
        4'b0000: bytes_in_transfer = 10'b0000000001;
        4'b0001: bytes_in_transfer = 10'b0000000010;
        4'b0010: bytes_in_transfer = 10'b0000000100;
        4'b0011: bytes_in_transfer = 10'b0000001000;
        4'b0100: bytes_in_transfer = 10'b0000010000;
        4'b0101: bytes_in_transfer = 10'b0000100000;
        4'b0110: bytes_in_transfer = 10'b0001000000;
        4'b0111: bytes_in_transfer = 10'b0010000000;
        4'b1000: bytes_in_transfer = 10'b0100000000;
        4'b1001: bytes_in_transfer = 10'b1000000000;
        default: bytes_in_transfer = 10'b0000000001;
    endcase
endfunction

    //--------------------------------------
    //  Burst type decode
    //--------------------------------------
AxiBurstType write_burst_type;

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

    //----------------------------------------------------
    // Ubiquitous, familiar log2 function
    //----------------------------------------------------
function integer log2;
    input integer value;

    value = value - 1;        
    for(log2 = 0; value > 0; log2 = log2 + 1)
        value = value >> 1;
    
endfunction
    //------------------------------------------------------------------------
    // This component will read address and size and check
    // if this is aligned or not. If not then it will align this address to the size
    // of the transfer:
    // Check alignment:
    //     - With data width, can define maximun how many lower bits of address to indicate this 
    //       address align to the size
    //     - Ex: 32 bits data => size can be: 1, 2, 4 bytes
    //           For 4 bytes: when 2 lower bits of address equal 0, this is aligned address
    //                        addr=00|00| (0), 01|00| (4) => align to size of 4 bytes
    //                        addr=00|01| (1)             => start addr at 1, is not aligned to size 4 byte
    //           For 2 bytes: use last one bit to indicate algined or not
    //                        addr=000|0| (0), 001|0| (2) => align to size of 2 bytes
    //                        addr=000|1| (1), 001|1| (3) => not align to 2 bytes
    // As size runtime change, creat mask and change accordingly to size, can detect address alignment
    // and to align to size, apply this mask with zero to the address.
    //-------------------------------------------------------------------------     

    // THe function return a vector which has width [(SELECT_BITS * 2) -1 : 0]
    // in which the first part contains the mask to check if this address aligned or not
    //              second part contains the mast to mask address to align to size
    
    function reg[(SELECT_BITS*2)-1 : 0] mask_select_and_align_address;
        input [ADDR_W-1:0] address;
        input [SIZE_W-1:0] size; // size is in AXI coding: 001 -> 2 bytes
        
        integer            i;
        reg [SELECT_BITS-1:0]  mask_address;
        reg [SELECT_BITS-1:0]  check_unaligned; // any bits =1 -> unalgined (except size = 0; 1 byte)
        mask_address   = '1;
        check_unaligned  = '0;
        for(i = 0; i < SELECT_BITS ; i = i + 1) begin
            if (i < size) begin
                check_unaligned[i]  = address[i];
                mask_address[i]       = 1'b0;
            end 
        end
        mask_select_and_align_address   = {check_unaligned,mask_address};
    endfunction

    // Generation of internal reset synchronization
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= ~reset;
      end
   end
   endgenerate 

    reg [ADDR_W-1 : 0]     in_address;
    reg [ADDR_W-1 : 0]     first_address_aligned;
    reg [SIZE_W-1 : 0]     in_size;
    reg [(SELECT_BITS*2)-1 : 0] output_masks;
    // Extract information from  input data
    assign in_address             = in_data[SIZE_W+ADDR_W-1 : SIZE_W];
    assign in_size                = in_data[SIZE_W-1 : 0];
    
    // Generate the masks
    always_comb
        begin
            output_masks  = mask_select_and_align_address(in_address, in_size);
        end
    
    // Align address if needed

    generate
        // SELECT_BITS == 1: input packet has 1 NUMSYMBOLS (1 bytes), it is aligned
        if (SELECT_BITS == 0)
            assign first_address_aligned = in_address;
        else begin
            // SELECT_BITS ==1 :input packet 2 bytes (2 SYMBOLS)
            wire [SELECT_BITS-1 : 0]    aligned_address_bits;
            if (SELECT_BITS == 1)
                assign aligned_address_bits   = in_address[0] & output_masks[0];
            else
                assign aligned_address_bits   = in_address[SELECT_BITS-1:0] & output_masks[SELECT_BITS-1:0];
            assign first_address_aligned  = {in_address[ADDR_W-1 : SELECT_BITS], aligned_address_bits};
        end
    endgenerate
    
    
    
    // Increment address base on size, first address keep the same
    generate
        if (INCREMENT_ADDRESS)
            begin
                reg [ADDR_W-1 : 0] increment_address;
                reg [ADDR_W-1 : 0] out_aligned_address_burst;
                reg [ADDR_W-1 : 0] address_burst;
                reg [ADDR_W-1 : 0] base_address;
                reg [9 : 0]        number_bytes_transfer;
                reg [ADDR_W-1 : 0] burstwrap_mask;
                reg [ADDR_W-1 : 0] burst_address_high;
                reg [ADDR_W-1 : 0] burst_address_low;
                reg [BURSTWRAP_W-2 :0] in_burstwrap_boundary;
                reg [TYPE_W-1 : 0]     in_type;
                //------------------------------------------------
                // Use the extended burstwrap value to split the high (constant) and
                // low (changing) part of the address
                //-----------------------------------------------
                assign in_type                = in_data[SIZE_W+ADDR_W+TYPE_W-1 : SIZE_W+ADDR_W];
                assign in_burstwrap_boundary  = in_data[IN_DATA_W-1 : ADDR_W+TYPE_W+SIZE_W];
                assign burstwrap_mask         = {{(ADDR_W - BURSTWRAP_W){1'b0}}, in_burstwrap_boundary};
                assign burst_address_high     = out_aligned_address_burst & ~burstwrap_mask;
                assign burst_address_low      = out_aligned_address_burst;
                assign number_bytes_transfer  = bytes_in_transfer(in_size);
                assign write_burst_type       = burst_type_decode(in_type);

                always @*
                    begin
                        if (in_sop)
                            begin
                                out_aligned_address_burst  = in_address;
                                base_address               = first_address_aligned;
                            end
                        else
                            begin
                                out_aligned_address_burst  = address_burst;
                                base_address               = out_aligned_address_burst;
                            end
                        case (write_burst_type)
                            INCR:
                                increment_address  = base_address + number_bytes_transfer;
                            WRAP:
                                increment_address  = ((burst_address_low + number_bytes_transfer) & burstwrap_mask) | burst_address_high;
                            FIXED:
                                increment_address  = out_aligned_address_burst;
                            default:
                                increment_address  = base_address + number_bytes_transfer;
                        endcase // case (write_burst_type)
                    end // always @ *
            
               if (SYNC_RESET == 0) begin : async_rst0 
                   always_ff @(posedge clk, negedge reset)
                       begin
                           if (!reset)
                               begin
                                   address_burst <= '0;
                               end
                           else
                               begin
                                   if (in_valid & out_ready)
                                       address_burst <= increment_address;
                               end
                       end
                end : async_rst0
 
                else begin : sync_rst0
                   always_ff @(posedge clk)
                       begin
                           if (internal_sclr)
                               begin
                                   address_burst <= '0;
                               end
                           else
                               begin
                                   if (in_valid & out_ready)
                                       address_burst <= increment_address;
                               end
                       end
                 end : sync_rst0  
            
                // send data to output with 2 part: [mask_t0_algin][address_aligned_increment]
                assign   out_data  = {output_masks[SELECT_BITS-1 : 0], out_aligned_address_burst};
            end // if (INCREMENT_ADDRESS)
        else
            begin
                assign   out_data  = {output_masks[SELECT_BITS-1 : 0], first_address_aligned};
            end // else: !if(INCREMENT_ADDRESS)
        
    endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "YhH6PGYVoenEE7S8VcGktyZSI1C0as9hhWpkDVFoMerVMrGF+LJXcnB1kt86uLR5FfOvO1UGAwrdYfIrl3U9twFOsehaO27J5A8ppUZa28mirkCERAx8MhnZ5wnIFJtIMEhw2eDgfO/5gJy9YxGg1c3y/l8e2kzKYyfsj42ubldS1xZw+AUIBsJG8C6tHpW011NFcLT+taBVEoomxWb2F5mvBhtjCl+Qc9z3LJuz1ZrEuUcfdf4c/iIMkt7fgfE9EbKeRj8zwLtI629gKFstX4VBT4hat9NZzpd5t/TmLIQ1v258e62eYLbv9U1m1pFgKPpCcC5tZT0vLGpuB8jSnF2SX/TEDcoBgyEqiQWonGCT/kvXE1Q0LaoCUhQix5P8+8kk8+BobF9vE/mkkzbbSbCntEjdjwlMZKKT1b5gW2xreulZgE44WvkqktpZaNvq+y3UDYiCPd+KwpSt6CwGEWw+SD2sUKRPSNLYx3PTFyYC1AG4XA6gABODoOTLIOnWM/GoRd0BoEMwtPnWH2SrBYenKWBZuguCoWYzjvSJchhEqHlLQLpBPlRwsS63EGHo8RoXAMDtHMMwFWUHcg7Vst27KHUI/iv3UW33euVcemx3fZE9AH079co+JwmuJqMkAXbbfaSYogWK6FB/wvjY7+foKChXFQQdTJvFWGm35O2zkID4pxm8oy89JZR+wWFAIEi0PEWL+YCAmg9eICQKxnm/pw/OtuFSsc1ofaAzL+IFcQJ6i227qCcREF7TW7zUKfODgxdjn/hol4zK4VTHWZwNLZ7TsdaK+Vn6aPyQnJmPfNl6wmgtPV36q753oZKH1fSwYCMb2bGiGmlF4VX2+ZvdHmphCQzRiaR+o/3oRx9L6wBeFSZyBB2uZQfKnfA7wb4E8kzhWaGgJzQ6vzmIU43yGQwDkRFiILzGNaaf1x+rxQvvAA+QEwR3Tl1HBjCkd9ZKtgja86DCIQQbbOfaNVqK35tqzXM3t1y8Y79aLJKT9ZH9uVxYHba/4lHjuI1l"
`endif