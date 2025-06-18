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

module compare_eq #(
    parameter WIDTH=10
) (
    input [WIDTH-1:0]  in_a,
    input [WIDTH-1:0]  in_b,
    output             equal
);

assign equal = (in_a==in_b);

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjQL9exbfXYTp137Dtd6Y0g6L4MgYOzwjRQpR0jP8MXyY0JHzOEOLBvGLeAfT0zJFN5eB54bfkyPWJXaUD9Yt++782v+rIWyQg5F3Q+VN5KWZObQSZSJZjskCikMATWs4odQUY2/UcTZ3iS0cyZ1gXZBv5vGyXsGpo3JMt8UqBRfF1GddwcaSNOLRFHi1adCsXu76Z1F1CAuiXCV+d92LcX5yDP9SbxTbuY8uOetEv1wHnVth16O1avdtiqUj8qtb0rrDaBUiskNDQOGgJrkP3YC2PV5p5Ep5C4udKdywI3ziips38Ds90PuJy67yjR8tG/R6zabBtu54dn1e8SLL326vGTA2sisJaEzjaRfIKsLJnA326qDRFJRXuJyNTM7cWuc6AbVd7frqsYkl08yfw34RPfW1+c+YH4f3PlPLrR0O6uYYvNhwJ9mQUj23tFchjYyASeMky7PNT0BIRTQEikjAtaLzBKpg5fs5fbnOqOERLQBFzbBPh4+FDq/9hu4gCx7eTa7MyIsxZKV5gt/lwT2hZcqDd/Z33loBENj5mAY5TuV7o5T6CQNg04nejD9dHDDPGwYJWtrjyx7Cdd/NXGCkPee8GzhdSawScqvEdT4qSIxEZ5C/Yaco4E3KjR+kltA956dS76He9dUzKofYAjSx8SNrd00sOxpHpDnq0yCOcmq6U2usnwNpYR4/6dZvcbsyarjLzWAiNvHJzbqrGMYbPHq2pU03yyDXkLFcSkzzETYMcG+/Jb0ZL6RUUP88PAn1MYWRVdlTzrc4hYcISV"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "F7WC8QZaT7vmnC3hwKGp3DONAYEv2i7yVqODTUXeYko19kYOPYfczZdrkKK2cn2SXhAaaUznybY5RoACRRs1IUHbXq21lpIx44cuUOTsrcbSWpSjKeTGgnYd3gR4m/i0MdU2DnJ2gAKCysnhMooXDQZZv/mc+ESIM91+e90fs++Ny1RCk/XyIWayLQGRa76w8uhicg0J82G9MBNIpKzO5g+NsAWw3jWjzb0n4krFLOzJ4IVj1ZVR8ry/J51W7q8f7hvrlXKghuw1UA7iOH5jTbNMqNnwt0BeGu7CatCPyDsHbh4AL9q/0daV6RlRdLoYKqqZwnk/mYpHz4P4iB18zncNu+PJjD1dxxsMQCb5jW0NzxPmpdDfP7SfJpYwAH+eb8Ksf0ToRLy74W7WI9LFfrkbLD9CFtJ9cwE868cXmwLiq7kwA4JtOy7MYEQokbJBHVBbFAw0rEu1Cx5P0gqph10ICK9sIeZFfx+t59aIl6BWbYVzKUqQy9A7YeWfQCYPRCu67iPG4U+n2pLqG2nkrv4WNVaW8BWTKlGH5utZmA6RzbgRcqJOJ1MqLGHIeJ+I3LCP9zruBAyQfol59OPx9DyHXzSSOnGV3XjFg52I6NKuciA57nihH8/QC1pn3gh0bTemV6KF18Bz3yd6cJ+9NJMFx2Ktwko/75ZJB25TZQmS63neD+zH1SUIisrYOqByLPOlmCDZVRyIQ8SK8XCQT9SOD7hVeBTw8YvABZWl07KrZ4ivVFK32m3Oz/M8OfAJ99gDlZvheqC2B0DeNQomfCFjX1ldvNYM+TJYfMinmzlJel6YzBM5N3xbXFAT27X7aW5pLox3Eg59RZab7aUutW17Lasr3Z8hZYPDXhSnql+L1nlKcfFXhvCF5KpQf/ngk43nsuhA8hS5cwBuTBSB1osD4if+ppzrP7GGVKQjVTUqnOaDxTGz6XVXuvj5kPOuGlRQVNDA9sNBaf0zWP7H5YUIjH3fVOqXq05BNnGnV/fzeN1CzSh8lvt73zNlfAKx"
`endif