# =============================================================================
# EEE4120F HPES Project — StarCore-1 + CRU Co-Processor
# Makefile — automates compilation and simulation of all modules
#
# Usage:
#   make alu          — compile and simulate the ALU testbench
#   make gpr          — compile and simulate the GPR testbench
#   make imem         — compile and simulate InstructionMemory testbench
#   make dmem         — compile and simulate DataMemory testbench
#   make aluctrl      — compile and simulate ALU_Control testbench
#   make ctrl         — compile and simulate ControlUnit testbench
#   make cru          — compile and simulate CRU (CORDIC) testbench
#   make integration  — compile and simulate the full processor + CRU
#   make all          — run all testbenches in order
#   make waves        — open the last integration waveform in GTKWave
#   make clean        — remove all compiled outputs and waveform files
#
# IMPORTANT: Makefile recipe lines must start with a TAB character, not spaces.
# =============================================================================

IVFLAGS = -Wall -I .

# Full processor source list (order matters for `include chains)
SRC = Parameter.v \
      ALU.v \
      GPR.v \
      InstructionMemory.v \
      DataMemory.v \
      ALU_Control.v \
      ControlUnit.v \
      CRU.v \
      Datapath.v \
      StarCore1.v

.PHONY: all alu gpr imem dmem aluctrl ctrl cru integration waves clean

# ---------------------------------------------------------------------------
# all — run every testbench
# ---------------------------------------------------------------------------
all: alu gpr imem dmem aluctrl ctrl cru integration

# ---------------------------------------------------------------------------
# Task 1: ALU
# ---------------------------------------------------------------------------
alu: build/alu_sim
	@echo "--- Running ALU testbench ---"
	cd test && ../build/alu_sim

build/alu_sim: ALU.v ALU_tb.v | build
	iverilog $(IVFLAGS) -o build/alu_sim Parameter.v ALU.v ALU_tb.v

# ---------------------------------------------------------------------------
# Task 2: General Purpose Register File
# ---------------------------------------------------------------------------
gpr: build/gpr_sim
	@echo "--- Running GPR testbench ---"
	cd test && ../build/gpr_sim

build/gpr_sim: GPR.v GPR_tb.v | build
	iverilog $(IVFLAGS) -o build/gpr_sim Parameter.v GPR.v GPR_tb.v

# ---------------------------------------------------------------------------
# Task 3: Instruction Memory
# ---------------------------------------------------------------------------
imem: build/im_sim
	@echo "--- Running InstructionMemory testbench ---"
	cd test && ../build/im_sim

build/im_sim: InstructionMemory.v InstructionMemory_tb.v | build
	iverilog $(IVFLAGS) -o build/im_sim \
		Parameter.v InstructionMemory.v InstructionMemory_tb.v

# ---------------------------------------------------------------------------
# Task 4: Data Memory
# ---------------------------------------------------------------------------
dmem: build/dm_sim
	@echo "--- Running DataMemory testbench ---"
	cd test && ../build/dm_sim

build/dm_sim: DataMemory.v DataMemory_tb.v | build
	iverilog $(IVFLAGS) -o build/dm_sim \
		Parameter.v DataMemory.v DataMemory_tb.v

# ---------------------------------------------------------------------------
# Task 5: ALU Control Unit
# ---------------------------------------------------------------------------
aluctrl: build/ac_sim
	@echo "--- Running ALU_Control testbench ---"
	cd test && ../build/ac_sim

build/ac_sim: ALU_Control.v ALU_Control_tb.v | build
	iverilog $(IVFLAGS) -o build/ac_sim \
		Parameter.v ALU_Control.v ALU_Control_tb.v

# ---------------------------------------------------------------------------
# Task 6: Main Control Unit
# ---------------------------------------------------------------------------
ctrl: build/cu_sim
	@echo "--- Running ControlUnit testbench ---"
	cd test && ../build/cu_sim

build/cu_sim: ControlUnit.v ControlUnit_tb.v | build
	iverilog $(IVFLAGS) -o build/cu_sim \
		Parameter.v ControlUnit.v ControlUnit_tb.v

# ---------------------------------------------------------------------------
# CRU: Coordinate Rotation Unit (CORDIC co-processor)
# ---------------------------------------------------------------------------
cru: build/cru_sim
	@echo "--- Running CRU testbench ---"
	cd test && ../build/cru_sim

build/cru_sim: CRU.v CRU_tb.v | build
	iverilog $(IVFLAGS) -o build/cru_sim CRU.v CRU_tb.v

# ---------------------------------------------------------------------------
# Full Processor Integration (StarCore-1 + CRU)
# ---------------------------------------------------------------------------
integration: build/star_sim
	@echo "--- Running StarCore-1 + CRU integration testbench ---"
	cd test && ../build/star_sim

build/star_sim: $(SRC) StarCore1_tb.v | build
	iverilog $(IVFLAGS) -o build/star_sim $(SRC) StarCore1_tb.v

# ---------------------------------------------------------------------------
# Open the integration waveform in GTKWave
# ---------------------------------------------------------------------------
waves:
	gtkwave waves/star.vcd &

cru_waves:
	gtkwave waves/cru_tb.vcd &

# ---------------------------------------------------------------------------
# Create build/waves directories if they do not exist
# ---------------------------------------------------------------------------
build:
	mkdir -p build waves

# ---------------------------------------------------------------------------
# Remove all generated files
# ---------------------------------------------------------------------------
clean:
	rm -f build/*
	rm -f waves/*.vcd
	rm -f test/*.vcd
	@echo "Clean complete."
