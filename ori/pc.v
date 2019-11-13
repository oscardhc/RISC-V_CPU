module pc (
    input   wire    clk,
    input   wire    rst,
    output  reg[31:0]   pc,
    output  reg         ce
);

    always @ (posedge clk) begin
        if (rst == 0'b1) begin
            ce <= 0'b0;
        end else begin
            ce <= 0'b1;
        end
    end

    always @ (posedge clk) begin
        if (ce == 0'b1) begin
            pc <= 32'h00000000;
        end else begin
            pc <= pc + 4'h4;
        end
    end

endmodule

