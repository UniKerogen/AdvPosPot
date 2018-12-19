`timescale 1ns / 100ps

module instructionMemory #(parameter INS_SIZE=32, INS_LENGTH=256, COUNTSIZE=8) (
                            input [COUNTSIZE-1:0] currentCount,
                            input nextProgramIdentifierDone,
                            input reset,
                                output reg [INS_SIZE-1:0] currentInstruction,
                                output reg instructionmemoryDone);

    reg [INS_SIZE-1:0] instructionMemory[0:INS_LENGTH-1];
    reg readingDone;
    reg [COUNTSIZE-1:0] previous1Count, previous2Count, previous3Count, currentCountStore;

    //integer n;

    initial begin
        $display("--Instruction Memory Module--");
        $display("instructionMemory Module Initializing...");
        instructionmemoryDone = 1'b0;
        readingDone = 1'b0;
        $readmemh("instruction.txt", instructionMemory);
        readingDone = 1'b1;
        currentInstruction = instructionMemory[0];
        #5; $display("-initialization done");
        instructionmemoryDone = 1'b1;
        previous1Count = 0;
        //#1; instructionmemoryDone = 1'b0;

        //for(n=0;n<=INS_LENGTH;n=n+1)	$display("%h",instructionMemory[n]);

    end

    always @* begin
        if (reset == 1) begin
            $display("### Instruction Memory Module Reset ###");
            instructionmemoryDone = 1'b0;
        end
    end

    always @( currentCount ) begin
        $display("--InstructionMemory Module--");

        previous3Count = previous2Count;
        previous2Count = previous1Count;
        previous1Count = currentCountStore;
        currentCountStore = currentCount;

        if(previous3Count == currentCount) begin
            $display("Process Exited due to same instruction looping");
            #5;
            $finish;
        end

        if(currentCount < INS_LENGTH) begin
            currentInstruction = instructionMemory[currentCount];
            instructionmemoryDone = 1'b1;
        end
        else begin
            if (currentCount[0] == 1'bx) begin
                currentInstruction = instructionMemory[0];
            end
            else begin
                $display("Desired program (%d) exceed INS_LENGTH (%d)", currentCount, INS_LENGTH);
                $display("Error Code: IM");
                $finish; $stop;
            end
        end
		  $display("Current Instruction: %h", currentInstruction);
    end

endmodule
