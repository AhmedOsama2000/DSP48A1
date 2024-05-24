(* dont_touch = "yes" *)
module multiplier
(
	input  wire [17:0] in0,
	input  wire [17:0] in1,
	output wire [35:0] out
);

wire [17:0]   passed_in0;
wire [17:0]   passed_in1;
wire [35:0] passed_out;

assign passed_in0 = (in0[17])? (~in0 + 1'b1): in0;
assign passed_in1 = (in1[17])? (~in1 + 1'b1): in1;

assign passed_out = passed_in0 * passed_in1;

assign out = (in0[17] ^ in1[17])? (~passed_out + 1'b1) : passed_out;

endmodule