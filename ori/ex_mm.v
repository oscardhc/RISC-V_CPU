module ex_mm (
    input   wire    rst,
    input   wire    clk,
    input   wire[4:0]   ex_wa,
    input   wire        ex_we,
    input   wire[31:0]  ex_wn,
    output  reg[4:0]    mm_wa,
    output  reg         mm_we,
    output  reg[31:0]   mm_wn
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            mm_wa <= 5'h0;
            mm_we <= 1'h0;
            mm_wn <= 32'h0;
        end else begin
            mm_wa <= ex_wa;
            mm_we <= ex_we;
            mm_wn <= ex_wn;
        end
    end

endmodule
