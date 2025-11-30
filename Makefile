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
#all: $(BIT)

# ================================
# Synthesis
# ================================
#$(JSON): $(SRC) | $(BUILD)
#	$(YOSYS) \
	  -p "read_verilog -sv $(SRC); synth_ecp5 -top $(TOP) -json $(JSON)"

# ================================
# Place and route
# ================================
#$(CONFIG): $(JSON) $(PCF)
#	$(NEXTPNR) \
	    --$(DEVICE) \
	    --package $(PACKAGE) \
	    --json $(JSON) \
	    --textcfg $(CONFIG) \
	    --lpf $(PCF)

# ================================
# Bitstream pack
# ================================
#$(BIT): $(CONFIG)
#	$(ECPPACK) $(CONFIG) $(BIT)

# ================================
# Program board
# ================================
#prog: $(BIT)
#	$(PROG) -b ecp5_evn $(BIT)


#########################
# Flash to FPGA
$(BUILD)/$(PROJ).json : $(ICE) $(SRC) $(PINMAP) Makefile
	# lint with Verilator
# 	verilator --top-module top $(SRC) $(SUP)
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	$(YOSYS) -p "read_json $(JSON); read_verilog -sv -noblackbox $(FILES); synth_ice40 -top ice40hx8k -json $(BUILD)/$(PROJ).json"

$(BUILD)/$(PROJ).asc : $(BUILD)/$(PROJ).json
	# Place and route using nextpnr
	$(NEXTPNR) --hx8k --package ct256 --pcf $(PINMAP) --asc $(BUILD)/$(PROJ).asc --json $(BUILD)/$(PROJ).json 2> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2)

$(BUILD)/$(PROJ).bin : $(BUILD)/$(PROJ).asc
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

# ================================
# Utils
# ================================


cram: $(BUILD)/$(PROJ).bin
	iceprog -S $(BUILD)/$(PROJ).bin

clean:
	rm -rf $(BUILD)

$(BUILD):
	mkdir -p $(BUILD)


.PHONY: sim_%_src
sim_%_src: 
	@echo -e "Creating executable for source simulation...\n"
	@mkdir -p $(BUILD) && rm -rf $(BUILD)/*
	@iverilog -g2012 -o $(BUILD)/$*_tb $(SRC) $(TB)/$*_tb.sv
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

