# ================================
# Project Configuration
# ================================

TOP        := ice40hx8k
SRC_DIR    := src
UART_DIR   := uart
TB_DIR     := testbench
BUILD      := build
PINMAP     := constraints/pinmap.pcf

# ================================
# FPGA Tools
# ================================

YOSYS    := yosys
NEXTPNR  := nextpnr-ice40
ICEPACK  := icepack
PROG     := iceprog

# ================================
# Source Files
# ================================

SRC   := $(wildcard $(SRC_DIR)/*.sv)
UART  := $(wildcard $(UART_DIR)/*.v)
FILES := $(SRC) $(UART)

# ================================
# Build Products
# ================================

JSON := $(BUILD)/$(TOP).json
ASC  := $(BUILD)/$(TOP).asc
BIN  := $(BUILD)/$(TOP).bin

# ================================
# FPGA Build Flow
# ================================

$(JSON): $(FILES) $(PINMAP) Makefile
	mkdir -p $(BUILD)
	$(YOSYS) -p "\
	    read_verilog -sv -noblackbox $(FILES); \
		read_verilog -lib $(shell yosys-config --datdir)/ice40/cells_sim.v; \
	    hierarchy -check -top $(TOP); \
	    proc; opt; fsm; opt; \
	    techmap; opt; \
	    synth_ice40 -top $(TOP) -json $(JSON)"

$(ASC): $(JSON)
	$(NEXTPNR) --hx8k --package ct256 --pcf $(PINMAP) \
	           --json $(JSON) --asc $(ASC) --top $(TOP)

$(BIN): $(ASC)
	$(ICEPACK) $(ASC) $(BIN)

all: $(BIN)

# ================================
# Flash to FPGA
# ================================

cram: $(BIN)
	$(PROG) -S $(BIN)

# ================================
# Simulation
# ================================

.PHONY: sim_%_src
sim_%_src: 
	@echo -e "Creating executable for source simulation...\n"
	@mkdir -p $(BUILD) && rm -rf $(BUILD)/*
	@iverilog -g2012 -o $(BUILD)/$*_tb -Y .sv -y $(SRC) $(TB_DIR)/$*_tb.sv
	@echo -e "\nSource Compilation complete!\n"
	@echo -e "Simulating source...\n"
	@vvp -l vvp_sim.log $(BUILD)/$*_tb
	@echo -e "\nSimulation complete!\n"
	@echo -e "\nOpening waveforms...\n"
	@if [ -f waves/$*.gtkw ]; then \
		gtkwave waves/$*.gtkw; \
	else \
		gtkwave waves/$*.vcd; \
	fi

# ================================
# Cleanup
# ================================

clean:
	rm -rf $(BUILD)

.PHONY: all clean cram