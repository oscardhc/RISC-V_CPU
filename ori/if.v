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
    reg     rcd;

    // always @ (inv) begin
    //     if (inv == 1) begin
    //         rec     = 1;
    //         invalid = 1;
    //     end else begin
    //         rec     = 0;
    //     end
    // end

    always @ (*) begin
        // $display(">> [%d] %d %d %d %d", $time, inv, rec, rcd, invalid);
        if (rst == 1'b1) begin
            pc      = 0;
            is      = 0;
            rec     = 0;
            rcd     = 0;
            invalid = 0;
        end else if (inv == 1 && rec == 0) begin 
            rec     = 1;
            pc      = pc;
            invalid = 1;
            rcd     = 1;
        end else if (inv == 0 && rec == 1) begin
            rec     = 0;
            pc      = pc;
        end else if (rcd == 0 && ok == 1'b1) begin
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
        end else begin
            pc      = pc;
            is      = is;
            rec     = rec;
            rcd     = 0;
            invalid = invalid;
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



