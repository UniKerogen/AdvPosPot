`include "OperationModule.v"
`timescale 1ns / 100ps

module alu_s #(parameter SIZE=32) (input [2:0] control, input aluEnable, input signed [SIZE-1:0] num1, input signed [SIZE-1:0] num2, input reset, input clk,
                                output reg signed [SIZE*2-1:0] output1, output reg signed [SIZE*2-1:0] output2, output reg aluDone);

    reg signed [SIZE-1:0] S_fir_num, S_sec_num;

    wire signed [SIZE-1:0] SA_sum, SD_quotient, SD_reminder, SS_difference;
    wire signed [SIZE*2-1:0] SM_product, UM_product;

    adderNS #(SIZE) addns(.fir_num(S_fir_num), .sec_num(S_sec_num),
                        .sum(SA_sum));

    dividerNS #(SIZE) divns(.divident(S_fir_num), .divisor(S_sec_num),
                        .quotient(SD_quotient), .reminder(SD_reminder));

    multiplierNS #(SIZE) mulns(.fir_num(S_fir_num), .sec_num(S_sec_num),
						.product(SM_product));

    subtractorNS #(SIZE) subns(.fir_num(S_fir_num), .sec_num(S_sec_num),
    						.difference(SS_difference));

    always @* begin
        if (reset == 1) begin
            $display("### ALU Module Reset ###");
            aluDone = 1'b0;
        end
    end

    always @(*) begin
		if (aluEnable == 1'b1) begin
			  $display("---- ALU Module ----");
			  S_fir_num = num1; S_sec_num = num2;
			  output1 = 0; output2 = 0;
			  #10;
					case (control)
						 3'b000: begin
							  //$display("Operation: Addition");
							  output1 = SA_sum;
							  end
						 3'b001: begin
							  //$display("Operation Subtraction");
							  output1 = SS_difference;
							  end
						 3'b010: begin
							  //$display("Operation Multiplication");
							  output1 = SM_product;
							  end
						 3'b011: begin
							  //$display("Operation Division");
							  //If X / 0, set both to MAX.
							  if (S_sec_num == 0) begin
									output1 = {SIZE{1'b1}};
									output2 = {SIZE{1'b1}};
									end
							  else begin
									output1 = SD_quotient;
									output2 = SD_reminder;
									end
							  end
						 3'b100: begin
							  //$display("Operation bitwise Negate");
							  output1 = ~num1;
							  end
						 3'b101: begin
							  //$display("Operation bitwise And");
							  output1 = num1 & num2;
							  end
						 3'b110: begin
							  //$display("Operation bitwise Or");
							  output1 = num1 | num2;
							  end
						 3'b111: begin
							 output1 = num1;
							 output2 = num2;
							 aluDone = 1'b1;
							 end
					endcase
			#10; aluDone = 1'b1;
		end

    end

endmodule
