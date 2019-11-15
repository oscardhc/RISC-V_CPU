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
    output  reg[31:0]   wn_o
);

    reg[31:0]   res;

    always @ (*) begin
        if (rst == 1'b1 || t == 6'h0) begin
            res = 32'h0;
        end else begin
            $display("%h t %h st %h sst %h", 7'b0010011, t, st, sst);
            case (t)
                7'b0010011: begin
                    case (st)
                        3'b000: res = n1 + n2;
                        3'b001: res = (n1 >> n2);
                        // TODO: SIGN!!!
                        3'b010: res = (n1 < n2 ? 32'h1 : 32'h0);
                        3'b011: res = (n1 < n2 ? 32'h1 : 32'h0);
                        3'b100: res = n1 ^ n2;
                        3'b110: res = n1 | n2;
                        3'b111: res = n1 & n2;
                        3'b101: begin
                            if (sst == 1'b1) begin
                                res = (n1 << n2);
                            end else begin
                                res = (n1 << n2);
                            end
                        end
                    endcase
                end
                default: begin
                    res = 32'h0;
                end
            endcase
        end
    end

    always @ (*) begin
        // $display("?????????? %d", res);
        wa_o = wa;
        we_o = we;
        case (t)
            7'b0010011: begin
                // $display("> write %d", res);
                wn_o = res;
            end
            default: begin
                wn_o = 32'h0;
            end
        endcase
    end

endmodule
