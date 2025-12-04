module scheduling_assistant_controlunit (
    input  logic          clk,
    input  logic          n_rst,

    // Scheduler outputs
    output logic          freeze1,
    output logic          freeze2,
    output logic          dependency_on_ins2,
    output logic          datapath_1_enable,
    output logic          datapath_2_enable,

    
    output logic [4:0]    RegD1, reg1, reg2,
    output logic [4:0]    RegD2, reg3, reg4,
    
    // Inputs from scheduler/cache
    input  logic          nothing_filled,
    input  logic [31:0]   instruction0,
    input  logic [31:0]   instruction1,
    output logic [31:0]   Imm1, Imm2,
    output logic ALUSrc1,
    output logic ALUSrc2
);

    // Internal signals
    logic [31:0] ins0, ins1;

    logic         dep_detected;
    logic [1:0]   dep_timer;
    logic         freeze1_next, freeze2_next;

    
    logic         dep_prev;      // registered previous value of dep_detected
    logic         dep_rising;    // dep_detected && ~dep_prev

    
    always_ff @(posedge clk or negedge n_rst) begin
        if (~n_rst) begin
            ins0 <= 32'd0;
            ins1 <= 32'd0;
        end else begin
            if (!freeze1 && !freeze2) begin
                ins0 <= instruction0;
                ins1 <= instruction1;
            end else begin
                ins0 <= ins0;
                ins1 <= ins1;
            end
        end
    end

    
    control_unit cu1 (
        .instruction(ins0),
        .ALUSrc(ALUSrc1),
        .RegD(RegD1),
        .Reg2(reg2),
        .Reg1(reg1),
        .Imm(Imm1)
    );

    control_unit cu2 (
        .instruction(ins1),
        .ALUSrc(ALUSrc2),
        .RegD(RegD2),
        .Reg2(reg4),
        .Reg1(reg3),
        .Imm(Imm2)
    );


    
    always_comb begin
        dep_detected = 1'b0;
        dependency_on_ins2 = 1'b0;

        datapath_1_enable = 1'b1;
        datapath_2_enable = 1'b1;

        // Detect register dependencies between instruction0 and instruction1
        if ( (RegD1 != 5'd0) && ((RegD1 == reg3) || (RegD1 == reg4)) ) begin
            dep_detected = 1'b1;
        end
        // Also check if both write to the same destination (WAW hazard)
        if ( (RegD1 != 5'd0) && (RegD2 != 5'd0) && (RegD1 == RegD2) ) begin
            dep_detected = 1'b1;
        end

        if (dep_detected) begin
            dependency_on_ins2 = 1'b1;
            datapath_1_enable = 1'b1;
            datapath_2_enable = 1'b0;
        end

        if (instruction0 == 32'h0) begin
            datapath_1_enable = 1'b0;
        end
        if (instruction1 == 32'h0) begin
            datapath_2_enable = 1'b0;
        end

        if (nothing_filled) begin
            datapath_1_enable = 1'b0;
            datapath_2_enable = 1'b0;
        end
    end

    
    always_ff @(posedge clk or negedge n_rst) begin
        if (~n_rst) begin
            dep_prev <= 1'b0;
        end else begin
            dep_prev <= dep_detected;
        end
    end

    // edge detect (combinational)
    always_comb begin
        dep_rising = dep_detected && ~dep_prev;
    end

    
    always_ff @(posedge clk or negedge n_rst) begin
        if (~n_rst) begin
            dep_timer <= 2'd0;
        end else begin
            if (dep_detected && dep_timer == 2'd0)
                dep_timer <= 2'd2;
            else if (dep_timer != 2'd0)
                dep_timer <= dep_timer - 2'd1;
            else
                dep_timer <= 2'd0;
        end
    end

    
    always_comb begin
        freeze1_next = 1'b0;
        freeze2_next = 1'b0;

        if (dep_timer == 2'd2) begin
            freeze1_next = 1'b1;
            freeze2_next = 1'b1;
        end
        else if (dep_timer == 2'd1) begin
            freeze1_next = 1'b0;
            freeze2_next = 1'b1;
        end
        else begin
            freeze1_next = 1'b0;
            freeze2_next = 1'b0;
        end

        if (nothing_filled) begin
            freeze1_next = 1'b1;
            freeze2_next = 1'b1;
        end
    end

    
    always_comb begin
        if (dep_rising && dep_timer == 2'd0) begin
            // Immediate reaction to *new* dependency only
            freeze1 = 1'b1;
            freeze2 = 1'b1;
        end else begin
            // Use the sequential freeze_next values
            freeze1 = freeze1_next;
            freeze2 = freeze2_next;
        end
    end

endmodule
