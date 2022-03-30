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

wire [31:0] register_debug[31:0];
wire [31:0] pc_debug;
wire [3:0] core_state_debug;

initial $readmemh("addi.txt", memory);

localparam WORD_IO_MODE = 2'h0;
localparam HALF_IO_MODE = 2'h1;
localparam BYTE_IO_MODE = 2'h2;

wire [1:0] io_mode;

reg [2:0] mem_state;

crabcore core1(.clk(clk), .reset(reset), .mem_addr_valid(mem_addr_valid), .mem_addr(mem_addr),
               .mem_data_valid(mem_data_write_valid), .mem_data(mem_data_write),
               .mem_ready(mem_ready), .mem_input(mem_input), .registers_debug(register_debug),
               .pc_debug(pc_debug), .core_state_debug(core_state_debug), .io_mode(io_mode));

localparam IDLE_STATE = 0;
localparam WRITE_STATE = 1;
localparam READ_STATE = 2;


always @(negedge clk) begin
    case (mem_state)
    IDLE_STATE : begin
        if (mem_addr_valid && mem_data_write_valid) begin
            mem_state <= WRITE_STATE;
            case (io_mode)
            WORD_IO_MODE : memory[mem_addr[14:2]] <= mem_data_write;
            HALF_IO_MODE : memory[mem_addr[14:2]][15:0] <= mem_data_write[15:0];
            BYTE_IO_MODE : memory[mem_addr[14:2]][7:0] <= mem_data_write[7:0];
            endcase
        end else if (mem_addr_valid) begin
            mem_state <= READ_STATE;
            mem_input <= memory[mem_addr[14:2]];
            mem_ready <= 1;
        end
    end
    WRITE_STATE : begin
        if (mem_addr_valid && !mem_data_write_valid) begin
            mem_state <= READ_STATE;
            mem_input <= memory[mem_addr[14:2]];
            mem_ready <= 1;
        end
    end
    READ_STATE : begin
        mem_state <= IDLE_STATE;
        mem_ready <= 0;
    end
    endcase
end

integer i;
integer j;

initial begin
    reset <= 1;
    #1;
    clk <= 1;
    #1;
    reset <= 0;
    #1;
    clk <= 0;
    #1;
    for (j = 0; j < 10; j++) begin
        clk <= !clk;
        $display("clk: %b, PC: %d, state: %d", clk,  pc_debug, core_state_debug);
        for (i = 0; i < 32; i++)
            $display("%d: %d", i, register_debug[i]);
        #1;
    end
end

endmodule
