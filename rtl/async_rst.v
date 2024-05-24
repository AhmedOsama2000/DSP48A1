module async_reset #(
	parameter WIDTH = 18
)
(
	input  wire 			rst,
	input  wire 			clk,
	input  wire [WIDTH-1:0] dataIn,
	output reg [WIDTH-1:0]  dataOut
);

always @(posedge clk,negedge rst) begin
    if (rst)
        dataOut <= 'b0;
    else
        dataOut <= dataIn;
end

endmodule