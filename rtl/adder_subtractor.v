module adder_subtractor #(
	parameter WIDTH = 18
) 
(
	input  wire [WIDTH-1:0]  in0,
	input  wire [WIDTH-1:0]  in1,
	input  wire              sel,
	input  wire              Cin,
	output wire  [WIDTH-1:0] out,
	output wire              Cout
);

reg  [WIDTH-1:0] result;
reg              carry;
wire             overflow;

always @(*) begin
	if (sel == 0)
		{carry,result} = in0 + (in1 + Cin);
	else
		{carry,result} = in0 - (in1 + Cin);
end

// detect overflow to determine the result
assign overflow = ((in0[15] == in1[15]) && (result[15] != in0[15]))? 1'b1:1'b0;

assign {Cout,out} = overflow? 'b0: {carry,result}; 

endmodule