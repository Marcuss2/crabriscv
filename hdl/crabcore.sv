module crabcore(
    input clk,
    input reset,

    output reg mem_addr_valid,
    output reg [31:0] mem_addr,

    output reg mem_data_valid,
    output reg [31:0] mem_data,

    input mem_ready,
    input [31:0] mem_input,

    output reg [1:0] io_mode,

    output [31:0] registers_debug [31:0],
    output [31:0] pc_debug,
    output [3:0] core_state_debug
);


wire [31:0] register_out [31:0];
reg [31:0] registers [31:0];
reg [31:0] program_counter;
reg [31:0] current_instruction;

integer i;
genvar c;

for (c = 1; c < 32; c++)
    assign register_out[c] = registers[c];

assign register_out[0] = 0;
assign pc_debug[31:0] = program_counter;

for (c = 0; c < 32; c++)
    assign registers_debug[c] = register_out[c];

localparam OP_IMM_ARITHM = 7'b0010011;
localparam OP_REG_ARITHM = 7'b0110011;
localparam OP_IMM_LOAD   = 7'b0000011;
localparam OP_STORE =      7'b0100011;
localparam OP_BRANCH =     7'b1100011;

wire [6:0] opcode = current_instruction[6:0];
wire [4:0] rd = current_instruction[11:7];
wire [2:0] funct3 = current_instruction[14:12];
wire [6:0] funct7 = current_instruction[31:25];
wire [4:0] rs1 = current_instruction[19:15];
wire [4:0] rs2 = current_instruction[24:20];
wire [11:0] i_immediate = current_instruction[31:20];
wire [11:0] s_immediate = {current_instruction[31:25], current_instruction[11:7]};
wire [12:0] b_immediate;
assign b_immediate[12] = current_instruction[31];
assign b_immediate[11] = current_instruction[7];
assign b_immediate[10:5] = current_instruction[30:25];
assign b_immediate[4:1] = current_instruction[11:8];
assign b_immediate[0] = 0;
wire [31:0] b_imm_extended = {{19{b_immediate[12]}}, b_immediate[12:1], 1'b0};
wire [31:0] rs1_register = register_out[rs1];
wire [31:0] rs2_register = register_out[rs2];

reg [31:0] rs1_register_alu;
reg [31:0] rs2_register_alu;
reg [2:0]  funct3_alu;
reg [6:0]  funct7_alu;
reg [11:0] imm_alu;

reg imm_select;
wire [31:0] alu_result;
wire branch_result;

wire [31:0] load_result;

alu alu1(.rs1(rs1_register_alu), .rs2(rs2_register_alu), .imm(imm_alu),
         .imm_select(imm_select), .funct3(funct3_alu), .funct7(funct7_alu),
         .result(alu_result));

branch_unit bu1(.rs1(rs1_register), .rs2(rs2_register), .funct3(funct3),
                .result(branch_result));

load_unit lu1(.mem_input(mem_input), .funct3(funct3), .result(load_result));

reg [3:0] core_state;

assign core_state_debug[3:0] = core_state;

localparam FETCH_STATE = 0;
localparam EXECUTE_STATE = 1;
localparam BRANCH_STATE = 2;
localparam LOAD_STATE = 3;
localparam AFTERLOAD_STATE = 4;

always @(posedge clk) begin
    if (reset) begin
        for (i = 1; i < 32; i++)
            registers[i] <= 0;
        program_counter <= 0;
        mem_data_valid <= 0;
        mem_addr <= 0;
        mem_addr_valid <= 1;
        core_state <= FETCH_STATE;
    end else begin
        if (core_state == FETCH_STATE && mem_ready) begin
            current_instruction <= mem_input;
            mem_addr_valid <= 0;
            case (opcode)
                OP_IMM_ARITHM : begin
                    rs1_register_alu <= rs1_register;
                    imm_alu <= i_immediate;
                    imm_select <= 1;
                    funct3_alu <= funct3;
                    funct7_alu <= funct7;
                    core_state <= EXECUTE_STATE;
                end
                OP_REG_ARITHM : begin
                    rs1_register_alu <= rs1_register;
                    rs2_register_alu <= rs2_register;
                    imm_select <= 0;
                    funct3_alu <= funct3;
                    funct7_alu <= funct7;
                    core_state <= EXECUTE_STATE;
                end
                OP_BRANCH : begin
                    rs1_register_alu <= program_counter;
                    rs2_register_alu <= b_imm_extended;
                    imm_select <= 0;
                    funct3_alu <= 0;
                    funct7_alu <= 0;
                    core_state <= BRANCH_STATE;
                end
                OP_IMM_LOAD : begin
                    mem_addr <= rs1_register + i_immediate;
                    mem_data_valid <= 1;
                    core_state <= LOAD_STATE;
                end
            endcase
        end else if (core_state == LOAD_STATE && mem_ready) begin
            registers[rd] <= load_result;
            core_state <= AFTERLOAD_STATE;
        end
    end
end

always @(negedge clk) begin
    if (reset) begin
        for (i = 1; i < 32; i++)
            registers[i] <= 0;
        program_counter = 0;
        core_state <= FETCH_STATE;
    end else begin
        case (core_state)
        EXECUTE_STATE : begin
            registers[rd] <= alu_result;
            core_state <= FETCH_STATE;
            program_counter = program_counter + 4;
            mem_addr <= program_counter;
            mem_addr_valid <= 1;
        end
        BRANCH_STATE : begin
            program_counter = branch_result ? alu_result : program_counter + 4;
            core_state <= FETCH_STATE;
            mem_addr_valid <= 1;
        end
        AFTERLOAD_STATE : begin
            program_counter = program_counter + 4;
            mem_addr <= program_counter;
            mem_addr_valid <= 1;
            core_state <= FETCH_STATE;
        end
        endcase
    end
        
end



endmodule
