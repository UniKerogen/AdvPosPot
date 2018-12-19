`timescale 1ns / 100ps
`include "processorModule.v"

//TODO: Fix instructions
//TODO: Initialize the Register Values

module processor_testbench();

    reg o_clk, reset;

    processorModule p1 (.clk(o_clk), .reset(reset));

    initial begin
        //create the vcd file for waveform
        $dumpfile("Wave_ProcessorModule.vcd");
        $dumpvars;
    end

    initial begin
        #1;
        reset = 1'b1;
        #1;
        forever begin
            reset = 1'b0;
            o_clk = 1'b0;
            #50;
            o_clk = 1'b1;
            #50;
            o_clk = 1'b0;
            #50;
            o_clk = 1'b1;
            reset = 1'b1;
            #50;
        end
    end

    initial begin
        #2000;
        $finish;
    end

endmodule
