module mct (
	input	wire		clk,
	input	wire		rst,
	input   wire[31:0]  if_a,
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
	output	reg			wr		
);

reg[1:0]	cu;
reg[1:0]	cur_mode; // 1-mem 0-inf

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
	end
end

always @ (if_a, mm_e) begin
	if (if_ok == 1'b1 || mm_ok == 1'b1) begin
		if (mm_e == 1'b1) begin
			cur_mode = 1;
			ad = mm_a;
			wr = mm_wr;
		end else begin
			cur_mode = 0;
			ad = if_a;
			wr = 0;
		end
	end
end

always @ (negedge clk) begin
	if (rst == 1'b0) begin
		$display("\t\t\t MCT ad %h", ad);
		if (cur_mode == 1'b1) begin
			if_ok <= 1'b0;
			mm_ok <= 1'b0;
			ad <= ad + 1;
			if (mm_wr == 1'b0) begin
				case (cu)
					2'h0: begin
			            mm_n_o[31:24] <= in;
			            cu <= 1;
			        end
			        2'h1: begin
			            mm_n_o[23:16] <= in;
			            cu <= 2;
			        end
			        2'h2: begin
			            mm_n_o[15: 8] <= in;
			            cu <= 3;
			        end
			        2'h3: begin
			            mm_n_o[ 7: 0] <= in;
			            cu <= 0;
			            mm_ok <= 1'b1;
			        end
	        	endcase
	        end else begin
				case (cu)
					2'h0: begin
			            out <= mm_n_i[31:24];
			            cu <= 1;
			        end
			        2'h1: begin
			            out <= mm_n_i[23:16];
			            cu <= 2;
			        end
			        2'h2: begin
			            out <= mm_n_i[15: 8];
			            cu <= 3;
			        end
			        2'h3: begin
			            out <= mm_n_i[ 7: 0];
			            cu <= 0;
			            mm_ok <= 1'b1;
			        end
	        	endcase
	        end
		end else begin
			if_ok <= 1'b0;
			mm_ok <= 1'b0;
			ad <= ad + 1;
			case (cu)
				2'h0: begin
		            if_n[31:24] <= in;
		            cu <= 1;
		        end
		        2'h1: begin
		            if_n[23:16] <= in;
		            cu <= 2;
		        end
		        2'h2: begin
		            if_n[15: 8] <= in;
		            cu <= 3;
		        end
		        2'h3: begin
		            if_n[ 7: 0] <= in;
		            cu <= 0;
		            if_ok <= 1'b1;
		        end
        	endcase
        end
    end
end

endmodule
