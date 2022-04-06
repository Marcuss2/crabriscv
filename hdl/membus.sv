module membus;

reg clk = 0;
reg reset = 0;

reg [31:0] memory_reversed [4096:0];

reg [31:0] memory [4096:0];

wire [31:0] mem_addr;
wire mem_addr_valid;
wire [31:0] mem_data_write;
wire mem_data_write_valid;

reg mem_ready;
reg [31:0] mem_input;

wire [31:0] register_debug[31:0];
wire [31:0] pc_debug;
wire [4:0] core_state_debug;

initial $readmemh("output.hex", memory_reversed);

initial begin
    for (i = 0; i < 4096; i++) begin
        memory[i][7:0] = memory_reversed[i][31:24];
        memory[i][15:8] = memory_reversed[i][23:16];
        memory[i][23:16] = memory_reversed[i][15:8];
        memory[i][31:24] = memory_reversed[i][7:0];
    end
end

integer i;
integer j;

localparam BYTE_IO_MODE = 2'h0;
localparam HALF_IO_MODE = 2'h1;
localparam WORD_IO_MODE = 2'h2;

wire [2:0] io_mode;

reg prev_mem_ack = 0;
wire mem_ack;

reg [2:0] mem_state = IDLE_STATE;

reg mem_write_done = 0;

crabcore core1(.clk(clk), .reset(reset), .mem_addr_valid(mem_addr_valid), .mem_addr(mem_addr),
               .mem_data_valid(mem_data_write_valid), .mem_data(mem_data_write),
               .mem_ready(mem_ready), .mem_input(mem_input), .registers_debug(register_debug),
               .pc_debug(pc_debug), .core_state_debug(core_state_debug), .io_mode(io_mode),
               .mem_write_done(mem_write_done), .mem_ack(mem_ack));

localparam IDLE_STATE = 0;
localparam WRITE_STATE = 1;
localparam READ_STATE = 2;


always @(clk) begin
    if (reset) begin
        mem_state <= IDLE_STATE;
    end
    case (mem_state)
    IDLE_STATE : begin
        if (mem_addr_valid && mem_data_write_valid) begin
            mem_state <= WRITE_STATE;
            case (io_mode)
            WORD_IO_MODE : memory[mem_addr[14:2]] <= mem_data_write;
            HALF_IO_MODE : memory[mem_addr[14:2]][15:0] <= mem_data_write[15:0];
            BYTE_IO_MODE : memory[mem_addr[14:2]][7:0] <= mem_data_write[7:0];
            endcase
            mem_write_done <= 1;
            prev_mem_ack <= mem_ack;
        end else if (mem_addr_valid) begin
            mem_state <= READ_STATE;
            mem_input <= memory[mem_addr[14:2]];
            mem_ready <= 1;
            prev_mem_ack <= mem_ack;
        end
    end
    WRITE_STATE : begin
        if (mem_addr_valid && !mem_data_write_valid) begin
            mem_state <= READ_STATE;
            mem_input <= memory[mem_addr[14:2]];
            mem_ready <= 1;
            prev_mem_ack <= mem_ack;
            mem_write_done <= 0;
        end
    end
    READ_STATE : begin
        if (mem_ack != prev_mem_ack) begin
            mem_write_done <= 0;
            mem_state <= IDLE_STATE;
            mem_ready <= 0;
        end
    end
    endcase
end



initial begin
    $dumpfile("vars.vcd");
    $dumpvars;
    reset <= 1;
    clk <= 1;
    #1;
    clk <= 0;
    #1;
    reset <= 0;
    #1;
    clk <= 0;
    #1;
    for (j = 0; j < 1000; j++) begin
        clk <= !clk;
        $display("clk: %b, PC: %h, state: %d", clk,  pc_debug, core_state_debug);
        for (i = 0; i < 32; i++)
            $display("%d: %d", i, register_debug[i]);
        #1;
    end
end

endmodule
