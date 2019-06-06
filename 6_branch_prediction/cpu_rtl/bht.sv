`timescale 1ns / 1ps

module BHT(
	input wire clk,
	input wire rst,
	input wire [6:0] PC,
	input wire [6:0] PCE,
	input wire realBranch,
	input wire [2:0] BranchTypeE,
	input wire isBhtTakenE,
	output wire isTaken,
	output reg [15:0] correct_count, wrong_count
);
`include "Parameters.v"


reg [1:0] buffer [128];

always @(posedge rst) begin
	for (integer i=0;i<128;i++)
		buffer[i] <= 2'b00;
	correct_count <= 16'b0;
	wrong_count <= 16'b0;
end


assign isTaken = buffer[PC][1];

always @(posedge clk)
	if (BranchTypeE != `NOBRANCH) begin
		case (buffer[PCE])
			2'b00:buffer[PCE] <= realBranch ? 2'b01 : 2'b00;
			2'b01:buffer[PCE] <= realBranch ? 2'b11 : 2'b00;
			2'b10:buffer[PCE] <= realBranch ? 2'b11 : 2'b00;
			2'b11:buffer[PCE] <= realBranch ? 2'b11 : 2'b10;
			default:buffer[PCE] <= 2'b00;
		endcase
    
        if (realBranch != isBhtTakenE)
                wrong_count <= wrong_count + 1;
        else
                correct_count <= correct_count + 1;
	end

endmodule