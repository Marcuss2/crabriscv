module load_unit(
    input  [31:0] mem_input,
    input  [2:0]  funct3,

    output [31:0] result
);

wire [31:0] signed_byte = {{24{mem_input[7]}}, mem_input[7:0]};
wire [31:0] signed_half = {{16{mem_input[15]}}, mem_input[15:0]};
wire [31:0] unsigned_byte = {{24{1'b0}}, mem_input[7:0]};
wire [31:0] unsigned_half = {{16{1'b0}}, mem_input[15:0]};

assign result = funct3 == 3'h0 ? signed_byte :
               (funct3 == 3'h1 ? signed_half :
               (funct3 == 3'h2 ? mem_input :
               (funct3 == 3'h4 ? unsigned_byte :
               (funct3 == 3'h5 ? unsigned_half : 0))));

endmodule