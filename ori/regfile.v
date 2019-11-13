module regfile(
    input   wire    rst,
    input   wire    clk,

    input   wire[4:0]   wa,
    input   wire[31:0]  wn,
    input   wire        we,

    input   wire[4:0]   ra1,
    input   wire        re1,
    output  reg[31:0]   rn1,

    input   wire[4:0]   ra2,
    input   wire        re2,
    output  reg[31:0]   rn2
);

    reg[31:0]   r[32];

    always @ (posedge clk) begin
        if (rst == 1'b0 && we == 1'b1 && wa != 5'b00000) begin
            r[wa] <= wn;
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0 && re1 == 1'b1) begin
            if (ra1 == wa) begin
                rn1 <= wn;
            end else begin
                rn1 <= r[ra1];
            end
        end else begin
            rn1 <= 32'h00000000;
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0 && re2 == 1'b1) begin
            if (ra2 == wa) begin
                rn2 <= wn;
            end else begin
                rn2 <= r[ra2];
            end
        end else begin
            rn2 <= 32'h00000000;
        end
    end

endmodule
