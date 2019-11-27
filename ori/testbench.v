// testbench top module file
// for simulation only

// `include "riscv_top.v"

`timescale 1ns/1ps

module testbench;

reg clk;
reg rst;

riscv_top #(.SIM(1)) top(
    .EXCLK(clk),
    .btnC(rst),
    .Tx(),
    .Rx(),
    .led()
);

initial begin
  clk=1;
  rst=1;
  repeat(4) #1 clk=!clk;
  rst=0; 
  // repeat(1000) #1 begin
  forever #1 begin
    clk=!clk;
  end
  $finish;
end


endmodule
