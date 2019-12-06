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

    reg[1:0]    ls_ok;
    
    reg         _npce;
    reg[31:0]   _npc;
    reg[31:0]   _pc;
    
    reg[31:0]   _is;
    
    reg     _rec;
    reg     _invalid;
    /*
    reg[31:0]   is;
    always @ (posedge clk) begin
        if (ok != 0) is_out <= is;
        else is_out = 0;
    end
    */
    
    always @ (posedge clk) begin
        _pc <= pc;
        _npc <= npc;
        _npce <= npce;
        
        _is <= is;
        
        _rec <= rec;
        _invalid <= invalid;
    end

    always @ (*) begin
        if (rst == 1'b1) begin
            pc      = 0;
            is      = 0;
            rec     = 0;
            rcd     = 0;
            invalid = 0;
            ls_ok   = 0;
            npce    = 0;
            npc     = 0;
        end else if (inv == 1 && rec == 0) begin 
            rec     = 1;
            pc      = _pc;
            invalid = 1;
            rcd     = 1;
            npce    = ex_if_pce;
            npc     = ex_if_pc;
            is      = _is;
        end else if (inv == 0 && rec == 1) begin
            rec     = 0;
            invalid = 1;
            npce    = 1;
            npc     = ex_if_pc;
            pc      = _pc;
            is      = _is;
            rcd     = 1;
        end else if (rcd == 0 && ok != 1'b0) begin
            npce    = _npce;
            npc     = _npc;
            rec     = 0;
            invalid = _invalid;
            is = _is;
            pc = _pc;
            rcd     = 0;
//            pc      = _pc;
            if (ls_ok != ok) begin
                if (invalid == 1) begin
                    if (cache_hit == 0) is = {rom_rn, dt[23: 2], 2'b10};
                    else is = {dt[31: 2], 2'b10};
                    invalid = 0;
                end else begin
                    if (cache_hit == 0) is = {rom_rn, dt[23: 0]};
                    else is = dt;
                end
                if (npce == 1'b1) begin
                    pc      = npc;
                    npce    = 1'b0;
                end else begin
                    pc      = pc + 4;
                end
            end
        end else begin
            npce    = _npce;
            npc     = _npc;
            pc      = _pc;
            is      = _is;
            rec     = 0;
            invalid = _invalid;
            rcd     = 0;
        end
        ls_ok   = ok;
    end
    
endmodule



