`include "clock.v"
`timescale 1ns / 100ps

///////////////////////////////////////////////////////////
//Adder Module
///////////////////////////////////////////////////////////

//Half Adder
module half_adder(input fir_num, input sec_num,
				  output sum, output carry);
		assign carry = fir_num & sec_num;
		assign sum = fir_num ^ sec_num;
endmodule

//Full adder
module full_adder(input fir_num, input sec_num, input carry_in,
						output sum, output carry_out);

	// Initialize Wire based on the Design Diagram
	wire wire_1, wire_2, wire_3;
	//Assign Value based on the Design Diagram
	assign wire_1 = fir_num ^ sec_num;
	assign wire_2 = wire_1 & carry_in;
	assign wire_3 = fir_num & sec_num;
	assign sum = wire_1 ^ carry_in;
	assign carry_out = wire_2 | wire_3;

endmodule

//Adder N Bit - Signed
module adderNS #(parameter SIZE=32) (input signed [SIZE-1:0] fir_num, input signed [SIZE-1:0] sec_num, input rst, input clk,
						output signed [SIZE-1:0] sum);

	wire end_carry; wire [SIZE-1:0] carry;

	genvar gi; //Prepare Variable for FOR loop
	generate
		for(gi=0; gi<SIZE; gi=gi+1) begin
			if (gi==0) begin
				//use half_adder for the first bit
				half_adder has(.fir_num(fir_num[0]),.sec_num(sec_num[0]),
									.sum(sum[0]),.carry(carry[0]));
			end
			else begin
				//use full_adder for the rest of bits
				full_adder fas(.fir_num(fir_num[gi]),.sec_num(sec_num[gi]), .carry_in(carry[gi-1]),
									.sum(sum[gi]), .carry_out(carry[gi]));
			end
		end
		//Assign carry to the Last Carry
		assign end_carry = carry[SIZE-1];

	endgenerate

endmodule

//Adder N Bit - Unsigned
module adderNU #(parameter SIZE=32) (input [SIZE-1:0] fir_num, input [SIZE-1:0] sec_num, input rst, input clk,
						output [SIZE-1:0] sum);

	wire end_carry; wire [SIZE-1:0] carry;

	genvar gi; //Prepare Variable for FOR loop
	generate
		for(gi=0; gi<SIZE; gi=gi+1) begin
			if (gi==0) begin
				//use half_adder for the first bit
				half_adder hau(.fir_num(fir_num[0]),.sec_num(sec_num[0]),
									.sum(sum[0]),.carry(carry[0]));
			end
			else begin
				//use full_adder for the rest of bits
				full_adder fau(.fir_num(fir_num[gi]),.sec_num(sec_num[gi]), .carry_in(carry[gi-1]),
									.sum(sum[gi]), .carry_out(carry[gi]));
			end
		end
		//Assign carry to the Last Carry
		assign end_carry = carry[SIZE-1];

	endgenerate

endmodule

///////////////////////////////////////////////////////////
//subtractor Module
///////////////////////////////////////////////////////////

//Subtractor N Bit - Unsigned
module subtractorNU #(parameter SIZE=32) (input [SIZE-1:0] fir_num, input [SIZE-1:0] sec_num, input clk, input rst,
						output [SIZE-1:0] difference);

		reg signed [SIZE-1:0] sec_num_temp;

		adderNS #(SIZE) subNU (.fir_num(fir_num), .sec_num(sec_num_temp),
							.sum(difference));

		always @(posedge clk) begin
			sec_num_temp = ~sec_num + 1;
		end

endmodule

//Subtractor N Bit - Signed
module subtractorNS #(parameter SIZE=32) (input signed [SIZE-1:0] fir_num, input signed [SIZE-1:0] sec_num, input clk, input rst,
						output [SIZE-1:0] difference);

		reg signed [SIZE-1:0] sec_num_temp;

		adderNS #(SIZE) subNS (.fir_num(fir_num), .sec_num(sec_num_temp),
							.sum(difference));

		always @(*) begin
			sec_num_temp = ~sec_num + 1;
		end

endmodule

///////////////////////////////////////////////////////////
//Multiplier Module
///////////////////////////////////////////////////////////

