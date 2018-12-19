`timescale 1ns / 100ps
//`include "OperationModule.v"

module jump #(parameter SIZE = 8) (input jumpControl, input [5:0] programNum, input [SIZE-1:0] currentCount, input jumpEnable, input reset,
                                    output reg [SIZE-1:0] jumpResult, output reg jumpDone);

    reg signed [SIZE:0] currentCountTemp, programNumTemp;
    wire signed [SIZE:0] jumpResultTemp;
    parameter PAD = SIZE - 3;

    adderNS #(SIZE+1) addnsj (.fir_num(currentCountTemp), .sec_num(programNumTemp),
                        .sum(jumpResultTemp));

    always @* begin
        if (reset == 1) begin
            $display("### Jump Module Reset ###");
            jumpDone = 1'b0;
        end
    end

    always @(*) begin
        if (jumpEnable == 1) begin
            $display("--Jump Module--");

            if (jumpControl == 1'b1) begin
                currentCountTemp = {1'b0, currentCount};
                programNumTemp = {{PAD{programNum[2]}},programNum};
                #5;
                if (jumpResultTemp[SIZE] == 1'b0) begin
                    jumpResult = jumpResultTemp[SIZE-1:0];
                    $display("---Jump Enable---");
                end
                else begin
                    $display("Jump not Executed.");
                    $display("Error Code: J");
                    jumpResult = currentCount;
                end
            end
            else begin
                $display("Jump not enbaled");
                jumpResult = currentCount;
            end

            #5; jumpDone = 1'b1;
        end
    end

endmodule
