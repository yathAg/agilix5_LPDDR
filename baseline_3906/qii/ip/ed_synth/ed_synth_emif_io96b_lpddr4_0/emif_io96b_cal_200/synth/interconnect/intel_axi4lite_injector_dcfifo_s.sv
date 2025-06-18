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




module intel_axi4lite_injector_dcfifo_s
#(
    parameter LOG_DEPTH          = 5,
    parameter WIDTH              = 20,
    parameter ALMOST_FULL_VALUE  = 30,
    parameter ALMOST_EMPTY_VALUE = 2,    
    parameter FAMILY             = "S10", 
    parameter SHOW_AHEAD         = 0,     
    parameter OVERFLOW_CHECKING  = 0,     
    parameter UNDERFLOW_CHECKING = 0      
)
(
    input wrclk,
    input wraresetn,
    input wrreq,
    input [WIDTH-1:0] data,
    output wrempty,
    output wrfull,
    output wr_almost_empty,
    output wr_almost_full,
    output [LOG_DEPTH-1:0] wrusedw,
    
    input rdclk,
    input rdaresetn,
    input rdreq,
    output [WIDTH-1:0] q,
    output rdempty,
    output rdfull,
    output rd_almost_empty,    
    output rd_almost_full,    
    output [LOG_DEPTH-1:0] rdusedw
);
initial begin
    if ((LOG_DEPTH >= 6) || (LOG_DEPTH <= 2))
        $error("Invalid parameter value: LOG_DEPTH = %0d; valid range is 2 < LOG_DEPTH < 6", LOG_DEPTH);

    if (WIDTH <= 0)
        $error("Invalid parameter value: WIDTH = %0d; it must be greater than 0", WIDTH);
        
    if ((ALMOST_FULL_VALUE >= 2 ** LOG_DEPTH) || (ALMOST_FULL_VALUE <= 0))
        $error("Incorrect parameter value: ALMOST_FULL_VALUE = %0d; valid range is 0 < ALMOST_FULL_VALUE < %0d", 
            ALMOST_FULL_VALUE, 2 ** LOG_DEPTH);     

    if ((ALMOST_EMPTY_VALUE >= 2 ** LOG_DEPTH) || (ALMOST_EMPTY_VALUE <= 0))
        $error("Incorrect parameter value: ALMOST_EMPTY_VALUE = %0d; valid range is 0 < ALMOST_EMPTY_VALUE < %0d", 
            ALMOST_EMPTY_VALUE, 2 ** LOG_DEPTH);  

    if ((FAMILY != "Agilex") && (FAMILY != "S10") && (FAMILY != "Other"))
        $error("Incorrect parameter value: FAMILY = %s; must be one of {Agilex, S10, Other}", FAMILY);  
end

generate
if (SHOW_AHEAD == 1)
    intel_axi4lite_injector_dcfifo_s_showahead #(
        .LOG_DEPTH(LOG_DEPTH),
        .WIDTH(WIDTH),
        .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
        .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
        .FAMILY(FAMILY),
        .OVERFLOW_CHECKING(OVERFLOW_CHECKING),
        .UNDERFLOW_CHECKING(UNDERFLOW_CHECKING)
    ) a1 (
        .wrclk(wrclk),
        .wraresetn(wraresetn),
        .wrreq(wrreq),
        .data(data),
        .wrempty(wrempty),
        .wrfull(wrfull),
        .wr_almost_empty(wr_almost_empty),
        .wr_almost_full(wr_almost_full),
        .wrusedw(wrusedw),
        .rdclk(rdclk),
        .rdaresetn(rdaresetn),
        .rdreq(rdreq),
        .q(q),
        .rdempty(rdempty),
        .rdfull(rdfull),
        .rd_almost_empty(rd_almost_empty),
        .rd_almost_full(rd_almost_full),
        .rdusedw(rdusedw)
    );
