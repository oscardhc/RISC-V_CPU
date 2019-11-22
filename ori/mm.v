module mm (
    input   wire    rst,
    input   wire    clk,

    input   wire        we,
    input   wire[4:0]   wa,
    input   wire[31:0]  wn,

    output  reg         we_o,
    output  reg[4:0]    wa_o,
    output  reg[31:0]   wn_o,

    input   wire[31:0]  mm_mem_n,
    input   wire[3:0]   mm_mem_e,

    output  reg[31:0]   mm_mct_a,
    output  reg[31:0]   mm_mct_n_i,
    input   wire[31:0]  mm_mct_n_o, 
    output  reg         mm_mct_wr,
    input   wire        mm_mct_ok,
    output  reg         mm_mct_e,
    output  reg[1:0]    mm_mct_cu,

    output  reg         stl
);

    reg[2:0]    cu;

    always @ (*) begin
        if (rst == 1'b1) begin
            we_o = 1'b0;
            wa_o = 5'h0;
            wn_o = 32'h0;
            stl  = 1'b0;
            mm_mct_n_i  = 0;
            mm_mct_a    = 0;
            mm_mct_wr   = 0;
            mm_mct_cu   = 0;
            mm_mct_e    = 0;
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            we_o = we;
            wa_o = wa;
            if (mm_mem_e[3] != 1'b0) begin
                $display("MM_MEM_E !!!!!!!!!! %b", mm_mem_e);
                case (mm_mem_e[0])
                    1'b0: begin
                        if (mm_mct_ok == 1'b1) begin
                            stl      = 1'b0;
                            mm_mct_e = 1'b0;
                            case (mm_mct_cu)
                                2'h3: wn_o = mm_mct_n_o;
                                2'h1: wn_o = {{17{mm_mct_n_o[15]}}, mm_mct_n_o[14:0]};
                                2'h0: wn_o = {{25{mm_mct_n_o[ 7]}}, mm_mct_n_o[ 6:0]};
                            endcase
                        end else begin
                            mm_mct_cu   = mm_mem_e[2:1];
                            stl         = 1'b1;
                            mm_mct_a    = wn;
                            mm_mct_wr   = 1'b0;
                            mm_mct_e    = 1'b1;
                        end
                    end
                    1'b1: begin
                        $display("<><><><><><><><><><> %d %d", mm_mem_n, wn);
                        if (mm_mct_ok == 1'b1) begin
                            stl      = 1'b0;
                            mm_mct_e = 1'b0;
                        end else begin
                            mm_mct_n_i  = mm_mem_n;
                            mm_mct_cu   = mm_mem_e[2:1];
                            stl         = 1'b1;
                            mm_mct_a    = wn;
                            mm_mct_wr   = 1'b1;
                            mm_mct_e    = 1'b1;
                        end
                    end
                endcase
            end else begin
                wn_o = wn;
            end
        end
    end

    // always @ (negedge clk) begin
    //     if (rst == 1'b0) begin
    //         we_o <= we;
    //         wa_o <= wa;
    //         if (mm_mem_e[3] != 1'b0) begin
    //             $display("MM_MEM_E !!!!!!!!!! %b", mm_mem_e);
    //             case (mm_mem_e[0])
    //                 1'b0: begin
    //                     if (mm_mct_ok == 1'b1) begin
    //                         $display("!!!!!!!!!!!!!!!!!!!! %d MM OK!", $time);
    //                         stl      <= 1'b0;
    //                         mm_mct_e <= 1'b0;
    //                         case (mm_mct_cu)
    //                             2'h0: wn_o <= mm_mct_n_o;
    //                             2'h2: wn_o <= {{17{mm_mct_n_o[15]}}, mm_mct_n_o[14:0]};
    //                             2'h3: wn_o <= {{25{mm_mct_n_o[ 7]}}, mm_mct_n_o[ 6:0]};
    //                         endcase
    //                     end else begin
    //                         $display("!!!!!!!!!!!!!!!!!!!! %d MM NOT OK!", $time);
    //                         mm_mct_cu   <= mm_mem_e[2:1];
    //                         stl         <= 1'b1;
    //                         mm_mct_a    <= wn;
    //                         mm_mct_wr   <= 1'b0;
    //                         mm_mct_e    <= 1'b1;
    //                     end
    //                 end
    //                 1'b1: begin
    //                     $display("????????????? NOT POSSIBLE!");
    //                 end
    //             endcase
    //         end else begin
    //             wn_o <= wn;
    //         end
    //     end
    // end

endmodule
