module inf (
    input   wire    clk,
    input   wire    rst,
    input   wire    ok,
    input   wire[31:0]  dt,
    output  reg[31:0]   pc,
    output  reg[31:0]   is,

    input   wire[31:0]  id_if_pc,
    input   wire        id_if_pce,

    output  reg         not_ok,
    input   wire        stl
);

    always @ (*) begin
        if (rst == 1'b1) begin
            pc = 32'h0;
            is = 32'h0;
        end
    end

    // always @ (posedge clk) begin
    //     was_taken <= is_taken;
    //     if (rst == 1'b0) begin
    //         if (ok == 1'b1) begin
    //             is  <= dt;
    //             $display("======== PC %h %h %h %h", pc, id_if_pc, dt, is);
    //             if (id_if_pce == 1'b1) begin
    //                 pc <= id_if_pc;
    //             end else begin
    //                 pc <= pc + 4;
    //             end
    //             $display("-------- PC %h %h %h %h", pc, id_if_pc, dt, is);
    //         end else if (is_taken == 1) begin
    //         end
    //     end
    // end

    always @ (*) begin
        if (rst == 1'b0) begin
            if (ok == 1'b1) begin
                is      = dt;
                not_ok  = 1'b0;
                $display("======== PC %h %h %h %h", pc, id_if_pc, dt, is);
                if (id_if_pce == 1'b1) begin
                    pc = id_if_pc;
                end else begin
                    pc = pc + 4;
                end
                $display("-------- PC %h %h %h %h", pc, id_if_pc, dt, is);
            end else if (stl == 1'b0) begin
                not_ok = 1'b1;
            end
        end
    end
    
endmodule