else
    intel_axi4lite_injector_dcfifo_s_normal #(
        .LOG_DEPTH(LOG_DEPTH),
        .WIDTH(WIDTH),
        .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
        .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
        .FAMILY(FAMILY),
        .OVERFLOW_CHECKING(OVERFLOW_CHECKING),
        .UNDERFLOW_CHECKING(UNDERFLOW_CHECKING)        
    ) a2 (
        .wrclk(wrclk),
        .wraresetn(wraresetn),
        .wrreq(wrreq),
        .data(data),
        .wrempty(wrempty),
        .wrfull(wrfull),
        .wr_almost_empty(wr_almost_empty),
        .wr_almost_full(wr_almost_full),
        .wrusedw(wrusedw),
        .rdclk(rdclk),
        .rdaresetn(rdaresetn),
        .rdreq(rdreq),
        .q(q),
        .rdempty(rdempty),
        .rdfull(rdfull),
        .rd_almost_empty(rd_almost_empty),
        .rd_almost_full(rd_almost_full),
        .rdusedw(rdusedw)
    );
endgenerate
endmodule


module intel_axi4lite_injector_dcfifo_s_normal
#(
    parameter LOG_DEPTH          = 5,
    parameter WIDTH              = 20,
    parameter ALMOST_FULL_VALUE  = 30,
    parameter ALMOST_EMPTY_VALUE = 2,    
    parameter FAMILY             = "S10", 
    parameter NUM_WORDS          = 2**LOG_DEPTH - 1,
    parameter MLAB_ALWAYS_READ   = 1,
    parameter OVERFLOW_CHECKING  = 0,     
    parameter UNDERFLOW_CHECKING = 0      
)
(
    input wrclk,
    input wraresetn,
    input wrreq,
    input [WIDTH-1:0] data,
    output reg wrempty,
    output reg wrfull,
    output reg wr_almost_empty,
    (* altera_attribute = "-name DUPLICATE_REGISTER 4" *) output reg wr_almost_full,
    output [LOG_DEPTH-1:0] wrusedw,
    
    input rdclk,
    input rdaresetn,
    input rdreq,
    output [WIDTH-1:0] q,
    output reg rdempty,
    output reg rdfull,
    output reg rd_almost_empty,    
    output reg rd_almost_full,    
    output [LOG_DEPTH-1:0] rdusedw
);
       
initial begin
    if ((LOG_DEPTH > 5) || (LOG_DEPTH < 3))
        $error("Invalid parameter value: LOG_DEPTH = %0d; valid range is 2 < LOG_DEPTH < 6", LOG_DEPTH);
        
    if ((ALMOST_FULL_VALUE > 2 ** LOG_DEPTH - 1) || (ALMOST_FULL_VALUE < 1))
        $error("Incorrect parameter value: ALMOST_FULL_VALUE = %0d; valid range is 0 < ALMOST_FULL_VALUE < %0d", 
            ALMOST_FULL_VALUE, 2 ** LOG_DEPTH);     

    if ((ALMOST_EMPTY_VALUE > 2 ** LOG_DEPTH - 1) || (ALMOST_EMPTY_VALUE < 1))
        $error("Incorrect parameter value: ALMOST_EMPTY_VALUE = %0d; valid range is 0 < ALMOST_EMPTY_VALUE < %0d", 
            ALMOST_EMPTY_VALUE, 2 ** LOG_DEPTH);  

    if ((NUM_WORDS > 2 ** LOG_DEPTH - 1) || (NUM_WORDS < 1))
        $error("Incorrect parameter value: NUM_WORDS = %0d; valid range is 0 < NUM_WORDS < %0d", 
            NUM_WORDS, 2 ** LOG_DEPTH);  
end

(* altera_attribute = "-name AUTO_CLOCK_ENABLE_RECOGNITION OFF" *) reg [LOG_DEPTH-1:0] write_addr = 0;
(* altera_attribute = "-name AUTO_CLOCK_ENABLE_RECOGNITION OFF" *) reg [LOG_DEPTH-1:0] read_addr = 0;
reg [LOG_DEPTH-1:0] wrcapacity = 0;
reg [LOG_DEPTH-1:0] rdcapacity = 0;

wire [LOG_DEPTH-1:0] wrcapacity_w;
wire [LOG_DEPTH-1:0] rdcapacity_w;

wire [LOG_DEPTH-1:0] rd_write_addr;
wire [LOG_DEPTH-1:0] wr_read_addr;

wire wrreq_safe;
wire rdreq_safe;
assign wrreq_safe = OVERFLOW_CHECKING ? wrreq & ~wrfull : wrreq;
assign rdreq_safe = UNDERFLOW_CHECKING ? rdreq & ~rdempty : rdreq;

