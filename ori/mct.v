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
  output	reg			if_ok,
  output	reg			mm_ok,
  output	reg[7:0]	out,
  output 	reg[31:0]	if_n,
  output	reg[31:0]	ad,
  output	reg			wr,
  input	wire[1:0]	mm_cu		
);

  reg[1:0]	cu;
  reg[1:0]	cur_mode; // 1-mem 0-inf
  reg			nready;

  reg[31:0]	ls_if_a;
  reg			ls_mm_e;
  reg[1:0]	es;

  always @ (negedge clk) begin 
    if (rst == 1'b1) begin
      cu <= 2'h0;
      if_n <= 32'h0;
      wr <= 1'b0;
      ad <= 32'h0;
      out <= 8'h0;
      if_ok <= 1'h0;
      mm_ok <= 1'h0;
      cur_mode <= 1'b0;
      ls_if_a <= 32'h0;
      ls_mm_e <= 1'h0;
      nready <= 1'h0;
      es <= 2'h3;
    end
  end

  always @ (posedge clk) begin
    if (rst == 1'b0) begin
      if (mm_e != ls_mm_e || if_a != ls_if_a) begin
        if (if_ok == 1'b1 || mm_ok == 1'b1) begin
          // // $display("MAYBE CHANGE %b", mm_e);
          if (mm_e == 1'b1) begin
            cur_mode <= 1;
            if (ad != mm_a) begin
              ad <= mm_a;
              nready <= 1;
            end
            wr <= mm_wr;
            if (mm_wr == 1) begin
              if (mm_cu == 0) begin
                mm_ok <= 1;
              end
              out <= mm_n_i[ 7: 0];
              cu <= 1;
            end else begin
              cu <= 0;
            end
            es <= mm_cu;
            ls_mm_e <= mm_e;
          end else begin
            cur_mode <= 0;
            if (ad != if_a) begin
              ad <= if_a;
              nready <= 1;
            end
            wr <= 0;
            cu <= 0;
            es <= 3;
            ls_if_a <= if_a;
          end
          if (mm_e != ls_mm_e && !(mm_e == 1 && mm_cu == 0)) begin
            mm_ok <= 1'b0;
          end 
          if (if_a != ls_if_a) begin
            if_ok <= 1'b0;
          end
        end
      end
    end else ad <= 32'h0;
  end

  always @ (negedge clk) begin
    if (rst == 1'b0) begin
      // $display("\t\t\t MCT ad %h", ad);
      if (nready == 1) begin
        nready <= 0;
      end else if (cur_mode == 1'b1) begin
        // mm_ok <= 1'b0;
        ad <= ad + 1;
        if (mm_wr == 1'b0) begin
          if (cu == es) begin
            mm_ok <= 1'b1;
          end
          case (cu)
            2'h0: begin
              mm_n_o[ 7: 0] <= in;
              cu <= 1;
            end
            2'h1: begin
              mm_n_o[15: 8] <= in;
              cu <= 2;
            end
            2'h2: begin
              mm_n_o[23:16] <= in;
              cu <= 3;
            end
            2'h3: begin
              mm_n_o[31:24] <= in;
              cu <= 0;
            end
          endcase
        end else begin
          if (cu == es) begin
            mm_ok <= 1'b1;
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
          endcase
        end
      end else begin
        ad <= ad + 1;
        // if_ok <= 1'b0;
        if (cu == es) begin
          if_ok <= 1'b1;
        end
        case (cu)
          2'h0: begin
            if_n[ 7: 0] <= in;
            cu <= 1;
          end
          2'h1: begin
            if_n[15: 8] <= in;
            cu <= 2;
          end
          2'h2: begin
            if_n[23:16] <= in;
            cu <= 3;
          end
          2'h3: begin
            if_n[31:24] <= in;
            cu <= 0;
          end
        endcase
      end
    end
  end


  // always @ (if_a) begin
  // 	if (if_ok == 1'b1 || mm_ok == 1'b1) begin
  // 		// // $display("MAYBE CHANGE %b", mm_e);
  // 		if (mm_e == 1'b1) begin
  // 			cur_mode = 1;
  // 			if (ad != mm_a) begin
  // 				ad = mm_a;
  // 				nready = 1;
  // 			end
  // 			wr = mm_wr;
  // 			cu = mm_cu;
  // 		end else begin
  // 			cur_mode = 0;
  // 			if (ad != if_a) begin
  // 				// $display("??????? %h %h", ad, if_a);
  // 				ad = if_a;
  // 				nready = 1;
  // 			end
  // 			wr = 0;
  // 			cu = 0;
  // 		end
  // 	end
  // 	if_ok = 1'b0;
  // end

  // always @ (posedge mm_e) begin
  // 	if (if_ok == 1'b1 || mm_ok == 1'b1) begin
  // 		// $display("MAYBE CHANGE %d %b", $time, mm_e);
  // 		if (mm_e == 1'b1) begin
  // 			cur_mode = 1;
  // 			if (ad != mm_a) begin
  // 				ad = mm_a;
  // 				nready = 1;
  // 			end
  // 			wr = mm_wr;
  // 			cu = mm_cu;
  // 		end else begin
  // 			cur_mode = 0;
  // 			if (ad != if_a) begin
  // 				ad = if_a;
  // 				nready = 1;
  // 			end
  // 			wr = 0;
  // 			cu = 0;
  // 		end
  // 	end
  // 	mm_ok <= 1'b0;
  // end

  // always @ (negedge mm_e) begin
  // 	if (if_ok == 1'b1 || mm_ok == 1'b1) begin
  // 		// $display("MAYBE CHANGE %d %b", $time, mm_e);
  // 		if (mm_e == 1'b1) begin
  // 			cur_mode = 1;
  // 			if (ad != mm_a) begin
  // 				ad = mm_a;
  // 				nready = 1;
  // 			end
  // 			wr = mm_wr;
  // 			cu = mm_cu;
  // 		end else begin
  // 			cur_mode = 0;
  // 			if (ad != if_a) begin
  // 				ad = if_a;
  // 				nready = 1;
  // 			end
  // 			wr = 0;
  // 			cu = 0;
  // 		end
  // 	end
  // 	mm_ok <= 1'b0;
  // end

  // always @ (if_a, mm_e) begin
  // 	if (if_ok == 1'b1 || mm_ok == 1'b1) begin
  // 		// // $display("MAYBE CHANGE %b", mm_e);
  // 		if (mm_e == 1'b1) begin
  // 			cur_mode = 1;
  // 			ad = mm_a;
  // 			wr = mm_wr;
  // 			cu = mm_cu;
  // 			// mm_ok = 0;
  // 		end else begin
  // 			cur_mode = 0;
  // 			ad = if_a;
  // 			wr = 0;
  // 			cu = 0;
  // 			// if_ok = 0;
  // 		end
  // 	end
  // end

endmodule
