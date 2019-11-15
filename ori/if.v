module inf (
    input   wire    clk,
    input   wire    rst,
    input 	wire[7:0]	in,
    output  reg         wr,
    output  reg[31:0]   pc,
    output  reg         ce,
    output  reg[31:0]   is,
    output  reg[2:0]    cu
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            ce <= 1'b0;
        end else begin
            ce <= 1'b1;
        end
    end

    always @ (posedge clk) begin
        if (ce == 1'b0) begin
            pc <= 32'h00000000;
            cu <= 2'h0;
            is <= 32'h0;
            wr <= 1'b0;
        end else begin
            wr <= 1'b0;
        end
    end

    always @ (negedge clk) begin
        if (ce == 1'b1) begin
            pc <= pc + 4'h1;
            wr <= 1'b0;
            // $display("cu %d in %h is %h", cu, in, is);
        	if (cu == 0) begin
	            is[31:24] <= in;
	            cu <= 1;
        	end else if (cu == 1) begin
	            is[23:16] <= in;
	            cu <= 2;
        	end else if (cu == 2) begin
	            is[15: 8] <= in;
	            cu <= 3;
        	end else if (cu == 3) begin
	            is[ 7: 0] <= in;
	            cu <= 0;
        	end
        end
    end
    
endmodule



