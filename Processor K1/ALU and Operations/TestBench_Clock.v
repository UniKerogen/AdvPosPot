`include "clock.v"
`timescale 1ns / 100ps

module testbench_Clock;

    wire clk;
    reg L, R, H, reset, set;

    clock clkM(.clk(clk));

    initial begin
        $dumpfile("Wave_clock.vcd");
        $dumpvars;
    end

    initial begin
        $monitor("t=%3d clk=%b", $time, clk);
        reset = 0;
        #15 L = 0; R = 0; H = 0;
        #20 L = 0; R = 0; H = 1;
        #25 L = 0; R = 1; H = 0;
        #30 L = 0; R = 1; H = 1;
        #35 L = 1; R = 0; H = 0;
        #45 L = 1; R = 0; H = 1;
        #50 L = 1; R = 1; H = 0;
        #55 L = 1; R = 1; H = 1;

        reset = 1;
        #60 L = 0; R = 0; H = 0;
        #65 L = 0; R = 0; H = 1;
        #70 L = 0; R = 1; H = 0;
        #75 L = 0; R = 1; H = 1;
        #80 L = 1; R = 0; H = 0;
        #85 L = 1; R = 0; H = 1;
        #90 L = 1; R = 1; H = 0;
        #95 L = 1; R = 1; H = 1;
        $stop;
    end

    initial begin
        set = 0;
    end

        always @(posedge clk) begin
            set = ~set;
        end
    //end

endmodule