initial begin 
    write_addr = 0;
    read_addr = 0;
    wrempty = 1;
    wrfull = 0;
    rdempty = 1;
    rdfull = 0;
    wrcapacity = 0;
    rdcapacity = 0;    
    rd_almost_empty = 1;
    rd_almost_full = 0;
    wr_almost_empty = 1;
    wr_almost_full = 0;
end



intel_axi4lite_injector_util_add_a_b_s0_s1 #(LOG_DEPTH) wr_adder(
    .a(write_addr),
    .b(~wr_read_addr),
    .s0(wrreq_safe),
    .s1(1'b1),
    .out(wrcapacity_w)
);

always @(posedge wrclk or negedge wraresetn) begin

    if (~wraresetn) begin
        write_addr <= 0;
        wrcapacity <= 0;
        wrempty <= 1;
        wrfull <= 0;
        wr_almost_full <= 0;
        wr_almost_empty <= 1;
    end else begin
        write_addr <= write_addr + wrreq_safe;
        wrcapacity <= wrcapacity_w;
        wrempty <= (wrcapacity == 0) && (wrreq == 0);
        wrfull <= (wrcapacity == NUM_WORDS) || (wrcapacity == NUM_WORDS - 1) && (wrreq == 1);
        
        wr_almost_empty <=
            (wrcapacity < (ALMOST_EMPTY_VALUE-1)) || 
            (wrcapacity == (ALMOST_EMPTY_VALUE-1)) && (wrreq == 0);
        
        wr_almost_full <= 
            (wrcapacity >= ALMOST_FULL_VALUE) ||
            (wrcapacity == ALMOST_FULL_VALUE - 1) && (wrreq == 1);    
    end
end

assign wrusedw = wrcapacity;


intel_axi4lite_injector_util_add_a_b_s0_s1 #(LOG_DEPTH) rd_adder(
    .a(rd_write_addr),
    .b(~read_addr),
    .s0(1'b0),
    .s1(~rdreq_safe),
    .out(rdcapacity_w)
);

always @(posedge rdclk or negedge rdaresetn) begin
    if (~rdaresetn) begin
        read_addr <= 0;
        rdcapacity <= 0;
        rdempty <= 1;
        rdfull <= 0;    
        rd_almost_empty <= 1;
        rd_almost_full <= 0;
    end else begin
        read_addr <= read_addr + rdreq_safe;
        rdcapacity <= rdcapacity_w;
        rdempty <= (rdcapacity == 0) || (rdcapacity == 1) && (rdreq == 1);
        rdfull <= (rdcapacity == NUM_WORDS) && (rdreq == 0);    
        rd_almost_empty <= 
            (rdcapacity < ALMOST_EMPTY_VALUE) || 
            (rdcapacity == ALMOST_EMPTY_VALUE) && (rdreq == 1);
            
        rd_almost_full <= 
            (rdcapacity > ALMOST_FULL_VALUE) ||
            (rdcapacity == ALMOST_FULL_VALUE) && (rdreq == 0);                
    end
end

assign rdusedw = rdcapacity;


wire [LOG_DEPTH-1:0] gray_read_addr;
wire [LOG_DEPTH-1:0] wr_gray_read_addr;
wire [LOG_DEPTH-1:0] gray_write_addr;
wire [LOG_DEPTH-1:0] rd_gray_write_addr;

intel_axi4lite_injector_util_binary_to_gray #(.WIDTH(LOG_DEPTH)) rd_b2g (.clock(rdclk), .aclr(~rdaresetn), .din(read_addr), .dout(gray_read_addr));
intel_axi4lite_injector_util_synchronizer_ff_r2 #(.WIDTH(LOG_DEPTH)) rd2wr (.din_clk(rdclk),  .din_aclr(~rdaresetn),  .din(gray_read_addr), 
                                                                            .dout_clk(wrclk), .dout_aclr(~wraresetn), .dout(wr_gray_read_addr));
intel_axi4lite_injector_util_gray_to_binary #(.WIDTH(LOG_DEPTH)) rd_g2b (.clock(wrclk), .aclr(~wraresetn), .din(wr_gray_read_addr), .dout(wr_read_addr));


intel_axi4lite_injector_util_binary_to_gray #(.WIDTH(LOG_DEPTH)) wr_b2g (.clock(wrclk), .aclr(~wraresetn), .din(write_addr), .dout(gray_write_addr));
intel_axi4lite_injector_util_synchronizer_ff_r2 #(.WIDTH(LOG_DEPTH)) wr2rd (.din_clk(wrclk),  .din_aclr(~wraresetn),  .din(gray_write_addr), 
                                                                            .dout_clk(rdclk), .dout_aclr(~rdaresetn), .dout(rd_gray_write_addr));
