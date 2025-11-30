module top (
  input        hz100, reset,
  input  [20:0] pb,
  output [7:0] left, right,
  output [7:0] ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output       red, green, blue,
  output [7:0] txdata,
  input  [7:0] rxdata,
  output       txclk, rxclk,
  input        txready, rxready
);

   assign left[0] = hz100;
   assign left[1] = hz1_clk_en;
   logic [31:0] ALU_result1;
    logic [31:0] ALU_result2;
    logic [31:0] imm1, imm2;
    logic ALU_src1, ALU_src2;
    logic [31:0] read_data1_dp1, read_data2_dp1;
    logic [31:0] read_data1_dp2, read_data2_dp2;

    //Testing Outputs
    logic [6:0] opcode_1;
    logic [6:0] opcode_2;

    //Depndency Signals
    logic freeze1, freeze2;
    logic dependency_on_ins2;
    logic nothing_filled;
    logic datapath_1_enable;
    logic datapath_2_enable;
    
    //Intructions from Queue
    logic [31:0] instruction0;
    logic [31:0] instruction1;

    //Registers
    logic [4:0] RegD1, reg1, reg2;
    logic [4:0] RegD2, reg3, reg4;

    logic clk_d;



    logic [7:0] led_sampled;
    clock_div clk_divider_1HZ
    (
        .clk(hz100),
        .n_rst(reset),
        .new_clk(hz1_clk_en),
        .div(2)
    );

    logic hz1_clk_en;
    // assign J40_m4 = hz1_clk;

    assign right[7:0] = led_sampled[7:0];

    always_ff @(posedge hz100, posedge reset) begin
    if (reset) begin
        led_sampled <= 0;
    end
    else if(hz1_clk_en) begin
        led_sampled <= ALU_result1[7:0];
    end
    end

    cache1 cache_inst ( // Clocked Stuffs
        .clk(hz100),
        .n_rst(reset),
        .en(hz1_clk_en),
        .freeze1(freeze1),
        .freeze2(freeze2),
        .dependency_on_ins2(1'b0),
        .nothing_filled(nothing_filled),
        .instruction0(instruction0),
        .instruction1(instruction1)
    );

    scheduling_assistant_controlunit sched_assist_inst ( // Clocked Stuffs
        .clk(hz100),
        .n_rst(reset),
        .en(hz1_clk_en),
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
        .ALUSrc1(ALU_src1),
        .ALUSrc2(ALU_src2),
        .Imm1(imm1),
        .Imm2(imm2)
    );

      // Dual register file
    register_file reg_file_inst ( // Clocked Stuffs
        .clk(hz100),
        .n_rst(reset),
        .en(hz1_clk_en),
        .reg_write((datapath_1_enable || !freeze1) && instruction0 != 32'd0),
        .reg_write2((datapath_2_enable || !freeze2) && instruction1 != 32'd0),
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

    ALU alu1(
        .src_A(read_data1_dp1),
        .src_B(ALU_src1 ? imm1 : read_data2_dp1),
        .instruction(instruction0),
        .ALU_control(1'b0),
        .ALU_result(ALU_result1),
        .opcode_out(opcode_1)
    );

    // Datapath 2
    ALU alu2(
        .src_A(read_data1_dp2),
        .src_B(ALU_src2 ? imm2 : read_data2_dp2),
        .instruction(instruction1),
        .ALU_control(1'b0),
        .ALU_result(ALU_result2),
        .opcode_out(opcode_2)
    );

endmodule