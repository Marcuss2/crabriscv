module alu (
    input [31:0] rs1,
    input [31:0] rs2,
    input [11:0] imm,
    input imm_select,
    input [2:0] funct3,
    input [6:0] funct7,

    output [31:0] result
);

wire [31:0] imm_msbextend = { {20{imm[11]}},imm[11:0]};
wire [31:0] imm_zeroextend = { {20{1'b0}}, imm[11:0]};

wire [31:0] operand = imm_select ? imm_msbextend : rs2;

wire signed [31:0] rs1_signed = rs1;
wire signed [31:0] operand_signed = operand;

wire [31:0] add_res = rs1 + operand;
wire [31:0] sub_res = rs1 - operand;
wire [31:0] xor_res = rs1 ^ operand;
wire [31:0] or_res  = rs1 | operand;
wire [31:0] and_res = rs1 & operand;
wire [31:0] sll_res = rs1 << operand[4:0];
wire [31:0] srl_res = rs1 >> operand[4:0];
wire [31:0] sra_res = rs1_signed >> operand[4:0];
wire [31:0] slt_res = rs1_signed < operand_signed ? 1 : 0;
wire [31:0] sltu_res = rs1 < imm_zeroextend ? 1 : 0;

wire [31:0] add_sub = !imm_select && funct7 == 7'h20 ? sub_res : add_res;
wire [31:0] sll_sra = funct7 == 7'h20 ? sra_res : srl_res;

assign result = funct3 == 3'h0 ? add_sub :
               (funct3 == 3'h4 ? xor_res :
               (funct3 == 3'h6 ? or_res  :
               (funct3 == 3'h7 ? and_res :
               (funct3 == 3'h1 ? sll_res :
               (funct3 == 3'h5 ? sll_sra :
               (funct3 == 3'h2 ? slt_res :
               (sltu_res)))))));

endmodule