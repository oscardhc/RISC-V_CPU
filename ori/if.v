module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire    ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            pc = 32'h0;
            is = 32'h0;
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            if (pc == 0)       is <= 32'b00000111101100000110000010010011;
            else if (pc == 8)  is <= 32'b00111110011100001110001000010011;
            else if (pc == 4)  is <= 32'b00001110100100000110000100010011;
            else if (pc == 12)  is <= 32'b00011100100000000110000110010011;
            else is <= 32'h0;
            $display("pc %h is %h", pc, is);
            pc <= pc + 4;
            //if (ok == 1'b1) begin
            //    pc = pc + 4;
            //    is = dt;
            //end else begin
            //    is = 32'h0;
            //end
            // $display("cu %d in %h is %h", cu, in, is);
        end
    end
    
endmodule



