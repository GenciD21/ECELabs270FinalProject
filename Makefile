# ================================
# Project configuration
# ================================
TOP        := top
SRC_DIR    := src
PCF        := constraints/ecp5_evn_full.lpf

# Auto-detect all SystemVerilog sources
SRC        := $(wildcard $(SRC_DIR)/*.sv)
TB	=  testbench

DEVICE     := um5g-85k
PACKAGE    := CABGA381

YOSYS      := yosys
NEXTPNR    := nextpnr-ecp5
ECPPACK    := ecppack
PROG       := openFPGALoader

BUILD      := build
JSON       := $(BUILD)/$(TOP).json
CONFIG     := $(BUILD)/$(TOP).config
BIT        := $(BUILD)/$(TOP).bit

# ================================
# Default target
# ================================
all: $(BIT)

# ================================
# Synthesis
# ================================
$(JSON): $(SRC) | $(BUILD)
	$(YOSYS) \
	  -p "read_verilog -sv $(SRC); synth_ecp5 -top $(TOP) -json $(JSON)"

# ================================
# Place and route
# ================================
$(CONFIG): $(JSON) $(PCF)
	$(NEXTPNR) \
	    --$(DEVICE) \
	    --package $(PACKAGE) \
	    --json $(JSON) \
	    --textcfg $(CONFIG) \
	    --lpf $(PCF)

# ================================
# Bitstream pack
# ================================
$(BIT): $(CONFIG)
	$(ECPPACK) $(CONFIG) $(BIT)

# ================================
# Program board
# ================================
prog: $(BIT)
	$(PROG) -b ecp5_evn $(BIT)

# ================================
# Utils
# ================================
clean:
	rm -rf $(BUILD)

$(BUILD):
	mkdir -p $(BUILD)


.PHONY: sim_%_src
sim_%_src: 
	@echo -e "Creating executable for source simulation...\n"
	@mkdir -p $(BUILD) && rm -rf $(BUILD)/*
	@iverilog -g2012 -o $(BUILD)/$*_tb -Y .sv -y $(SRC) $(TB)/$*_tb.sv
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


.PHONY: all clean prog

