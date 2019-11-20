module ex_mm (
    input   wire    rst,
    input   wire    clk,
    input   wire[4:0]   ex_wa,
    input   wire        ex_we,
    input   wire[31:0]  ex_wn,
    output  reg[4:0]    mm_wa,
    output  reg         mm_we,
    output  reg[31:0]   mm_wn,

    input   wire[3:0]   ex_mem_e,
    input   wire[31:0]  ex_mem_n,

    output  reg[3:0]    mm_mem_e,
    output  reg[31:0]   mm_mem_n,

    input   wire        stl
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            mm_wa <= 5'h0;
            mm_we <= 1'h0;
            mm_wn <= 32'h0;
        end else if (stl != 1'b1) begin
            $display("ex_wn %d", ex_wn);
            mm_wa <= ex_wa;
            mm_we <= ex_we;
            mm_wn <= ex_wn;
            mm_mem_e <= ex_mem_e;
        end
    end

endmodule
