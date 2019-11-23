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

    output  reg[4:0]    ex_mem_e,
    output  reg[31:0]   ex_mem_n
    // e 0/1: enable(0/1) + length(1/4) + wr(r/w)
);

    always @ (*) begin
        wa_o = wa;
        we_o = we;
        if (rst == 1'b1 || t == 6'h0) begin
            res = 32'h0;
            ex_mem_e = 4'h0;
        end else begin
            $display("t %b st %b sst %b", t, st, sst);
            ex_mem_e = 4'h0;
            case (t)
                7'b0110111: begin
                    res = n1;
                end
                7'b0010111: begin
                    res = n1 + n2;
                end
                7'b0010011, 7'b0110011: begin
                    case (st)
                        3'b000: begin 
                            case (sst)
                                1'b0: res = n1 + n2;
                                1'b1: res = n1 - n2;
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
                end
                7'b1100111: begin
                    case (st)
                        3'b000: res = n2;
                    endcase
                end
                7'b0100011: begin
                    res = n1 + nn;
                    ex_mem_n = n2;
                    case(st)
                        3'b000: ex_mem_e = {1'b1, 2'h0, 1'b1, 1'b0};
                        3'b001: ex_mem_e = {1'b1, 2'h1, 1'b1, 1'b0};
                        3'b010: ex_mem_e = {1'b1, 2'h3, 1'b1, 1'b0};
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
                    endcase
                end
                default: begin
                    res = 32'h0;
                end
            endcase
        end
    end

    // always @ (*) begin
    //     // $display("?????????? %d", res);
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
