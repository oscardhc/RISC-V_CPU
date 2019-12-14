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
    input   wire        stl
);

    reg         npce;
    reg[31:0]   npc;

    reg[1:0]    ls_ok;
    
    
    /*
    reg[31:0]   is;
    always @ (posedge clk) begin
        if (ok != 0) is_out <= is;
        else is_out = 0;
    end
    */
    
    reg         used;
    
    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            npce    <= 0;
            npc     <= 0;
        end else if (ex_if_pce == 1) begin
            npce <= 1;
            npc  <= ex_if_pc;
        end else if (used == 1) begin
            npce <= 0;
            npc  <= 0;
        end
    end

    always @ (*) begin
//        $display("IF TRI %d %h", $time, dt);
        if (ok != 0) begin
            if (ls_ok != ok) begin
                ls_ok  = ok;
                if (npce == 1) begin
                    if (cache_hit == 0) is = {rom_rn, dt[23: 2], 2'b10};
                    else is = {dt[31: 2], 2'b10};
                    pc      = npc;
                    used    = 1;
                end else begin
                    if (cache_hit == 0) is = {rom_rn, dt[23: 0]};
                    else is = dt;
                    pc      = pc + 4;
                    npce    = 0;
                    used    = 0;
                end
            end
        end else begin
            ls_ok   = ok;
        end
//        ls_ok  = ok;
    end
    
endmodule



