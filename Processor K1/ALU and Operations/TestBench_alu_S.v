`include "alu_S.v"
`timescale 1ns / 100ps

module testbenchALU_S;

    parameter SIZE = `VAR_SIZE;

    reg [2:0] control;
    reg signed [SIZE-1:0] num1, num2;
    wire signed [SIZE*2-1:0] output1, output2;

    alu_s #(SIZE) aluS(.control(control), .num1(num1), .num2(num2),
                        .output1(output1), .output2(output2));

    initial begin
        //create the vcd file for waveform
        $dumpfile("Wave_aluSModule.vcd");
        $dumpvars;
    end

    initial begin
        #2;
        control = `CONTROL;
        num1 = `NUM1;
        num2 = `NUM2;

        $display("Control: %b (%d) | Size: %d | num1 = %d | num2 = %d", control, control, SIZE, num1, num2);

        #5;
        $display("Input Control Signal is %b", control);
        case (control)
            3'b000: $display("Operation: Addition");
            3'b001: $display("Operation Subtraction");
            3'b010: $display("Operation Multiplication");
            3'b011: $display("Operation Division");
            3'b100: $display("Operation Logic Negate");
            3'b101: $display("Operation Logic And");
            3'b110: $display("Operation Logic Or");
            default: $display("Invalid Control Input");
        endcase

        $display("The result for output1 is:");
        $display("BINARY: %b", output1);
        $display("DECIMAL: %d", output1);
        $display("The result for output2 is %d", output2);

        #5;
        $finish;
    end

endmodule
