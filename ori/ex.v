module ex (
    input   wire    rst,
    input   wire    clk,
    input   wire[6:0]   t,
    input   wire[3:0]   st,
    input   wire[0:0]   sst,
    input   wire[32:0]  n1,
    input   wire[32:0]  n2,
    input   wire[4:0]   wa,
    input   wire        we,

    output  reg[4:0]    wa_o,
    output  reg[1:0]    we_o,
    output  reg[31:0]   wn
);

    reg[31:0]   res;

    always @ (*) begin
        if (rst == 1'b1) begin
        end else begin
            case (t)
                7'b0010011: begin
                    case (st)
                        // OR
                        3'b110: begin
                            res <= n1 | n2;
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
        wa_o <= wa;
        we_o <= we;
        case (t)
            7'b0010011: begin
                wn <= res;
            end
            default: begin
                wn <= 32'h0;
            end
        endcase
    end

endmodule
