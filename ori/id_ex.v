module id_ex (
    input   wire    clk,
    input   wire    rst,
    
    input   wire[6:0]   id_t,
    input   wire[2:0]   id_st,
    input   wire        id_sst,

    input   wire[31:0]  id_n1,
    input   wire[31:0]  id_n2,
    input   wire[4:0]   id_wa,
    input   wire        id_we,
    input   wire[31:0]  id_nn,

    output  reg[6:0]    ex_t,
    output  reg[2:0]    ex_st,
    output  reg         ex_sst,

    output  reg[31:0]   ex_n1,
    output  reg[31:0]   ex_n2,
    output  reg[4:0]    ex_wa,
    output  reg         ex_we,
    output  reg[31:0]   ex_nn,

    // input   wire[31:0]  id_if_off_i,
    // input   wire[31:0]  id_if_pc_i,
    // input   wire        id_if_pce_i,

    // output  reg[31:0]   id_if_pc_o,
    // output  reg         id_if_pce_o,

    input   wire[31:0]  id_npc,
    output  reg[31:0]   ex_npc,
    
    input   wire        next_invalid,

    input   wire        stl_mm
);

    reg         invalid;

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            ex_t    <= 7'h0;
            ex_st   <= 3'h0;
            ex_sst  <= 1'h0;
            ex_n1   <= 32'h0;
            ex_n2   <= 32'h0;
            ex_wa   <= 5'h0;
            ex_we   <= 1'h0;
            ex_npc  <= 0;
            invalid <= 0;
        end else if (stl_mm != 1'b1) begin
            // $display("[%d] - id %d %d", $time, id_n1, id_n2);
            if (next_invalid == 0 && invalid == 0) begin
                ex_t    <= id_t;
                ex_st   <= id_st;
                ex_sst  <= id_sst;
                ex_n1   <= id_n1;
                ex_n2   <= id_n2;
                ex_wa   <= id_wa;
                ex_we   <= id_we;
                ex_nn   <= id_nn;
                ex_npc  <= id_npc;
            end else begin
                ex_t    <= 0;
                if (next_invalid == 1) begin
                    invalid <= 1;
                end else if (id_t[1:0] == 2'b10) begin
                    invalid <= 0;
                end
            end
        end
    end

    // always @ (negedge clk) begin
    //     if (rst == 1'b1) begin
    //         id_if_pc_o  <= 32'h0;
    //         id_if_pce_o <= 1'b0;
    //     end else if (stl_mm != 1'b1) begin
    //         id_if_pc_o  <= id_if_pc_i + id_if_off_i;
    //         id_if_pc_o[0] <= 1'b0;
    //         id_if_pce_o <= id_if_pce_i;
    //     end
    // end

endmodule
