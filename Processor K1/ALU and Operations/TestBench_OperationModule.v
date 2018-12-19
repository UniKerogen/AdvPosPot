`include "OperationModule.v"
`timescale 1ns / 100ps

module testbenchOperationModule;

    parameter SIZE = `VAR_SIZE;

    reg signed [SIZE-1:0] S_fir_num, S_sec_num;
    reg [SIZE-1:0] U_fir_num, U_sec_num;

    wire signed [SIZE-1:0] SA_sum, SD_quotient, SD_reminder, SS_difference;
    wire signed [SIZE*2-1:0] SM_product, UM_product;
    wire [SIZE-1:0] UA_sum, UD_quotient, UD_reminder, US_difference;

    adderNS #(SIZE) addns(.fir_num(S_fir_num), .sec_num(S_sec_num),
                        .sum(SA_sum));

    dividerNS #(SIZE) divns(.divident(S_fir_num), .divisor(S_sec_num),
                        .quotient(SD_quotient), .reminder(SD_reminder));

    multiplierNS #(SIZE) mulns(.fir_num(S_fir_num), .sec_num(S_sec_num),
						.product(SM_product));

    subtractorNS #(SIZE) subns(.fir_num(S_fir_num), .sec_num(S_sec_num),
    						.difference(SS_difference));

    adderNU #(SIZE) addnu(.fir_num(U_fir_num), .sec_num(U_sec_num),
                        .sum(UA_sum));

    dividerNU #(SIZE) divnu(.divident(U_fir_num), .divisor(U_sec_num),
						.quotient(UD_quotient), .reminder(UD_reminder));

    multiplierNU #(SIZE) mulnu(.fir_num(U_fir_num), .sec_num(U_sec_num),
                        .product(UM_product));

    subtractorNU #(SIZE) subnu(.fir_num(U_fir_num), .sec_num(U_sec_num),
    						.difference(US_difference));


    initial begin
        //create the vcd file for waveform
        $dumpfile("Wave_OperationModule.vcd");
        $dumpvars;
    end

    initial begin
        $monitor("Time = %g", $time);

        #5;

        S_fir_num = `NUM1;
        S_sec_num = `NUM2;
        S_sec_num = ~S_sec_num + 1;

        U_fir_num = `NUM1;
        U_sec_num = `NUM2;

        #5;
        $display(" ");
        $display("N Bit Operation Module");
        $display(" ");
        $display("N Bit Unsigned Adder: %d + %d = %d", U_fir_num, U_sec_num, UA_sum);
        $display("N Bit Signed Adder: %d + %d = %d", S_fir_num, S_sec_num, SA_sum);
        $display(" ");
        $display("N Bit Unsigned Subtractor: %d - %d = %d", U_fir_num, U_sec_num, US_difference);
        $display("N Bit Signed Subtractor: %d - %d = %d", S_fir_num, S_sec_num, SS_difference);
        $display(" ");
        $display("N Bit Unsigned Multiplier: %d * %d = %d", U_fir_num, U_sec_num, UM_product);
        $display("N Bit Signed Multiplier: %d * %d = %d", S_fir_num, S_sec_num, SM_product);
        $display(" ");
        $display("N Bit Unsigned Divider: %d / %d = %d ... %d", U_fir_num, U_sec_num, UD_quotient, UD_reminder);
        $display("N Bit Signed Divider: %d / %d = %d ... %d", S_fir_num, S_sec_num, SD_quotient, SD_reminder);
        $display(" ");

        #10;
        $finish;

    end

endmodule
