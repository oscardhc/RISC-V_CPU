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

    output  reg[6:0]    ex_t,
    output  reg[2:0]    ex_st,
    output  reg         ex_sst,

    output  reg[31:0]   ex_n1,
    output  reg[31:0]   ex_n2,
    output  reg[4:0]    ex_wa,
    output  reg         ex_we
);

    always @ (posedge clk) begin
        if (rst == 1'b1 || id_t == 7'h0) begin
            ex_t    <= 7'h0;
            ex_st   <= 3'h0;
            ex_sst  <= 1'h0;
            ex_n1   <= 32'h0;
            ex_n2   <= 32'h0;
            ex_wa   <= 5'h0;
            ex_we   <= 1'h0;
        end else begin
            $display("[%d] - id %d %d", $time, id_n1, id_n2);
            ex_t    <= id_t;
            ex_st   <= id_st;
            ex_sst  <= id_sst;
            ex_n1   <= id_n1;
            ex_n2   <= id_n2;
            ex_wa   <= id_wa;
            ex_we   <= id_we;
        end
    end

endmodule
