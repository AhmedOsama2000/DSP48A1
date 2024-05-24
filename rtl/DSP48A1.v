`include "params.v"
module top_DSP48A1 (
	// Reset Input Ports
	input wire RSTA, // reset REGA
	input wire RSTB, // reset REGB
	input wire RSTC, // reset REGC
	input wire RSTD, // reset REGD
	input wire RSTM, 	   // reset multiplier registers
	input wire RSTCARRYIN, // Reset carry-in & carry-out register (CYO)
	input wire RSTOPMODE,  // Reset opmode register
	input wire RSTP,       // Reset for the P output registers

	// control input ports
	input wire 		 clk,
	input wire [7:0] OPMODE, // select DSP48A1 slice operation
	
	// Clock Enable Input Ports
	input wire CEA, 	  // Clock enable REGA
	input wire CEB, 	  // Clock enable REGB
	input wire CEC, 	  // Clock enable REGC
	input wire CED, 	  // Clock enable REGD
	input wire CECARRYIN, // Clock enable carry-in/out registers
	input wire CEM,       // Clock enable multiplier register 
	input wire CEOPMODE,  // Clock enable opmode registe
	input wire CEP,       // Clock enable for P out regsiters

	// cascade ports
	input  wire [17:0] BCIN,  // cascaded input port B
	input  wire [47:0] PCIN,  // cascaded input port P
	output wire [47:0] PCOUT, // cascaded output port P
	output wire [17:0] BCOUT, // cascaded output port B

	// Data Ports
	input  wire [17:0] A,
	input  wire [17:0] B,
	input  wire [47:0] C,
	input  wire [17:0] D,
	input  wire 	   CARRYIN,
	output wire [35:0] M,
	output wire [47:0] P,
	output wire        CARRYOUT,
	output wire 	   CARRYOUTF
);

// main clocks
wire [7:0] en_clks;
wire [7:0] clocksOut;

wire clockA;
wire clockB;
wire clockC;
wire clockD;
wire clockCarry;
wire clockM;
wire clockOp;
wire clockP;

// internal signals
wire [17:0] a0regOut;
wire [17:0] a1regOut;
wire [17:0] b0regOut;
wire [17:0] b1regOut;
wire [17:0] BSrc;
wire [47:0] cregOut;
wire [17:0] dregOut;

wire [35:0] mulOut;
wire [35:0] mregOut;

// opmode output from entry pair
wire [7:0]  opmodeOut;

// multiplier B input
wire [17:0] inBMul;

wire [17:0] pre_addSubOut;
wire [47:0] post_addSubOut;
wire [47:0] pregOut;
wire        post_carryOut;

wire	    CYIOut;
wire	    CYOOut;
wire	    CYISrc;

wire [47:0] XOut;
wire [47:0] ZOut;

assign en_clks = {CEA,CEB,CEC,CED,CECARRYIN,CEM,CEOPMODE,CEP};

assign {clockA,clockB,clockC,clockD,
		clockCarry,clockM,clockOp,clockP} = clocksOut;

assign BSrc   = (`B_INPUT == "DIRECT")? B :
			    (`B_INPUT == "CASCADED")? BCIN : 18'b0;

assign CYISrc = (`CARRYINSEL == "OPMODE5")? opmodeOut[5] : 
				(`CARRYINSEL == " CARRYIN")? CARRYIN : 1'b0;

// internal modules

// Generate an array of registers
genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : clock_gates
        clkGate ckGates (
            .clk(clk),
            .en(en_clks[i]),
            .gate_clk(clocksOut[i])
        );
    end
endgenerate

// opmode entry
reg_mux_pair #(.WIDTH(8),.RESET(`RSTTYPE),.PIPELINE(`OPMODEREG)) OPREGTR (
	.rst(RSTOPMODE),
	.clk(clockOp),
	.dataIn(OPMODE),
	.dataOut(opmodeOut)
);

reg_mux_pair #(.WIDTH(18),.RESET(`RSTTYPE),.PIPELINE(`A0REG)) A0REGTR (
	.rst(RSTA),
	.clk(clockA),
	.dataIn(A),
	.dataOut(a0regOut)
);

reg_mux_pair #(.WIDTH(18),.RESET(`RSTTYPE),.PIPELINE(`B0REG)) B0REGTR (
	.rst(RSTB),
	.clk(clockB),
	.dataIn(BSrc),
	.dataOut(b0regOut)
);

// choose the second input of mul (bypass addSyb or take the output)
mux2x1 #(.WIDTH(18)) muxMulB (
	.i0(b0regOut),
	.i1(pre_addSubOut),
	.sel(opmodeOut[4]),
	.out(inBMul)
); 

reg_mux_pair #(.WIDTH(48),.RESET(`RSTTYPE),.PIPELINE(`CREG)) CREGTR (
	.rst(RSTC),
	.clk(clockC),
	.dataIn(C),
	.dataOut(cregOut)
);

reg_mux_pair #(.WIDTH(18),.RESET(`RSTTYPE),.PIPELINE(`DREG)) DREGTR (
	.rst(RSTD),
	.clk(clockD),
	.dataIn(D),
	.dataOut(dregOut)
);

reg_mux_pair #(.WIDTH(18),.RESET(`RSTTYPE),.PIPELINE(`A1REG)) A1REGTR (
	.rst(RSTA),
	.clk(clockA),
	.dataIn(a0regOut),
	.dataOut(a1regOut)
);

reg_mux_pair #(.WIDTH(18),.RESET(`RSTTYPE),.PIPELINE(`B1REG)) B1REGTR (
	.rst(RSTB),
	.clk(clockB),
	.dataIn(inBMul),
	.dataOut(b1regOut)
);

adder_subtractor #(.WIDTH(18)) pre_adder_subtractor (
	.in0(D),
	.in1(B),
	.sel(opmodeOut[6]),
	.Cin(1'b0),
	.out(pre_addSubOut),
	.Cout()
);

(* dont_touch = "yes" *)
multiplier mul (
	.in0(a1regOut),
	.in1(b1regOut),
	.out(mulOut)	
);

reg_mux_pair #(.WIDTH(36),.RESET(`RSTTYPE),.PIPELINE(`MREG)) MREGTR (
	.rst(RSTM),
	.clk(clockM),
	.dataIn(mulOut),
	.dataOut(mregOut)
);

reg_mux_pair #(.WIDTH(1),.RESET(`RSTTYPE),.PIPELINE(`CARRYINREG)) CYIREGTR (
	.rst(RSTCARRYIN),
	.clk(clockCarry),
	.dataIn(CYISrc),
	.dataOut(CYIOut)
);

mux4x1 X (
	.i0(48'b0),
	.i1({{12{mregOut[35]}},mregOut}),
	.i2(PCOUT),
	.i3({D[11:0],A,B}),
	.sel(opmodeOut[1:0]),
	.out(XOut)
);

mux4x1 Z (
	.i0(48'b0),
	.i1(PCIN),
	.i2(PCOUT),
	.i3(cregOut),
	.sel(opmodeOut[3:2]),
	.out(ZOut)
);

adder_subtractor #(.WIDTH(48)) post_adder_subtractor (
	.in0(ZOut),
	.in1(XOut),
	.sel(opmodeOut[7]),
	.Cin(CYIOut),
	.out(post_addSubOut),
	.Cout(post_carryOut)
);

reg_mux_pair #(.WIDTH(48),.RESET(`RSTTYPE),.PIPELINE(`PREG)) PREGTR (
	.rst(RSTP),
	.clk(clockP),
	.dataIn(post_addSubOut),
	.dataOut(pregOut)
);

reg_mux_pair #(.WIDTH(1),.RESET(`RSTTYPE),.PIPELINE(`CARRYOUTREG)) CYOREGTR (
	.rst(RSTCARRYIN),
	.clk(clockCarry),
	.dataIn(post_carryOut),
	.dataOut(CYOOut)
);

// assign outputs
assign BCOUT 	 = b1regOut;
assign M     	 = mulOut;
assign CARRYOUT  = CYOOut;
assign CARRYOUTF = CYOOut;
assign P         = pregOut;
assign PCOUT     = pregOut;

endmodule