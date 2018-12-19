`timescale 1ns / 100ps

module memory #(parameter SIZE=32, parameter MAX_RANGE=10) (input memoryControl, input [SIZE*2-1:0] data1, input [SIZE*2-1:0] data2, input memEnable, input reset,
        output reg [SIZE*2-1:0] dataOutput1, output reg [SIZE*2-1:0] dataOutput2, output reg memDone);

    integer loop, n;
    reg [SIZE*2-1:0] writeReg, dataReg;
    reg [SIZE*2-1:0] memoryArray[0:MAX_RANGE];

    always @* begin
        if (reset == 1) begin
            $display("### Memory Module Reset ###");
            memDone = 1'b0;
        end
    end

    initial begin
        $readmemh("memoryFile.txt", memoryArray);
    end



    always @(posedge memEnable) begin

            case (memoryControl)
                //Load Memory from File
                1'b0: begin
                    $display("--- Memory Read Module ---");
						  $readmemh("memoryFile.txt", memoryArray);
						  #5;
                    if (data1 < MAX_RANGE && data2 < MAX_RANGE) begin
                        dataReg = memoryArray[data1];
                        dataOutput1 = dataReg[SIZE-1:0];
                        dataReg = memoryArray[data2];
                        dataOutput2 = dataReg[SIZE-1:0];
								//$display("Memory Result: %d", dataOutput1);
								//$display("Memory Result: %d", dataOutput2);
                        end
                    else begin
                        $display("Address of associated memory location exceed MAX_RANGE(%d)", MAX_RANGE);
						$display("Inputed Address %d and %d", data1, data2);
                        end
                    end
                //Write to File
                1'b1: begin
                    $display("----- Memory Write Module ---");
						  $readmemh("memoryFile.txt", memoryArray);
						  #5;
                    if (data2 < MAX_RANGE) begin
                        writeReg = data1;
                        memoryArray[data2] = writeReg;
                        $writememh("memoryFile.txt", memoryArray);
						#10;
                    end
                    else begin
                        $display("Address of associated memory location exceed MAX_RANGE(%d)", MAX_RANGE);
                    end
                end
                //Default Case
                default: $display("Memory Control No Action.");
            endcase
            memDone = 1'b1;
    end

endmodule
