module DSP48A1_tb();

	// signals declaration
	reg [17:0] A_tb;
	reg [17:0] B_tb;
	reg [17:0] D_tb;
	reg [17:0] BCIN_tb;
	reg [47:0] C_tb;
	reg [47:0] PCIN_tb;
	reg [7:0] OPMODE_tb; 
	reg CLK_tb;
	reg CARRYIN_tb;
	reg RSTA_tb;
	reg RSTB_tb;
	reg RSTC_tb;
	reg RSTD_tb;
	reg RSTM_tb;
	reg RSTP_tb;
	reg RSTCARRYIN_tb;
	reg RSTOPMODE_tb; 
	reg CEA_tb;
	reg CEB_tb;
	reg CEC_tb;
	reg CED_tb;
	reg CEM_tb;
	reg CEP_tb;
	reg CECARRYIN_tb;
	reg CEOPMODE_tb;

	wire [17:0] BCOUT_tb;
	wire [35:0] M_tb;
	wire [47:0] P_tb;
	wire [47:0] PCOUT_tb;
	wire 		CARRYOUT_tb;
	wire 		CARRYOUTF_tb;

	// DUT Instantiation
	DSP48A1 DUT
	(
		.A(A_tb),
		.B(B_tb),
		.C(C_tb),
		.D(D_tb),
		.clk(CLK_tb),
		.CARRYIN(CARRYIN_tb),
		.OPMODE(OPMODE_tb),
		.BCIN(BCIN_tb),
		.RSTA(RSTA_tb),
		.RSTB(RSTB_tb),
		.RSTC(RSTC_tb),
		.RSTD(RSTD_tb),
		.RSTM(RSTM_tb),
		.RSTP(RSTP_tb),
		.RSTCARRYIN(RSTCARRYIN_tb),
		.RSTOPMODE(RSTOPMODE_tb),
		.CEA(CEA_tb),
		.CEB(CEB_tb),
		.CEC(CEC_tb),
		.CED(CED_tb),
		.CEM(CEM_tb),
		.CEP(CEP_tb),
		.CECARRYIN(CECARRYIN_tb),
		.CEOPMODE(CEOPMODE_tb),
		.PCIN(PCIN_tb),
		.BCOUT(BCOUT_tb),
		.PCOUT(PCOUT_tb),
		.P(P_tb),
		.M(M_tb),
		.CARRYOUT(CARRYOUT_tb),
		.CARRYOUTF(CARRYOUTF_tb)
	);
	// clk generation block
	initial begin
		CLK_tb = 0;
		forever
			#1 CLK_tb = ~CLK_tb;
	end
	// directed test stimulus
	initial begin
		initialize();
		RST_TASK();
		@(negedge CLK_tb);
		ENABLE_CLK_TASK();
		// check (BCOUT = PRE_ADDER_SUB_OUT = D + B) and (M = (d + b) * A) and ({CARRYOUT,P} = (d + b) * A + C + CARRYIN)
		FORCE_INPUT_TASK('d10, 'd20, 'd30, 'd40,'d50, 'd60, 1'b0, 8'b00111101);
		@(negedge CLK_tb);
		@(negedge CLK_tb);
		@(negedge CLK_tb);
		@(negedge CLK_tb);
		CHECK_OUTPUT_TASK('d50, 'd500, 'd551, 'd551, 1'b0, 1'b0);
		// check (PRE_ADDER_SUB_OUT = D - B) and (BCOUT = B) and (M = B * A) and ({CARRYOUT,P} = PCIN - (B * A + CARRYIN))
		FORCE_INPUT_TASK('d10, 'd20, 'd30, 'd40,'d50, 'd600, 1'b0, 8'b11100101);
		@(negedge CLK_tb);
		@(negedge CLK_tb);
		@(negedge CLK_tb);
		@(negedge CLK_tb);
		CHECK_OUTPUT_TASK('d20, 'd200, 'd399, 'd399, 1'b0, 1'b0);

		#10;
		$stop;
	end	

	// tasks
	task initialize;
		begin
			A_tb = 'b0;
			B_tb = 'b0; 
			D_tb = 'b0; 
			C_tb = 'b0;
			CARRYIN_tb = 1'b0; 
			OPMODE_tb = 'b0; 
			BCIN_tb = 'b0;
			CEA_tb = 1'b0; 
			CEB_tb = 1'b0;
			CEM_tb = 1'b0; 
			CEP_tb = 1'b0; 
			CEC_tb = 1'b0;
			CED_tb = 1'b0; 
			CECARRYIN_tb = 1'b0; 
			CEOPMODE_tb = 1'b0;
			PCIN_tb = 'b0;
		end	 
	endtask

	task RST_TASK;
		begin
			RSTA_tb = 1'b1; 
			RSTB_tb = 1'b1; 
			RSTM_tb = 1'b1; 
			RSTP_tb = 1'b1; 
			RSTC_tb = 1'b1; 
			RSTD_tb = 1'b1; 
			RSTCARRYIN_tb = 1'b1; 
			RSTOPMODE_tb = 1'b1;
			@(negedge CLK_tb);
			@(negedge CLK_tb);
			RSTA_tb = 1'b0; 
			RSTB_tb = 1'b0; 
			RSTM_tb = 1'b0; 
			RSTP_tb = 1'b0; 
			RSTC_tb = 1'b0; 
			RSTD_tb = 1'b0; 
			RSTCARRYIN_tb = 1'b0; 
			RSTOPMODE_tb = 1'b0;
		end

	endtask

	task ENABLE_CLK_TASK;
		begin
			CEA_tb = 1'b1; 
			CEB_tb = 1'b1;
			CEM_tb = 1'b1; 
			CEP_tb = 1'b1; 
			CEC_tb = 1'b1;
			CED_tb = 1'b1; 
			CECARRYIN_tb = 1'b1; 
			CEOPMODE_tb = 1'b1;
		end
	endtask

	task FORCE_INPUT_TASK;
		input [17:0] A_input, B_input, D_input, BCIN_input;
		input [47:0] C_input, PCIN_input;
		input CARRYIN_input; 
		input [7:0] OPMODE_input;
		begin
			A_tb = A_input;
			B_tb = B_input;
			D_tb = D_input;
			C_tb = C_input;
			BCIN_tb = BCIN_input;
			PCIN_tb = PCIN_input;
			CARRYIN_input = CARRYIN_tb;
			OPMODE_tb = OPMODE_input;
		end	
	endtask

	task CHECK_OUTPUT_TASK;
		input [17:0] BCOUT_EXP;
		input [35:0] M_EXP;
		input [47:0] P_EXP, PCOUT_EXP;
		input CARRYOUT_EXP, CARRYOUTF_EXP;
		begin
			if ((BCOUT_tb != BCOUT_EXP) || (M_tb != M_EXP) || (P_tb != P_EXP) || (PCOUT_tb != PCOUT_EXP) || (CARRYOUT_tb != CARRYOUT_EXP) || (CARRYOUTF_tb !=CARRYOUTF_EXP))
				$display("error, check wave form");
		end
	endtask
endmodule