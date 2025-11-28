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
    J40_j3, J40_l4, J40_m4, J40_n4, J40_k5

    // //left line J40
    // output logic J40_p5, J40_n5, J40_l5, J40_k3,J40_g1,
    // J40_d11
);

    //VCC < 3.3V, GND < GND, BL < 3.3V, RST < LCD_RST J4, CS < GND, DC < LCD_DC H2, CLK < LCD_SCK A15, DIN < LCD_SDA J5 
//     output logic       LCD_BLK    , <- Stuff We'll Need
//     output logic       LCD_RST    ,
//     output logic       LCD_DC     ,
//     output logic       LCD_SDA    ,
//     output logic       LCD_SCK    

    //Data transmission is possible up to 75 Mhz (SCL clock period). 
    //When exceeded this frequency, transmitted data was corrupted, 
    //and display filled with impure color
    //https://github.com/fkwilken/OtterSpiTftDriverST7789?utm_source=chatgpt.com


    //st7789 initialization components
    st7789_mgr st7789_mgr_inst (
        .CLK          (clk100       ),
        .RESET        (reset100     ),
        .RUN          (run          ),
        
        .COMPONENT_R  (component_r  ),
        .COMPONENT_G  (component_g  ),
        .COMPONENT_B  (component_b  ),
        
        .M_AXIS_TDATA (m_axis_tdata ),
        .M_AXIS_TKEEP (m_axis_tkeep ),
        .M_AXIS_TUSER (m_axis_tuser ),
        .M_AXIS_TVALID(m_axis_tvalid),
        .M_AXIS_TLAST (m_axis_tlast ),
        .M_AXIS_TREADY(m_axis_tready)
    );

    st7789_driver st7789_driver_inst (
        .CLK          (clk100       ),
        .RESET        (reset100     ),
        .SCLK         (clk50        ),
        .S_AXIS_TDATA (m_axis_tdata ),
        .S_AXIS_TKEEP (m_axis_tkeep ),
        .S_AXIS_TUSER (m_axis_tuser ),
        .S_AXIS_TVALID(m_axis_tvalid),
        .S_AXIS_TLAST (m_axis_tlast ),
        .S_AXIS_TREADY(m_axis_tready),
        .LCD_BLK      (LCD_BLK      ),
        .LCD_RST      (LCD_RST      ),
        .LCD_DC       (LCD_DC       ),
        .LCD_SDA      (LCD_SDA      ),
        .LCD_SCK      (LCD_SCK      )
    );
    
    logic n_rst;
    logic hz1_clk;


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
        .div(9_999_999)
    );

    // assign led[3] = btn;
    // assign led[4] = rst;
    assign led[7] = hz1_clk;
    logic [6:0] led_sampled;

    always_ff @(posedge hz1_clk, negedge n_rst) begin
    if (~n_rst)
        led_sampled <= 0;
    else
        led_sampled <= ALU_result1[6:0];
    end

    assign led[6:0] = led_sampled;

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
