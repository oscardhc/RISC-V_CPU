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

    reg[31:0]   r[31:0];
    integer     i;
    
    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            for (i = 0; i < 32; i = i + 1) r[i] <= 0;
        end else if (we == 1'b1 && wa != 0) begin
            r[wa] <= wn;
        end
        r[0] <= 32'h0;
    end

    always @ (*) begin
        if (rst == 1'b0 && re1 == 1'b1) begin
            if (we == 1 && ra1 == wa && wa != 0) begin
                // $display("  <%d> LLLLLUCKY %d %d %d", $time, ra1, r[ra1], rn1);
                rn1 = wn;
            end else begin
                // $display("- <%d> RA %d %d %d", $time, ra1, r[ra1], rn1);
                rn1 = r[ra1];
                // $display("+ <%d> RA %d %d %d", $time, ra1, r[ra1], rn1);
            end
        end else begin
            rn1 = 32'h00000000;
        end
    end

    always @ (*) begin
        if (rst == 1'b0 && re2 == 1'b1) begin
            if (we == 1 && ra2 == wa && wa != 0) begin
                rn2 = wn;
            end else begin
                rn2 = r[ra2];
            end
        end else begin
            rn2 = 32'h00000000;
        end
    end

endmodule
