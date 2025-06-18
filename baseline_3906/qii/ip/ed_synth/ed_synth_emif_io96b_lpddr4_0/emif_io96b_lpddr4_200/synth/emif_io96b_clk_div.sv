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


// a generic clock divider to be used in simulation
module clk_div #(
  parameter RATIO = 2
) (
  input wire clk_input,
  output wire clk_output
);
  localparam WIDTH = $clog2(RATIO);
  logic [WIDTH-1:0] r_reg;

  initial r_reg = 0;

  always @(posedge clk_input)
    r_reg <= r_reg + 1;

  assign clk_output = r_reg[WIDTH-1];
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFle0zHBHMoMtOTdyUd16RteWh7LoXBc0G7xxzgZdFRS0TA9Df8ku8VPLSjw8iv9nQF3T7rw/DqB9teqqOrUZAv9C/7MP832ClJSz8+HFKfmcwQxgjBRBSdpB87+Y56TmJPUYX1G3dKFMenVib0If7k1xT529EP94AM7pmhqSA7hbZBEKW0ALqGDe0a6rN0Zk6KmXWKCGSYxC96gyQb5Q9RIC1qgO7DnqExxOtTu1CmXsCPhv4jTtL26jxy8drQ134AiOzdDGc8tdY9oG3RGcgt7opsphEawMBBGcabpiHq0RfCxN/ExafkL+JRHpQ1LLOxslMykF9TXSETSOafZYuQuLHULRAW1YK6USGM/czOh5YkH13v8tgW9NDMeBE2JJbHHqRzy95952+SNM4movF4GrYglcxTqc16rcL1lDX0acU1somZo+hBfGvGLNjPEAYcdysZH3D7aroB4pRRoGUOyaWm9AQVESVfzCsIGjtzGBdf9IbJTxI/w0btQUvTNZWEkyr0v9JytcTZsVB5N6se68yMRYnJSoNhNs5Ywq949JOEna9cPX6A73i/0IdVxk/jEc7Nh9dywrYB2aYCh+q/xkPps1/FfA1xAfbPWyx0nDJ6VKpi81DIc7FskEjS3O8hssqcbK4osr+LkvLqPbvna2QI0WWdGbkY2GVnZLljzF44uk6s30IlZEDzr+nLR0qdvojF+wA0fMlV5JBBZ21qpONkkKFFy/0VRR+3LEdIXvLJ6GPTG5EBVgwWkpzt6L88MwJStMgjCl2hDPJM2iwNbY"
`endif