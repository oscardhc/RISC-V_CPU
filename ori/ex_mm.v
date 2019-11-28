module ex_mm (
    input   wire    rst,
    input   wire    clk,
    input   wire[4:0]   ex_wa,
    input   wire        ex_we,
    input   wire[31:0]  ex_wn,
    output  reg[4:0]    mm_wa,
    output  reg         mm_we,
    output  reg[31:0]   mm_wn,

    input   wire[4:0]   ex_mem_e,
    input   wire[31:0]  ex_mem_n,

    output  reg[4:0]    mm_mem_e,
    output  reg[31:0]   mm_mem_n,

    // input   wire[31:0]  ex_if_pc_i,
    // input   wire        ex_if_pce_i,

    // output  reg[31:0]   ex_if_pc_o,
    // output  reg         ex_if_pce_o,

    input   wire        stl_mm
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            mm_wa <= 5'h0;
            mm_we <= 1'h0;
            mm_wn <= 32'h0;
        end else if (stl_mm != 1'b1) begin
            // $display("ex_wn %d", ex_wn);
            mm_wa <= ex_wa;
            mm_we <= ex_we;
            mm_wn <= ex_wn;
            mm_mem_e <= ex_mem_e;
            mm_mem_n <= ex_mem_n;
        end
    end

    // always @ (negedge clk) begin
    //     if (rst == 1'b1) begin
    //         ex_if_pce_o <= 0;
    //         ex_if_pc_o  <= 0;
    //     end else if (stl_mm != 1'b1) begin
    //         ex_if_pce_o <= ex_if_pce_i;
    //         ex_if_pc_o  <= ex_if_pc_i;
    //     end
    // end

endmodule
