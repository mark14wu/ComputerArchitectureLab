`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB (Embeded System Lab)
// Engineer: Haojun Xia
// Create Date: 2019/02/08
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output wire [1:0] AluSrc2D,
    output wire AluSrc1D,
    output reg [2:0] ImmType
    );

    assign JalD = (Op == 7'b1101111) ? 1'b1 : 1'b0;
    // JalD==1          表示Jal指令是否到达ID译码阶段

    assign JalrD = (Op == 7'b1100111) ? 1'b1 : 1'b0;
    // JalrD==1         表示Jalr指令是否到达ID译码阶段

    assign MemToRegD = (Op == 7'b0000011) ? 1'b1 : 1'b0;
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器

    assign LoadNpcD = (Op == 7'b1100111 || Op == 7'b1101111) ? 1'b1 : 1'b0;
    // LoadNpcD==1      表示将NextPC输出到ResultM

    assign AluSrc2D[0] = ((Op == 7'b0010011 ) && (Fn3 == 3'b001 || Fn3 == 3'b101)) ? 1'b1 : 1'b0;
    // shift Itype

    assign AluSrc2D[1] = (Op == 7'b0000011 || Op == 7'b0010011|| Op == 7'b1110011 || Op == 7'b1100111 || Op == 7'b0110111 || Op == 7'b0010111 || Op == 7'b0100011) ? 1'b1 : 1'b0;
    // 在这些指令load alui csr system jalr lui auipc store为1，否则为0
    // AluSrc2D         表示Alu输入源2的选择

    assign AluSrc1D = (Op == 7'b0010111) ? 1'b1:1'b0;
    // AluSrc1D         表示Alu输入源1的选择，在auipc指令时为1，否则为0

    // 剩余信号说明
    // RegWriteD        表示ID阶段的指令对应的 寄存器写入模式 ，所有模式定义在Parameters.v中
    // MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // RegReadD[1]==1   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // ImmType          表示指令的立即数格式，所有类型定义在Parameters.v中
    always@(*)
    begin
        case(Op)
            7'b0000011://load
            begin
                case(Fn3)
                    3'b000: RegWriteD <= `LB;
                    3'b001: RegWriteD <= `LH;
                    3'b010: RegWriteD <= `LW;
                    3'b100: RegWriteD <= `LBU;
                    3'b101: RegWriteD <= `LHU;
                    default: RegWriteD <= `NOREGWRITE;
                endcase
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b10;
                BranchTypeD <= `NOBRANCH;
                AluContrlD <= `ADD;
                ImmType <= `ITYPE;
            end

            7'b0100011://store
            begin
                RegWriteD <= `NOREGWRITE;
                case(Fn3)
                    3'b000:MemWriteD <= 4'b0001;
                    3'b001:MemWriteD <= 4'b0011;
                    3'b010:MemWriteD <= 4'b1111;
                    default: MemWriteD <= 4'b0000;
                endcase
                RegReadD <= 2'b11;
                BranchTypeD <= `NOBRANCH;
                AluContrlD <= `ADD;
                ImmType <= `STYPE;
            end

            7'b0110011:     // alu (寄存器)
            begin
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b11;
                BranchTypeD <= `NOBRANCH;
                case(Fn3)
                    3'b000: AluContrlD <= (Fn7 == 7'b0000000) ? `ADD : `SUB;
                    3'b001: AluContrlD <= `SLL;
                    3'b010: AluContrlD <= `SLT;
                    3'b011: AluContrlD <= `SLTU;
                    3'b100: AluContrlD <= `XOR;
                    3'b101: AluContrlD <= (Fn7 == 7'b0000000) ? `SRL : `SRA;
                    3'b110: AluContrlD <= `OR;
                    3'b111: AluContrlD <= `AND;
                endcase // case (Fn3)
                ImmType <= `RTYPE;
            end

            7'b0010011:     // alui
            begin
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b10;
                BranchTypeD <= `NOBRANCH;
                case (Fn3)
                    3'b000: AluContrlD <= `ADD;
                    3'b001: AluContrlD <= `SLL;
                    3'b010: AluContrlD <= `SLT;
                    3'b011: AluContrlD <= `SLTU;
                    3'b100: AluContrlD <= `XOR;
                    3'b101: AluContrlD <= (Fn7 == 7'b0000000) ? `SRL : `SRA;
                    3'b110: AluContrlD <= `OR;
                    3'b111: AluContrlD <= `AND;
                endcase
                ImmType <= `ITYPE;
            end

            7'b0110111://lui
            begin
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= `NOBRANCH;
                ImmType <= `UTYPE;
                AluContrlD <= `LUI; 
            end

            7'b0010111://auipc
            begin
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= `NOBRANCH;
                ImmType <= `UTYPE;
                AluContrlD <= `ADD; 
            end

            7'b1100011://branch
            begin
                RegWriteD <= `NOREGWRITE;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b11;
                case(Fn3)
                    3'b000:BranchTypeD <= `BEQ;
                    3'b001:BranchTypeD <= `BNE;
                    3'b100:BranchTypeD <= `BLT;
                    3'b101:BranchTypeD <= `BGE;
                    3'b110:BranchTypeD <= `BLTU;
                    3'b111:BranchTypeD <= `BGEU;
                    default:BranchTypeD <= `NOBRANCH;
                endcase
                ImmType <= `BTYPE;
                AluContrlD <= `ADD;
            end

            7'b1101111://JAL
            begin
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= `NOBRANCH;
                AluContrlD <= `ADD;
                ImmType <= `JTYPE;
            end

            7'b1100111://JALR
            begin
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b10;
                BranchTypeD <= `NOBRANCH;
                AluContrlD <= `ADD;
                ImmType <= `ITYPE;
            end

            default:
            begin
                RegWriteD <= `NOREGWRITE;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= `NOBRANCH;
                ImmType <= `RTYPE;
                AluContrlD <= `ADD; 
            end
        endcase
    end

endmodule

//功能说明
    //ControlUnit       是本CPU的指令译码器，组合逻辑电路
//输入
    // Op               是指令的操作码部分
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的 寄存器写入模式 ，所有模式定义在Parameters.v中
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
    // MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD[1]==1   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // AluSrc2D         表示Alu输入源2的选择
    // AluSrc1D         表示Alu输入源1的选择
    // ImmType          表示指令的立即数格式，所有类型定义在Parameters.v中   
//实验要求  
    //实现ControlUnit模块