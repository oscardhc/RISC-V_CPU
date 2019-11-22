module mm_wb (
    input   wire    rst,
    input   wire    clk,

    input   wire        mm_we,
    input   wire[4:0]   mm_wa,
    input   wire[31:0]  mm_wn,

    output  reg         wb_we,
    output  reg[4:0]    wb_wa,
    output  reg[31:0]   wb_wn,

    input   wire        stl_mm
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            wb_we <= 1'b0;
            wb_wa <= 5'h0;
            wb_wn <= 32'h0;
        end else if (stl_mm != 1'b1) begin
            wb_we <= mm_we;
            wb_wa <= mm_wa;
            wb_wn <= mm_wn;
        end
    end

endmodule
