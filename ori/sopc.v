module sopc (
    input   wire    clk,
    input   wire    rst
);

    wire[31:0]  ad;
    wire[31:0]  is;
    wire        ce;

    risc risc0 (
        .clk(clk), .rst(rst),
        .rom_data(is), .rom_addr(ad),
        .rom_ce(ce)
    );

endmodule
