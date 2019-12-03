module mct (
  input	  wire          clk,
  input	  wire          rst,
  input   wire[31:0]    if_a,
  input	  wire          mm_e,
  input	  wire[31:0]    mm_a,
  input	  wire[31:0]    mm_n_i,
  input	  wire          mm_wr,
  input	  wire[7:0]     in,
  output 	reg[31:0]     mm_n_o,
  output	reg[1:0]      if_ok,
  output	reg			      mm_ok,
  output	reg[7:0]      out,
  output 	reg[31:0]	    if_n,
  output	reg[31:0]	    ad,
  output	reg			      wr,
  output  reg           cache_hit,
  input	  wire[1:0]	    mm_cu
);

  reg[1:0]	cu;
  reg   	  cur_mode; // 1-mem 0-inf
  reg       nready;

  reg[31:0]	ls_if_a;
  reg			  ls_mm_e;
  reg[1:0]	es;

  reg[31:0] ca;

`define ICACHE_SIZE 7
  reg[15 - `ICACHE_SIZE + 1 + 31:0] cache[2 ** `ICACHE_SIZE - 1:0];
  reg       lst_cache;

  wire[31:0] add;
  assign add = ad - 4;

  always @ (posedge clk) begin
    if (rst == 1'b1) begin
      cu    <= 0;
      if_n  <= 0;
      wr    <= 0;
      ad    <= 1;
      out   <= 0;
      if_ok <= 0;
      mm_ok <= 0;
      es    <= 2;
      ls_if_a <= 1;
      ls_mm_e <= 0;
      nready  <= 3;
      cur_mode  <= 0;
      lst_cache <= 0;
      cache_hit <= 0;
    end else begin
      
        if (cur_mode == 0 && cu == es) begin
          cu    <= 0;
          cache[add[`ICACHE_SIZE + 1 :2]] <= {add[16: `ICACHE_SIZE + 2], 1'h1, in, ca[23: 0]};
          if (ca[6:0] == 7'b0000011) lst_cache <= 1;
          // $display("CACHE %h %h", add, {in, ca[23: 0]});
        end

      if ((mm_e != ls_mm_e || if_a != ls_if_a) && (ls_if_a == 1 || if_ok != 0 || mm_ok == 1) && !(mm_e == 1 && mm_e == ls_mm_e)) begin

        if (mm_e != ls_mm_e) begin
          mm_ok <= 0;
        end
        ls_mm_e <= mm_e;
        if (mm_e == 1) begin
          cur_mode  <= 1;
          ad        <= mm_a;
          wr        <= mm_wr;
          if (mm_wr == 1) begin
            nready  <= 0;
            out     <= mm_n_i[ 7: 0];
            cu      <= 1;
            es      <= mm_cu;
            if (mm_cu == 0) begin
              mm_ok <= 1;
            end
          end else begin
            nready  <= 1;
            cu      <= 0;
            es      <= mm_cu;
          end
        end else begin
          if (lst_cache == 0 && cache[if_a[`ICACHE_SIZE + 1 :2]][47 - `ICACHE_SIZE:32] == {if_a[16: `ICACHE_SIZE + 2], 1'b1}) begin
            if (if_ok == 1) if_ok <= 2;
            else            if_ok <= 1;
            if_n      <= cache[if_a[`ICACHE_SIZE + 1 :2]][31:0];
            ls_if_a   <= 1;
            ad        <= 1;
            cache_hit <= 1;
            cur_mode  <= 0;
            if (cache[if_a[`ICACHE_SIZE + 1 :2]][6:0] == 7'b0000011) lst_cache <= 1;
            else lst_cache <= 0;
            // $display("%d CACHE HIT!!  %h %h", $time, if_a, cache[if_a[`ICACHE_SIZE + 1 :2]][31:0]);
          end else begin
            lst_cache <= 0;
            cache_hit <= 0;
            // $display("%d CACHE MISS!! %h", $time, if_a);
            if (cur_mode == 0 && ad == if_a) begin
