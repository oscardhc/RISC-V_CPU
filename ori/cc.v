module cc(
    input   wire        clk,
    input   wire        rst,

    input   wire        in_e,
    input   wire[31:0]  in_a,
    input   wire[31:0]  in_d,

    output  reg[31:0]   mct_a,
    input   wire        ls_load,

    input   wire[31:0]  ou_a,
    output  reg[31:0]   ou_d,
    output  reg         ou_hit,
    input   wire        stl
);

    `define ICACHE_SIZE 7
    integer   i;
    (*ram_style = "registers"*) reg[15 - `ICACHE_SIZE + 1 + 31:0] cache[2 ** `ICACHE_SIZE - 1:0];

    reg     ls_stl;
    always @ (posedge clk) begin
        ls_stl <= stl;
    end

    always @ (*) begin
        if (rst == 0) begin
            if (ls_load == 0 && cache[ou_a[`ICACHE_SIZE + 1: 2]][47 - `ICACHE_SIZE: 32] == {ou_a[16: `ICACHE_SIZE + 2], 1'b1}) begin
                if (ls_stl == 0) begin
                    ou_d = cache[ou_a[`ICACHE_SIZE + 1 : 2]][31: 0];
                    ou_hit = 1;
                    mct_a = 1;
//                    $display("CACHE HIT %d %h %h", $time, ou_a, ou_d);
                end else begin
                    ou_d = 0;
                    ou_hit = 0;
                    mct_a = 1;
                end
            end else begin
                ou_d = 0;
                ou_hit = 0;
                mct_a = ou_a;
            end
        end else begin
            ou_hit = 0;
            ou_d = 0;
            mct_a = 1;
        end
    end

    always @ (posedge clk) begin
        if (rst == 0) begin
            if (in_e == 1) begin
                cache[in_a[`ICACHE_SIZE + 1 :2]] <= {in_a[16: `ICACHE_SIZE + 2], 1'h1, in_d};
//                $display("CACHE WRITE %d %h %h", $time, in_a, in_d);
            end
        end else begin
            for (i = 0; i < (2 ** `ICACHE_SIZE); i = i + 1) cache[i] <= 0;
        end
    end

endmodule
