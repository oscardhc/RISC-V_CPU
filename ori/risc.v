module risc (
    input   wire    rst,
    input   wire    clk,
    input   wire[31:0]  rom_data,
    output  wire[31:0]  rom_addr,
    output  wire        rom_ce
);

    wire[31:0]  pc;
    wire[31:0]  id_pc;
    wire[31:0]  id_is;

    wire[6:0]   id_t;
    wire[2:0]   id_st;
    wire        id_sst;
    wire[31:0]  id_n1;
    wire[31:0]  id_n2;
    wire[4:0]   id_wa;
    wire        id_we;

    wire[6:0]   ex_t;
    wire[2:0]   ex_st;
    wire        ex_sst;
    wire[31:0]  ex_n1;
    wire[31:0]  ex_n2;
    wire[4:0]   ex_wa;
    wire        ex_we;

    wire[4:0]   ex_wa_o;
    wire        ex_we_o;
    wire[31:0]  ex_wn_o;

    wire[4:0]   mm_wa;
    wire        mm_we;
    wire[31:0]  mm_wn;

    wire[4:0]   mm_wa_o;
    wire        mm_we_o;
    wire[31:0]  mm_wn_o;

    wire[4:0]   wb_wa;
    wire        wb_we;
    wire[31:0]  wb_wn;

    wire[4:0]   wa;
    wire[31:0]  wn;
    wire        we;
    wire[31:0]  rn1;
    wire[4:0]   ra1;
    wire        re1;
    wire[31:0]  rn2;
    wire[4:0]   ra2;
    wire        re2;

    pc pc0 (
        .clk(clk), .rst(rst),
        .pc(pc),
        .ce(rom_ce)
    );

    assign rom_addr = pc;

    if_id if_id0 (
        .clk(clk), .rst(rst),
        .if_pc(pc),
        .if_is(rom_data),
        .id_pc(id_pc),
        .id_is(id_is)
    );

    id id0 (
        .rst(rst),
        .pc(id_pc), .is(id_is),
        .rn1(rn1), .rn2(rn2),

        .re1(re1), .re2(re2),
        .ra1(ra1), .ra2(ra2),

        .t(id_t), .st(id_st), .sst(id_sst),
        .out1(id_n1), .out2(id_n2),
        .wa(id_wa), .we(id_we)
    );

    regfile regfile0 (
        .clk(clk), .rst(rst),
        .we(wb_we), .wa(wb_wa), .wn(wb_wn),

        .re1(re1), .ra1(ra1), .rn1(rn1),
        .re2(re2), .ra2(ra2), .rn2(rn2)
    );
    

endmodule
