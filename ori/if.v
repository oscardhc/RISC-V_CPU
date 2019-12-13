module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire        ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is,

    input   wire[31:0]  ex_if_pc,
    input   wire        ex_if_pce,

    input   wire        cache_hit,
    input   wire[31:0]  cache_in,
    
    input   wire        if_almost_ok,
    output  reg         ls_load,
    
    input   wire[31:0]  ipc,
    output  reg[31:0]   opc,

    input   wire        stl
);

    reg     invalid;
    reg     rcd;

    reg         npce;
    reg[31:0]   npc;
    
    reg     ls_stl;

    always @ (posedge clk) begin
        ls_stl <= stl;
        if (rst == 1'b1) begin
            pc      <= 0;
            rcd     <= 0;
            npce    <= 0;
            npc     <= 0;
        end else if (ok == 1 || cache_hit == 1) begin
            if (npce == 1) begin
                pc <= npc;
                npce <= 0;
            end else if (ex_if_pce == 1) begin
                pc <= ex_if_pc;
            end else begin
                pc <= pc + 4;
            end
        end else if (ex_if_pce == 1) begin
            npc     <= ex_if_pc;
            npce    <= 1;
        end
    end
    
//    always @ (posedge clk) begin
//        if (is[6:0] == 7'b0000011) begin
//            ls_load = 1;
//        end else begin
//            ls_load = 0;
//        end
//    end

    always @ (*) begin
//        $display("IF TRI %d %d %d %d", $time, ok, cache_hit, ls_stl);
        if (ok == 1 || cache_hit == 1) begin
            if (npce == 1 || ex_if_pce == 1) begin
                if (cache_hit == 1) begin
                    is = {cache_in[31: 2], 2'b10};
                    opc = pc;
                end else begin
                    is = {dt[31: 2], 2'b10};
                    opc = ipc;
                end
            end else begin
                if (cache_hit == 1) begin
                    is = cache_in;
                    opc = pc;
                end else begin 
                    is = dt;
                    opc = ipc;
                end
            end
            if (is[6:0] == 7'b000011) begin
                ls_load = 1;
            end else begin
                ls_load = 0;
            end
        end else if (ls_stl == 0) begin
            is  = 0;
        end
    end

endmodule

