module register #(
	parameter WIDTH    = 18,
	parameter RESET    = "SYNC"
)
(
	input  wire 			rst,
	input  wire 			clk,
	input  wire [WIDTH-1:0] dataIn,
	output wire [WIDTH-1:0] dataOut
);

// generate the regsier based on the type of the reset
generate
    if (RESET == "SYNC") begin: sync_reset
        sync_reset #(.WIDTH(WIDTH)) syncRst_Register (
			.rst(rst),
			.clk(clk),
			.dataIn(dataIn),
			.dataOut(dataOut)
        );
    end 
    else if (RESET == "ASYNC") begin: async_reset
        async_reset #(.WIDTH(WIDTH)) asyncRst_Register (
			.rst(rst),
			.clk(clk),
			.dataIn(dataIn),
			.dataOut(dataOut)
        );
    end
    else begin : default_reset
        sync_reset #(.WIDTH(WIDTH)) default_syncRst_Register (
			.rst(rst),
			.clk(clk),
			.dataIn(dataIn),
			.dataOut(dataOut)
        );
    end
endgenerate

endmodule