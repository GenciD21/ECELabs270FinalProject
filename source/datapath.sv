module datapath(
    input logic clk,
    input logic rst
);

    logic freeze1, freeze2;
    logic dependency_on_ins2;
    logic nothing_filled;
    logic [31:0] instruction0;
    logic [31:0] instruction1;
    logic datapath_1_enable;
    logic datapath_2_enable;
    logic [4:0] RegD1, reg1, reg2;
    logic [4:0] RegD2, reg3, reg4;

    cache1 cache_inst (
        .clk(clk),
        .rst(rst),
        .freeze1(freeze1),
        .freeze2(freeze2),
        .dependency_on_ins2(1'b0),
        .nothing_filled(nothing_filled),
        .instruction0(instruction0),
        .instruction1(instruction1)
    );

    scheduling_assistant sched_assist_inst (
        .clk(clk),
        .rst(rst),
        .freeze1(freeze1),
        .freeze2(freeze2),
        .dependency_on_ins2(dependency_on_ins2),
        .datapath_1_enable(datapath_1_enable),
        .datapath_2_enable(datapath_2_enable),
        .nothing_filled(nothing_filled),
        .instruction0(instruction0),
        .instruction1(instruction1),
        .RegD1(RegD1),
        .reg1(reg1),
        .reg2(reg2),
        .RegD2(RegD2),
        .reg3(reg3),
        .reg4(reg4),
        .ack1(1'b1),
        .ack2(1'b1)
    );

    // Datapath 1
    logic [31:0] ALU_result1;
    logic [31:0] ALU_result2;
    logic [31:0] imm1, imm2;
    logic ALU_src1, ALU_src2;
    logic [31:0] read_data1_dp1, read_data2_dp1;
    logic [31:0] read_data1_dp2, read_data2_dp2;

    control_unit DP_CU1 (
        .instruction(instruction0),
        .RegWrite(),
        .ALUSrc(ALU_src1),
        .MemRead(),
        .MemWrite(),
        .MemToReg(),
        .Jal(),
        .Jalr(),
        .Imm(imm1),
        .ALU_control(),
        .RegD(),
        .Reg2(),
        .Reg1()
    );

    ALU alu1(
        .src_A(read_data1_dp1),
        .src_B(ALU_src1 ? imm1 : read_data2_dp1),
        .ALU_control(1'b0),
        .ALU_result(ALU_result1),
        .BranchConditionFlag(),
        .MUL_EN()
    );

    // Datapath 2
    control_unit DP_CU2 (
        .instruction(instruction1),
        .RegWrite(),
        .ALUSrc(ALU_src2),
        .MemRead(),
        .MemWrite(),
        .MemToReg(),
        .Jal(),
        .Jalr(),
        .Imm(imm2),
        .ALU_control(),
        .RegD(),
        .Reg2(),
        .Reg1()
    );

    ALU alu2(
        .src_A(read_data1_dp2),
        .src_B(ALU_src2 ? imm2 : read_data2_dp2),
        .ALU_control(1'b0),
        .ALU_result(ALU_result2),
        .BranchConditionFlag(),
        .MUL_EN()
    );

    // Dual register file
    register_file reg_file_inst (
        .clk(clk),
        .rst(rst),
        .reg_write(!freeze1),
        .reg_write2(!freeze2),
        .reg1(reg1),
        .reg2(reg2),
        .reg3(reg3),
        .reg4(reg4),
        .regd(RegD1),
        .regd2(RegD2),
        .write_data(ALU_result1),
        .write_data2(ALU_result2),
        .read_data1(read_data1_dp1),
        .read_data2(read_data2_dp1),
        .read_data3(read_data1_dp2),
        .read_data4(read_data2_dp2)
    );

endmodule
