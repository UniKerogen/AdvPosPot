`timescale 1ns / 100ps

module clock(output reg clk);

    initial begin
        clk = 0;
        forever begin
            #10;
            clk = ~clk;
        end
    end

    /*
    initial begin
        //create the vcd file for waveform
        $dumpfile("Clock_Module.vcd");
        $dumpvars;
    end
    */

endmodule
