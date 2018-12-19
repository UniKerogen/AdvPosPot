`timescale 1ns / 100ps
//`include "OperationModule.v"

module branch #(parameter SIZE = 8)(input [SIZE-1:0] currentCount, input signed [2:0] programNum, input branchControl, input branchEnable, input reset,
                output reg [SIZE-1:0] branchResult, output reg branchDone);

    reg signed [SIZE:0] currentCountTemp, programNumTemp;
    wire signed [SIZE:0] branchResultTemp;
    parameter PAD = SIZE - 3;

    adderNS #(SIZE+1) addnsb (.fir_num(currentCountTemp), .sec_num(programNumTemp),
                        .sum(branchResultTemp));

    always @* begin
        if (reset == 1) begin
            $display("### Branch Module Reset ###");
            branchDone = 1'b0;
        end
    end

    always @(*) begin
        if (branchEnable == 1) begin
            $display("--Branch Module--");
            branchResult = currentCount;
    
            if (branchControl == 1'b1) begin
                currentCountTemp = {1'b0, currentCount};
                programNumTemp = {{PAD{programNum[2]}},programNum};
                #5;
                if (branchResultTemp[SIZE] == 1'b0) begin
                    branchResult = branchResultTemp[SIZE-1:0];
                    $display("---Branch Exected---");
                end
                else begin
                    $display("Branch not Executed.");
                    $display("Error Code: B");
                    $display("Current Count: %b", currentCountTemp);
                    $display("Program Number: %b", programNumTemp);
                    $display("Branch Result: %b", branchResult);
                end
            end
            else begin
                $display("Branch Module not enabled");
            end
    
            #5; branchDone = 1'b1;
        end
    end

endmodule
