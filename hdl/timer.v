module timer #(parameter WIDTH = 32, parameter PERIOD = 25000000)(
	input clk,		// clk system clock
	input [9:0] period,
	output reg out // output pulse
	);
	
   // *********************************************************************
	//
	// TASK 1:  we need add inputs enable and reset to the code from week 06
	//
	// *********************************************************************

	reg [(WIDTH-1):0] counter;
	
	wire [24:0] p;
	assign p[24:15] = period;
	assign p[14:2] = 0;
	assign p[1] = 1;
	assign p[0] = 0;
	
	always @(posedge clk) begin
		if (counter < p) begin
			counter <= counter + {{WIDTH-1{1'b0}},1'b1};
			out <= 1'b0;
		end
		else begin
			counter <= 0;
			out <= 1'b1;
		end
	end
endmodule