module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire[1:0]   ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is,
    output  reg[31:0]   cpc,

    input   wire[31:0]  ex_if_pc,
    input   wire        ex_if_pce,
    input   wire[31:0]  ex_if_opc,

    input   wire[7:0]   rom_rn,
    input   wire        cache_hit,
    
    output  reg         if_e,

    // output  reg         not_ok,
    input   wire        stl
);

    reg         npce;
    reg[31:0]   npc;

    reg[1:0]    ls_ok;
    reg         used;
    
    reg[31:0]   _pc;
    reg[31:0]   _is;
    reg[31:0]   _cpc;
    
    reg[31:0]   pc4;
    
    reg[63:0]   btb[31:0];
    integer     i;
    
    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            npce <= 0;
            npc  <= 0;
            for (i = 0; i < 32; i = i + 1) btb[i] <= {32'h1, 32'h0};
        end else if (ex_if_pce == 1) begin
            npce <= 1;
            npc  <= ex_if_pc;
            if (1 == 1) btb[ex_if_opc[6:2]] <= {ex_if_opc, ex_if_pc};
        end else if (used == 1) begin
            npce <= 0;
            npc  <= 0;
        end
        _pc     <= pc;
        _is     <= is;
        _cpc    <= cpc;
        ls_ok   <= ok;
        pc4     <= pc + 4;
    end

    always @ (*) begin
        if (rst == 1'b1) begin
            pc      = 0;
            is      = 0;
            used    = 0;
            if_e    = 0;
            cpc     = 0;
        end else if (ok != 0) begin
            if (ls_ok != ok) begin
                cpc     = _pc;
                if (npce == 1) begin
                    if (cache_hit == 0) is = {rom_rn, dt[23: 2], 2'b10};
                    else                is = {dt[31: 2], 2'b10};
                    pc      = npc;
                    used    = 1;
                end else begin
                    if (cache_hit == 0) is = {rom_rn, dt[23: 0]};
                    else                is = dt;
                    if (btb[pc[6:2]][63:32] == _pc) begin
                        pc     = btb[_pc[6:2]][31:0];
                    end else begin
                        pc     = pc4;
                    end
                    used    = 0;
                end
                if_e    = 1;
            end else begin
                if_e    = 0;
                pc      = _pc;
                is      = _is;
                used    = 0;
                cpc     = _cpc;
            end
        end else begin
            if_e    = 0;
            used    = 0;
            if_e    = 0;
            pc      = _pc;
            is      = _is;
            cpc     = _cpc;
        end
    end
    
endmodule