// --------------------------------------------------
      if (nready == 1) begin
        ad <= ad + 1;
        nready <= 0;
        if (wr == 0 && cur_mode == 1 && es == 0) begin
          mm_ok <= 1;
        end 
      end else begin
        ad <= ad + 1;
          case (cu)
            0: begin
              ca[ 7: 0] <= in;
              cu <= 1;
            end
            1: begin
              ca[15: 8] <= in;
              cu <= 2;
            end
            2: begin
              ca[23:16] <= in;
              if_n  <= {8'h0, in, ca[15: 0]};
              cu <= 3;
              if_ok <= 1;
            end
            3: begin
              ca[31:24] <= in;
              cu <= 0;
              cache[add[`ICACHE_SIZE + 1 :2]] <= {add[16: `ICACHE_SIZE + 2], 1'h1, in, ca[23: 0]};
              if (ca[6:0] == 7'b0000011) lst_cache <= 1;
            end
            default: begin
              cu <= 0;
            end
          endcase
      end
// --------------------------------------------------
            end else begin
              ad      <= if_a;
              nready  <= 1;
              cu      <= 0;
            end
            if_ok     <= 0;
            cur_mode  <= 0;
            wr        <= 0;
            es        <= 3;
            ls_if_a   <= if_a;
          end
        end
      end else begin
// --------------------------------------------------
      if (nready == 1) begin
        ad <= ad + 1;
        nready <= 0;
        if (wr == 0 && cur_mode == 1 && es == 0) begin
          mm_ok <= 1;
        end 
      end else begin
        ad <= ad + 1;
        if (wr == 1) begin
          case (es)
            0: begin
              case (cu)
                0: begin
                  mm_ok <= 1;
                  cu <= 0;
                end
                default: cu <= 0;
              endcase
            end
            1: begin
              case (cu)
                0: begin
                  cu    <= 1;
                end
                1: begin
                  cu    <= 0;
                  mm_ok <= 1;
                end
                default: begin
                  cu    <= 0;
                end
              endcase
            end
            3: begin
              case (cu)
                0: begin
                  cu    <= 1;
                end
                1: begin
                  cu    <= 2;
                end
                2: begin
                  cu    <= 3;
                end
                3: begin
                  mm_ok <= 1;
                  cu    <= 0;
                end
                default: begin
                  cu    <= 0;
                end
              endcase
            end
          endcase
          // if (cu == es) begin
          //   mm_ok <= 1;
          //   cu <= 0;
          // end else begin
          //   cu <= cu + 1;
          // end
          case (cu)
            2'h0: out <= mm_n_i[ 7: 0];
            2'h1: out <= mm_n_i[15: 8];
            2'h2: out <= mm_n_i[23:16];
            2'h3: out <= mm_n_i[31:24];
            default: out <= 0;
          endcase
        end else if (cur_mode == 1) begin
          case (es)
            0: begin
              case (cu)
                0: begin
                  cu <= 0;
                end
                default: cu <= 0;
              endcase
            end
            1: begin
              case (cu)
                0: begin
                  cu    <= 1;
                  mm_n_o <= {24'h0, in};
                  mm_ok <= 1;
                end
                1: begin
                  cu    <= 0;
                end
                default: begin
                  cu    <= 0;
                end
              endcase
            end
            3: begin
              case (cu)
                0: begin
                  cu    <= 1;
                end
                1: begin
                  cu    <= 2;
                end
                2: begin
                  cu    <= 3;
                  mm_n_o <= { 8'h0, in, ca[15:0]};
                  mm_ok <= 1;
                end
                3: begin
                  cu    <= 0;
                end
                default: begin
                  cu    <= 0;
                end
              endcase
            end
          endcase

          // if (cu == es) begin
          //   cu    <= 0;
          // end else begin
          //   if (cu + 1 == es) begin
          //     case(es)
          //       3: mm_n_o <= { 8'h0, in, ca[15:0]};
          //       1: mm_n_o <= {24'h0, in};
          //       default: mm_n_o <= 0;
          //     endcase
          //     mm_ok   <= 1;
          //   end
          //   cu <= cu + 1;
          // end

          case (cu)
            2'h0: ca[ 7: 0] <= in;
            2'h1: ca[15: 8] <= in;
            2'h2: ca[23:16] <= in;
            2'h3: ca[31:24] <= in;
          endcase
        end else begin

          case (cu)
            0: begin
              ca[ 7: 0] <= in;
              cu <= 1;
            end
            1: begin
              ca[15: 8] <= in;
              cu <= 2;
            end
            2: begin
              ca[23:16] <= in;
              if_n  <= {8'h0, in, ca[15: 0]};
              cu <= 3;
              if_ok <= 1;
            end
            3: begin
              ca[31:24] <= in;
              cu <= 0;
              // cache[add[`ICACHE_SIZE + 1 :2]] <= {add[16: `ICACHE_SIZE + 2], 1'h1, in, ca[23: 0]};
              if (ca[6:0] == 7'b0000011) lst_cache <= 1;
            end
            default: begin
              cu <= 0;
            end
          endcase

          // if (cu == es) begin
          //   cu    <= 0;
          //   cache[add[`ICACHE_SIZE + 1 :2]] <= {add[16: `ICACHE_SIZE + 2], 1'h1, in, ca[23: 0]};
          //   if (ca[6:0] == 7'b0000011) lst_cache <= 1;
          //   // $display("CACHE %h %h", add, {in, ca[23: 0]});
          // end else begin
          //   if (cu + 1 == es) begin
          //     if_n  <= {8'h0, in, ca[15: 0]};
          //     if_ok <= 1;
          //   end
          //   cu <= cu + 1;
          // end
          // case (cu)
          //   2'h0: ca[ 7: 0] <= in;
          //   2'h1: ca[15: 8] <= in;
          //   2'h2: ca[23:16] <= in;
          //   2'h3: ca[31:24] <= in;
          // endcase
        end
      end
// --------------------------------------------------
      end
    end
  end

endmodule
