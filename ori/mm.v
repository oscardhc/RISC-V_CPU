module mm (
    input   wire    rst,
    input   wire    clk,

    input   wire        we,
    input   wire[4:0]   wa,
    input   wire[31:0]  wn,

    output  reg         we_o,
    output  reg[4:0]    wa_o,
    output  reg[31:0]   wn_o
);

    always @ (*) begin
        if (rst == 1'b1) begin
            we_o <= 1'b0;
            wa_o <= 5'h0;
            wn_o <= 32'h0;
        end else begin
            we_o <= we;
            wa_o <= wa;
            wn_o <= wn;
        end
    end

endmodule
