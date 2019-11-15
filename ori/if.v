module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire    ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is
);

    always @ (*) begin
        if (rst == 1'b1) begin
            pc = 32'h0;
            is = 32'h0;
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            if (ok == 1'b1) begin
                pc = pc + 4;
                is = dt;
            end else begin
                is = 32'h0;
            end
            // $display("cu %d in %h is %h", cu, in, is);
        end
    end
    
endmodule



