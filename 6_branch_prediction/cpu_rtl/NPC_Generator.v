`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB（Embeded System Lab）
// Engineer: Haojun Xia
// Create Date: 2019/03/14 11:21:33
// Design Name: RISCV-Pipline CPU
// Module Name: NPC_Generator
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Choose Next PC value
//////////////////////////////////////////////////////////////////////////////////
module NPC_Generator(
    input wire [31:0] PCF,JalrTarget, BranchTarget, JalTarget,PCE,
    input wire BranchE,JalD,JalrE,
    input wire isBtbTakenE,
    input wire isBtbTaken,
    input wire isBhtTaken,
    input wire isBhtTakenE,
    input wire [31:0] BtbPCPred,
    output reg [31:0] PC_In
    );
    always @(*)
    begin
        if(JalrE)
            PC_In <= JalrTarget;
        else if(isBhtTaken)
            PC_In <= BtbPCPred;
        else if(JalD)
            PC_In <= JalTarget;
        else
            PC_In <= PCF+4;
            
        if (isBhtTakenE != BranchE)
                PC_In <= BranchE==1'b1 ? BranchTarget : PCE+4;

    end
endmodule
