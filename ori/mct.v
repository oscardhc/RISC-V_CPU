module mct (
	input	wire		clk,
	input	wire		rst,
	input	wire		wr,
	input	wire[31:0]	wn_i,
    input   wire[31:0]  ra_i,
	input	wire[7:0]	in,
	output	reg			ok,
	output	reg[7:0]	out,
	output 	reg[31:0]	rn_o,
	output	reg[31:0]	ad_o,
	output	reg			wr_o		
);

	reg[1:0]	cu;

	always @ (posedge clk) begin 
		if (rst == 1'b1) begin
			cu <= 2'h0;
			rn_o <= 32'h0;
			wr_o <= 1'b0;
			ad_o <= 32'h0;
			ok <= 1'h0;
        end else begin
            if (cu == 2'h0) begin
                ad_o <= ra_i;
                ok <= 1'h0;
            end
        end
	end

	always @ (negedge clk) begin
		if (rst == 1'b0) begin
            $display("\t\t\tAD_O %h IN %h", ad_o, in);
            if (ad_o == 0) rn_o <= 32'h7b06093;
            else if (ad_o == 4) rn_o <= 32'h3e70e213;
            else if (ad_o == 8) rn_o <= 32'he906113;
            else if (ad_o == 12) rn_o <= 32'h1c806193;
            ok <= 1'h1;
            /*
			ok <= 1'b0;
			ad_o <= ad_o + 1;
			case (cu)
				2'h0: begin
		            rn_o[31:24] <= in;
		            cu <= 1;
		        end
		        2'h1: begin
		            rn_o[23:16] <= in;
		            cu <= 2;
		        end
		        2'h2: begin
		            rn_o[15: 8] <= in;
		            cu <= 3;
		        end
		        2'h3: begin
		            rn_o[ 7: 0] <= in;
		            cu <= 0;
		            ok <= 1'b1;
		        end
        	endcase
            */
        end
	end

endmodule
