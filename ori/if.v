module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire    ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is,

    input   wire[31:0]  ex_if_pc,
    input   wire        ex_if_pce,

    output  reg         not_ok,
    input   wire        inv,
    output  reg         rec,
    input   wire        stl
);

    reg     invalid;

    always @ (inv) begin
        if (inv == 1) begin
            rec     = 1;
            invalid = 1;
        end else begin
            rec     = 0;
        end
    end

    always @ (*) begin
        if (rst == 1'b1) begin
            pc = 32'h0;
            is = 32'h0;
        end else begin
            if (ok == 1'b1) begin
                if (invalid == 1) begin
                    is      = {dt[31:2], 2'b10};
                    invalid = 0;
                end else begin
                    is = dt;
                end
                if (ex_if_pce == 1'b1) begin
                    pc = ex_if_pc;
                end else begin
                    pc = pc + 4;
                end
            end
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            if (ok == 1'b1) begin
                not_ok <= 0;
            end else if (stl == 0) begin
                not_ok <= 1;
            end
        end
    end
    
endmodule



