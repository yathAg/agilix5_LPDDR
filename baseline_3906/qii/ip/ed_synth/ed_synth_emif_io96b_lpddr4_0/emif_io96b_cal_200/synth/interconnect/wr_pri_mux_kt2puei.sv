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


module wr_pri_mux_kt2puei (
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
`pragma questa_oem_00 "4+6jNUoxc5SxbAQ+3GBx3+4XREOZvhns2xU5WkJSQ2Npk00vz8KbOFIOISwt8eXQnazXQ04ddjhCXDis9cIqg1tJ7F163NPH1xy7QxPM5nqlY2Y8HDIeSalj897RpZBL1u7m4+i5XF79rK2M9D+qGO3+q1Ofk+IMzB59rySvuOSbevRJ4J6WeSYyeVz5rmGpwUwunB0JgXmkJqAjTEWEwPrmPYeDZDqwqGPUH5vEFld4BAL/EfsvRPnbqANxytVILQpeTChX/xaaZ0TucaUccETtSZXsJ/CRXHVQwVA9hUj6oJeSmDL+TR0RTBKXKlxkPdBLB/MkrTYpwLh7KiVfWMupk6TAz7feti0jae6MuOcL4eDyqQ/5zMw++XkdgycB1vmmTBzZnQen7QYOJTuaM1JX/5wi4Ez4b/LVewYC2WSkbewmpKznBOx8ugncf2XMY3+G4A3y8v0WCugZaIMvl9aWfBCrm3E3q/JMvWasfWYqbW9jxFmhCJbAQvUhcZjnQIvE5i4ZtD+5a7nwk+b00oXcmVaFMiaxcttdCio+9FtltgpmcUb5s4vZ3FYub6K810OttSRsIJ/tZRA4Xny/NlrNP5DKU6yyzcw5MfnvmLmV9IvzQ6wptuLXSf4JA1x62qrL02JFFHiwU9MQEsW9530KkYMx171p17AO858te+SZL46TndYC7e/VDkvDZM3WiaS1wON8Tm6qKC8eUTc9Pry+tYBZ/msldSx1XhaApKEwK5sN358FENRnXJUSYwce/inphucTK0RTGgd19rzyCjZUg3BtqnTvL44NiXFIgsaV5/KRXkBVHzZrghLyrECuPdGrqdxGg3DNrH+AuaMVX5umy0v00q1nSow1fdMuSuJ/rwxIcFmM7paNIfnfLRKh0BOSUVPYtn34xnt88jsY13QYURwWPlhcmI7Ln2Cbv14dJyrCctcG8SajmtSOf65DUfjZ1EQwBUi9sc8sd0MYquV1P8q7Fx6MmrHA2qEUBDjURN9J46mmArLDfFbLD66A"
`endif