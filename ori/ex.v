module ex (
    input   wire    rst,
    input   wire    clk,
    input   wire[6:0]   t,
    input   wire[2:0]   st,
    input   wire[0:0]   sst,
    input   wire[31:0]  n1,
    input   wire[31:0]  n2,
    input   wire[4:0]   wa,
    input   wire        we,

    output  reg[4:0]    wa_o,
    output  reg         we_o,
    output  reg[31:0]   res,
    input   wire[31:0]  nn,

    input   wire[31:0]  npc,

    output  reg[31:0]   ex_if_pc,
    output  reg         ex_if_pce,
    
    output  reg         next_invalid,

    output  reg[4:0]    ex_mem_e,
    output  reg[31:0]   ex_mem_n
    // e 0/1: enable(0/1) + length(1/4) + wr(r/w)
);

    

    `define JUMP begin \
        ex_if_pce   = 1'b1; \
        ex_if_pc    = npc; \
        next_invalid = 1; \
    end

    reg[4:0]    _wa_o;
    reg         _we_o;

    always @ (*) begin
    
            ex_mem_e = 4'h0;
            wa_o = 0;
            we_o = 0;

            if (rst == 1'b1) begin
                res         = 0;
                ex_if_pc    = 0;
                ex_if_pce   = 0;
                ex_mem_n    = 0;
                next_invalid    = 0;
            end else begin
                res         = 0;
                ex_mem_n    = 0;
                    wa_o        = wa;
                    we_o        = we;
                    ex_if_pc    = 0;
                    ex_if_pce   = 0;
                    next_invalid = 0;
                    case (t)
                        7'b0110111: begin
                            next_invalid = 0;
                            res = n2;
                        end
                        7'b0010111: begin
                            next_invalid = 0;
                            res = n2;
                        end
                        7'b0010011, 7'b0110011: begin
                            next_invalid = 0;
                            case (st)
                                3'b000: begin 
                                    case (t)
                                        7'b0010011:
                                            res = n1 + n2;
                                        7'b0110011:
                                            case (sst)
                                                1'b0: res = n1 + n2;
                                                1'b1: res = n1 - n2;
                                            endcase
                                        default: res = 32'h0;
                                    endcase
                                end
                                3'b001: res = (n1 << n2);
                                3'b010: res = ($signed(n1) < $signed(n2) ? 32'h1 : 32'h0);
                                3'b011: res = (n1  < n2  ? 32'h1 : 32'h0);
                                3'b100: res = n1 ^ n2;
                                3'b110: res = n1 | n2;
                                3'b111: res = n1 & n2;
                                3'b101: begin
                                    case (sst)
                                        1'b0: res = n1 >>  n2;
                                        1'b1: res = n1 >>> n2;
                                    endcase
                                end
                            endcase
                        end
                        7'b1101111: begin
                            res = n2;
                            `JUMP
                        end
                        7'b1100111: begin
                            res = n2;
                            ex_if_pce   = 1'b1;
                            ex_if_pc    = npc + n1;
                            next_invalid = 1;
                        end
                        7'b1100011: begin
                            res = 0;
                            case (st)
                                3'b000: if ( (n1 == n2)) `JUMP
                                3'b001: if (!(n1 == n2)) `JUMP
                                3'b100: if ( ($signed(n1) < $signed(n2))) `JUMP
                                3'b101: if (!($signed(n1) < $signed(n2))) `JUMP
                                3'b110: if ( (n1 < n2)) `JUMP
                                3'b111: if (!(n1 < n2)) `JUMP
                                default: next_invalid = 0;
                            endcase
                        end
                        7'b0100011: begin
                            next_invalid = 0;
                            res = n1 + nn;
                            ex_mem_n = n2;
                            case(st)
                                3'b000: ex_mem_e = {1'b1, 2'h0, 1'b1, 1'b0};
                                3'b001: ex_mem_e = {1'b1, 2'h1, 1'b1, 1'b0};
                                3'b010: ex_mem_e = {1'b1, 2'h3, 1'b1, 1'b0};
                                default: ex_mem_e = 5'h0;
                            endcase
                        end
                        7'b0000011: begin
                            next_invalid = 0;
                            res = n1 + n2;
                            ex_mem_n = 32'h0;
                            case(st)
                                3'b000: ex_mem_e = {1'b1, 2'h0, 1'b0, 1'b0};
                                3'b001: ex_mem_e = {1'b1, 2'h1, 1'b0, 1'b0};
                                3'b010: ex_mem_e = {1'b1, 2'h3, 1'b0, 1'b0};
                                3'b100: ex_mem_e = {1'b1, 2'h0, 1'b0, 1'b1};
                                3'b101: ex_mem_e = {1'b1, 2'h1, 1'b0, 1'b1};
                                default: ex_mem_e = 5'h0;
                            endcase
                        end
                        default: begin
                            next_invalid = 0;
                            res = 32'h0;
                        end
                    endcase
            end
    end

endmodule
