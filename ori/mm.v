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
    input   wire[4:0]   mm_mem_e,

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
    reg         ls_ok;

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
            ls_ok = 0;
        end else begin

            mm_mct_cu   = mm_mem_e[3:2];
            mm_mct_a    = wn;
            mm_mct_wr   = 1'b0;
            mm_mct_n_i  = mm_mem_n;

            we_o = we;
            wa_o = wa;
//            wn_o = wn;
            stl  = 0;
            if (mm_mem_e[4] != 1'b0) begin
//                $display("MM_MEM_E !!!!!!!!!! %d %b %b", $time, mm_mem_e, mm_mct_ok);
                ls_ok       = mm_mct_ok;
                mm_mct_e    = 1'b1;
                case (mm_mem_e[1])
                    1'b0: begin
                        if (mm_mct_ok == 1'b1) begin
                            stl      = 1'b0;
                            mm_mct_e = 1'b0;
                            wn_o     = 0;
                            case (mm_mct_cu)
                                2'h3: wn_o = mm_mct_n_o;
                                2'h1: begin
                                    if (mm_mem_e[0] == 1'b1) wn_o = {16'h0, mm_mct_n_o[15:0]};
                                    else wn_o = {{17{mm_mct_n_o[7]}}, mm_mct_n_o[15:0]};
                                end 
                                2'h0: begin
                                    if (mm_mem_e[0] == 1'b1) wn_o = {24'h0, mm_mct_n_o[7:0]};
                                    else wn_o = {{25{mm_mct_n_o[ 7]}}, mm_mct_n_o[6:0]};
                                end
                            endcase
                        end else begin
                            mm_mct_cu   = mm_mem_e[3:2];
                            stl         = 1'b1;
                            mm_mct_a    = wn;
                            mm_mct_wr   = 1'b0;
                            mm_mct_e    = 1'b1;
                        end
                    end
                    default: begin
                        // $display("<><><><><><><><><><> %d %d", mm_mem_n, wn);
                        if (mm_mct_ok == 1'b1) begin
                            stl      = 1'b0;
                            mm_mct_e = 1'b0;
                        end else begin
                            mm_mct_n_i  = mm_mem_n;
                            mm_mct_cu   = mm_mem_e[3:2];
                            stl         = 1'b1;
                            mm_mct_a    = wn;
                            mm_mct_wr   = 1'b1;
                            mm_mct_e    = 1'b1;
                        end
                        wn_o = 0;
                    end
                endcase
            end else begin
                wn_o = wn;
                mm_mct_e    = 1'b0;
            end
        end
    end

endmodule
