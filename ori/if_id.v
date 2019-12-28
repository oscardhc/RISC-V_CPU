module if_id(
    input   wire[31:0]  if_pc,
    input   wire[31:0]  if_is,
    input   wire        rst,
    input   wire        clk,
    output  reg[31:0]  id_pc,
    output  reg[31:0]  id_is,

    input   wire        stl_mm,
    input   wire[1:0]   mmif_ok
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            id_pc <= 32'h00000000;
            id_is <= 32'h00000000;
        end else if (stl_mm == 1'b0) begin
            id_pc <= if_pc;
//            $display("%h %d", if_pc, $time);
            if (mmif_ok != 1'b0) begin
                id_is <= if_is;
            end else begin
                id_is <= 32'h0;
            end
        end
    end

endmodule
