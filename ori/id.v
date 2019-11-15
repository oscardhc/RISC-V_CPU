module id(
    input   wire[31:0]  pc,
    input   wire[31:0]  is,
    input   wire        rst,

    input   wire[31:0]  rn1,
    input   wire[31:0]  rn2,
    output  reg         re1,
    output  reg         re2,
    output  reg[4:0]    ra1,
    output  reg[4:0]    ra2,

    output  reg[6:0]    t,
    output  reg[2:0]    st,
    output  reg         sst,

    output  reg[31:0]   out1,
    output  reg[31:0]   out2,
    output  reg[4:0]    wa,
    output  reg         we
);

    reg[31:0]   imm;
    reg         vld;

    always @ (*) begin
        if (rst == 1'b1 || is == 32'h0) begin

            re1 <= 1'b0;
            re2 <= 1'b0;
            ra1 <= 5'h0;
            ra2 <= 5'h0;
            t   <= 6'h0;
            st  <= 3'h0;
            sst <= 1'h0;
            out1    <= 32'h0;
            out2    <= 32'h0;
            wa  <= 5'h0;
            we  <= 1'h0;

        end else begin

            t <= is[6:0];
            st <= is[14:12];
            sst <= is[30:30];

            ra1 <= is[19:15];
            ra2 <= is[24:20];

            imm <= 32'h00000000;

            case (t)
                7'b0010011: begin
                    imm[11:0] <= is[31:25];
                    wa <= is[11:7];
                    case (st)
                        // OR
                        3'b110: begin
                            we  <= 1'b1;
                            re1 <= 1'b1;
                            re2 <= 1'b0;
                        end
                    endcase
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst == 1'b1) begin
            out1 <= 32'h0;
        end else if (re1 == 1'b1) begin
            out1 <= rn1;
        end else if (re1 == 1'b0) begin
            out1 <= imm;
        end else begin
            out1 <= 32'h0;
        end
    end

    always @ (*) begin
        if (rst == 1'b1) begin
            out2 <= 32'h0;
        end else if (re2 == 1'b1) begin
            out2 <= rn1;
        end else if (re2 == 1'b0) begin
            out2 <= imm;
        end else begin
            out2 <= 32'h0;
        end
    end

endmodule
