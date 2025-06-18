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





module intel_axi4lite_injector_util_add_a_b_s0_s1 #(
    parameter SIZE = 5
)(
    input [SIZE-1:0] a,
    input [SIZE-1:0] b,
    input s0,
    input s1,
    output [SIZE-1:0] out
);
wire [SIZE:0] left;
wire [SIZE:0] right;
wire temp;
    
assign left = {a ^ b, s0};
assign right = {a[SIZE-2:0] & b[SIZE-2:0], s1, s0};
assign {out, temp} = left + right;  

endmodule


module intel_axi4lite_injector_util_binary_to_gray #(
    parameter WIDTH = 5
) (
    input clock,
    input aclr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

always @(posedge clock or posedge aclr) begin
    if (aclr)
        dout <= 0;
    else
        dout <= din ^ (din >> 1);
end

endmodule


module intel_axi4lite_injector_util_gray_to_binary #(
    parameter WIDTH = 5
) (
    input clock,
    input aclr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

wire [WIDTH-1:0] dout_w;

genvar i;
generate
    for (i = 0; i < WIDTH; i=i+1) begin : loop
        assign dout_w[i] = ^(din[WIDTH-1:i]);
    end
endgenerate

always @(posedge clock or posedge aclr) begin
    if (aclr)
        dout <= 0;
    else
        dout <= dout_w;
end

endmodule


(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module intel_axi4lite_injector_util_generic_mlab_sc #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5,
    parameter FAMILY = "Other" 
)(
    input clk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout
);

genvar i;
generate
if (FAMILY == "S10") begin    
    reg [WIDTH-1:0] wdata_hipi;
    always @(posedge clk) wdata_hipi <= din;
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = clk; 
        wire rclk_w = clk; 
        fourteennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            /* synthesis translate_off */
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            /* synthesis translate_on */           

            .portabyteenamasks(1'b1),
            .portadatain(wdata_hipi[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
end else if (FAMILY == "Agilex") begin    
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = clk; 
        wire rclk_w = clk; 
        tennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            /* synthesis translate_off */
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            /* synthesis translate_on */       

            .portabyteenamasks(1'b1),
            .portadatain(din[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
    
end else begin

    localparam DEPTH = 1 << ADDR_WIDTH;
    (* ramstyle = "mlab" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    reg [WIDTH-1:0] dout_r;
    always @(posedge clk) begin
        if (we)
            mem[waddr] <= din;
        if (re)
            dout_r <= mem[raddr];
    end
    assign dout = dout_r;

end
endgenerate    

endmodule


(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module intel_axi4lite_injector_util_generic_mlab_dc #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5,
    parameter FAMILY = "Other" 
)(
    input rclk,
    input wclk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout
);

genvar i;
generate
if (FAMILY == "S10") begin    
    reg [WIDTH-1:0] wdata_hipi;
    always @(posedge wclk) wdata_hipi <= din;
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = wclk; 
        wire rclk_w = rclk; 
        fourteennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            /* synthesis translate_off */
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            /* synthesis translate_on */       

            .portabyteenamasks(1'b1),
            .portadatain(wdata_hipi[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
end else if (FAMILY == "Agilex") begin    
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = wclk; 
        wire rclk_w = rclk; 
        tennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            /* synthesis translate_off */
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            /* synthesis translate_on */       

            .portabyteenamasks(1'b1),
            .portadatain(din[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
    
end else begin

    localparam DEPTH = 1 << ADDR_WIDTH;
    (* ramstyle = "mlab" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    reg [WIDTH-1:0] dout_r;
    always @(posedge wclk) begin
        if (we)
            mem[waddr] <= din;
    end
    always @(posedge rclk) begin
        if (re)
            dout_r <= mem[raddr];
    end
    assign dout = dout_r;

end
endgenerate    

endmodule


module intel_axi4lite_injector_util_synchronizer_ff_r2 #(
    parameter WIDTH = 8
)(
    input din_clk,
    input din_aclr,
    input [WIDTH-1:0] din,
    input dout_clk,
    input dout_aclr,
    output [WIDTH-1:0] dout
);

localparam MULTI = "-name SDC_STATEMENT \"set_multicycle_path -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]] 2\" ";
localparam FPATH = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]]\" ";
localparam FHOLD = "-name SDC_STATEMENT \"set_false_path -hold -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]]\" ";

reg [WIDTH-1:0] ff_launch = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge din_clk or posedge din_aclr) begin
    if (din_aclr)
        ff_launch <= 0;
    else
        ff_launch <= din;
end

localparam SDC = {MULTI,";",FHOLD};
(* altera_attribute = SDC *)
reg [WIDTH-1:0] ff_meta = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge dout_clk or posedge dout_aclr) begin
    if (dout_aclr)    
        ff_meta <= 0;
    else
        ff_meta <= ff_launch;
end

reg [WIDTH-1:0] ff_sync = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge dout_clk or posedge dout_aclr) begin
    if (dout_aclr)
        ff_sync <= 0;
    else
        ff_sync <= ff_meta;
end

assign dout = ff_sync;
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOz5tntaCm5R1N5kzxuVz5FIRRCTki6Tvsbr+ZhV9iDQAm3U/9Yh85kHjudmCTpRqWG8qDKNOjXcZIuI926eFfTyetTSPk3lA7x0PFIhLHsCYjAFDBc8i7QQ3eIqIhrSZ9a6LUhnEtFplM0pGc3vyIx1HGhVKXAFSH9VFjyA38qHE0X8iil1/7U0ciOeGbaTzYGNOCjGASJEP12YaLiiPqfayKTCDfgT3pyISiww38I+HwBNellz8B4f8LcJXBGHJ7xwYchAp8rG3cI5EOo5v9d6qNwHPMupOtIF+fUF56uX7lTLwJ31qBT2xvsoxXbsqKgXNdp+sfHHAG2xpyCrvoiUTCTPrp9PMkKqpFO3QgbUW4rDK9Y790V2DzDzZi/g0nVr52/LPI1U2lNwSxM43/D3Tg5/8RL0Xh9bbwNyl3NgwnZyR+t9wCmIoHAy6tqEuVj1TUt0RT6e+VUxak5BSBVxnOtb50rp7dDBD3qW1dAPA7ucgOxrhvlKgClqCTmdJJQcYrHEJWgwzM2LjIdnwbUcdjvtXRc8oL+s9aTqaYuLf20wLS+l6+Yh8qpKFhlIExBaM5uB00UoICkuFhat2kS0/ErxBd3IP6QWtxxNj7uY9/X+cJ2ZMKyVFXV73R1Z9ljrfFBeSiop73JUlH/kfC+y7DAIIEuHyt/B7FUs9/49ag2MqPE9FrpVG6f4Q87cFaObW3mDgG7L9Lef5gov2QZnGY7vs2+Z2hWvezAnuLvlkBDycpaqjgbiv+odv/ld6Sd0B7uiPYcDzY0RWLmuImgx"
`endif