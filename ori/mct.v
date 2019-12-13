module mct (
    input       wire          clk,
    input       wire          rst,
    input       wire[31:0]    if_a,
    input       wire          mm_e,
    input       wire[31:0]    mm_a,
    input       wire[31:0]    mm_n_i,
    input       wire          mm_wr,
    input       wire[7:0]     in,
    output      reg[31:0]     mm_n_o,
    output      reg           if_ok,
    output      reg			  mm_ok,
    output      reg[7:0]      out,
    output      reg[31:0]	  if_n,
    output      reg[31:0]	  ad,
    output      reg			  wr,
    input       wire[1:0]     mm_cu,
    output      reg           if_almost_ok,
    output      reg[31:0]     ca_a
);

    reg[1:0]	cu;
    reg         cur_mode; // 1-mem 0-inf
    reg         nready;
    reg         free;

    reg         ls_if_e;
    reg[31:0]	ls_if_a;
    reg			ls_mm_e;
    reg[1:0]	es;

    reg[31:0]   ca;
    reg         done;

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            cu    <= 0;
            if_n  <= 0;
            wr    <= 0;
            ad    <= 0;
            out   <= 0;
            if_ok <= 0;
            mm_ok <= 0;
            es    <= 2;
            ls_if_a <= 1;
            ls_mm_e <= 0;
            nready  <= 3;
            cur_mode  <= 0;
            free    <= 1;
        end else begin
            mm_ok <= 0;
            if_ok <= 0;
            if (((mm_e == 1) || (if_a != 1 && if_a != ls_if_a)) && (free == 1)) begin
                ls_mm_e <= mm_e;
                done    <= 0;
                if (mm_e == 1) begin
                    cur_mode  <= 1;
                    ad        <= mm_a;
                    wr        <= mm_wr;
                    if (mm_wr == 1) begin
                        nready  <= 0;
                        out     <= mm_n_i[ 7: 0];
                        cu      <= 1;
                        es      <= mm_cu;
                        if (mm_cu == 0) begin
                            mm_ok <= 1;
                            free  <= 1;
                        end else begin
                            free  <= 0;
                        end
                    end else begin
                        free    <= 0;
                        nready  <= 1;
                        cu      <= 0;
                        es      <= mm_cu;
                    end
                end else begin
//                     $display("%d CACHE MISS!! %h", $time, if_a);
                    free <= 0;
                    if (cur_mode == 0 && ad == if_a + 1) begin
                        ad <= ad + 1;
                        ca[ 7: 0] <= in;
                        cu <= 1;
                    end else begin
                        ad      <= if_a;
                        nready  <= 1;
                        cu      <= 0;
                    end
                    if_ok     <= 0;
                    cur_mode  <= 0;
                    wr        <= 0;
                    es        <= 3;
                    ls_if_a   <= if_a;
                end
            end else if (done == 0) begin
                if (nready == 1) begin
                    ad <= ad + 1;
                    nready <= 0;
                end else begin
                    ad <= ad + 1;
                    if (wr == 1) begin
                        case (es)
                            0: begin
                                case (cu)
                                    1: begin
                                        cu      <= 0;
                                        done    <= 1;
                                        wr      <= 0;
                                    end
                                    default: cu <= 0;
                                endcase
                            end
                            1: begin
                                case (cu)
                                    0: begin
                                        cu      <= 0;
                                        done    <= 1;
                                        wr      <= 0;
                                    end
                                    1: begin
                                        cu    <= 0;
                                        mm_ok <= 1;
                                        free  <= 1;
                                    end
                                    default: begin
                                        cu    <= 0;
                                    end
                                endcase
                            end
                            3: begin
                                case (cu)
                                    0: begin
                                        cu      <= 0;
                                        done    <= 1;
                                        wr      <= 0;
                                    end
                                    1: begin
                                        cu    <= 2;
                                    end
                                    2: begin
                                        cu    <= 3;
                                    end
                                    3: begin
                                        mm_ok <= 1;
                                        free  <= 1;
                                        cu    <= 0;
                                    end
                                    default: begin
                                        cu    <= 0;
                                    end
                                endcase
                            end
                        endcase
                        case (cu)
                            2'h0: out <= mm_n_i[ 7: 0];
                            2'h1: out <= mm_n_i[15: 8];
                            2'h2: out <= mm_n_i[23:16];
                            2'h3: out <= mm_n_i[31:24];
                            default: out <= 0;
                        endcase
                    end else if (cur_mode == 1) begin
                        case (es)
                            0: begin
                                case (cu)
                                    0: begin
                                        cu <= 0;
                                        mm_n_o  <= {24'h0, in};
                                        mm_ok   <= 1;
                                        free    <= 1;
                                        done    <= 1;
                                    end
                                    default: cu <= 0;
                                endcase
                            end
                            1: begin
                                case (cu)
                                    0: begin
                                        cu    <= 1;
                                    end
                                    1: begin
                                        cu    <= 0;
                                        mm_n_o  <= {16'h0, in, ca[7:0]};
                                        mm_ok   <= 1;
                                        free    <= 1;
                                        done    <= 1;
                                    end
                                    default: begin
                                        cu    <= 0;
                                    end
                                endcase
                            end
                            3: begin
                                case (cu)
                                    0: begin
                                        cu    <= 1;
                                    end
                                    1: begin
                                        cu    <= 2;
                                    end
                                    2: begin
                                        cu    <= 3;
                                    end
                                    3: begin
                                        cu    <= 0;
                                        free  <= 1;
                                        mm_n_o <= {in, ca[23:0]};
                                        mm_ok <= 1;
                                        done    <= 1;
                                    end
                                    default: begin
                                        cu    <= 0;
                                    end
                                endcase
                            end
                        endcase

                        case (cu)
                            2'h0: ca[ 7: 0] <= in;
                            2'h1: ca[15: 8] <= in;
                            2'h2: ca[23:16] <= in;
                            2'h3: ca[31:24] <= in;
                        endcase
                    end else begin

                        case (cu)
                            0: begin
                                ca[ 7: 0] <= in;
                                cu <= 1;
                            end
                            1: begin
                                ca[15: 8] <= in;
                                cu <= 2;
                            end
                            2: begin
                                ca[23:16] <= in;
                                cu <= 3;
                            end
                            3: begin
                                if_n  <= {in, ca[23: 0]};
                                ca[31:24] <= in;
                                cu <= 0;
                                free <= 1;
                                if (free == 0) if_ok <= 1;
                                ca_a <= ad - 4;
                            end
                            default: begin
                                cu <= 0;
                            end
                        endcase
                    end
                end
            end else begin
                wr = 0;
            end
        end
    end

endmodule