intel_axi4lite_injector_util_gray_to_binary #(.WIDTH(LOG_DEPTH)) wr_g2b (.clock(rdclk), .aclr(~rdaresetn), .din(rd_gray_write_addr), .dout(rd_write_addr));


intel_axi4lite_injector_util_generic_mlab_dc #(.WIDTH(WIDTH), .ADDR_WIDTH(LOG_DEPTH), .FAMILY(FAMILY)) mlab_inst (
    .rclk(rdclk),
    .wclk(wrclk),
    .din(data),
    .waddr(write_addr),
    .we(1'b1),
    .re(MLAB_ALWAYS_READ ? 1'b1 : rdreq_safe),
    .raddr(read_addr),
    .dout(q)
);

endmodule



module intel_axi4lite_injector_dcfifo_s_showahead
#(
    parameter LOG_DEPTH          = 5,
    parameter WIDTH              = 20,
    parameter ALMOST_FULL_VALUE  = 30,
    parameter ALMOST_EMPTY_VALUE = 2,    
    parameter FAMILY             = "S10", 
    parameter OVERFLOW_CHECKING  = 0,     
    parameter UNDERFLOW_CHECKING = 0      
)
(
    input wrclk,
    input wraresetn,
    input wrreq,
    input [WIDTH-1:0] data,
    output wrempty,
    output wrfull,
    output wr_almost_empty,
    output wr_almost_full,
    output [LOG_DEPTH-1:0] wrusedw,
    
    input rdclk,
    input rdaresetn,
    input rdreq,
    output reg [WIDTH-1:0] q,
    output reg rdempty,
    output rdfull,
    output reg rd_almost_empty,    
    output reg rd_almost_full,    
    output reg [LOG_DEPTH-1:0] rdusedw
);

initial begin
    if ((LOG_DEPTH > 5) || (LOG_DEPTH < 3))
        $error("Invalid parameter value: LOG_DEPTH = %0d; valid range is 2 < LOG_DEPTH < 6", LOG_DEPTH);
        
    if ((ALMOST_FULL_VALUE > 2 ** LOG_DEPTH - 1) || (ALMOST_FULL_VALUE < 1))
        $error("Incorrect parameter value: ALMOST_FULL_VALUE = %0d; valid range is 0 < ALMOST_FULL_VALUE < %0d", 
            ALMOST_FULL_VALUE, 2 ** LOG_DEPTH);     

    if ((ALMOST_EMPTY_VALUE > 2 ** LOG_DEPTH - 1) || (ALMOST_EMPTY_VALUE < 1))
        $error("Incorrect parameter value: ALMOST_EMPTY_VALUE = %0d; valid range is 0 < ALMOST_EMPTY_VALUE < %0d", 
            ALMOST_EMPTY_VALUE, 2 ** LOG_DEPTH);     
end

wire rdreq_safe;
assign rdreq_safe = UNDERFLOW_CHECKING ? rdreq & ~rdempty : rdreq;

wire [WIDTH-1:0] w_q;

wire w_empty;
wire w_full;
wire w_almost_empty;
wire w_almost_full;    

wire [LOG_DEPTH-1:0] w_usedw;

reg read_fifo;
reg read_fifo_r; 

reg [WIDTH-1:0] r_q2;
reg r_q2_ready;

intel_axi4lite_injector_dcfifo_s_normal #(
    .LOG_DEPTH(LOG_DEPTH), 
    .WIDTH(WIDTH), 
    .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE), 
    .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
    .NUM_WORDS(2**LOG_DEPTH - 4),
    .MLAB_ALWAYS_READ(0),
    .FAMILY(FAMILY),
    .OVERFLOW_CHECKING(OVERFLOW_CHECKING)
) fifo_inst(
    .wrclk(wrclk),
    .wraresetn(wraresetn),
    .wrreq(wrreq),
    .data(data),
    .wrempty(wrempty),
    .wrfull(wrfull),
    .wr_almost_empty(wr_almost_empty),
    .wr_almost_full(wr_almost_full),
    .wrusedw(wrusedw),
    
    .rdclk(rdclk),
    .rdaresetn(rdaresetn),
    .rdreq(read_fifo),
    .q(w_q),
    .rdempty(w_empty),
    .rdfull(rdfull),
    .rdusedw(w_usedw)    
);

