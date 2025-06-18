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




module emif_ph2_gen_ff_init_1 (
    input wire clk,
    input wire d,
    output reg q 
    );
    
    initial
        q <= 1'b1;
        
    always @(posedge clk)
        q <= d;
    
    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFlc+Qva80YsOZJ6uRIHSRRtU2n1vF2DwBb29ooshKi0JFMi7xQmxC30LQqcZO01W93pSgI66T25dyF5zOoNZv7kNR1KPKOHFcyDs/aCzsftvMsyIhYMnH1acAdXT2tirTRERm1WjkkdiQ8w6KFDCP9fGWbx+d4WeWPUbZYcZteeu9wxMphyOt4+aI4jiDTeS/mQQlhtoMUmrRwPH3b4tl64DpiHJyCeEDMdgHK+ETXmzod8DeGUY7Idk2EvSpunM2PLL5Gn7wpoxtk87mOqztL4C8A8juYfosa/pRa3fqIisQQKA9DNf+ZD3TeoHSwtptvA+2vQmcdq1zLwjxTyJgWGHncdPAeL6AHNeT0g0ljKyKUdEKRCQWgSpckn9AZ/xqFpUmiQOvWkyasgrbhoJYrl4QU/rXlSCk1UDzmX2PMPTUsMtRUWTWiKhlv2bDRqOPZOG/NqHKxwXqK54b+NobB2C0X++0qS/2DA+2D3NYlMqkky5+SY89xxAYUvOeDjRkwENQErOPSMREgWQXmx7c4XUb7SV+VFWxaFcIUr2iW2cOZ9/htdXhy9QfooyAXVVfejTWVoRyvXJzqB25ImHXZU384/5ET/6q0qIU6TUUnqk2LXksJ+ecv0SzHM1s5KH0MqJKBCp/0eU7R5RDP89i3teB1Bx3cG7FmGu8M1KieFpVS1krdQEUaq/kExmIp96flqUU81NDoEehmel03SqtCMLnnlSZExrtbt01zPFaqiGRSz9cTXwehh+OyORlPpAc0NPWWL7VQ4Bd0zxcrfbEKeS"
`endif