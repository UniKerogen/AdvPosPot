`timescale 1ns / 100ps

module doneMux (input branchDone, input jumpDone, input memWriteDone1, input memWriteDone2, input reset,
                output reg doneMuxResult);

    //assign doneMuxResult = branchDone & jumpDone & memWriteDone1 & memWriteDone2;

    always @* begin
        if (reset == 1) begin
            $display("### Done Mux Module Reset ###");
            doneMuxResult = 1'b0;
        end
    end

    always @* begin
        if(branchDone == 1'b1 && jumpDone==1'b1 && memWriteDone1==1'b1 && memWriteDone2==1'b1) begin
            doneMuxResult = 1'b1;
            $display("--doneMux Executed--");
        end
    end

endmodule
