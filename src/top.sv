module top (
    input  logic clk,       // 100 MHz clock from PCF
    input  logic btn,       // pushbutton
    output logic [7:0] led,  // onboard LED but
    input logic rst_pin,
    // input logic J39_b15, J39_c15, J39_b20, J39_e11,

    // //right line J39
    // input logic J39_b10, J39_a14, J39_d13, J39_e12,

    // input logic J40_m3,
    // // //right line J40
    output logic J40_j5, J40_a15, J40_h2, J40_j4, 
    J40_j3, J40_l4, J40_m4, J40_n4, J40_k5, J40_p5, // Some of these GPIOs are probably tied to some other 
    //driven signal because they arent working

    output logic J39_b15, J39_c15, J39_b20, J39_e11, J39_d11, J39_b13, J39_b12, J39_d15, J39_d12, // Seg 1 GPIO
    
    output logic J39_c12, J39_e12, J39_c13, J39_d13, J39_a14,J39_e13,J39_a9, J39_b10, J39_e7

   //J39_c13, //Display 1
    //J39_d13  // Disply 2
    //J39_c12, // A
    //J39_e12, // B
    //J39_a14
    //J39_e13 
    //J39_A9
    //J39_B10
    //J39_E7 
);
    

    alu_7seg_mux goon0 (
    .clk(clk), 
    .alu_result(ALU_result1), 
    .seg({J39_e11,J39_b20,J39_d11,J39_b13,J39_b12,J39_d15,J39_d12}), // A-G 
    .digit_en({J39_b15, J39_c15}), // [1]=left, [0]=right (active LOW)
    .dp()                  // Decimal point
);

    logic n_rst;
    logic hz1_clk;
    
     alu_7seg_mux goon2 (
    .clk(clk), 
    .alu_result(8'h88), 
    .seg({J39_c12,J39_e12,J39_e13,J39_a9,J39_b10,J39_a14,J39_e7}), // A-G 
    .digit_en({J39_c13, J39_d13}), // [1]=left, [0]=right (active LOW)
    .dp()                  // Decimal point
);

     // assign J39_c13 = 0;
    // assign J39_d13 = 0;
    // assign J39_c12 = 1; // A
    // assign J39_e12 = 1; // B
    // assign J39_e13 = 1; // C
    // assign J39_a9 = 1; // E
    // assign J39_b10 = 1; // D
    // assign J39_a14 = 1;  // F
    // assign J39_e7 = 1; // G

    //E11 Is Right
    // assign J39_b15 = 0; // Display 1 
    // assign J39_c15 = 0; // Display 2 
    // assign J39_e11 = 0; // A 
    // assign J39_b20 = 0; // B
    // assign J39_d11 = 0; // C
    // assign J39_b13 = 0; // D
    // assign J40_m4 = 0; // E
    // assign J39_d15 = 0; // F
    // assign J39_d12 = 0; // G

    //J39_c13, //Display 1
    //J39_d13  // Disply 2
    //J39_c12, // A
    //J39_e12, // B
    //J39_a14
    //J39_e13 
    //J39_A9
    //J39_B10
    //J39_E7 

    // assign J39_c13 = 0;
    // assign J39_d13 = 0;
    // assign J39_c12 = 1; // A
    // assign J39_e12 = 1; // B
    // assign J39_e13 = 1; // C
    // assign J39_a9 = 1; // E
    // assign J39_b10 = 1; // D
    // assign J39_a14 = 1;  // F
    // assign J39_e7 = 1; // G


    assign J40_n4 = 0; //Right Active
    assign J40_m4 = 0; //Left Active


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



    
    reset_on_start
     ros (
        .reset(n_rst),
        .clk(clk),
        .manual(rst_pin)
    );

    clock_div clk_divider_1HZ
    (
        .clk(clk),
        .n_rst(n_rst),
        .new_clk(hz1_clk),
        .div(2_499_999)
    );


    logic [7:0] led_sampled;

    always_ff @(posedge hz1_clk, negedge n_rst) begin
    if (~n_rst)
        led_sampled <= 0;
    else
        led_sampled <= ALU_result1[7:0];
    end

    assign led[7] = hz1_clk;

    cache1 cache_inst (
        .clk(hz1_clk),
        .n_rst(n_rst),
        .freeze1(freeze1),
        .freeze2(freeze2),
        .dependency_on_ins2(1'b0),
        .nothing_filled(nothing_filled),
        .instruction0(instruction0),
        .instruction1(instruction1)
    );

    scheduling_assistant_controlunit sched_assist_inst (
        .clk(hz1_clk),
        .n_rst(n_rst),
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
        .clk(clk),
        .n_rst(n_rst),
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


endmodule
