module scheduling_assistant_controlunit (
    input  logic          clk,
    input  logic          rst,

    // Scheduler outputs
    output logic          freeze1,
    output logic          freeze2,
    output logic          dependency_on_ins2,
    output logic          datapath_1_enable,
    output logic          datapath_2_enable,

    // Exposed decoded register indices (driven by the control_units instantiated here)
    output logic [4:0]    RegD1, reg1, reg2,
    output logic [4:0]    RegD2, reg3, reg4,
    
    // Inputs from scheduler/cache
    input  logic          nothing_filled,
    input  logic [31:0]   instruction0,
    input  logic [31:0]   instruction1,
    output logic [31:0] Imm1, Imm2,
    output logic ALUSrc1,
    output logic ALUSrc2
);

    // Internal signals
    logic [31:0] ins0, ins1;

    // These are driven by the control_unit instances below
    // (and exposed as outputs)
    // logic [4:0] RegD1, reg1, reg2;
    // logic [4:0] RegD2, reg3, reg4;

    logic         dep_detected;
    logic [1:0]   dep_timer;        // 2-cycle countdown for dependency handling
    logic         freeze1_next, freeze2_next;

    // =========================================================
    //  INSTRUCTION LATCHING
    //  - latch new pair only when both freezes are low
    // =========================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ins0 <= 32'd0;
            ins1 <= 32'd0;
        end else begin
            if (!freeze1 && !freeze2) begin //both are not frozen, let it flow freeze1 == 0 and freeze2 == 0
                ins0 <= instruction0;
                ins1 <= instruction1;
            end else begin //keep same instructions otherwise.
                ins0 <= ins0;
                ins1 <= ins1;
            end
        end
    end

    // =========================================================
    //  CONTROL UNIT DECODE (instantiated for both lanes)
    //  - control_unit port names: .instruction, .RegD, .Reg2, .Reg1, .Imm, etc.
    // =========================================================

    
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

    // =========================================================
    //  HAZARD DETECTION (combinational)
    //  - detect register hazards between destinations and sources
    // =========================================================
    always_comb begin
        dep_detected = 1'b0;
        dependency_on_ins2 = 1'b0;

        datapath_1_enable = 1'b1;
        datapath_2_enable = 1'b1;

        // simple reg-to-reg dependencies: check RegD of each against sources of the other
        if ( (RegD1 != 5'd0) && ((RegD1 == reg4) || (RegD1 == reg3) || (RegD1==RegD2) ))
            dep_detected = 1'b1;
        else if ( (RegD2 != 5'd0) && ((RegD2 == reg1) || (RegD2 == reg2) || (RegD1==RegD2)) )
            dep_detected = 1'b1;

        if (dep_detected) begin
            dependency_on_ins2 = 1'b1;
            datapath_1_enable = 1'b1;   // let lane 1 run
            datapath_2_enable = 1'b0;   // stall lane 2 until sequence completes
        end

        // Cache empty overrides everything

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

    // =========================================================
    //  DEPENDENCY TIMER (2-cycle behavior)
    //    dep_timer == 2 -> both frozen (first cycle)
    //    dep_timer == 1 -> allow lane1 only (second cycle)
    //    dep_timer == 0 -> normal operation
    // =========================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dep_timer <= 2'd0;
        end else begin
            if (dep_detected && dep_timer == 2'd0)
                dep_timer <= 2'd2;        // start countdown when a new dep appears
            else if (dep_timer != 2'd0)
                dep_timer <= dep_timer - 2'd1;
            else
                dep_timer <= 2'd0;
        end
    end

    // =========================================================
    //  FREEZE CONTROL (combination of dep_timer and nothing_filled)
    // =========================================================
    always_comb begin
        // default: no freeze
        freeze1_next = 1'b0;
        freeze2_next = 1'b0;

        // dependency timer controls freeze behavior
        if (dep_timer == 2'd2) begin
            // first cycle after detection: freeze both lanes
            freeze1_next = 1'b1;
            freeze2_next = 1'b1;
        end
        else if (dep_timer == 2'd1) begin
            // second cycle: let lane1 run, keep lane2 frozen
            freeze1_next = 1'b0;
            freeze2_next = 1'b1;
        end
        else begin
            // normal operation
            freeze1_next = 1'b0;
            freeze2_next = 1'b0;
        end

        // nothing_filled overrides everything
        if (nothing_filled) begin
            freeze1_next = 1'b1;
            freeze2_next = 1'b1;
        end
    end

    // Sequentially update freeze outputs
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            freeze1 <= 1'b0;
            freeze2 <= 1'b0;
        end else begin
            freeze1 <= freeze1_next;
            freeze2 <= freeze2_next;
        end
    end

    // =========================================================
    //  Expose debug outputs (already connected to control_unit outputs)
    // =========================================================
    // reg1, reg2, reg3, reg4, RegD1, RegD2 are driven by cu1/cu2 above

endmodule
