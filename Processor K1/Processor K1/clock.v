`timescale 1ns / 100ps

module clock(output reg clk);

    initial begin
        clk = 0;
        forever begin
            #1;
            clk = ~clk;
        end
    end

endmodule
