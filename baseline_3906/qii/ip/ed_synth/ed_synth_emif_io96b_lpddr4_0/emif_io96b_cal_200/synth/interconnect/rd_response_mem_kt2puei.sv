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

module rd_response_mem_kt2puei #(
    parameter ST_DATA_W = 35,
    parameter ID_W      = 10,
    parameter PIPELINE_OUT = 0,
    parameter PIPELINE_CMP = 0
) ( 
    input                 clk,
    input                 rst,
    input                 in_valid,
    input [ST_DATA_W-1:0] in_data,
    output                in_ready,
    output logic          out_valid,
    output[ST_DATA_W-1:0] out_data,
    input                 out_ready,
    output                cmd_valid,
    output [ID_W-1:0]     cmd_id,
    input                 cmd_ready,
    input                 rsp_valid,
    input [ID_W-1:0]      rsp_id,
    output logic          rsp_ready    
);

localparam PIPELINE_CNT = PIPELINE_OUT + PIPELINE_CMP ;


	  localparam [4:0] depth = 1;
	  localparam [4:0] depth_index = 1;


logic [ST_DATA_W:0] dout0;
logic [1-1:0] sel_index;
logic [1-1 :0] demuxed,demuxed_valid;
logic ready_out_mem;
logic [1 -1 :0] shift_occurred;

rd_sipo_plus_kt2puei #(
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
    .dout0           (dout0)
);


rd_comp_sel_kt2puei #(
    .PIPELINE_OUT(PIPELINE_OUT),
    .PIPELINE_CMP(PIPELINE_CMP),
    .WIDTH       (ID_W)
) comp_sel (
    .clk            (clk),
    .in_0           ({dout0[ST_DATA_W],dout0[ID_W-1:0]}),
    .base           (rsp_id),
    .shift_occurred (shift_occurred),
    .sel            (),
    .sel_index      (sel_index),
    .clr            (demuxed_valid)
);

rd_demux_kt2puei demux ( .index(sel_index), .demuxed(demuxed)  );

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_0
        assign demuxed_valid[i] = demuxed[i] & rsp_valid & rsp_ready;
    end
endgenerate 
rd_mux_kt2puei #(
    .DATA_W(ST_DATA_W)
) mux (
    .index (sel_index),
    .in0           (dout0[ST_DATA_W-1:0]),
    .muxed (out_data)
);

assign in_ready = ready_out_mem;
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


assign cmd_valid = in_valid & in_ready;
assign cmd_id    = in_data[ID_W-1:0];

endmodule

module rd_demux_kt2puei (
    input  [1-1:0] index,
    output [1 -1 :0] demuxed
);

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_1
        assign demuxed[i] = (i==index);
    end
endgenerate
endmodule


module rd_mux_kt2puei #(
    parameter DATA_W = 10
) (
    input [1-1:0] index,

    input  [DATA_W-1:0] in0,

    output logic [DATA_W-1:0] muxed
);
  
always @ * 
    case (index)
     default : muxed = in0;

    endcase

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOz+ArnMnGFii0/QwWj8aIG2dvldx+UTVlFTsobrdBGsvziKiDwQeu1sFFAjO3EHrVDCledVoAnW66qLh2XBcb1U/xGeTEaglBOgij0CPdGlxNxMuFuY1QmEBfeAmUyEmKWtCgSquwEYCBl4Dg7M5KMng2vSZV3P6TDduFZOQA0JK97zD3X8JXcCEmisnS5PoEg0rniWhsuQmb8oKDtALtcQNLQ/qRE3IFUDBSnfPEHtqMg6yyi5DS2jlPMQDk+ECN0u6KHj5/Vae9Qaw5aPAgt2joaQF7IFkua6AvGuijdeB//ygQw+pjnk9uNvY725MpJpSEnF4l/7zsy9sgzxSxAHeye/h17xb6RvGCqfGXk1YGQNpBoDLbCwKsff0bGHK3sLuJyltHroQy4C9z9Mwm51FVmN8E7zD43/OtGeWqVqTJA2mVE4VETgUWDof4iFYkooW7kxN9j8PRl53+IbFZJ2YS9dU/mLCyl1fV3KaC6CH+IchZUkjym7pi3mmq/7uLPvVxsfFW0M/Z6XxB36YQMMmmGSKhZ7EzlenAHXslfH39m7ePssLBPsv1uXQjK/pYaKlXBqTjk5ky5Z11X67sQrPKZatM0MPBBkxBum4XfsTDl8PWjmLNV7jLb7PG5/sQHtMzv7K3CuTALDvlacEUxhchrYsK/SrDB6QptprM3PtIWM1E9Sk/Qfo5NNBn09Flp4cSt52/83dUdwX7XmajxovZLu7YkhjM1zJZ3aKqYTgmH6FUoHugxRk2U+XhM6SyHWC0EA2X2SMsTTgxvWhBCz"
`endif