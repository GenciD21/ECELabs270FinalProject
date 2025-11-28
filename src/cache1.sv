module cache1 (
    input  logic clk,
    input  logic n_rst,

    // Scheduler outputs
    input  logic freeze1,             // do not increment instructions     
    input  logic freeze2,             // do not increment instructions 
    input  logic dependency_on_ins2,  // only time we slide by 1
    

    // Outputs to scheduler
    output logic nothing_filled,          // high when cache is empty (stall)
    output logic [31:0] instruction0,    // current instruction
    output logic [31:0] instruction1    // next instruction
);
    logic [31:0] ins [0:11]; //The Current Instruction
    logic [31:0] n_ins [0:11]; // Next Instruction Well Load in

    logic [31:0] pc_wb_ins [0:5]; //6 Instruction from wb 

    logic busy;
    //logic [2:0] counter;
   //logic [2:0] n_counter;
    logic second_half_cache_to_fill;
    logic [31:0] next_PC;
    logic [31:0] PC;
    //CAVEAT PC UPDATE IS JANK

    always_ff @(posedge clk, negedge n_rst) begin
        if(~n_rst) begin
            PC <= 0;
        end
        else begin
            PC <= next_PC;
        end
    end


    always_comb begin
    next_PC = PC;
    if ((n_ins[0] == ins[0] && n_ins[1] == ins[1] && n_ins[2] == ins[2] && n_ins[3] == ins[3] && n_ins[4] == ins[4] && n_ins[5] == ins[5]))
        next_PC = PC + 32'd6;
    else if (freeze1 || freeze2)
        next_PC = PC;
    else if (dependency_on_ins2)
        next_PC = PC + 32'd4;
    else if (!nothing_filled || busy == 1'b1)
        next_PC = PC + 32'd8;
    end

    always_ff @(posedge clk, negedge n_rst) begin
    if (~n_rst) begin
        for (int i = 0; i < 12; i++) begin
            ins[i] <= 32'd0;
        end
    end 
    else begin
        for (int i = 0; i < 12; i++) begin
             ins[i] <= n_ins[i];
        end
    end
end
    
    always_comb begin
         for (int i = 0; i < 12; i++) begin
             n_ins[i] = ins[i];
        end
        if (nothing_filled && !busy) begin
            n_ins[0] = pc_wb_ins[0];
            n_ins[1] = pc_wb_ins[1];
            n_ins[2] = pc_wb_ins[2];
            n_ins[3] = pc_wb_ins[3];
            n_ins[4] = pc_wb_ins[4];
            n_ins[5] = pc_wb_ins[5];
        end  
        else if (!freeze1) begin
            // --- Immediate reaction to dependency_on_ins2 ---
            if (dependency_on_ins2) begin
                // Slide by 1 instruction (ins[1] becomes new ins[0])
                n_ins[0] = ins[1];
                n_ins[1] = ins[2];
                n_ins[2] = ins[3];
                n_ins[3] = ins[4];
                n_ins[4] = ins[5];
                n_ins[5] = ins[6];
                n_ins[6] = (second_half_cache_to_fill ? n_ins[0] : pc_wb_ins[7]);
                n_ins[7] = (second_half_cache_to_fill ? n_ins[1] : pc_wb_ins[8]);
                n_ins[8] = (second_half_cache_to_fill ? n_ins[2] : pc_wb_ins[9]);
                n_ins[9] = (second_half_cache_to_fill ? n_ins[3] : pc_wb_ins[10]);
                n_ins[10] = (second_half_cache_to_fill ? n_ins[4] : pc_wb_ins[11]);
                n_ins[11] = (second_half_cache_to_fill ? n_ins[5] : 32'd0);
            end 
            else begin
                // Normal slide by 2 instructions
                n_ins[0] = ins[2];
                n_ins[1] = ins[3];
                n_ins[2] = ins[4];
                n_ins[3] = ins[5];
                n_ins[4] = ins[6];
                n_ins[5] = ins[7];
                n_ins[6] = (second_half_cache_to_fill ? n_ins[0] : pc_wb_ins[8]);
                n_ins[7] = (second_half_cache_to_fill ? n_ins[1] : pc_wb_ins[9]);
                n_ins[8] = (second_half_cache_to_fill ? n_ins[2] : pc_wb_ins[10]);
                n_ins[9] = (second_half_cache_to_fill ? n_ins[3] : pc_wb_ins[11]);
                n_ins[10] = (second_half_cache_to_fill ? n_ins[4] : 32'd0);
                n_ins[11] = (second_half_cache_to_fill ? n_ins[5] : 32'd0);
            end
        end
        else begin
            if (second_half_cache_to_fill) begin
                n_ins[6] = ins[0];
                n_ins[7] = ins[1];
                n_ins[8] = ins[2];
                n_ins[9] = ins[3];
                n_ins[10] = ins[4];
                n_ins[11] = ins[5];
            end
        end
    end



assign instruction0 = ins[0]; //nothing_filled ? n_ins[0] : ins[0];
assign instruction1 = ins[1]; //nothing_filled ? n_ins[1] : ins[1];

    always_comb begin
        nothing_filled = (ins[0] == 32'd0 ? 1'b1 : 1'b0);
        second_half_cache_to_fill = 32'd0;
    end



    // logic [31:0] n_instruction_0;
    // logic [31:0] n_instruction_1;
    // logic [31:0] n_lookahead_0;
    // logic [31:0] n_lookahead_1;
    // logic [31:0] n_lookahead_2;
    // logic [31:0] n_lookahead_3;

    // --- WB instruction memory simulators ---
    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst0 (
        .clk(clk),
        .rst_n(n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC),
        .wdata(32'd0),
        .rdata(pc_wb_ins[0]),
        .busy(busy),
        .valid()
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst1 (
        .clk(clk),
        .rst_n(n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd4),
        .wdata(32'd0),
        .rdata(pc_wb_ins[1]),
        .busy(),
        .valid()
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst2 (
        .clk(clk),
        .rst_n(n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd8),
        .wdata(32'd0),
        .rdata(pc_wb_ins[2]),
        .busy(),
        .valid()
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst3 (
        .clk(clk),
        .rst_n(n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd12),
        .wdata(32'd0),
        .rdata(pc_wb_ins[3]),
        .busy(),
        .valid()
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst4 (
        .clk(clk),
        .rst_n(n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd16),
        .wdata(32'd0),
        .rdata(pc_wb_ins[4]),
        .busy(),
        .valid()
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst5 (
        .clk(clk),
        .rst_n(n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd20),
        .wdata(32'd0),
        .rdata(pc_wb_ins[5]),
        .busy(),
        .valid()
    );

   
endmodule