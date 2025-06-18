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





`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

    input   clk,
    output  reset_out
);

    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1Fht4277Y+91VJnUrh/5hrFqOADwKRqiLsdt/cqGLEzhQQcrWmg51Yy5mXnSiw6FfImIkgD8Ck/ZT4cliEkfBJ8MvlFHiucF4gjdNZhvvfZU3j81OpYa3tPH5H2W4J0+SkdP2DPeAapjXi9YkQVQjsI0v4dbWpeIG8fZzNZQb9r7IdLCqtnNFCmiFw1vqqzdGnE27id82+iufRydCYAVk76+AWQbaZyosgkUXLqY4VRCSoh4OJxErbAAjmhklcR3qbZtNBCdqCF9bqryWupZkMpklXsfe5G7KRiw8bMAjFvuAkGQdFiOzIojPkWtODBv1c3i4gjsuZE3PgHhRr39wn7obP7Zbf3zLQj/+o5QqVZOBuvsEIcRop+a6TucmMyF05/Unhp5C8/X3pneoq2+xZlVNyoTAWvXxsJsJerJ6mVoXwgs0Z3s450Mwxyi5f58hSPcUlD0U5YH1oljVxcbGyTA/kGzhItzAQlqjUK8Y6PiM7sgNM8c2LCi+syVlvevi00Di4+5Yflxzgid71tikJyvSLR2JIWvDyEwfW1F979kr7GG6qPKwZe6wFqkahaYAqD1kRkCW5dk+TcXzoc1iadVqlx0CgQIAleg7RoO0x/ejjgjSGMJ+kMMBQjDfpp8ulvK+sQlLhAx4dAtyXhMd1yE2XZo2y0Cet2gTSahyRCLfrD8ATSo+QfCgxeAyrOgC1PLuBivxvInziHwS9gnXV4igXcvshPg1Ix27cLQaYhmSMa44reiY9GfUxWuPfMvegh30ope1L7aenwCK7bSPmwX"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOwiH59dehC3fUmRM84gjlDQ0UmDGN2gqqJ+KWD0gr6VGpmMbbDL7SQiBvn6hTn5t37NNzK+laiA5spFu0+UTEJQ7Xju4lXxK27w4LhzB4wdCpufzWQ7JRhEsCAiS44mObCVPCLLA0kVmOaFLoDsN1swKZkrYUhmzKQuidIacLZE8V4/wWGgLYbbOSRFO1Inio7aJraBu8cVoLSf1vJAiArUCsvBMEoFPpKz+p1cWZYF1p6LuRNVMdSkWNQYzG6+bTJghyKUVJ9DSqOWinaJjahHhjIHgp3Zggv7JB9HZfV/LYw+GJtdMUEbJLm7GumM7CTF+d/M/+dpA5WsaN0X0yAM2USeGSDXDZoQGPiHGw9+Fxbq3VJPUcmkTMZiCvB5GTT1pwfN7Rwoh2X6LbDuk1Gi94QjjnoEh8Tzc8lJwRWeDF8nCryixTKiehk5PjosjLKvT4jwTZ/MRqQ3nr2EykjDzt/vSz/OPCW3HNzymIHjaXu9Vwihj5YUwNwAzeVtdf3v4Hqfnd1As/pDyl75Vx5Fq2CrTM9lrQkR0R7PmKfZXNKmPR7rqE//pdBpgqHKOeHa165K0mBVvyPEWuaqbnwvN7QDU5jXY/kWWKoRasPLgTVtAyvAJGPAmNM4kVBKgHLON64JfVoqLqNrKRHN5QtwtOf/E/d6v2Y1upsBm9q8t2a+/lRcKCB7CtKOeXQF5j9nWNu3g2zz9c2JzG0zCP3KAvqD6eUFJRWHJQmgZcRqpLnROJqOfxW5rBgKgtKdHKMJzVMQ4H5+trnMsn+3mWaa"
`endif