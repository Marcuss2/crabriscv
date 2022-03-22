module crabcore(
    input clk,
    input reset,

    output reg mem_addr_valid,
    output reg [31:0] mem_addr,

    output reg mem_data_valid,
    output reg [31:0] mem_data,

    input mem_ready,
    input [31:0] mem_input,

    output [31:0] registers_debug [31:0]
);

wire [31:0] register_out [31:0];
reg [31:0] registers [31:0];
reg [31:0] program_counter;

integer i;
genvar c;

for (c = 1; c < 32; c++)
    assign register_out[c] = registers[c];

assign register_out[0] = 0;

for (c = 0; c < 32; c++)
    assign registers_debug[c] = register_out[c];


always @(posedge clk) begin
    if (reset) begin

        for (i = 0; i < 32; i++) registers[i] <= 0;
        program_counter <= 0;
    end else begin

    end
end



endmodule