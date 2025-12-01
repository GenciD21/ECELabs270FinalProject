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

    //Mr Clock Divider





     logic [31:0] ALU_result1;
    logic [31:0] ALU_result2;

    logic [7:0] led_sampled1;
    logic [7:0] led_sampled2;
    // assign J40_m4 = hz1_clk;


    //Alu 1? Question Mark
    assign right[7:0] = led_sampled1[7:0];

    always_ff @(posedge hz100, posedge reset) begin
    if (reset) begin
        led_sampled1 <= 0;
    end
    else begin
        led_sampled1 <= ALU_result1[7:0];
      end
    end


   logic [3:0] alu1_hundred;
   logic [3:0] alu1_tens;
   logic [3:0] alu1_ones;
   bin8_to_bcd3 alu_result_1
   (
    .bin(led_sampled1),
    .hundreds(alu1_hundred),
    .tens(alu1_tens),
    .ones(alu1_ones)
   );

    ssdec hundred_1
    (
       .in(alu1_hundred),
       .enable(1),
       .out(ss2)
    );

    ssdec tens_1
    (
       .in(alu1_tens),
       .enable(1),
       .out(ss1)
    );


    ssdec ones_1
    (
       .in(alu1_ones),
       .enable(1),
       .out(ss0)
    );

     //Alu 2? Question Mark
    assign left[7:0] = led_sampled2[7:0];

    always_ff @(posedge hz100, posedge reset) begin
    if (reset) begin
        led_sampled2 <= 0;
    end
    else begin
        led_sampled2 <= ALU_result2[7:0];
      end
    end


   logic [3:0] alu2_hundred;
   logic [3:0] alu2_tens;
   logic [3:0] alu2_ones;
   bin8_to_bcd3 alu_result_2
   (
    .bin(led_sampled2),
    .hundreds(alu2_hundred),
    .tens(alu2_tens),
    .ones(alu2_ones)
   );

    ssdec hundred_2
    (
       .in(alu2_hundred),
       .enable(1),
       .out(ss6)
    );

    ssdec tens_2
    (
       .in(alu2_tens),
       .enable(1),
       .out(ss5)
    );


    ssdec ones_2
    (
       .in(alu2_ones),
       .enable(1),
       .out(ss4)
    );




   // Actual Program
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


      cache1 cache_inst (
        .clk(hz100),
        .rst(reset),
        .freeze1(freeze1),
        .freeze2(freeze2),
        .dependency_on_ins2(dependency_on_ins2),
        .nothing_filled(nothing_filled),
        .instruction0(instruction0),
        .instruction1(instruction1)
    );

    scheduling_assistant_controlunit sched_assist_inst (
        .clk(hz100),
        .rst(reset),
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


    // Dual register file
    register_file reg_file_inst (
        .clk(hz100),
        .rst(reset),
        .reg_write(!freeze1),
        .reg_write2(freeze1 ? 1'b0 : !freeze2),
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