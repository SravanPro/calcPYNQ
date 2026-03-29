`timescale 1ns / 1ps


module deleteTB  #(parameter n=4)();

    reg clock, reset, inc, dec;
    wire [n-1 : 0] count;
    miscCounter dut(
        .clock(clock),
        .reset(reset),
        .inc(inc),
        .dec(dec),
        .count(count)
    );
endmodule