wire next_empty;

assign next_empty = (w_usedw == 0) || (w_usedw == 1) && (read_fifo == 1);

reg tmp;

always @(posedge rdclk or negedge rdaresetn) begin

    if (~rdaresetn) begin
        rdempty <= 1;
        read_fifo <= 0;
        read_fifo_r <= 0;        
        r_q2_ready <= 0;
        rdusedw <= 0;
        rd_almost_full <= 0;
        rd_almost_empty <= 1;
    end else begin

        if (rdreq_safe || rdempty) begin
            if (r_q2_ready)
                q <= r_q2;
            else
                q <= w_q;
        end
        
        if (rdreq_safe || rdempty) begin
            rdempty <= !(r_q2_ready || read_fifo_r); 
        end
        
        if (r_q2_ready) begin
            if (rdreq_safe || rdempty)
                r_q2 <= w_q;
        end else begin
            r_q2 <= w_q;
        end

        if (r_q2_ready) begin
            if (rdreq_safe || rdempty)
                r_q2_ready <= read_fifo_r;
        end else begin
            if (rdreq_safe || rdempty)
                r_q2_ready <= 0;
            else
                r_q2_ready <= read_fifo_r;
        end
                    
        read_fifo_r <= read_fifo || read_fifo_r && !(rdreq_safe || rdempty || !r_q2_ready);
        
        read_fifo <= !next_empty && (
            rdreq_safe && (!rdempty + r_q2_ready + read_fifo + read_fifo_r < 4) || 
           !rdreq_safe && (!rdempty + r_q2_ready + read_fifo + read_fifo_r < 3)
        ); 
        
        {rdusedw, tmp} <= {w_usedw, !rdempty & !rdreq_safe} + {
            read_fifo_r & r_q2_ready, 
            read_fifo_r ^ r_q2_ready, 
            !rdempty & !rdreq_safe};
                
        rd_almost_empty <=
            (rdusedw < ALMOST_EMPTY_VALUE) || 
            (rdusedw == ALMOST_EMPTY_VALUE) && (rdreq == 1);
            
        rd_almost_full <= 
            (rdusedw > ALMOST_FULL_VALUE) ||
            (rdusedw == ALMOST_FULL_VALUE) && (rdreq == 0);    

    end
end
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzhL9jW4NJXonqUe6rIt36Gz8F2CC9w401JLvY4uxrpBjlE0djkNMo92l8iTyQqXtJJWgLfCFryztP9TYqehwVg6WokvgBoW67yjtNqsCeje9Dk3chJdJnQYgG0pQehLgzwmoEis1AUWkefimQlnMFQp1SJ8vvY8Sik9jrWSqVqtMgd4oFltaqDt7xPGS9nGST55udFggdTcm66GlneAAOB+2PjdMqSJ0GJ+bAMVDU/fvMctvKNgb2NBl+byU4pf0c24k8FqKFfeNkNtjKtHsKOZSsEuJNGe4o/8cSZhhv9jtgDbykr6m13z/spwy6w2vX7c5B/kiRNypEozXDZdAx2OFVHKkMRzCIv2JJ+v69eBFuHEab0bFh2oR+zhI0r9l8zkjeOK0IOaypmZZ/j+JAnmCIePbajlMFPHFmZ7/9Mf55DWTHyiq1/pgKH0DgoykAgECWJk7ijBIMi71WvS0SI3GpLA/loAhw+Mp/RHzl9Fha0TCoCcxcCD7z+IklscPrT0mt5u7MMTOatQ7zeW5YPkY+znNDMG8Zl1vQiwwU3LqH4KcRVvQBOKPeGxqOCbU67flEY1nMejOxyNbfOzmrbMKV6qs0pNmFt3egrW4JIc7nq/FNLOfUZr4PkaGYnTHlyy+W3aZHWF56XQg/T5GeVNiVIVvy/mrwera5BZg9oZhPmU9OEjw/lXeblkRi+V8VOJQuoCitb1Jkfw2OREfgrl2SVGdauLdxoh6d4N8U+J/FvvMGtgczMDw3usZBYUI3jU7uFBNJYNf8OijnTJb5k"
`endif