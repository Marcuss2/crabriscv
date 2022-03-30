module branch_unit(
    input signed [31:0] rs1,
    input signed [31:0] rs2,
    input [2:0] funct3,
    
    output result
);

wire unsigned [31:0] rs1_unsigned = rs1;
wire unsigned [31:0] rs2_unsigned = rs2;

assign result = funct3 == 3'h0 ? rs1          == rs2 :
               (funct3 == 3'h1 ? rs1          != rs2 :
               (funct3 == 3'h4 ? rs1          <  rs2 :
               (funct3 == 3'h5 ? rs1          >= rs2 :
               (funct3 == 3'h6 ? rs1_unsigned <  rs2_unsigned :
               (funct3 == 3'h7 ? rs1_unsigned >= rs2_unsigned : 0)))));

endmodule
