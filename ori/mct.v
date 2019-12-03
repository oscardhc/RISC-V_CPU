module mct (
  input	wire	  clk,
  input	wire		rst,
  input wire[31:0]  if_a,
  input	wire		mm_e,
  input	wire[31:0]	mm_a,
  input	wire[31:0]	mm_n_i,
  input	wire		mm_wr,
  input	wire[7:0]	in,
  output 	reg[31:0]	mm_n_o,
  output	reg[1:0]	if_ok,
  output	reg			mm_ok,
  output	reg[7:0]	out,
  output 	reg[31:0]	if_n,
  output	reg[31:0]	ad,
  output	reg			wr,
  input	wire[1:0]	mm_cu
);

  reg[1:0]	cu;
  reg   	  cur_mode; // 1-mem 0-inf
  reg[1:0]  nready;

  reg[31:0]	ls_if_a;
  reg			  ls_mm_e;
  reg[1:0]	es;

  reg[31:0] ca;
  reg       done;

`define ICACHE_SIZE 7
  reg[15 - `ICACHE_SIZE + 1 + 31:0] cache[2 ** `ICACHE_SIZE - 1:0];
  reg       lst_cache;

  wire[31:0] add;
  assign add = ad - 5;

  always @ (posedge clk) begin
    if (rst == 1'b1) begin
      cu    <= 0;
      if_n  <= 0;
      wr    <= 0;
      ad    <= 0;
      out   <= 0;
      if_ok <= 0;
      mm_ok <= 0;
      es    <= 2;
      ls_if_a <= 1;
      ls_mm_e <= 0;
      nready  <= 3;
      cur_mode  <= 0;
      lst_cache <= 0;
    end else begin
      if ((mm_e != ls_mm_e || if_a != ls_if_a) && (ls_if_a == 1 || if_ok != 0 || mm_ok == 1) && !(mm_e == 1 && mm_e == ls_mm_e)) begin
        if (mm_e != ls_mm_e) begin
          mm_ok <= 0;
        end
        // if (if_a != ls_if_a) begin
        // end
        ls_mm_e <= mm_e;
        if (mm_e == 1) begin
            // $display("MM SET! %d %d %d", $time, ad, mm_a);
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
              end else begin

              end
            end else begin
              nready  <= 1;
              cu      <= 0;
              es      <= mm_cu;
            end
        end else begin
          // $display("IF SET! %d %d %d", $time, ad, if_a);
          if (lst_cache == 0 && cache[if_a[`ICACHE_SIZE + 1 :2]][47 - `ICACHE_SIZE:32] == {if_a[16: `ICACHE_SIZE + 2], 1'b1}) begin
              if (if_ok == 1) if_ok <= 2;
              else            if_ok <= 1;
              if_n      <= cache[if_a[`ICACHE_SIZE + 1 :2]][31:0];
              ls_if_a   <= 0;
              ad        <= 0;
            if (cache[if_a[`ICACHE_SIZE + 1 :2]][6:0] == 7'b0000011) lst_cache <= 1;
            else lst_cache <= 0;
            // $display("%d CACHE HIT!!  %h %h", $time, if_a, cache[(if_a >> 2) & 63][31:0]);
          end else begin
            lst_cache <= 0;
            // $display("%d CACHE MISS!! %h", $time, if_a);
            if (cur_mode == 0 && ad == if_a + 2) begin
        // --------------------------------------------------
              if (nready == 1 || nready == 2) begin
                ad <= ad + 1;
                nready <= nready - 1;
              end else if (nready == 0) begin
                ad <= ad + 1;
                if (cu == es) begin
                  done <= 1;
                end
                if (done == 1) begin
                  if_ok <= 1;
                  if_n  <= ca;
                  done  <= 0;
                  cache[add[`ICACHE_SIZE + 1 :2]] <= {add[16: `ICACHE_SIZE + 2], 1'h1, ca};
                  if (ca[6:0] == 7'b0000011) lst_cache <= 1;
                end
                case (cu)
                  2'h0: begin
                    ca[ 7: 0] <= in;
                    cu <= 1;
                  end
                  2'h1: begin
                    ca[15: 8] <= in;
                    cu <= 2;
                  end
                  2'h2: begin
                    ca[23:16] <= in;
                    cu <= 3;
                  end
                  2'h3: begin
                    ca[31:24] <= in;
                    cu <= 0;
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
      if (nready == 1 || nready == 2) begin
        ad <= ad + 1;
        nready <= nready - 1;
      end else if (nready == 0) begin
        ad <= ad + 1;
        if (wr == 1) begin
          if (cu == es) begin
            mm_ok <= 1;
          end
          case (cu)
            2'h0: begin
              out <= mm_n_i[ 7: 0];
              cu <= 1;
            end
            2'h1: begin
              out <= mm_n_i[15: 8];
              cu <= 2;
            end
            2'h2: begin
              out <= mm_n_i[23:16];
              cu <= 3;
            end
            2'h3: begin
              out <= mm_n_i[31:24];
              cu <= 0;
            end
            default: begin
              cu <= 0;
            end
          endcase
        end else if (cur_mode == 1) begin
          if (cu == es) begin
            done <= 1;
          end
          if (done == 1) begin
            mm_ok <= 1;
            mm_n_o <= ca;
            done  <= 0;
          end
          case (cu)
            2'h0: begin
              ca[ 7: 0] <= in;
              cu <= 1;
            end
            2'h1: begin
              ca[15: 8] <= in;
              cu <= 2;
            end
            2'h2: begin
              ca[23:16] <= in;
              cu <= 3;
            end
            2'h3: begin
              ca[31:24] <= in;
              cu <= 0;
            end
            default: begin
              cu <= 0;
            end
          endcase
        end else begin
          if (cu == es) begin
            done <= 1;
          end
          if (done == 1) begin
            if_ok <= 1;
            if_n  <= ca;
            done  <= 0;
            cache[add[`ICACHE_SIZE + 1 :2]] <= {add[16: `ICACHE_SIZE + 2], 1'h1, ca};
            if (ca[6:0] == 7'b0000011) lst_cache <= 1;
          end
          case (cu)
            2'h0: begin
              ca[ 7: 0] <= in;
              cu <= 1;
            end
            2'h1: begin
              ca[15: 8] <= in;
              cu <= 2;
            end
            2'h2: begin
              ca[23:16] <= in;
              cu <= 3;
            end
            2'h3: begin
              ca[31:24] <= in;
              cu <= 0;
            end
            default: begin
              cu <= 0;
            end
          endcase
        end
      end
// --------------------------------------------------
      end
    end
  end

endmodule
