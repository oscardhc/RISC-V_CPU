module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire[1:0]   ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is,

    input   wire[31:0]  ex_if_pc,
    input   wire        ex_if_pce,

    input   wire[7:0]   rom_rn,
    input   wire        cache_hit,

    // output  reg         not_ok,
    input   wire        inv,
    output  reg         rec,
    input   wire        stl
);

    reg     invalid;
    reg     rcd;

    reg         npce;
    reg[31:0]   npc;

    // always @ (inv) begin
    //     if (inv == 1) begin
    //         rec     = 1;
    //         invalid = 1;
    //     end else begin
    //         rec     = 0;
    //     end
    // end

    always @ (rst, ok, inv) begin
        // $display(">> [%d] %d %d %d %d | %d %d %d", $time, inv, rec, rcd, invalid, ok, npc, npce);
        if (rst == 1'b1) begin
            pc      = 0;
            is      = 0;
            rec     = 0;
            rcd     = 0;
            invalid = 0;
        end else if (inv == 1 && rec == 0) begin 
            // $display("%d *** INV... %d %d", $time, ex_if_pce, ex_if_pc);
            rec     = 1;
            pc      = pc;
            invalid = 1;
            rcd     = 1;
            npce    = ex_if_pce;
            npc     = ex_if_pc;
        end else if (inv == 0 && rec == 1) begin
            rec     = 0;
            pc      = pc;
        end else if (rcd == 0 && ok != 1'b0) begin
            if (invalid == 1) begin
                if (cache_hit == 0) is = {rom_rn, dt[23: 2], 2'b10};
                else is = {dt[31: 2], 2'b10};
                invalid = 0;
            end else begin
                // $display("%h %d", pc, $time);
                if (cache_hit == 0) is = {rom_rn, dt[23: 0]};
                else is = dt;
            end
            if (npce == 1'b1) begin
                // $display("[%d] JUMP... %d", $time, npc);
                pc      = npc;
                npce    = 1'b0;
            end else begin
                pc      = pc + 4;
            end
        end else begin
            pc      = pc;
            is      = is;
            rec     = rec;
            invalid = invalid;
        end
        rcd     = 0;
    end

    // always @ (posedge clk) begin
    //     if (rst == 1'b0) begin
    //         if (ok == 1'b1) begin
    //             not_ok <= 0;
    //         end else if (stl == 0) begin
    //             not_ok <= 1;
    //         end
    //     end
    // end
    
endmodule



