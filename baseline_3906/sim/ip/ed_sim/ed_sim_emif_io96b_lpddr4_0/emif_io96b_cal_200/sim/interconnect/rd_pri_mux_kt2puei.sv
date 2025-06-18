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


module rd_pri_mux_kt2puei (
input in0,
input [1-1:0] clr, 
input [1-1:0] shift_index_out, 
output logic sel,
output logic [1-1:0] sel_index
);

always @ * begin
    if (in0 && !clr[0]) begin
        sel = in0;
        sel_index=0;
    end
end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOxD9/DCK10JF1nDBJrPvwuzADFCnnQSlDz+fwmklYbpiucxdimUOIChZvs5JkkPJqSOJaUX5NaYKQYdri0p1AgQkKCKD+xV7zIla+i609Ja8WXoozsGGqBS5mWhm2ClafOKigaDNHKbSW6cy+pABKqkmF/NjKsiVpa5oBy+C3DCdOHvIPawV6bbJOh1MFCDhEMvvj1ggW5rnTo/wHllEYE2zY/4D/Gi35a68jBpe1EKrXM17vp76NQgY1x/5rK03W75mwn0GNj+Qw9/vDL8x91OHtrG1hxHhDFc0bSapzVtGnR/+ekZkXtR1osk7GbMHHn49sZtKIgEm1T+ydTQilvCzoG78OX3Syfk41MvOqU/P2yvgnr6t9eHAmK+4cS+rVx3BllAXlG7rah4JlOm2EJLhaTYDz3NsXg3aZlrRuoNOUqjv2jdAwHbbECVG4HWBKf4KlhAqbTFBFPJkKM8Jl4lKa+SZoi0hshu+qGM9RYNoHUNb1jCnekUQD99dyVnXC1/sumbDxT9ljciJfsj2hvdvgxVr//eWy8ix+WIRdpjVOCvXwjF3zTK94Gnyf64yVLEuNv5jFglxYyGmAzkGq4Vu2Y6OyQj9jDdHZrmKWFKJTlpJ/34HhzPDH8dohZrD65r9FNdgFvZSrUTjgI2mZTJHxpahriSm/oC1zt2ty6MlTAvyWXHnJyNbJgbCpTL+GQDo0mVEghe/UeWRqmH7X8rTGzFCaIZVCi1pwtna++C9BYi3M/d+MoEfTU61eX7y3IAeCjHH8VZyNU5k/83zCCO"
`endif