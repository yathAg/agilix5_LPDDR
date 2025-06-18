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







`timescale 1ns / 1ns

module altera_avalon_st_pipeline_base (
                                       clk,
                                       reset,
                                       in_ready,
                                       in_valid,
                                       in_data,
                                       out_ready,
                                       out_valid,
                                       out_data
                                       );

   parameter  SYMBOLS_PER_BEAT  = 1;
   parameter  BITS_PER_SYMBOL   = 8;
   parameter  PIPELINE_READY    = 1;
   parameter  SYNC_RESET        = 0;
   parameter  BACKPRESSURE_DURING_RESET = 0;
   localparam DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;
   
   input clk;
   input reset;
   
   output in_ready;
   input  in_valid;
   input [DATA_WIDTH-1:0] in_data;
   
   input                  out_ready;
   output                 out_valid;
   output [DATA_WIDTH-1:0] out_data;
   
   reg                     full0;
   reg                     full1;
   reg [DATA_WIDTH-1:0]    data0;
   reg [DATA_WIDTH-1:0]    data1;

   assign out_valid = full1;
   assign out_data  = data1;    
   
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate

   generate if (PIPELINE_READY == 1) 
     begin : REGISTERED_READY_PLINE
        
        assign in_ready  = !full0;

        always @(posedge clk) begin
              if (~full0)
                data0 <= in_data;
              if (~full1 || (out_ready && out_valid)) begin
                 if (full0)
                   data1 <= data0;
                 else
                   data1 <= in_data;
              end
        end
       
        if (SYNC_RESET == 0) begin : async_rst0 
           always @(posedge clk or posedge reset) begin
              if (reset) begin
                 full0    <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
                 full1    <= 1'b0;
              end else begin
                 if(~full1 & full0)begin
                     full0 <= 1'b0;
                 end

                 if (~full0 & ~full1) begin
                    if (in_valid) begin
                       full1 <= 1'b1;
                    end
                 end 

                 if (full1 & ~full0) begin
                    if (in_valid & ~out_ready) begin
                       full0 <= 1'b1;
                    end
                    if (~in_valid & out_ready) begin
                       full1 <= 1'b0;
                    end
                 end 
                 
                 if (full1 & full0) begin
                    if (out_ready) begin
                       full0 <= 1'b0;
                    end
                 end 
              end
           end
       end 
       else begin 
           always @(posedge clk ) begin
              if (internal_sclr) begin
                 full0    <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
                 full1    <= 1'b0;
              end else begin
                 if(~full1 & full0)begin
                     full0 <= 1'b0;
                 end

                 if (~full0 & ~full1) begin
                    if (in_valid) begin
                       full1 <= 1'b1;
                    end
                 end 

                 if (full1 & ~full0) begin
                    if (in_valid & ~out_ready) begin
                       full0 <= 1'b1;
                    end
                    if (~in_valid & out_ready) begin
                       full1 <= 1'b0;
                    end
                 end 
                 
                 if (full1 & full0) begin
                    if (out_ready) begin
                       full0 <= 1'b0;
                    end
                 end 
              end
           end
       end 
     end 
   else 
     begin : UNREGISTERED_READY_PLINE
	
	assign in_ready = (~full1) | out_ready;

   if (SYNC_RESET == 0) begin : async_rst1	
	   always @(posedge clk or posedge reset) begin
	      if (reset) begin
	         data1 <= 'b0;
	         full1 <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
	      end
	      else begin
	         if (in_ready) begin
	   	 data1 <= in_data;
	   	 full1 <= in_valid;
	         end
	      end
	   end
   end 
   else begin 
      always @(posedge clk ) begin
	      if (internal_sclr) begin
	         data1 <= 'b0;
	         full1 <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
	      end
	      else begin
	         if (in_ready) begin
	   	 data1 <= in_data;
	   	 full1 <= in_valid;
	         end
	      end
	   end
	end 
     end
   endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "+AbvKNif4wIR5q/igDfM4DePC0l9exDgETX/dMtFAe71y0qcBHKGD6iKoAonAc18tp3+n/dPcXHqqPQcDPaTTmk7OKjrFa3Pkst/YjYx7bmo6SUfrzaVl9kc3zT+f1aRSGKf5IVl/Ez3tpEbJU8K9v/gNVYnzYrHsEy/PmUF70jGx1Y0gg9VJp9ZA4cKQBHvpOeIQDAu1e1V9vqrigbcMJYaagQ8BdQNgGlG54uA9jkeuJGToVB/w0SRZv7vWkHAzy4Kt1CiWFvCd6zJYjSPeLWe6moaY3yNeegErACTuP3xEjI2JtzMm8lHEhSvib+52ZRzcmWf2HX/qHTq3KZeVNAUJF1boYeN2B2s+TtPz2xamQ+itIWJbO7S4C1bxDFEXrZ/rX3Oc8rgPhPCXIx/SwLiXYUuVc+SjdO95Zb1ydeqQh3HEI8j7i+RAy76jv1/E+Ph7e1BWey1tf0MBbI06N3r7cz+VvAdRaUlhViAR2KN/Givzdxrab6o84xhLxO/VSKtbwP2okPpu/ULYd0o2MIgs+tktL1UK8kk8Om0zW8JbYIQLNTYJcI3uGkAJPWWyshRZdliDtKdfiXndHDvCD+feDG/iJ6sLfsHmIAUZZXiWC4HqeCW1hwS44DMPV86WYBmwe0c1QsIG9wlK9QyEy0fZeaKcVOTbiinTRtCSgyCTZUR8BoY5d/PhDcm0vXNEgRWs5B6QNU9U5nSnOoT0AhMtiDrc+2+U1KggIpWPTzAP72cJpXim6RCQlcw67LtY2+CWVwjVeDO8Z0OTrCInuJZs5ZX/HH00Z5DDSHJjqxzaBA1e658Q8pVZzSaQbSOv3TwrFZj42AADRs38L41S26w7XuP0bt0pyH1ZIZXqHWWVYs5jhJJkzObhEq1PPmoUGLamtr7sYO05bvAdWBlqSuYHJBY3/Mi+P8lFn1XolhFrsKIKApYzvVFpLJiqmX3atA2rM1WQMJ2l1n3Jv54co7gFk/s2Wczerlxny75seicGEiBISvmsuWJPoqVG21f"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "WgQPBVH1VBdyP1GnR2LUpBzapu3xqcPGd0xGo/Q4H4WpUeO+Hjltnkr805HvMqRkWDh3DyN3peSztswEbmtfL0y+XxwNgZXD8HzMTx127Mwzcyz+hm45kBealsJBAXnHmYFlorRoaB/cee+emunA/0c48mpmEF4OlQtcwz5XqcWvwenzsvQhJKdJ/IF87NHqDP/WjB3TeL4879eoAz/zIDUkxAOJQxnV3qexrxF9wbIt59dMnwBUatIiIOf0v9KwtF9tt/1EFaqn0GEk41TL5Ztz7dgRJB+MkME2Nh1WQs9g1suGV1V90KstCXwLQig2VSLJClZxblvP6TfgY4hZQtjwLpxqHp30Ddl4PYB3bkbJ+zC94wAfjCFRVzSE6dFxqaVuB8m0pN2+FhbNpwgzJNnzENiUx5ziUKCLEqtQ5bL6UlJonLDa+x7e2lMk7HWRY/oyt14PAQXchAomo6wYny4JnMPznLxi8j4EikAKH/Gi1Gg62Lfwx7KPWqGF63Zbnh3by7TsxNfEXwVm10fYjPVg5XbfXkgE6aWwEaduo1oOvR3Dx9hsW5B5VAfFJ12f0qNIS+ct4jb+wRpc+eu3bYnFL1ZqAzNxIk4Fn5dYXPrRSssIK0mULjatHkaZ5CfZU0veW+03+t6SnjzXPCt1qqSmpk30hCPZwuZgQC6HQ/lk022NuP+ol3sqmB8DsTlvsWdanhhdY+oxzHXS8JgP37nDIa4LLh/4Ty+TvZH7bih+Qnbxtstb1gKw752GQoLT4ecREc9jHwHFWli9kxc+0xMCNmd2Dm8W0vimvLFFmYryN+mmHSApZYelU5BdHYHZDSW5v5lFHn2qfG15vhkKKCoCgqxi0+rgDGXK1TYg060+ApbBWe2hRB9kzD0VJkVGxEa8zArA5smKD671VE+sNwJL7jyPnPsnbamVX/Xx71xD8lTeMnZcX9niyv9wzRu9agDTsoLLenltQe1Wm8piJYvz05i+1JsVmH7Y6P2GpGk2NkVrM/oHsLBeMAyEd41j"
`endif