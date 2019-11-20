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

    output  reg         stl
);

    always @ (*) begin
        if (rst == 1'b1) begin
            we_o = 1'b0;
            wa_o = 5'h0;
            wn_o = 32'h0;
            stl  = 1'b0;
        end else begin
            if (mm_mct_e != 0'b0) begin
                
            end
            we_o = we;
            wa_o = wa;
            wn_o = wn;
        end
    end

endmodule
