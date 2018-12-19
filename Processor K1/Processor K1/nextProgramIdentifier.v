`timescale 1ns / 100ps

module nextProgramIdentifier #(parameter SIZE = 8)
                    (input [SIZE-1:0] currentCount,
                    input [SIZE-1:0] branchResult,
                    input [SIZE-1:0] jumpResult,
                    input [1:0] nextProgramControl,
                    input doneMuxResult,
                    input reset,
                        output reg [SIZE-1:0] nextProgramNum,
                        output reg nextProgramIdentifierDone);

    reg [SIZE-1:0] nextProgramNumTemp;

    initial begin
        #5;
        nextProgramNum = 0;
    end

    always @(negedge reset) begin
        nextProgramNum = nextProgramNumTemp;
    end

    always @* begin
        if (reset == 1) begin
            $display("### NPI Module Reset ###");
            nextProgramIdentifierDone = 1'b0;
        end
    end

    always @(posedge doneMuxResult) begin
        $display("----- Next Program Identifier --");

        case (nextProgramControl)
            2'b00: nextProgramNumTemp = currentCount + 1;
            2'b01: nextProgramNumTemp = branchResult;
            2'b10: nextProgramNumTemp = jumpResult;
            default: begin
                $display ("Unable to select instructions");
                $display ("Error Code: NPI");
                $display ("Proceed as Default");
                nextProgramNumTemp = currentCount + 1;
                end
        endcase

        nextProgramIdentifierDone = 1'b1;
        $display("One cycle Done");

    end
endmodule
