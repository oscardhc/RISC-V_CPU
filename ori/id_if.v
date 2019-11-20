
module id_if (
	input	wire	clk,    
	input	wire	rst,
	
	input	wire[31:0]	id_if_pc_i,
	input 	wire		id_if_pce_i,

	output	reg[31:0]	id_if_pc_o,
	output	reg			id_if_pce_o
);

always @ (negedge clk) begin
	if (rst == 1'b1) begin
		id_if_pc_o 	<= 32'h0;
		id_if_pce_o <= 1'b0;
	end else begin
		id_if_pc_o 	<= id_if_pc_i;
		id_if_pce_o <= id_if_pce_i;
	end
end

endmodule