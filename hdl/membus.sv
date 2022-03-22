module membus;

reg clk = 0;
reg reset = 0;

reg [31:0] memory [4096:0];

wire [31:0] mem_addr;
wire mem_addr_valid;
wire [31:0] mem_data_write;
wire mem_data_write_valid;

reg mem_ready;
reg [31:0] mem_input;

initial $readmemh("addi.txt", memory);

crabcore core1(.clk(clk), .reset(reset), .mem_addr_valid(mem_addr_valid), .mem_addr(mem_addr),
               .mem_data_valid(mem_data_write_valid), .mem_data(mem_data_write),
               .mem_ready(mem_ready), .mem_input(mem_input));

initial $display(memory[0]);

endmodule