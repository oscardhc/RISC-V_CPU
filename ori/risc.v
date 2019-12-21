
// `include "mct.v"
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

    wire        stl_mm;
    wire        not_ok;

    wire[31:0]  if_mct_rn;
    wire[1:0]   if_ok;
    wire        cache_hit;

    wire        mm_e;
    wire[31:0]  mm_a;
    wire[31:0]  mm_n_i;
    wire[31:0]  mm_n_o;
    wire        mm_wr;
    wire        mm_ok;
    wire[1:0]   mm_cu;

    wire[31:0]  if_pc;
    wire[31:0]  if_is;

    wire[31:0]  id_pc;
    wire[31:0]  id_is;

    wire[31:0]  ex_if_pc;
    wire        ex_if_pce;

    wire[6:0]   id_t;
    wire[2:0]   id_st;
    wire        id_sst;
    wire[31:0]  id_n1;
    wire[31:0]  id_n2;
    wire[4:0]   id_wa;
    wire        id_we;
    wire[31:0]  id_nn;

    wire[31:0]  id_npc;

    wire[6:0]   ex_t;
    wire[2:0]   ex_st;
    wire        ex_sst;
    wire[31:0]  ex_n1;
    wire[31:0]  ex_n2;
    wire[4:0]   ex_wa;
    wire        ex_we;
    wire[31:0]  ex_nn;

    wire        ex_if_inv;
    wire        ex_if_rec;

    wire[31:0]  ex_npc;

    wire[4:0]   ex_wa_o;
    wire        ex_we_o;
    wire[31:0]  ex_wn_o;

    wire[4:0]   mm_wa;
    wire        mm_we;
    wire[31:0]  mm_wn;

    wire[4:0]   ex_mem_e;
    wire[31:0]  ex_mem_n;
    wire[4:0]   mm_mem_e;
    wire[31:0]  mm_mem_n;

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
    
    wire        if_e;

    mct mct0 (
        .clk(clk), .rst(rst),
        .if_a(if_pc),
        .in(rom_rn),
        .out(rom_wn), 
        .if_ok(if_ok),
        .if_n(if_mct_rn),
        .ad(rom_a),
        .wr(rom_wr),
        .mm_wr(mm_wr),
        .mm_n_i(mm_n_i),
        .mm_n_o(mm_n_o),
        .mm_a(mm_a),
        .mm_ok(mm_ok),
        .mm_e(mm_e),
        .cache_hit(cache_hit),
        .if_e(if_e),
        .mm_cu(mm_cu)
    );

    inf if0 (
        .clk(clk), .rst(rst),
        .dt(if_mct_rn),
        .ok(if_ok),
        .pc(if_pc),
        .is(if_is),
        .ex_if_pc (ex_if_pc),
        .ex_if_pce(ex_if_pce),

        .rom_rn   (rom_rn),
        .cache_hit(cache_hit),
        .if_e(if_e),

//        .inv(ex_if_inv),
//        .rec(ex_if_rec),
        .stl(stl_mm)
    );

    if_id if_id0 (
        .clk(clk), .rst(rst),
        .if_pc(if_pc),
        .if_is(if_is),
        .id_pc(id_pc),
        .id_is(id_is),
        .stl_mm(stl_mm),
        .mmif_ok(if_ok)
    );

    id id0 (
        .rst(rst),
        .pc(id_pc), .is(id_is),
        .rn1(rn1), .rn2(rn2),

        .re1(re1), .re2(re2),
        .ra1(ra1), .ra2(ra2),

        .t(id_t), .st(id_st), .sst(id_sst),
        .out1(id_n1), .out2(id_n2),
        .wa(id_wa), .we(id_we),
        .outn(id_nn),
        .npc(id_npc),

        .ex_wa(ex_wa_o), .ex_wn(ex_wn_o), .ex_we(ex_we_o),
        .mm_wa(mm_wa_o), .mm_wn(mm_wn_o), .mm_we(mm_we_o)
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
        .id_n1(id_n1), .id_n2(id_n2), .id_wa(id_wa), .id_we(id_we),
        .id_nn(id_nn),

        .ex_t(ex_t), .ex_st(ex_st), .ex_sst(ex_sst),
        .ex_n1(ex_n1), .ex_n2(ex_n2), .ex_wa(ex_wa), .ex_we(ex_we),
        .ex_nn(ex_nn),

        .id_npc(id_npc),
        .ex_npc(ex_npc),

        .stl_mm(stl_mm)
    );

    ex ex0 (
        .clk(clk),  .rst(rst),

        .t(ex_t), .st(ex_st), .sst(ex_sst),
        .n1(ex_n1), .n2(ex_n2), .wa(ex_wa), .we(ex_we),

        .wa_o(ex_wa_o), .we_o(ex_we_o), .res(ex_wn_o),
        .nn(ex_nn),

        .npc(ex_npc),

        .ex_if_pc (ex_if_pc),
        .ex_if_pce(ex_if_pce),

//        .inv_o(ex_if_inv),
//        .rec_i(ex_if_rec),
        
        .ex_mem_e(ex_mem_e), .ex_mem_n(ex_mem_n)
    );

    ex_mm ex_mm0 (
        .clk(clk),  .rst(rst),

        .ex_wa(ex_wa_o), .ex_we(ex_we_o), .ex_wn(ex_wn_o),
        .mm_wa(mm_wa), .mm_we(mm_we), .mm_wn(mm_wn),
        
        .ex_mem_e(ex_mem_e),
        .ex_mem_n(ex_mem_n),
        .mm_mem_e(mm_mem_e),
        .mm_mem_n(mm_mem_n),
        .stl_mm(stl_mm)
    );

    mm mm0 (
        .clk(clk),  .rst(rst),

        .wn(mm_wn), .wa(mm_wa), .we(mm_we),
        .wn_o(mm_wn_o), .wa_o(mm_wa_o), .we_o(mm_we_o),
    
        .mm_mem_e(mm_mem_e),
        .mm_mem_n(mm_mem_n),

        .mm_mct_a(mm_a), 
        .mm_mct_n_i(mm_n_i), 
        .mm_mct_n_o(mm_n_o), 
        .mm_mct_wr(mm_wr),
        .mm_mct_ok(mm_ok),
        .mm_mct_e(mm_e),
        .mm_mct_cu(mm_cu),

        .rom_rn    (rom_rn),

        .stl(stl_mm)
    );

    mm_wb mm_wb0 (
        .clk(clk), .rst(rst),

        .mm_wn(mm_wn_o), .mm_wa(mm_wa_o), .mm_we(mm_we_o),
        .wb_wn(wb_wn), .wb_wa(wb_wa), .wb_we(wb_we),
    
        .stl_mm(stl_mm)
    );
    

endmodule
