`timescale 1ns/1ps

`include "sopc.v"

module test();

    reg clk;
    reg rst;

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        #1000 $finish;
    end

    sopc sopc0(
        .clk(clk),
        .rst(rst)
    );

endmodule
