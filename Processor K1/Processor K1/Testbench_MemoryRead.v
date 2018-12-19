
`timescale 1ns / 100ps

module instructionRead ();

    parameter SIZE = 32;
    parameter INSTRUCTION_RANGE = 10;

    reg [SIZE-1:0] instructionMemory[0:255];
    integer n;

	initial begin
        #5;

		$readmemh("instruction.txt", instructionMemory); 

		#100;

		for(n=0;n<=INSTRUCTION_RANGE;n=n+1)	$display("%h",instructionMemory[n]);

        $finish;

	end

endmodule
