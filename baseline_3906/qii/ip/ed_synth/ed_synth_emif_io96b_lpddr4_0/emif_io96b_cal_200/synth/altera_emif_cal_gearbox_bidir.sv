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






`ifndef F2C_GB_WRITE_ACK_DELAY
`define F2C_GB_WRITE_ACK_DELAY 32
`endif

`ifndef ZERO_PAD_ASSIGN
`define ZERO_PAD_ASSIGN(SRC_WIDTH, DST_WIDTH, SRC, DST) \
   generate \
      if (SRC_WIDTH >= DST_WIDTH) begin \
         assign DST = SRC[(DST_WIDTH-1):0]; \
      end \
      else begin \
         assign DST = {'0,SRC[(SRC_WIDTH-1):0]}; \
      end \
   endgenerate
`endif

`define GB_HIPI_C2P   (* preserve, altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON; -name HYPER_REGISTER_DELAY_CHAIN 350"} *)
`define GB_HIPI_P2C   (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_PERIPHERY_CORE_TRANSFER ON"} *)


module altera_emif_cal_gearbox_bidir
  #(parameter AXI_ADDR_WIDTH = 20,
    parameter AXI_DATA_WIDTH = 32,
    parameter WRITE_ACK_DELAY = `F2C_GB_WRITE_ACK_DELAY          
    )
   (
    (* preserve, noprune *) input  logic                       axi_clk,
    (* preserve, noprune *) input  logic                       axi_rst_n,

    (* preserve, noprune *) input  logic                       axi_awvalid,
    (* preserve, noprune *) output logic                       axi_awready,
    (* preserve, noprune *) input  logic  [AXI_ADDR_WIDTH-1:0] axi_awaddr,

    (* preserve, noprune *) input  logic                       axi_arvalid,
    (* preserve, noprune *) output logic                       axi_arready,
    (* preserve, noprune *) input  logic  [AXI_ADDR_WIDTH-1:0] axi_araddr,

    (* preserve, noprune *) input  logic                       axi_wvalid,
    (* preserve, noprune *) output logic                       axi_wready,
    (* preserve, noprune *) input  logic  [AXI_DATA_WIDTH-1:0] axi_wdata,

    (* preserve, noprune *) output logic                       axi_rvalid,
    (* preserve, noprune *) input  logic                       axi_rready,
    (* preserve, noprune *) output logic [ 1:0]                axi_rresp,
    (* preserve, noprune *) output logic [AXI_DATA_WIDTH-1:0]  axi_rdata,

    (* preserve, noprune *) output logic                       axi_bvalid,
    (* preserve, noprune *) input  logic                       axi_bready,
    (* preserve, noprune *) output logic [ 1:0]                axi_bresp,

    output logic                       m_axi_awvalid,
    input  logic                       m_axi_awready,
    output logic  [AXI_ADDR_WIDTH-1:0] m_axi_awaddr,

    output logic                       m_axi_arvalid,
    input  logic                       m_axi_arready,
    output logic  [AXI_ADDR_WIDTH-1:0] m_axi_araddr,

    output logic                       m_axi_wvalid,
    input  logic                       m_axi_wready,
    output logic  [AXI_DATA_WIDTH-1:0] m_axi_wdata,

    input  logic                       m_axi_rvalid,
    output logic                       m_axi_rready,
    input  logic [ 1:0]                m_axi_rresp,
    input  logic [AXI_DATA_WIDTH-1:0]  m_axi_rdata,

    input  logic                       m_axi_bvalid,
    output logic                       m_axi_bready,
    input  logic [ 1:0]                m_axi_bresp,

    input  logic                       c2f_rst_n,
    output logic [5:0]                 ssm_c2p,
    input  logic [4:0]                 ssm_p2c
    );
   
    timeunit 1ns;
    timeprecision 1ps;

    localparam SUB_ID = 1'b1;
    localparam MGR_ID = 1'b0;

    logic clk, rst_n;
   
    assign clk     = axi_clk;
    assign rst_n   = c2f_rst_n;

    logic  [4:0]   vio_out;
    logic  [4:0]   vio_in;
    (* preserve, noprune *) logic [4:0]  preserve_ssm_c2p;
    
    logic  [31:0]  sub_address;
    logic  [3:0]   sub_byteenable;
    logic          sub_read;
    logic [31:0]   sub_readdata;
    logic [1:0]    sub_rresp;
    logic          sub_readdatavalid;  
    logic          sub_waitrequest;
    logic          sub_write;
    logic  [31:0]  sub_writedata;
    logic          sub_burstcount;
    logic          sub_debugaccess;
    
    logic          mgr_waitrequest;  
    logic  [31:0]  mgr_readdata;     
    logic          mgr_readdatavalid;
    logic  [31:0]  mgr_writedata;    
    logic  [31:0]  mgr_address;      
    logic          mgr_write;        
    logic          mgr_read;         
    logic  [3:0]   mgr_byteenable;   
    logic          mgr_burstcount;
    logic          mgr_debugaccess;
    logic   [1:0]  mgr_rresp;

    logic [2:0] mgr_c_st , mgr_n_st ; 
    logic [2:0] sub_c_st , sub_n_st ; 

    localparam MGR_IDLE             = 3'h0;     
    localparam MGR_WR               = 3'h1;     
    localparam MGR_RD               = 3'h2;     
    localparam MGR_WR_DONE          = 3'h3;     
    localparam MGR_RD_DONE          = 3'h4;     
    localparam MGR_WAIT_WR_ACK      = 3'h5;     
    localparam MGR_WAIT_RD_RESP     = 3'h6;     
    
    localparam SUB_IDLE             = 3'h0;     
    localparam SUB_WR               = 3'h1;     
    localparam SUB_RD               = 3'h2;     
    localparam SUB_WR_DONE          = 3'h3;    
    localparam SUB_RD_DONE          = 3'h4;    
    localparam SUB_SEND_WR_ACK      = 3'h5;    
    localparam SUB_SEND_RD_RESP     = 3'h6;



    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            preserve_ssm_c2p <= '0;
            vio_in <= '0;
        end
        else begin
            preserve_ssm_c2p <= vio_out;
            vio_in <= ssm_p2c;
        end
    end

    assign ssm_c2p = preserve_ssm_c2p;
    

    logic m_a_busy;
    logic m_a_done;
    logic m_w_done;
    
    always @(posedge clk, negedge axi_rst_n)
        if(~axi_rst_n)
        begin
            m_a_busy <= 1'b0;
            m_a_done <= 1'b0;
            m_w_done <= 1'b0;
            m_axi_awvalid <= 1'b0;
            m_axi_arvalid <= 1'b0;
            m_axi_wvalid <= 1'b0;
        end
        else
        begin
            m_a_busy <= (sub_read | sub_write | m_a_busy) & ~m_a_done; 
            m_a_done <= (m_axi_awvalid & m_axi_awready) | 
                        (m_axi_arvalid & m_axi_arready) | 
                        (m_a_done & sub_waitrequest);
            m_w_done <= (m_axi_wvalid & m_axi_wready) | 
                        (m_w_done & sub_waitrequest);
            m_axi_awvalid <= sub_write & ~m_a_done &
                               ~(m_axi_awvalid & m_axi_awready);
            m_axi_arvalid <= sub_read & ~m_a_done &
                               ~(m_axi_arvalid & m_axi_arready);
            m_axi_wvalid  <= sub_write & ~m_w_done &
                               ~(m_axi_wvalid & m_axi_wready);
        end

    `ZERO_PAD_ASSIGN(32, AXI_ADDR_WIDTH, sub_address, m_axi_awaddr);
    `ZERO_PAD_ASSIGN(32, AXI_ADDR_WIDTH, sub_address, m_axi_araddr);
    `ZERO_PAD_ASSIGN(32, AXI_DATA_WIDTH, sub_writedata, m_axi_wdata);

    `ZERO_PAD_ASSIGN(AXI_DATA_WIDTH, 32, m_axi_rdata, sub_readdata);
    assign sub_rresp = m_axi_rresp;
    assign sub_readdatavalid = m_axi_rready & m_axi_rvalid;

    always @(posedge clk, negedge axi_rst_n)
        if(~axi_rst_n)
        begin
            sub_waitrequest <= 1'b1;
            m_axi_rready <= 1'b0;
            m_axi_bready <= 1'b0;
        end
        else
        begin
            sub_waitrequest <= ~( ( sub_write & (m_a_done & m_w_done & m_axi_bready) ) |
                                  ( sub_read &  (m_a_done & m_axi_rready) ) );
            m_axi_rready <= m_axi_rvalid & ~m_axi_rready;
            m_axi_bready <= m_axi_bvalid & ~m_axi_bready;
        end
            
    logic rw_arb;     
    logic rw_busy;    
    logic wr_waiting;
    logic rsp_wait;
    logic resp_busy;
    logic mgr_wr_ack;
    assign wr_waiting = axi_awvalid & axi_wvalid;
    assign rsp_wait = resp_busy & ( rw_arb ? ~(axi_rvalid & axi_rready)
                                           : ~(axi_bvalid & axi_bready) );
    
    assign mgr_byteenable = '0;
    assign mgr_burstcount = '0;
    assign mgr_debugaccess = '0;
    assign axi_bresp = '0;
    
    always @(posedge clk, negedge axi_rst_n)
        if(~axi_rst_n)
        begin
            rw_arb <= 1'b0;
            rw_busy <= 1'b0;
            resp_busy <= 1'b0;
        end
        else
        begin
            if( ~(resp_busy | rw_busy) & (wr_waiting | axi_arvalid) )
            begin
                rw_arb <= ( rw_arb ? ~wr_waiting : axi_arvalid );
                rw_busy <= 1'b1;
            end
            else
                rw_busy <= rw_busy & mgr_waitrequest;
            resp_busy <= (rw_busy & ~mgr_waitrequest) | ( resp_busy & rsp_wait);
        end
    
    logic [31:0] axi_araddr_zero_pad;
    logic [31:0] axi_awaddr_zero_pad;
    `ZERO_PAD_ASSIGN(AXI_DATA_WIDTH, 32, axi_wdata, mgr_writedata);
    `ZERO_PAD_ASSIGN(AXI_ADDR_WIDTH, 32, axi_araddr, axi_araddr_zero_pad)
    `ZERO_PAD_ASSIGN(AXI_ADDR_WIDTH, 32, axi_awaddr, axi_awaddr_zero_pad)
    assign mgr_write = ~rw_arb & rw_busy;
    assign mgr_read  =  rw_arb & rw_busy;
    assign mgr_address = rw_arb ? axi_araddr_zero_pad : axi_awaddr_zero_pad;
        
    logic [AXI_DATA_WIDTH-1:0] mgr_readdata_zero_pad;
    `ZERO_PAD_ASSIGN(32, AXI_DATA_WIDTH, mgr_readdata, mgr_readdata_zero_pad);
    always @(posedge clk)
        if(rw_arb & mgr_readdatavalid)
        begin
            axi_rdata <= mgr_readdata_zero_pad;
            axi_rresp <= mgr_rresp;
        end
            
    always @(posedge clk, negedge axi_rst_n)
        if(~axi_rst_n)
        begin
            axi_arready <= 1'b0;
            axi_awready <= 1'b0;
            axi_wready <= 1'b0;
            axi_rvalid <= 1'b0;
            axi_bvalid <= 1'b0;
        end
        else
        begin
            axi_arready <=  rw_arb & rw_busy & ~mgr_waitrequest;
            axi_awready <= ~rw_arb & rw_busy & ~mgr_waitrequest;
            axi_wready  <= ~rw_arb & rw_busy & ~mgr_waitrequest;
            axi_bvalid  <= (~rw_arb & mgr_wr_ack) | ( axi_bvalid & ~axi_bready);
            axi_rvalid  <= ( rw_arb & resp_busy & mgr_readdatavalid) | ( axi_rvalid & ~axi_rready);
        end

    if (WRITE_ACK_DELAY==0)
    begin: no_write_ack_delay
        assign mgr_wr_ack =  ( mgr_c_st == MGR_WAIT_WR_ACK &&  mgr_n_st == MGR_IDLE ) ? 1'b1 : 1'b0;
    end
    else
    begin: write_ack
        localparam TIMER_WIDTH = $clog2(WRITE_ACK_DELAY);
        logic [TIMER_WIDTH-1:0] write_ack_timer;
        logic decr;
        logic decr_q;
        
        always @(posedge clk, negedge axi_rst_n)
            if(~axi_rst_n)
                write_ack_timer <= WRITE_ACK_DELAY - 1;
            else if(axi_wready)
                write_ack_timer <= WRITE_ACK_DELAY - 1;
            else
                write_ack_timer <= write_ack_timer - decr;
                
        assign decr =  (mgr_n_st == MGR_IDLE) ? (rsp_wait & ~rw_arb & |write_ack_timer) : 1'b0;

        always @(posedge clk, negedge axi_rst_n)
            if(~axi_rst_n)
                decr_q <= '0;
            else
                decr_q <= decr;

        assign mgr_wr_ack =  decr_q & ~decr;
    end




    logic [31:0] temp_mgr_writedata;
    logic [31:0] temp_mgr_address;
    
    logic   mgr_start_1, mgr_start_2, mgr_start_3, mgr_start_4, mgr_start_5, mgr_start_6, mgr_start_7, mgr_start_8, mgr_start_9, mgr_start_10;
    logic   mgr_start_11, mgr_start_12, mgr_start_13, mgr_start_14, mgr_start_15, mgr_start_16, mgr_start_17;
    
    logic   done_mgr_write, done_mgr_read;
    
    logic   mgr_rd_start_1, mgr_rd_start_2, mgr_rd_start_3, mgr_rd_start_4, mgr_rd_start_5, mgr_rd_start_6, mgr_rd_start_7, mgr_rd_start_8;
    logic   mgr_rd_start_9, mgr_rd_start_10, mgr_rd_start_11, mgr_rd_start_12, mgr_rd_start_13, mgr_rd_start_14, mgr_rd_start_15, mgr_rd_start_16, mgr_rd_start_17;
    
    logic           temp_mgr_readdatavalid;
    logic [31:0]    temp_mgr_readdata;
    logic [1:0]     temp_mgr_response;
    logic   done_mgr_rd_valid;
    
    logic [4:0] vio_out_mgr_cmd;
    
    logic   sub_start_1, sub_start_2, sub_start_3, sub_start_4, sub_start_5, sub_start_6, sub_start_7, sub_start_8, sub_start_9, sub_start_10;
    logic   sub_start_11, sub_start_12, sub_start_13, sub_start_14, sub_start_15, sub_start_16;
    
    logic   done_sub_write, done_sub_read;
    
    logic   sub_rd_start_1, sub_rd_start_2, sub_rd_start_3, sub_rd_start_4, sub_rd_start_5, sub_rd_start_6, sub_rd_start_7, sub_rd_start_8, sub_rd_start_9;
    logic   sub_rd_start_10, sub_rd_start_11, sub_rd_start_12, sub_rd_start_13, sub_rd_start_14, sub_rd_start_15, sub_rd_start_16, sub_rd_start_17;
    
    logic [31:0] temp_sub_writedata;
    logic [31:0] temp_sub_address;
    
    logic           temp_sub_readdatavalid;
    logic [31:0]    temp_sub_readdata;
    logic [1:0]     temp_sub_response;
    logic   done_sub_rdata_packet;
    logic   done_sub_wr_ack;
    
    logic [4:0] vio_out_sub_rd_data;
    logic [4:0] vio_out_sub_wr_ack;
    
    
    logic was_doing_mgr_write, was_doing_mgr_read, was_doing_sub_write, was_doing_sub_read;
    
    logic mgr_id = MGR_ID;
    logic sub_id  = SUB_ID;
    
    logic mgr_using_vio_out;
    logic sub_using_vio_out;
    
    logic mgr_read_resp_in_progress;

    
    

    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n) begin
            mgr_c_st    <= MGR_IDLE;
        end
        else begin
            mgr_c_st    <= mgr_n_st;
        end
    end


    always @(*) 
    begin
        case ( mgr_c_st )
 
            MGR_IDLE :
                if ( mgr_write )                                                     
                    begin 
                        mgr_n_st = MGR_WR;
                    end 
                else if ( mgr_read )                                                 
                    begin
                        mgr_n_st = MGR_RD;
                    end
                else begin
                        mgr_n_st = MGR_IDLE;
                    end


            MGR_WR : 
                if ( done_mgr_write )                                                
                    begin
                        mgr_n_st = MGR_WR_DONE;
                    end
                else begin
                        mgr_n_st = MGR_WR;
                    end


            MGR_RD : 
                if ( done_mgr_read )                                                 
                    begin
                        mgr_n_st = MGR_RD_DONE;
                    end
                else begin
                        mgr_n_st = MGR_RD;
                    end


            MGR_WR_DONE : 
                        mgr_n_st = MGR_WAIT_WR_ACK;                               


            MGR_WAIT_WR_ACK : 
                if ( (vio_in[4:3] == {1'b1, mgr_id}) && vio_in[2:0] == 3'b010 && (sub_c_st != SUB_WR || done_sub_write) && (sub_c_st != SUB_RD || done_sub_read ) )      
                    begin
                        mgr_n_st = MGR_IDLE;
                    end
                else begin
                        mgr_n_st = MGR_WAIT_WR_ACK;
                    end


            MGR_RD_DONE : 
                        mgr_n_st = MGR_WAIT_RD_RESP;                              


            MGR_WAIT_RD_RESP : 
                if ( done_mgr_rd_valid )                                             
                    begin
                        mgr_n_st = MGR_IDLE;
                    end
                else begin
                        mgr_n_st = MGR_WAIT_RD_RESP;
                    end


            default :
                        mgr_n_st = MGR_IDLE;
        endcase
    end






    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n) begin
            sub_c_st    <= SUB_IDLE;
        end
        else begin
            sub_c_st    <= sub_n_st;
        end
    end


    always @(*) 
    begin
        case (sub_c_st) 
            SUB_IDLE :
                if ( (vio_in[4:3] == {1'b1, sub_id}) && vio_in[2:0] == 3'b000 && ~mgr_read_resp_in_progress )                           
                    begin 
                        sub_n_st = SUB_WR;
                    end 
                else if ( (vio_in[4:3] == {1'b1, sub_id}) && vio_in[2:0] == 3'b001 && ~mgr_read_resp_in_progress )                      
                    begin
                        sub_n_st = SUB_RD;
                    end
                else begin
                        sub_n_st = SUB_IDLE;
                    end


            SUB_WR : 
                if ( done_sub_write )                                                                 
                    begin
                        sub_n_st = SUB_WR_DONE;
                    end
                else begin
                        sub_n_st = SUB_WR;
                    end


            SUB_RD : 
                if ( done_sub_read )                                                                  
                    begin
                        sub_n_st = SUB_RD_DONE;
                    end
                else begin
                        sub_n_st = SUB_RD;
                    end


            SUB_WR_DONE : 
                if ( ~sub_waitrequest )                                                               
                    begin 
                        sub_n_st = SUB_SEND_WR_ACK;
                    end
                else begin
                        sub_n_st = SUB_WR_DONE;
                    end
                

            SUB_SEND_WR_ACK : 
                if ( done_sub_wr_ack )                                                                
                    begin
                        sub_n_st = SUB_IDLE;
                    end
                else begin
                        sub_n_st = SUB_SEND_WR_ACK;
                    end


            SUB_RD_DONE : 
                if ( ~sub_waitrequest )                                                               
                    begin 
                        sub_n_st = SUB_SEND_RD_RESP;
                    end
                else begin
                        sub_n_st = SUB_RD_DONE;
                    end


            SUB_SEND_RD_RESP : 
                if ( done_sub_rdata_packet )                                                          
                    begin
                        sub_n_st = SUB_IDLE;
                    end
                else begin
                        sub_n_st = SUB_SEND_RD_RESP;
                    end


            default :
                        sub_n_st = SUB_IDLE;
        endcase
    end







    always @ (posedge clk or negedge rst_n)
    begin
        if (!rst_n) 
            begin
                        mgr_start_1             <= 1'b0;
                        mgr_start_2             <= 1'b0;
                        mgr_start_3             <= 1'b0;
                        mgr_start_4             <= 1'b0;
                        mgr_start_5             <= 1'b0;
                        mgr_start_6             <= 1'b0;
                        mgr_start_7             <= 1'b0;
                        mgr_start_8             <= 1'b0;
                        mgr_start_9             <= 1'b0;
                        mgr_start_10            <= 1'b0;
                        mgr_start_11            <= 1'b0;
                        mgr_start_12            <= 1'b0;
                        mgr_start_13            <= 1'b0;
                        mgr_start_14            <= 1'b0;
                        mgr_start_15            <= 1'b0;
                        mgr_start_16            <= 1'b0;
                        mgr_start_17            <= 1'b0;
                        temp_mgr_address        <= 32'b0;
                        temp_mgr_writedata      <= 32'b0;
                        done_mgr_write          <= 1'b0;
                        done_mgr_read           <= 1'b0;
                        vio_out_mgr_cmd         <= 5'b0;
            end
        else begin
            if ( mgr_c_st == MGR_WR && !(sub_c_st == SUB_SEND_WR_ACK || sub_c_st == SUB_SEND_RD_RESP) && !( mgr_using_vio_out || done_mgr_write ) )                                                                                                                                         
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= { mgr_id , 3'b000};            
                        mgr_start_1             <= 1'b1;
                        temp_mgr_address        <= mgr_address;
                        temp_mgr_writedata      <= mgr_writedata;
                end 
            else if ( mgr_c_st == MGR_WR && mgr_start_1 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[31:28];
                        mgr_start_1             <= 1'b0;
                        mgr_start_2             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_2 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[27:24];
                        mgr_start_2             <= 1'b0;
                        mgr_start_3             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_3 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[23:20];
                        mgr_start_3             <= 1'b0;
                        mgr_start_4             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_4 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[19:16];
                        mgr_start_4             <= 1'b0;
                        mgr_start_5             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_5 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[15:12];
                        mgr_start_5             <= 1'b0;
                        mgr_start_6             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_6 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[11:8];
                        mgr_start_6             <= 1'b0;
                        mgr_start_7             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_7 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[7:4];
                        mgr_start_7             <= 1'b0;
                        mgr_start_8             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_8 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[3:0];
                        mgr_start_8             <= 1'b0;
                        mgr_start_9             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_9 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_writedata[31:28];
                        mgr_start_9             <= 1'b0;
                        mgr_start_10            <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_10 ) 
                begin
                        vio_out_mgr_cmd[4]       <= 1'b1;                            
                        vio_out_mgr_cmd[3:0]     <= temp_mgr_writedata[27:24];
                        mgr_start_10             <= 1'b0;
                        mgr_start_11             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_11 ) 
                begin
                        vio_out_mgr_cmd[4]       <= 1'b1;                            
                        vio_out_mgr_cmd[3:0]     <= temp_mgr_writedata[23:20];
                        mgr_start_11             <= 1'b0;
                        mgr_start_12             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_12 ) 
                begin
                        vio_out_mgr_cmd[4]       <= 1'b1;                            
                        vio_out_mgr_cmd[3:0]     <= temp_mgr_writedata[19:16];
                        mgr_start_12             <= 1'b0;
                        mgr_start_13             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_13 ) 
                begin
                        vio_out_mgr_cmd[4]       <= 1'b1;                            
                        vio_out_mgr_cmd[3:0]     <= temp_mgr_writedata[15:12];
                        mgr_start_13             <= 1'b0;
                        mgr_start_14             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_14 ) 
                begin
                        vio_out_mgr_cmd[4]       <= 1'b1;                            
                        vio_out_mgr_cmd[3:0]     <= temp_mgr_writedata[11:8];
                        mgr_start_14             <= 1'b0;
                        mgr_start_15             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_15 ) 
                begin
                        vio_out_mgr_cmd[4]       <= 1'b1;                            
                        vio_out_mgr_cmd[3:0]     <= temp_mgr_writedata[7:4];
                        mgr_start_15             <= 1'b0;
                        mgr_start_16             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_16 ) 
                begin
                        vio_out_mgr_cmd[4]       <= 1'b1;                            
                        vio_out_mgr_cmd[3:0]     <= temp_mgr_writedata[3:0];
                        mgr_start_16             <= 1'b0;
                        mgr_start_17             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WR && mgr_start_17 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b0;                             
                        vio_out_mgr_cmd[3:0]    <= 4'b0;
                        mgr_start_17            <= 1'b0;
                        done_mgr_write          <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && !(sub_c_st == SUB_SEND_WR_ACK || sub_c_st == SUB_SEND_RD_RESP) && !( mgr_using_vio_out || done_mgr_read ) )                                                                                                                                     
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= { mgr_id , 3'b001};            
                        mgr_start_1             <= 1'b1;
                        temp_mgr_address        <= mgr_address;
                end 
            else if ( mgr_c_st == MGR_RD && mgr_start_1 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[31:28];
                        mgr_start_1             <= 1'b0;
                        mgr_start_2             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_2 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[27:24];
                        mgr_start_2             <= 1'b0;
                        mgr_start_3             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_3 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[23:20];
                        mgr_start_3             <= 1'b0;
                        mgr_start_4             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_4 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[19:16];
                        mgr_start_4             <= 1'b0;
                        mgr_start_5             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_5 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[15:12];
                        mgr_start_5             <= 1'b0;
                        mgr_start_6             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_6 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[11:8];
                        mgr_start_6             <= 1'b0;
                        mgr_start_7             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_7 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[7:4];
                        mgr_start_7             <= 1'b0;
                        mgr_start_8             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_8 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b1;                             
                        vio_out_mgr_cmd[3:0]    <= temp_mgr_address[3:0];
                        mgr_start_8             <= 1'b0;
                        mgr_start_9             <= 1'b1;
                end
            else if ( mgr_c_st == MGR_RD && mgr_start_9 ) 
                begin
                        vio_out_mgr_cmd[4]      <= 1'b0;                             
                        vio_out_mgr_cmd[3:0]    <= 4'b0;
                        mgr_start_9             <= 1'b0;
                        done_mgr_read           <= 1'b1;
                end
            else
                begin
                        vio_out_mgr_cmd[4:0]    <= 5'b0;                     
                        done_mgr_write          <= 1'b0;
                        done_mgr_read           <= 1'b0;
                end
        end
    end

    assign mgr_using_vio_out = (mgr_start_1 || mgr_start_2 || mgr_start_3 || mgr_start_4 || mgr_start_5 || mgr_start_6 || mgr_start_7 || mgr_start_8 || mgr_start_9 || mgr_start_10  
                                || mgr_start_11 || mgr_start_12 || mgr_start_13 || mgr_start_14 || mgr_start_15 || mgr_start_16 || mgr_start_17 );


    always @ (posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            begin
                        mgr_rd_start_1              <= 1'b0;
                        mgr_rd_start_2              <= 1'b0;
                        mgr_rd_start_3              <= 1'b0;
                        mgr_rd_start_4              <= 1'b0;
                        mgr_rd_start_5              <= 1'b0;
                        mgr_rd_start_6              <= 1'b0;
                        mgr_rd_start_7              <= 1'b0;
                        mgr_rd_start_8              <= 1'b0;
                        temp_mgr_readdata           <= 32'b0;
                        done_mgr_rd_valid           <= 1'b0;
                        mgr_rresp                   <= 2'h0;
            end
        else begin
            if ( mgr_c_st == MGR_WAIT_RD_RESP && (sub_c_st != SUB_WR || done_sub_write ) && (sub_c_st != SUB_RD || done_sub_read )  && ( vio_in[4:2] == {1'b1, mgr_id, 1'b1} ) 
                  && !( mgr_rd_start_1 || mgr_rd_start_2 || mgr_rd_start_3 || mgr_rd_start_4 || mgr_rd_start_5 || mgr_rd_start_6 || mgr_rd_start_7 || mgr_rd_start_8 || done_mgr_rd_valid ) )
                begin
                        mgr_rd_start_1              <= 1'b1;                                     
                        mgr_rresp                   <= vio_in[1:0];
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_1 ) 
                begin
                        temp_mgr_readdata[31:28]    <= vio_in[3:0];
                        mgr_rd_start_1              <= 1'b0;
                        mgr_rd_start_2              <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_2 ) 
                begin
                        temp_mgr_readdata[27:24]    <= vio_in[3:0];
                        mgr_rd_start_2              <= 1'b0;
                        mgr_rd_start_3              <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_3 ) 
                begin
                        temp_mgr_readdata[23:20]    <= vio_in[3:0];
                        mgr_rd_start_3              <= 1'b0;
                        mgr_rd_start_4              <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_4 ) 
                begin
                        temp_mgr_readdata[19:16]    <= vio_in[3:0];
                        mgr_rd_start_4              <= 1'b0;
                        mgr_rd_start_5              <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_5 ) 
                begin
                        temp_mgr_readdata[15:12]    <= vio_in[3:0];
                        mgr_rd_start_5              <= 1'b0;
                        mgr_rd_start_6              <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_6 ) 
                begin
                        temp_mgr_readdata[11:8]     <= vio_in[3:0];
                        mgr_rd_start_6              <= 1'b0;
                        mgr_rd_start_7              <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_7 ) 
                begin
                        temp_mgr_readdata[7:4]      <= vio_in[3:0];
                        mgr_rd_start_7              <= 1'b0;
                        mgr_rd_start_8              <= 1'b1;
                end
            else if ( mgr_c_st == MGR_WAIT_RD_RESP &&  vio_in[4]  && mgr_rd_start_8 ) 
                begin
                        temp_mgr_readdata[3:0]      <= vio_in[3:0];
                        mgr_rd_start_8              <= 1'b0;
                        done_mgr_rd_valid           <= 1'b1;
                end
            else
                begin
                        done_mgr_rd_valid           <= 1'b0;
                end
        end
    end

    
    assign mgr_read_resp_in_progress = (mgr_rd_start_1 || mgr_rd_start_2 || mgr_rd_start_3 || mgr_rd_start_4 || mgr_rd_start_5 || mgr_rd_start_6 || mgr_rd_start_7 || mgr_rd_start_8) ;
    
    
    always @ (posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            begin
                        sub_start_1         <= 1'b0;
                        sub_start_2         <= 1'b0;
                        sub_start_3         <= 1'b0;
                        sub_start_4         <= 1'b0;
                        sub_start_5         <= 1'b0;
                        sub_start_6         <= 1'b0;
                        sub_start_7         <= 1'b0;
                        sub_start_8         <= 1'b0;
                        sub_start_9         <= 1'b0;
                        sub_start_10        <= 1'b0;
                        sub_start_11        <= 1'b0;
                        sub_start_12        <= 1'b0;
                        sub_start_13        <= 1'b0;
                        sub_start_14        <= 1'b0;
                        sub_start_15        <= 1'b0;
                        sub_start_16        <= 1'b0;
                        temp_sub_address    <= 32'b0;
                        temp_sub_writedata  <= 32'b0;
                        done_sub_write      <= 1'b0;
                        done_sub_read       <= 1'b0;
            end
        else begin
            if (  sub_c_st == SUB_WR && vio_in[4] && !( sub_start_1 || sub_start_2 || sub_start_3 || sub_start_4 || sub_start_5 || sub_start_6 || sub_start_7 || sub_start_8 || sub_start_9 
                                                    || sub_start_10  || sub_start_11 || sub_start_12 || sub_start_13 || sub_start_14 || sub_start_15 || sub_start_16 || done_sub_write ) )
                begin
                        temp_sub_address[31:28]     <= vio_in[3:0];                       
                        sub_start_1                 <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_1 ) 
                begin
                        temp_sub_address[27:24]     <= vio_in[3:0];                     
                        sub_start_1                 <= 1'b0;
                        sub_start_2                 <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_2 ) 
                begin
                        temp_sub_address[23:20]     <= vio_in[3:0];                     
                        sub_start_2                 <= 1'b0;
                        sub_start_3                 <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_3 ) 
                begin
                        temp_sub_address[19:16]     <= vio_in[3:0];                     
                        sub_start_3                 <= 1'b0;
                        sub_start_4                 <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_4 ) 
                begin
                        temp_sub_address[15:12]       <= vio_in[3:0];                     
                        sub_start_4                   <= 1'b0;
                        sub_start_5                   <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_5 ) 
                begin
                        temp_sub_address[11:8]        <= vio_in[3:0];                     
                        sub_start_5                   <= 1'b0;
                        sub_start_6                   <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_6 ) 
                begin
                        temp_sub_address[7:4]         <= vio_in[3:0];                     
                        sub_start_6                   <= 1'b0;
                        sub_start_7                   <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_7 ) 
                begin
                        temp_sub_address[3:0]         <= vio_in[3:0];                     
                        sub_start_7                   <= 1'b0;
                        sub_start_8                   <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_8 ) 
                begin
                        temp_sub_writedata[31:28]     <= vio_in[3:0];                 
                        sub_start_8                   <= 1'b0;
                        sub_start_9                   <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_9 ) 
                begin
                        temp_sub_writedata[27:24]     <= vio_in[3:0];                     
                        sub_start_9                   <= 1'b0;
                        sub_start_10                  <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_10 ) 
                begin
                        temp_sub_writedata[23:20]     <= vio_in[3:0];                     
                        sub_start_10                  <= 1'b0;
                        sub_start_11                  <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_11 ) 
                begin
                        temp_sub_writedata[19:16]     <= vio_in[3:0];                     
                        sub_start_11                  <= 1'b0;
                        sub_start_12                  <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_12 ) 
                begin
                        temp_sub_writedata[15:12]     <= vio_in[3:0];                     
                        sub_start_12                  <= 1'b0;
                        sub_start_13                  <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_13 ) 
                begin
                        temp_sub_writedata[11:8]      <= vio_in[3:0];                     
                        sub_start_13                  <= 1'b0;
                        sub_start_14                  <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_14 ) 
                begin
                        temp_sub_writedata[7:4]       <= vio_in[3:0];                     
                        sub_start_14                  <= 1'b0;
                        sub_start_15                  <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && vio_in[4] && sub_start_15 ) 
                begin
                        temp_sub_writedata[3:0]       <= vio_in[3:0];                     
                        sub_start_15                  <= 1'b0;
                        sub_start_16                  <= 1'b1;
                end
            else if ( sub_c_st == SUB_WR && sub_start_16 ) 
                begin
                        sub_start_16                <= 1'b0;
                        done_sub_write              <= 1'b1;
                end
            else if ( sub_c_st == SUB_RD && vio_in[4] && !( sub_start_1 || sub_start_2 || sub_start_3 || sub_start_4 || sub_start_5 || sub_start_6 || sub_start_7 || sub_start_8 || sub_start_9 ||                                                    sub_start_10  || sub_start_11 || sub_start_12 || sub_start_13 || sub_start_14 || sub_start_15 || sub_start_16 || done_sub_read ) )
                begin
                        temp_sub_address[31:28]     <= vio_in[3:0];                   
                        sub_start_1                 <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && vio_in[4] && sub_start_1 ) 
                begin
                        temp_sub_address[27:24]     <= vio_in[3:0];                     
                        sub_start_1                 <= 1'b0;
                        sub_start_2                 <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && vio_in[4] && sub_start_2 ) 
                begin
                        temp_sub_address[23:20]     <= vio_in[3:0];                     
                        sub_start_2                 <= 1'b0;
                        sub_start_3                 <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && vio_in[4] && sub_start_3 ) 
                begin
                        temp_sub_address[19:16]     <= vio_in[3:0];                     
                        sub_start_3                 <= 1'b0;
                        sub_start_4                 <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && vio_in[4] && sub_start_4 ) 
                begin
                        temp_sub_address[15:12]       <= vio_in[3:0];                     
                        sub_start_4                   <= 1'b0;
                        sub_start_5                   <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && vio_in[4] && sub_start_5 ) 
                begin
                        temp_sub_address[11:8]        <= vio_in[3:0];                     
                        sub_start_5                   <= 1'b0;
                        sub_start_6                   <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && vio_in[4] && sub_start_6 ) 
                begin
                        temp_sub_address[7:4]         <= vio_in[3:0];                     
                        sub_start_6                   <= 1'b0;
                        sub_start_7                   <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && vio_in[4] && sub_start_7 ) 
                begin
                        temp_sub_address[3:0]         <= vio_in[3:0];                     
                        sub_start_7                   <= 1'b0;
                        sub_start_8                   <= 1'b1;
                end
            else if (  sub_c_st == SUB_RD && sub_start_8 ) 
                begin
                        sub_start_8                 <= 1'b0;
                        done_sub_read               <= 1'b1;
                end
            else
                begin
                        done_sub_write              <= 1'b0;
                        done_sub_read               <= 1'b0;
                end
        end
    end





    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n) 
            begin
                    temp_sub_readdatavalid        <= 1'b0;
                    temp_sub_readdata             <= 32'b0;
            end
        else begin
            if ( (sub_c_st == SUB_SEND_RD_RESP || sub_c_st == SUB_RD_DONE) && sub_readdatavalid)    
                begin
                    temp_sub_readdatavalid        <= 1'b1;
                    temp_sub_readdata             <= sub_readdata;
                    temp_sub_response             <= sub_rresp;
                end
            else if ( sub_c_st == SUB_IDLE )
                begin
                    temp_sub_readdatavalid        <= 1'b0;
                    temp_sub_readdata             <= 32'b0;
                end    
            end        
    end

    always @ (posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            begin
                        sub_rd_start_1              <= 1'b0;
                        sub_rd_start_2              <= 1'b0;
                        sub_rd_start_3              <= 1'b0;
                        sub_rd_start_4              <= 1'b0;
                        sub_rd_start_5              <= 1'b0;
                        sub_rd_start_6              <= 1'b0;
                        sub_rd_start_7              <= 1'b0;
                        sub_rd_start_8              <= 1'b0;
                        sub_rd_start_9              <= 1'b0;
                        vio_out_sub_rd_data         <= 5'b0;
                        done_sub_rdata_packet       <= 1'b0;
            end
        else begin
            if ( sub_c_st == SUB_SEND_RD_RESP && ~mgr_using_vio_out &&  temp_sub_readdatavalid  && !( sub_using_vio_out || done_sub_rdata_packet ) )
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                                    
                        vio_out_sub_rd_data[3:0]    <= { sub_id, 1'b1, temp_sub_response };     
                        sub_rd_start_1              <= 1'b1;                    
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_1 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[31:28];        
                        sub_rd_start_1              <= 1'b0;
                        sub_rd_start_2              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_2 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[27:24];
                        sub_rd_start_2              <= 1'b0;
                        sub_rd_start_3              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_3 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[23:20];
                        sub_rd_start_3              <= 1'b0;
                        sub_rd_start_4              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_4 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[19:16];
                        sub_rd_start_4              <= 1'b0;
                        sub_rd_start_5              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_5 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[15:12];
                        sub_rd_start_5              <= 1'b0;
                        sub_rd_start_6              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_6 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[11:8];
                        sub_rd_start_6              <= 1'b0;
                        sub_rd_start_7              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_7 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[7:4];
                        sub_rd_start_7              <= 1'b0;
                        sub_rd_start_8              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_8 ) 
                begin
                        vio_out_sub_rd_data[4]      <= 1'b1;                              
                        vio_out_sub_rd_data[3:0]    <= temp_sub_readdata[3:0];
                        sub_rd_start_8              <= 1'b0;
                        sub_rd_start_9              <= 1'b1;
                end
            else if ( sub_c_st == SUB_SEND_RD_RESP  &&  sub_rd_start_9 ) 
                begin
                        vio_out_sub_rd_data[4:0]    <= 5'b0;                     
                        sub_rd_start_9              <= 1'b0;
                        done_sub_rdata_packet       <= 1'b1;
                end
            else
                begin
                        vio_out_sub_rd_data[4:0]    <= 5'b0;
                        done_sub_rdata_packet       <= 1'b0;
                end
        end
    end

    assign sub_using_vio_out = (sub_rd_start_1 || sub_rd_start_2 || sub_rd_start_3 || sub_rd_start_4 || sub_rd_start_5 || sub_rd_start_6 || sub_rd_start_7 || sub_rd_start_8 || sub_rd_start_9);  


    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n) 
            begin
                    done_sub_wr_ack             <= 1'b0;
                    vio_out_sub_wr_ack          <= 5'b0;
            end
        else begin
            if ( sub_c_st == SUB_SEND_WR_ACK && ~mgr_using_vio_out && ~done_sub_wr_ack ) 
                begin
                    vio_out_sub_wr_ack[4]       <= 1'b1;                  
                    vio_out_sub_wr_ack[3:0]     <= { sub_id, 3'b010 };  
                    done_sub_wr_ack             <= 1'b1;
                end
            else begin
                    vio_out_sub_wr_ack          <= 5'b0;
                    done_sub_wr_ack             <= 1'b0;
                end    
        end        
    end


    
    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n) 
            begin
                    mgr_waitrequest      <= 1'b1;
            end
        else begin
            if ( mgr_n_st == MGR_WR_DONE || mgr_n_st == MGR_RD_DONE ) 
                begin
                    mgr_waitrequest      <= 1'b0;            
                end
            else begin
                    mgr_waitrequest      <= 1'b1;
                end    
        end        
    end

    
    
    
    assign mgr_readdata          = temp_mgr_readdata;            
    assign mgr_readdatavalid     = done_mgr_rd_valid;
    
    
    
    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n) 
            begin
                    sub_write             <= 1'b0;
                    sub_read              <= 1'b0;
            end
        else begin
            if ( sub_n_st == SUB_WR_DONE ) 
                begin
                    sub_write     <= 1'b1;
                end
            else if ( sub_n_st == SUB_RD_DONE ) 
                begin
                    sub_read      <= 1'b1;
                end
            else begin
                    sub_write     <= 1'b0;
                    sub_read      <= 1'b0;
                end    
        end        
    end

    assign  sub_address       = temp_sub_address; 
    assign  sub_writedata     = temp_sub_writedata;     
    
    assign  sub_byteenable    = 4'hf;
    assign  sub_burstcount    = 1'b1;
    assign  sub_debugaccess   = 1'b0;



    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n) 
            begin
                    vio_out     <= 5'b0;
            end
        else begin
            if ( mgr_using_vio_out ) 
                begin
                    vio_out     <= vio_out_mgr_cmd;            
                end
            else if ( sub_using_vio_out ) 
                begin
                    vio_out     <= vio_out_sub_rd_data;
                end
            else if ( done_sub_wr_ack ) 
                begin
                    vio_out     <= vio_out_sub_wr_ack;
                end 
            else begin
                    vio_out     <= 5'b0;
                end    
        end        
    end

endmodule

`ifdef ZERO_PAD_ASSIGN
`undef ZERO_PAD_ASSIGN
`endif

`undef GB_HIPI_C2P
`undef GB_HIPI_P2C
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "WgQPBVH1VBdyP1GnR2LUpBzapu3xqcPGd0xGo/Q4H4WpUeO+Hjltnkr805HvMqRkWDh3DyN3peSztswEbmtfL0y+XxwNgZXD8HzMTx127Mwzcyz+hm45kBealsJBAXnHmYFlorRoaB/cee+emunA/0c48mpmEF4OlQtcwz5XqcWvwenzsvQhJKdJ/IF87NHqDP/WjB3TeL4879eoAz/zIDUkxAOJQxnV3qexrxF9wbJYD37Z0gk/MlnNI7hfBNAbOhGygktNnhnMzfe9rq6aVfJf8rY/DaypPg2kHI61RmNsOudFGr8XoVwhN6t1JuDafluidzYT0WgEklorFfQu1+FLWkW2MdlGmQCf9UZTXgBZNtrLwLwrtGCozpNylF7mLB7c4w0WeD1/bwJZznTa9jopsPtvLlRoWys7e7YhnC9SOb3VwzVqVp6EaxJTfWmD2RccPgEZu30IxLUOwIRwhO6kM4R/DQ4pQ8rkBkgaaAJuhhFvbYrlgMA6I5JPSsQOQxcItKUgJBwN+Pzw4aP90x+DYuPTdvxrEVOkMYUUGAxRrodUvQzki9zzliyTeiDZM+zm7lx9OU2YTW8b+dzZRYKYZQsoV7j3qK65Y6Qev3tw4GgtLK1L3J849Wdz0ivDnNdw8cxOIG8l5be5wELSuwOiDX20OfVVn5xP1Mlc1IxbXNfgNu5zM1Z26BjjNAdMpEsTmUil81EyRiUMf9WxDXD2G/i+96AVEKzEo1SaZggE0DRpaYmvxILxZff81FpVVvBXUs1k1Z+sL/fh/IynOQr7Lb+bVOaSF0uRrfQewr82rtvu+KQ+VxJVLvYzLnMV8gGmvwSOGLz/iA8ewzwHjeUwdhvaGnEdXuLuOc62iaqb9wglzOMHsE68Tt3xHTbJB3WXcz3t7RI1mo/TexqOYWJJWZ6ROHvSX+lgV6VeuIuXyHIxF22UrFug4ao9T9LCm3lSa+xl4A+ZGG2vtpbeDfR8GvVjmUtZk+1sJqzUVuZ+cVcEVVu0GhADYrgYMTAe"
`endif