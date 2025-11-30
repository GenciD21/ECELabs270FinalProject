module cache1 (
    input  logic clk,
    input  logic n_rst,
    input  logic en,
    // Scheduler outputs
    input  logic freeze1,             // do not increment instructions     
    input  logic freeze2,             // do not increment instructions 
    input  logic dependency_on_ins2,  // only time we slide by 1
    

    // Outputs to scheduler
    output logic nothing_filled,          // high when cache is empty (stall)
    output logic [31:0] instruction0,    // current instruction
    output logic [31:0] instruction1    // next instruction
);
    logic [31:0] ins [0:11];
    logic [31:0] n_ins [0:5];
    logic [31:0] past_n_ins [0:5];
    logic busy;
    //logic [2:0] counter;
   //logic [2:0] n_counter;
    logic second_half_cache_to_fill;
    logic [31:0] next_PC;
    logic [31:0] PC;
    //CAVEAT PC UPDATE IS JANK
    always_comb begin
    if ((n_ins[0] == ins[0] && n_ins[1] == ins[1] && n_ins[2] == ins[2] && n_ins[3] == ins[3] && n_ins[4] == ins[4] && n_ins[5] == ins[5]))
        next_PC = PC + 32'd6;
    else if (freeze1 || freeze2)
        next_PC = PC;
    else if (dependency_on_ins2)
        next_PC = PC + 32'd4;
    else if (!nothing_filled || busy == 1'b1)
        next_PC = PC + 32'd8;
    else 
        next_PC = PC;
    end

    always_ff @(posedge clk, posedge n_rst) begin
        if(n_rst) begin
            PC <= 32'h0000_0000;
        end
        else if (en) begin
        PC <= next_PC;
        end
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
        .rst_n(!n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC),
        .wdata(32'd0),
        .rdata(n_ins[0]),
        .busy(busy),
        .valid(),
        .en(1)
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst1 (
        .clk(clk),
        .rst_n(!n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd4),
        .wdata(32'd0),
        .rdata(n_ins[1]),
        .busy(),
        .valid(),
        .en(1)
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst2 (
        .clk(clk),
        .rst_n(!n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd8),
        .wdata(32'd0),
        .rdata(n_ins[2]),
        .busy(),
        .valid(),
        .en(1)
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst3 (
        .clk(clk),
        .rst_n(!n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd12),
        .wdata(32'd0),
        .rdata(n_ins[3]),
        .busy(),
        .valid(),
        .en(1)
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst4 (
        .clk(clk),
        .rst_n(!n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd16),
        .wdata(32'd0),
        .rdata(n_ins[4]),
        .busy(),
        .valid(),
        .en(1)
    );

    wb_simulator #(
        .MEM_FILE("instruction_memory.memh"),
        .DEPTH(1024),
        .LATENCY(3)
    ) wb_inst5 (
        .clk(clk),
        .rst_n(!n_rst),
        .req(1'b1),
        .we(1'b0),
        .addr(PC + 32'd20),
        .wdata(32'd0),
        .rdata(n_ins[5]),
        .busy(),
        .valid(),
        .en(1)
    );

    always_ff @(posedge clk or posedge n_rst) begin
    if (n_rst) begin
        for (int i = 0; i < 6; i++) begin
            past_n_ins[i] <= 32'd0;
        end
        // instruction0 <= 32'd0;
        // instruction1 <= 32'd0;
        for (int i = 0; i < 12; i++) begin
            ins[i] <= 32'd0;
        end
    end 
    else if (en) begin
        for (int i = 0; i < 6; i++) begin
            past_n_ins[i] <= n_ins[i];
        end
        // instruction0 <= ins[0];
        // instruction1 <= ins[1];

        if (nothing_filled) begin
            ins[0] <= n_ins[0];
            ins[1] <= n_ins[1];
            ins[2] <= n_ins[2];
            ins[3] <= n_ins[3];
            ins[4] <= n_ins[4];
            ins[5] <= n_ins[5];
        end  
        else if (!freeze1) begin
            // --- Immediate reaction to dependency_on_ins2 ---
            if (dependency_on_ins2) begin
                // Slide by 1 instruction (ins[1] becomes new ins[0])
                ins[0] <= ins[1];
                ins[1] <= ins[2];
                ins[2] <= ins[3];
                ins[3] <= ins[4];
                ins[4] <= ins[5];
                ins[5] <= ins[6];
                ins[6] <= (second_half_cache_to_fill ? n_ins[0] : ins[7]);
                ins[7] <= (second_half_cache_to_fill ? n_ins[1] : ins[8]);
                ins[8] <= (second_half_cache_to_fill ? n_ins[2] : ins[9]);
                ins[9] <= (second_half_cache_to_fill ? n_ins[3] : ins[10]);
                ins[10] <= (second_half_cache_to_fill ? n_ins[4] : ins[11]);
                ins[11] <= (second_half_cache_to_fill ? n_ins[5] : 32'd0);
            end 
            else begin
                // Normal slide by 2 instructions
                ins[0] <= ins[2];
                ins[1] <= ins[3];
                ins[2] <= ins[4];
                ins[3] <= ins[5];
                ins[4] <= ins[6];
                ins[5] <= ins[7];
                ins[6] <= (second_half_cache_to_fill ? n_ins[0] : ins[8]);
                ins[7] <= (second_half_cache_to_fill ? n_ins[1] : ins[9]);
                ins[8] <= (second_half_cache_to_fill ? n_ins[2] : ins[10]);
                ins[9] <= (second_half_cache_to_fill ? n_ins[3] : ins[11]);
                ins[10] <= (second_half_cache_to_fill ? n_ins[4] : 32'd0);
                ins[11] <= (second_half_cache_to_fill ? n_ins[5] : 32'd0);
            end
        end
        else begin
            if (second_half_cache_to_fill) begin
                ins[6] <= n_ins[0];
                ins[7] <= n_ins[1];
                ins[8] <= n_ins[2];
                ins[9] <= n_ins[3];
                ins[10] <= n_ins[4];
                ins[11] <= n_ins[5];
            end
        end
    end
end

assign instruction0 = ins[0]; //nothing_filled ? n_ins[0] : ins[0];
assign instruction1 = ins[1]; //nothing_filled ? n_ins[1] : ins[1];

    always_comb begin
        nothing_filled = (ins[0] == 32'd0 ? 1'b1 : 1'b0);
        // if (counter < 3'd6) begin
        //     n_counter = counter + 3'd1;
        // end
        // else begin
        //     n_counter = counter;
        // end
        second_half_cache_to_fill = 32'd0;
    end
endmodule