
// `include "if.v"
// `include "if_id.v"
// `include "id.v"
// `include "id_ex.v"
// `include "ex.v"
// `include "ex_mm.v"
// `include "mm.v"
// `include "mm_wb.v"
// `include "regfile.v"

module risc (
    input   wire    rst,
    input   wire    clk,
    input   wire[7:0]   rom_rn,
    output  wire[7:0]   rom_wn,
    output  wire[31:0]  rom_a,
    output  wire        rom_wr
);

    wire[31:0]  if_pc;
    wire[31:0]  if_is;
    wire[2:0]   if_cu;

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

    inf if0 (
        .clk(clk), .rst(rst),
        .in(rom_rn),
        .wr(rom_wr),
        .pc(if_pc),
        .ce(rom_ce),
        .is(if_is),
        .cu(if_cu)
    );

    assign rom_a = if_pc;

    if_id if_id0 (
        .clk(clk), .rst(rst),
        .if_pc(if_pc),
        .if_is(if_is),
        .if_cu(if_cu),
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

    id_ex id_ex0 (
        .clk(clk),  .rst(rst),
        
        .id_t(id_t), .id_st(id_st), .id_sst(id_sst),
        .id_n1(id_n1), .id_n2(id_n1), .id_wa(id_wa), .id_we(id_we),

        .ex_t(ex_t), .ex_st(ex_st), .ex_sst(ex_sst),
        .ex_n1(ex_n1), .ex_n2(ex_n2), .ex_wa(ex_wa), .ex_we(ex_we)
    );

    ex ex0 (
        .clk(clk),  .rst(rst),

        .t(ex_t), .st(ex_st), .sst(ex_sst),
        .n1(ex_n1), .n2(ex_n2), .wa(ex_wa), .we(ex_we),

        .wa_o(ex_wa_o), .we_o(ex_we_o), .wn_o(ex_wn_o)
    );

    ex_mm ex_mm0 (
        .clk(clk),  .rst(rst),

        .ex_wa(ex_wa_o), .ex_we(ex_we_o), .ex_wn(ex_wn_o),
        .mm_wa(mm_wa), .mm_we(mm_we), .mm_wn(mm_wn)
    );

    mm mm0 (
        .clk(clk),  .rst(rst),

        .wn(mm_wn), .wa(mm_wa), .we(mm_we),
        .wn_o(mm_wn_o), .wa_o(mm_wa_o), .we_o(mm_we_o)
    );

    mm_wb mm_wb0 (
        .clk(clk), .rst(rst),

        .mm_wn(mm_wn_o), .mm_wa(mm_wa_o), .mm_we(mm_we_o),
        .wb_wn(wb_wn), .wb_wa(wb_wa), .wb_we(wb_we)
    );
    

endmodule
