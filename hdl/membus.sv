module membus(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);

wire clk = CLOCK_50;
wire reset = !KEY[0];

//timer timer0(.clk(CLOCK_50), .period(SW), .out(clk));

// Quartus Prime Verilog Template
// Single port RAM with single read/write address and initial contents 
// specified with an initial block

wire mem_addr_valid;
wire [31:0] mem_addr;

wire mem_data_write_valid;
wire [31:0] mem_data;

reg mem_ready = 0;
reg [31:0] mem_input = 0;
reg mem_write_done = 0;

wire [2:0] io_mode;
wire mem_ack;
reg mem_ack_bus = 0;

wire [3:0] be = io_mode[1:0] == 0 ? 4'b0001 :
                io_mode[1:0] == 1 ? 4'b0011 :
                                    4'b1111;

reg [3:0] byte_enable = 0;

reg mem_enable = 0;

wire [31:0] wmem_data_out;

wire busy;
reg write = 0;

localparam MEM_IDLE = 0;
localparam MEM_WRITE_1 = 1;
localparam MEM_WRITE_2 = 2;
localparam MEM_READ = 3;

reg [1:0] state = MEM_IDLE;

reg [31:0] hex_out = 0;

always @(posedge clk) begin
    if (reset) begin
        mem_ready <= 0;
        mem_input <= 0;
        mem_write_done <= 1;
        byte_enable <= 0;
        mem_enable <= 1;
        write <= 0;
        state <= MEM_READ;
		  mem_ack_bus <= 0;
		  hex_out <= 0;
    end else if (state == MEM_IDLE) begin
        if (mem_addr_valid && mem_data_write_valid && mem_ack != mem_ack_bus) begin
            if (mem_addr[31:14] == 0) begin
                mem_input <= mem_data;
                mem_enable <= 1;
                mem_write_done <= 0;
                byte_enable <= be;
                mem_ready <= 0;
                write <= 1;
                state <= MEM_WRITE_1;
					 mem_ack_bus <= mem_ack;
            end else if (mem_addr == 32'hfffffffc) begin
					hex_out <= mem_data;
					mem_ack_bus <= mem_ack;
					state <= MEM_WRITE_1;
				end
        end else if (mem_addr_valid && mem_ack != mem_ack_bus) begin
            if (mem_addr[31:14] == 0) begin
                mem_enable <= 1;
                mem_ready <= 0;
                mem_write_done <= 0;
                state <= MEM_READ;
					 mem_ack_bus <= mem_ack;
            end
        end
    end else if (state == MEM_WRITE_1) begin
        mem_enable <= 0;
        byte_enable <= 0;
        write <= 0;
        state <= MEM_WRITE_2;
    end else if (state == MEM_WRITE_2) begin
        if (busy == 0) begin
            mem_write_done <= 1;
            mem_ready <= 1;
            state <= MEM_IDLE;
        end
    end else if (state == MEM_READ) begin
        if (busy == 0) begin
            mem_ready <= 1;
            state <= MEM_IDLE;
            mem_input <= wmem_data_out;
        end
    end
end

wire [31:0] ins_loaded;

wire [3:0] core_state;

wire [31:0] stack_pointer;

crabcore core1(.clk(clk), .reset(reset), .mem_addr_valid(mem_addr_valid), .mem_addr(mem_addr),
               .mem_data_valid(mem_data_write_valid), .mem_data(mem_data),
               .mem_ready(mem_ready), .mem_input(mem_input), .io_mode(io_mode),
               .mem_write_done(mem_write_done), .mem_ack(mem_ack), .mem_addr_ack(mem_ack_bus),
					.stack_pointer(stack_pointer));

memorywrapper wrappedmemory(.clk(clk), .reset(reset), .enable(mem_enable), .mem_data(mem_data),
                            .mem_addr(mem_addr[13:0]), .byte_enable(byte_enable),
                            .write(write), .data_out(wmem_data_out),
                            .busy(busy));

segment7 seg0(.enable(1), .data(hex_out[3:0]), .seg(HEX0));
segment7 seg1(.enable(1), .data(hex_out[7:4]), .seg(HEX1));
segment7 seg3(.enable(1), .data(hex_out[11:8]), .seg(HEX2));
segment7 seg4(.enable(1), .data(hex_out[15:12]), .seg(HEX3));
segment7 seg5(.enable(1), .data(hex_out[19:16]), .seg(HEX4));
segment7 seg6(.enable(1), .data(hex_out[23:20]), .seg(HEX5));

endmodule