//Multiplier N Bit - Unsigned
module multiplierNU #(parameter SIZE=32) (input [SIZE-1:0] fir_num, input [SIZE-1:0] sec_num, input clk, input rst,
						output reg [SIZE*2-1:0] product);

    integer ji;

    always @(posedge clk) begin
        product = 0;
        for(ji=0; ji<SIZE; ji=ji+1) begin
            if (fir_num[ji] == 1'b1) begin
                product = product + (sec_num << ji);
            end
        end
    end

	always @* begin
		if(rst==1) product = 0;
    end

endmodule

//Multiplier N Bit - Signed
module multiplierNS #(parameter SIZE=32) (input signed [SIZE-1:0] fir_num, input signed [SIZE-1:0] sec_num, input clk, input rst,
						output reg signed [SIZE*2-1:0] product);

    reg [SIZE-1:0] fir_num_temp, sec_num_temp;
    reg [1:0] sign; integer ji;

    always @(*) begin
				sign = 2'b00;

				if (fir_num[SIZE-1] == 1'b1) begin
						fir_num_temp = ~fir_num + 1;
						sign[1] = 1'b1;
				end
				else begin
						fir_num_temp = fir_num;
				end

				if (sec_num[SIZE-1] == 1'b1) begin
						sec_num_temp = ~sec_num + 1;
						sign[0] = 1'b1;
				end
				else begin
						sec_num_temp = sec_num;
				end

        product = 0;
        for(ji=0; ji<SIZE; ji=ji+1) begin
            if (fir_num_temp[ji] == 1'b1) begin
                product = product + (sec_num_temp << ji);
            end
        end

        case (sign)
            2'b01, 2'b10: begin
				product = product - 1;
				product = ~product;
				end
            default: product = product;
        endcase
	end

	always @* begin
		if(rst==1) product = 0;
    end

endmodule

///////////////////////////////////////////////////////////
//Divider Module
///////////////////////////////////////////////////////////

//Divider N Bit - Unsigned
module dividerNU #(parameter SIZE = 32) (input [SIZE-1:0] divident, input [SIZE-1:0] divisor, input clk, input rst,
                                        output reg [SIZE-1:0] quotient, output reg [SIZE-1:0] reminder);

    reg [SIZE*2-1:0] differ;
    integer li;

    always @(posedge clk) begin

        quotient = {SIZE{1'b0}}; //Initilize quotient
        differ = {{SIZE{1'b0}}, divident}; //Initilize Reminder

		differ = differ << 1;

        for (li=1; li<=SIZE; li=li+1) begin
            differ[SIZE*2-1:SIZE] = differ[SIZE*2-1:SIZE] - divisor;
				if (differ[SIZE*2-1] == 1'b1) begin
					differ[SIZE*2-1:SIZE] = differ[SIZE*2-1:SIZE] + divisor;
					differ = differ << 1;
				end
				else begin
					differ = differ << 1;
					differ[0] = 1'b1;
				end
        end
		  differ[SIZE*2-1:SIZE] = {1'b0, differ[SIZE*2-1:SIZE+1]};
		  reminder = differ[SIZE*2-1:SIZE];
		  quotient = differ[SIZE-1:0];
  	end

	always @(*) begin
		if(rst == 1) begin
			quotient = 0;
			reminder = 0;
		end
    end

endmodule


//Divider N Bit - Signed
module dividerNS #(parameter SIZE = 32) (input signed [SIZE-1:0] divident, input signed [SIZE-1:0] divisor, input clk, input rst,
                                        output reg [SIZE-1:0] quotient, output reg [SIZE-1:0] reminder);

    reg [SIZE*2-1:0] dividentP, divisorP, differ;
    reg [SIZE-1:0] dividentN, divisorN;
	 reg [1:0] sign;
    integer li;

    always @(*) begin
        dividentN = divident;
        divisorN = divisor;
        li = 0; sign = 2'b00;

        if(dividentN[SIZE-1] == 1) begin
            dividentN = ~dividentN + 1;
            sign[0] = 1'b1;
        end
        if(divisorN[SIZE-1] == 1) begin
            divisorN = ~divisorN + 1;
            sign[1] = 1'b1;
        end

		  quotient = {SIZE{1'b0}}; //Initilize quotient
        differ = {{SIZE{1'b0}}, dividentN}; //Initilize Reminder

		  differ = differ << 1;

        for (li=1; li<=SIZE; li=li+1) begin
            differ[SIZE*2-1:SIZE] = differ[SIZE*2-1:SIZE] - divisorN;
				if (differ[SIZE*2-1] == 1'b1) begin
					differ[SIZE*2-1:SIZE] = differ[SIZE*2-1:SIZE] + divisorN;
					differ = differ << 1;
				end
				else begin
					differ = differ << 1;
					differ[0] = 1'b1;
				end
        end

		  differ[SIZE*2-1:SIZE] = {1'b0, differ[SIZE*2-1:SIZE+1]};
		  reminder = differ[SIZE*2-1:SIZE];
		  quotient = differ[SIZE-1:0];


        if (sign == 2'b10) begin
            quotient = ~quotient + 1;
	    reminder = ~reminder + 1;
        end
		if (sign == 2'b01) begin
			quotient = ~quotient + 1;
	  	end
	  	if (sign == 2'b11) begin
			reminder = ~reminder + 1;
		end

	end

	always @(*) begin
		if(rst == 1) begin
			quotient = 0;
			reminder = 0;
		end
    end

endmodule
