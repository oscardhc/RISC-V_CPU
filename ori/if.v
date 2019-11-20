module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire    ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is,

    input   wire[31:0]  id_if_pc,
    input   wire        id_if_pce
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
                $display("======== PC %h %h", pc, id_if_pc);
                if (id_if_pce == 1'b1) begin
                    pc = id_if_pc;
                end else begin
                    pc = pc + 4;
                end
                is = dt;
            end else begin
                is = 32'h0;
            end
        end
    end
    
endmodule



