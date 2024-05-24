module clkGate (
	input  wire clk,
	input  wire en,
	output wire gate_clk
);

reg latch_en;

always @(clk,en) begin
	
	if (!clk) begin
		latch_en <= en;
	end

end

assign gate_clk = latch_en && clk;

endmodule
