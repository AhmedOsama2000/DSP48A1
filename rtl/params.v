/*

	==> defines the number of pipeline stages
	==> The specified values indicates the default values
	0 ==> Not Regsitered
	1 ==> Regsitered 

*/

`define A0REG 		0
`define B0REG 		0

`define A1REG 		1
`define B1REG       1

`define CREG        1
`define MREG        1
`define DREG 		1
`define PREG        1

`define CARRYINREG  1
`define CARRYOUTREG 1

`define OPMODEREG   1

// choose either opcode[5] or carryin
`define CARRYINSEL  "OPMODE5"

// "DIRECT" or "CASCADE"
`define B_INPUT     "DIRECT"

// choose sync. or async reset "SYNC" "ASYNC"
`define RSTTYPE     "SYNC"