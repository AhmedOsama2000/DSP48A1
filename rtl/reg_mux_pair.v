module reg_mux_pair #(
	parameter WIDTH    = 18,
	parameter RESET    = "SYNC",
	parameter PIPELINE = 1'b0
)
(
	input  wire 			rst,
	input  wire 			clk,
	input  wire [WIDTH-1:0] dataIn,
	output wire [WIDTH-1:0] dataOut 
);

// internal signals
wire [WIDTH-1:0] regOut;
wire select;

assign select = (PIPELINE)? 1'b1:1'b0; 

register #(.WIDTH(WIDTH) , .RESET(RESET)) reg0
(
	.rst(rst),
	.clk(clk),
	.dataIn(dataIn),
	.dataOut(regOut)
);

mux2x1 #(.WIDTH(WIDTH)) mux (
	.i0(dataIn),
	.i1(regOut),
	.sel(select),
	.out(dataOut)
);

endmodule