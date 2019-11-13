
module rom(
    input   wire    ce,
    input   wire[5:0]   addr,

    output  reg[31:0]   inst
);

    reg[31:0] rom[63:0];

    initial begin
        $readmemh("rom.data", rom);
        $display("LOADED!! %d %d %d", rom[0], rom[1], rom[2]);
    end

    always @ (*) begin
        if (ce == 1'b0) begin
            inst <= 32'h0;
        end else begin
            inst <= rom[addr];
        end
        $display("TIME: %3d, CE: %d, ADDR: %5d, INST: %d", $time, ce, addr, inst);
    end

endmodule

module insf(
    input   wire    clk,
    input   wire    rst,
    output  wire[31:0]  inst_o
);

    wire[5:0] pc;
    wire rom_ce;

    pc pc0(.clk(clk), .rst(rst), .pc(pc), .ce(rom_ce));
    rom rom0(.ce(rom_ce), .addr(pc), .inst(inst_o));

endmodule

module insf_test;

    reg clk;
    reg rst;
    wire[31:0] inst;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars;
        clk = 1'b0;
        forever #10 begin
            clk = ~clk;
            $display("tik %4d %d", $time, clk);
        end
    end

    initial begin
        rst = 1'b1;
        #70 rst = 1'b0;
        #200 rst = 1'b1;
        #20 rst = 1'b0;
        #200 $finish;
    end

    insf insf0(.clk(clk), .rst(rst), .inst_o(inst));

endmodule



