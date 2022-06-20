module memorywrapper(
    input clk,
    input reset,
    input enable,
    input [31:0] mem_data,
    input [13:0] mem_addr,
    input [3:0] byte_enable,
    input write,
    output reg [31:0] data_out,
    output busy
);

reg [2:0] state = 0;
reg write_enable = 0;
reg [3:0] be = 0;
reg [11:0] mem_addr_in = 0;
reg [7:0] data_bytes [3:0];
reg [7:0] mem_data_write;
wire [31:0] q;

wire [7:0] data0;
wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;
assign data0 = data_bytes[0];
assign data1 = data_bytes[1];
assign data2 = data_bytes[2];
assign data3 = data_bytes[3];

assign busy = |state || write_enable;
assign be_data = be;
assign state_d = state;

always @(negedge clk) begin
    if (reset) begin
        state = 1;
        mem_addr_in = 0;
		  write_enable = 0;
    end else begin
        if (enable && write && state <= 1) begin
            data_bytes[3] = mem_data[7:0];
            data_bytes[2] = mem_data[15:8];
            data_bytes[1] = mem_data[23:16];
            data_bytes[0] = mem_data[31:24];
            state = byte_enable[3:1];
            be = 4'b0001;
            mem_addr_in = mem_addr[13:2];
            mem_data_write = mem_data[31:24];
            write_enable = 1;
        end else if (write_enable && (be[3:0] & {state,1'b1})) begin
            be = be << 1;
            case (be)
                4'b0010 : mem_data_write = data_bytes[1];
                4'b0100 : mem_data_write = data_bytes[2];
                4'b1000 : mem_data_write = data_bytes[3];
            endcase
        end else if (write_enable) begin
            write_enable = 0;
				state = 0;
				be = 0;
        end else if (enable && state == 0) begin
            state = 3;
            mem_addr_in = mem_addr[13:2];
        end else if (state == 3) begin
            state = 1;
        end else if (state == 1) begin
            state = 0;
            data_out[7:0] = q[31:24];
            data_out[15:8] = q[23:16];
            data_out[23:16] = q[15:8];
            data_out[31:24] = q[7:0];
        end
    end
end


memory mem1(.clk(clk), .waddr(mem_addr_in), .raddr(mem_addr_in), .be(be), 
				.we(write_enable), .wdata(mem_data_write), .q(q));

endmodule