`timescale 1ns / 1ps

module BTB(
	input wire clk,
	input wire rst,
	input wire [6:0] PC,
	input wire [6:0] PCE,
	input wire realBranch,
	input wire [31:0] BranchPC,
	input wire [2:0] BranchTypeE,
	output wire [31:0] PC_Pred,
	output wire isTaken
);
`include "Parameters.v"
reg [32:0] buffer [128];

always @(posedge rst)
	for (integer i=0;i<128;i++)
		buffer[i] <= 33'h0;


assign isTaken = buffer[PC][0];
assign PC_Pred = buffer[PC][32:1];
always @(posedge clk)
	if (BranchTypeE != `NOBRANCH)
		buffer[PCE] <= {BranchPC, realBranch};
		
	
endmodule