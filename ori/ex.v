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

    output  reg[4:0]    ex_mem_e,
    output  reg[31:0]   ex_mem_n,

    output  reg         inv_o,
    input   wire        rec_i
    // e 0/1: enable(0/1) + length(1/4) + wr(r/w)
);

    reg     next_invalid;

    always @ (rec_i) begin
        if (rec_i == 1) begin
            inv_o = 0;
        end
    end

    `define JUMP begin \
        ex_if_pce   = 1'b1; \
        ex_if_pc    = npc; \
        next_invalid = 1; \
        inv_o = 1; \
    end

    always @ (*) begin
        res = 32'h0;
        ex_mem_e = 4'h0;
        wa_o = 0;
        we_o = 0;
        if (rst == 1'b1) begin
            res = 32'h0;
            // ex_mem_e = 4'h0;
            ex_if_pce = 1'b0;
            // wa_o = 0;
            // we_o = 0;
        end else if (t != 0) begin
            // wa_o = 0;
            // we_o = 0;
            // ex_mem_e = 4'h0;
            // $display("%d t %b st %b sst %b", $time, t, st, sst);
            if (next_invalid > 0) begin
                ex_if_pce = 1'b0;
                if (t[0] == 0) begin
                    next_invalid = 0;
                end
            end else begin
                ex_if_pce = 1'b0;
                wa_o = wa;
                we_o = we;
                case (t)
                    7'b0110111: begin
                        res = n2;
                    end
                    7'b0010111: begin
                        res = n2;
                    end
                    7'b0010011, 7'b0110011: begin
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
                            // TODO: SIGN!!!
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
                        `JUMP
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
                        endcase
                    end
                    7'b0100011: begin
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
                        res = 32'h0;
                    end
                endcase
            end
        end
    end

    // always @ (*) begin
    //     // // $display("?????????? %d", res);
    //     wa_o = wa;
    //     we_o = we;
    //     case (t)
    //         7'b0010011: wn_o = res;
    //         7'b1101111: wn_o = res;
    //         7'b1100111: wn_o = res;
    //         7'b0100011: wn_o = res;
    //         7'b0000011: wn_o = res;
    //         default: begin
    //             wn_o = 32'h0;
    //         end
    //     endcase
    // end

endmodule
