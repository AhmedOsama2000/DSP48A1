module mux2x1 #(
	parameter WIDTH = 18
)
(
	input  wire [WIDTH-1:0] i0,
	input  wire [WIDTH-1:0] i1,
	input  wire        		sel,
	output reg  [WIDTH-1:0] out
);

always @(*) begin
	if (sel == 1'b0)
		out = i0;
	else if (sel == 1'b1)
		out = i1;
	else 
		out = i0;
end

endmodule
