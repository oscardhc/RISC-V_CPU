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
    output  reg         we,
    output  reg[31:0]   outn,

    input   wire[4:0]   ex_wa,
    input   wire[31:0]  ex_wn,
    input   wire        ex_we,

    input   wire[4:0]   mm_wa,
    input   wire[31:0]  mm_wn,
    input   wire        mm_we,

    // output  reg[31:0]   id_if_pc,
    // output  reg         id_if_pce,
    // output  reg[31:0]   id_if_off

    output  reg[31:0]   npc
);

    reg[31:0]   imm;

    always @ (*) begin

        if (rst == 1'b1 || is == 32'h0) begin

            re1 = 1'b0;
            re2 = 1'b0;
            ra1 = 5'h0;
            ra2 = 5'h0;
            t   = 6'h0;
            st  = 3'h0;
            sst = 1'h0;
            wa  = 5'h0;
            we  = 1'h0;
            imm = 0;
            outn    = 0;
            npc = 0;

        end else begin

            t   = is[6:0];
            st  = is[14:12];
            sst = is[30:30];

            ra1 = is[19:15];
            ra2 = is[24:20];
            wa  = is[11:7];

            // out1 = 0;
            // out2 = 0;
            // $display("id %h", is);

            imm     = 0;
            outn    = 0;
            npc = 0;

            case (t)
                7'b0110111: begin
                    we  = 1'b1;
                    re1 = 1'b0;
                    re2 = 1'b0;
                    imm = {is[31:12], 12'h0};
                end
                7'b0010111: begin
                    we  = 1'b1;
                    re1 = 1'b0;
                    re2 = 1'b0;
                    imm = pc + {is[31:12], 12'h0};
                end
                7'b0110011: begin
                    we  = 1'b1;
                    re1 = 1'b1;
                    re2 = 1'b1;
                end
                // JAL
                7'b1101111: begin
                    we  = 1'b1;
                    re1 = 1'b0;
                    re2 = 1'b0;
                    imm = pc;
                    npc = pc - 32'h4 + {{12{is[31]}}, is[19:12], is[20], is[30:21], 1'b0};
                end
                // JALR
                7'b1100111: begin
                    we  = 1'b1;
                    re1 = 1'b1;
                    re2 = 1'b0;
                    imm = pc;
                    npc = {{21{is[31]}}, is[30:20]};
                end
                // BRANCH
                7'b1100011: begin
                    we  = 1'b0;
                    re1 = 1'b1;
                    re2 = 1'b1;
                    npc = pc - 32'h4 + {{20{is[31]}}, is[7], is[30:25], is[11:8], 1'b0};
                end
                7'b0100011: begin
                    we  = 1'b0;
                    re1 = 1'b1;
                    re2 = 1'b1;
                    outn = {{21{is[31]}}, is[30:25], is[11:7]};
                end
                7'b0010011: begin
                    we  = 1'b1;
                    re1 = 1'b1;
                    re2 = 1'b0;
                    case (st)
                        3'b001, 3'b101: begin
                            imm = {28'h0, is[23:20]};
                        end
                        default: begin
                            imm = {{21{is[31]}}, is[30:20]};
                        end
                    endcase
                end
                7'b0000011: begin
                    we  = 1'b0;
                    re1 = 1'b1;
                    re2 = 1'b0;
                    imm = {{21{is[31]}}, is[30:20]};
                end
                default: begin
                    we  = 1'b0;
                    re1 = 1'b0;
                    re2 = 1'b0;
                    imm = 32'h0;
                end
            endcase
        end
    end

    // always @ (out1) begin
    //     if (rst == 1'b1) begin
    //         id_if_off = 32'h0;
    //     end else if (t == 7'b1100111 && st == 3'h0)begin
    //         id_if_off = out1;
    //     end
    // end

    always @ (*) begin
        if (rst == 1'b1 || is == 32'h0) begin
            out1 = 32'h0;
        end else if (re1 == 1'b1 && ex_wa == ra1 && ex_we == 1'b1) begin
            out1 = ex_wn;
        end else if (re1 == 1'b1 && mm_wa == ra1 && mm_we == 1'b1) begin
            out1 = mm_wn;
        end else if (re1 == 1'b1) begin
            // $display("[%d] RA %d %d", $time, ra1, rn1);
            out1 = rn1;
        end else if (re1 == 1'b0) begin
            out1 = imm;
        end else begin
            out1 = 32'h0;
        end
    end

    always @ (*) begin
        if (rst == 1'b1 || is == 32'h0) begin
            out2 = 32'h0;
        end else if (re2 == 1'b1 && ex_wa == ra2 && ex_we == 1'b1) begin
            out2 = ex_wn;
        end else if (re2 == 1'b1 && mm_wa == ra2 && mm_we == 1'b1) begin
            out2 = mm_wn;
        end else if (t == 7'b0010111) begin
            out2 = pc - 4;
        end else if (re2 == 1'b1) begin
            out2 = rn2;
        end else if (re2 == 1'b0) begin
            out2 = imm;
        end else begin
            out2 = 32'h0;
        end
    end

endmodule
