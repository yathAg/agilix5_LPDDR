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


`timescale 1ps/1ps

module rd_response_mem_ykxseta #(
    parameter ST_DATA_W = 35,
    parameter ID_W      = 10,
    parameter PIPELINE_OUT = 0,
    parameter PIPELINE_CMP = 0
) ( 
    input                 clk,
    input                 rst,
    // ST Sink IF to accept data
    input                 in_valid,
    input [ST_DATA_W-1:0] in_data,
    output                in_ready,
    // ST Source IF - response data
    output logic          out_valid,
    output[ST_DATA_W-1:0] out_data,
    input                 out_ready,
    // AXI Master IF  - just AR/R channel for now 
    // AR channel
    output                cmd_valid,
    output [ID_W-1:0]     cmd_id,
    input                 cmd_ready,
    // R channel
    input                 rsp_valid,
    input [ID_W-1:0]      rsp_id,
    output logic          rsp_ready    
);

localparam PIPELINE_CNT = PIPELINE_OUT + PIPELINE_CMP ;


	  localparam [4:0] depth = 16;
	  localparam [4:0] depth_index = 4;


logic [ST_DATA_W:0] dout0;
logic [ST_DATA_W:0] dout1;
logic [ST_DATA_W:0] dout2;
logic [ST_DATA_W:0] dout3;
logic [ST_DATA_W:0] dout4;
logic [ST_DATA_W:0] dout5;
logic [ST_DATA_W:0] dout6;
logic [ST_DATA_W:0] dout7;
logic [ST_DATA_W:0] dout8;
logic [ST_DATA_W:0] dout9;
logic [ST_DATA_W:0] dout10;
logic [ST_DATA_W:0] dout11;
logic [ST_DATA_W:0] dout12;
logic [ST_DATA_W:0] dout13;
logic [ST_DATA_W:0] dout14;
logic [ST_DATA_W:0] dout15;
logic [4-1:0] sel_index;
logic [16-1 :0] demuxed,demuxed_valid;
logic ready_out_mem;
logic [16 -1 :0] shift_occurred;

rd_sipo_plus_ykxseta #(
    .TOTAL_W (ST_DATA_W+1),
    .ID_W    (ID_W) 
) mem (
    .clk             (clk),
    .rst             (rst),
    .in_valid        (in_valid  & cmd_ready),
    .in_data         (in_data),
    .in_ready       (ready_out_mem),
    .clr             (demuxed_valid), 
    .shift_occurred  (shift_occurred),
    .dout0           (dout0),
    .dout1           (dout1),
    .dout2           (dout2),
    .dout3           (dout3),
    .dout4           (dout4),
    .dout5           (dout5),
    .dout6           (dout6),
    .dout7           (dout7),
    .dout8           (dout8),
    .dout9           (dout9),
    .dout10           (dout10),
    .dout11           (dout11),
    .dout12           (dout12),
    .dout13           (dout13),
    .dout14           (dout14),
    .dout15           (dout15)
);


rd_comp_sel_ykxseta #(
    .PIPELINE_OUT(PIPELINE_OUT),
    .PIPELINE_CMP(PIPELINE_CMP),
    .WIDTH       (ID_W)
) comp_sel (
    .clk            (clk),
    .in_0           ({dout0[ST_DATA_W],dout0[ID_W-1:0]}),
    .in_1           ({dout1[ST_DATA_W],dout1[ID_W-1:0]}),
    .in_2           ({dout2[ST_DATA_W],dout2[ID_W-1:0]}),
    .in_3           ({dout3[ST_DATA_W],dout3[ID_W-1:0]}),
    .in_4           ({dout4[ST_DATA_W],dout4[ID_W-1:0]}),
    .in_5           ({dout5[ST_DATA_W],dout5[ID_W-1:0]}),
    .in_6           ({dout6[ST_DATA_W],dout6[ID_W-1:0]}),
    .in_7           ({dout7[ST_DATA_W],dout7[ID_W-1:0]}),
    .in_8           ({dout8[ST_DATA_W],dout8[ID_W-1:0]}),
    .in_9           ({dout9[ST_DATA_W],dout9[ID_W-1:0]}),
    .in_10           ({dout10[ST_DATA_W],dout10[ID_W-1:0]}),
    .in_11           ({dout11[ST_DATA_W],dout11[ID_W-1:0]}),
    .in_12           ({dout12[ST_DATA_W],dout12[ID_W-1:0]}),
    .in_13           ({dout13[ST_DATA_W],dout13[ID_W-1:0]}),
    .in_14           ({dout14[ST_DATA_W],dout14[ID_W-1:0]}),
    .in_15           ({dout15[ST_DATA_W],dout15[ID_W-1:0]}),
    .base           (rsp_id),
    .shift_occurred (shift_occurred),
    .sel            (),
    .sel_index      (sel_index),
    .clr            (demuxed_valid)
);

rd_demux_ykxseta demux ( .index(sel_index), .demuxed(demuxed)  );

// demuxwed = clr - only applicable if RID is accepted
generate 
genvar i;
    for (i=0;i<16;i++) begin : MY_LABEL_0
        assign demuxed_valid[i] = demuxed[i] & rsp_valid & rsp_ready;
    end
endgenerate 
// no need to pass valid bit to mux
rd_mux_ykxseta #(
    .DATA_W(ST_DATA_W)
) mux (
    .index (sel_index),
    .in0           (dout0[ST_DATA_W-1:0]),
    .in1           (dout1[ST_DATA_W-1:0]),
    .in2           (dout2[ST_DATA_W-1:0]),
    .in3           (dout3[ST_DATA_W-1:0]),
    .in4           (dout4[ST_DATA_W-1:0]),
    .in5           (dout5[ST_DATA_W-1:0]),
    .in6           (dout6[ST_DATA_W-1:0]),
    .in7           (dout7[ST_DATA_W-1:0]),
    .in8           (dout8[ST_DATA_W-1:0]),
    .in9           (dout9[ST_DATA_W-1:0]),
    .in10           (dout10[ST_DATA_W-1:0]),
    .in11           (dout11[ST_DATA_W-1:0]),
    .in12           (dout12[ST_DATA_W-1:0]),
    .in13           (dout13[ST_DATA_W-1:0]),
    .in14           (dout14[ST_DATA_W-1:0]),
    .in15           (dout15[ST_DATA_W-1:0]),
    .muxed (out_data)
);

// ST IF Backpressure
// when mem is full Or downstream backpresures
assign in_ready = ready_out_mem;
// below logic needs fixing - since we have pipeline within comp_sel
generate 
    if (PIPELINE_CMP==1) begin : PPL_1
        always @ (posedge clk) begin
            out_valid <= rsp_valid;
            rsp_ready    <= out_ready;
        end
    end
    else begin : PPL_0
        assign out_valid = rsp_valid;
        assign rsp_ready    = out_ready;
    end
endgenerate


// AR channel 
assign cmd_valid = in_valid & in_ready;
assign cmd_id    = in_data[ID_W-1:0];

endmodule

module rd_demux_ykxseta (
    input  [4-1:0] index,
    output [16 -1 :0] demuxed
);

generate 
genvar i;
    for (i=0;i<16;i++) begin : MY_LABEL_1
        assign demuxed[i] = (i==index);
    end
endgenerate
endmodule


module rd_mux_ykxseta #(
    parameter DATA_W = 10
) (
    input [4-1:0] index,

    input  [DATA_W-1:0] in0,
    input  [DATA_W-1:0] in1,
    input  [DATA_W-1:0] in2,
    input  [DATA_W-1:0] in3,
    input  [DATA_W-1:0] in4,
    input  [DATA_W-1:0] in5,
    input  [DATA_W-1:0] in6,
    input  [DATA_W-1:0] in7,
    input  [DATA_W-1:0] in8,
    input  [DATA_W-1:0] in9,
    input  [DATA_W-1:0] in10,
    input  [DATA_W-1:0] in11,
    input  [DATA_W-1:0] in12,
    input  [DATA_W-1:0] in13,
    input  [DATA_W-1:0] in14,
    input  [DATA_W-1:0] in15,

    output logic [DATA_W-1:0] muxed
);
  
always @ * 
    case (index)
     0 : muxed = in0;
     1 : muxed = in1;
     2 : muxed = in2;
     3 : muxed = in3;
     4 : muxed = in4;
     5 : muxed = in5;
     6 : muxed = in6;
     7 : muxed = in7;
     8 : muxed = in8;
     9 : muxed = in9;
     10 : muxed = in10;
     11 : muxed = in11;
     12 : muxed = in12;
     13 : muxed = in13;
     14 : muxed = in14;
     default : muxed = in15;

    endcase

endmodule

