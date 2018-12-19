
`timescale 1ns / 100ps
`include "alu_S.v"
`include "memoryModule.v"
`include "branch.v"
`include "jump.v"
`include "nextProgramIdentifier.v"
`include "doneMux.v"
`include "instructionMemory.v"

module processorModule (input clk, input reset);
    parameter INS_SIZE=32; parameter MEM_RANGE=16; parameter INS_RANGE=10;
    parameter INS_LENGTH=256; parameter COUNTSIZE=8; parameter MOD_SIZE=32;

    wire nextProgramIdentifierDone, instructionmemoryDone, memDone, aluDone, memW1Done, memW2Done;
    wire branchControl, branchDone, jumpControl, jumpEnable, jumpDone, doneMuxResult;//, reset;
    wire [COUNTSIZE-1:0] currentCount, branchResult, jumpResult, nextProgramNum;
    wire [INS_SIZE-1:0] currentInstruction;
    wire [MOD_SIZE*2-1:0] memRead1T, memRead2T;
    wire [MOD_SIZE-1:0] memRead1, memRead2;
    wire [MOD_SIZE*2-1:0] aluResult1, aluResult2;
    wire [1:0] nextProgramControl;
    wire [2:0] aluControl, branchAddress;
    wire [5:0] jumpAddress;
    wire [MOD_SIZE*2-1:0] writeAddress1, writeAddress2, readAddress1, readAddress2;

    instructionMemory #(INS_SIZE, INS_LENGTH, COUNTSIZE) im(.currentCount(currentCount), .nextProgramIdentifierDone(nextProgramIdentifierDone), .reset(reset),
        .currentInstruction(currentInstruction), .instructionmemoryDone(instructionmemoryDone));

    memory #(MOD_SIZE, MEM_RANGE) mread(.memoryControl(1'b0), .data1(readAddress1), .data2(readAddress2), .memEnable(instructionmemoryDone), .reset(reset),
        .dataOutput1(memRead1T), .dataOutput2(memRead2T), .memDone(memDone));

    alu_s #(MOD_SIZE) alus(.control(aluControl), .aluEnable(memDone), .num1(memRead1), .num2(memRead2), .reset(reset), .clk(clk),
        .output1(aluResult1), .output2(aluResult2), .aluDone(aluDone));

    memory #(MOD_SIZE, MEM_RANGE) mwrite1(.memoryControl(1'b1), .data1(aluResult1), .data2(writeAddress1), .memEnable(aluDone), .reset(reset),
        .dataOutput1(), .dataOutput2(), .memDone(memW1Done));

    memory #(MOD_SIZE, MEM_RANGE) mwrite2(.memoryControl(1'b1), .data1(aluResult2), .data2(writeAddress2), .memEnable(memW1Done), .reset(reset),
        .dataOutput1(), .dataOutput2(), .memDone(memW2Done));

    branch #(COUNTSIZE) branch(.currentCount(currentCount), .programNum(branchAddress), .branchControl(branchControl), .branchEnable(instructionmemoryDone), .reset(reset),
        .branchResult(branchResult), .branchDone(branchDone));

    jump #(COUNTSIZE) jump(.jumpControl(jumpControl), .programNum(jumpAddress), .currentCount(currentCount), .jumpEnable(instructionmemoryDone), .reset(reset),
        .jumpResult(jumpResult), .jumpDone(jumpDone));

    doneMux dMux (.branchDone(branchDone), .jumpDone(jumpDone), .memWriteDone1(memW1Done), .memWriteDone2(memW2Done), .reset(reset),
        .doneMuxResult(doneMuxResult));

    nextProgramIdentifier #(COUNTSIZE) npi (.currentCount(currentCount), .branchResult(branchResult), .jumpResult(jumpResult), .nextProgramControl(nextProgramControl), .doneMuxResult(doneMuxResult), .reset(reset),
        .nextProgramNum(nextProgramNum), .nextProgramIdentifierDone(nextProgramIdentifierDone));

    //For 32 Bit
    assign aluControl = currentInstruction[31:29];
    assign readAddress1 = {{60{1'b0}},currentInstruction[28:25]};
    assign readAddress2 = {{60{1'b0}},currentInstruction[24:21]};
    assign writeAddress1 = {{60{1'b0}},currentInstruction[20:17]};
    assign writeAddress2 = {{60{1'b0}},currentInstruction[16:13]};
    assign nextProgramControl = currentInstruction[12:11];
    assign branchControl = currentInstruction[10];
    assign branchAddress = currentInstruction[9:7];
    assign jumpControl = currentInstruction[6];
    assign jumpAddress = currentInstruction[5:0];

    assign memRead1 = memRead1T[MOD_SIZE-1:0];
    assign memRead2 = memRead2T[MOD_SIZE-1:0];

    reg [INS_SIZE-1:0] programCounter;


    initial begin
        #5;
        programCounter = 0;
    end

    always @(*) begin
        programCounter = nextProgramNum;
    end

    assign currentCount = programCounter;
	assign currentCount = nextProgramNum;

endmodule
