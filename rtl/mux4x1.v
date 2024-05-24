module mux4x1
(
	input  wire [47:0] i0,
	input  wire [47:0] i1,
	input  wire [47:0] i2,
	input  wire [47:0] i3,
	input  wire [1:0]  sel,
	output reg  [47:0] out
);

always @(*) begin
	if (sel == 2'b00)
		out = i0;
	else if (sel == 2'b01)
		out = i1;
	else if (sel == 2'b10)
		out = i2;
	else if (sel == 2'b11)
		out = i3;
	else 
		out = i0;
end

endmodule
