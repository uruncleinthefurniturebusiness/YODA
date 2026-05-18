# =============================================================================
# EEE4120F HPES Project — StarCore-1 + CRU Co-Processor
# Makefile
#
# Usage (run from project root):
#   make alu          — compile and simulate ALU testbench
#   make gpr          — compile and simulate GPR testbench
#   make imem         — compile and simulate InstructionMemory testbench
#   make dmem         — compile and simulate DataMemory testbench
#   make aluctrl      — compile and simulate ALU_Control testbench
#   make ctrl         — compile and simulate ControlUnit testbench
#   make cru          — compile and simulate CRU (CORDIC) testbench
#   make integration  — compile and simulate full processor + CRU
#   make all          — run all testbenches in order
#   make waves        — open integration waveform in GTKWave
#   make cru_waves    — open CRU waveform in GTKWave
#   make clean        — remove all compiled outputs and waveform files
# =============================================================================

IVFLAGS = -Wall -I src

.PHONY: all alu gpr imem dmem aluctrl ctrl cru integration waves cru_waves clean

all: alu gpr imem dmem aluctrl ctrl cru integration

# ---------------------------------------------------------------------------
# Task 1: ALU
# ---------------------------------------------------------------------------
alu: build/alu_sim
	@echo "--- Running ALU testbench ---"
	./build/alu_sim

build/alu_sim: src/ALU.v src/Parameter.v test/ALU_tb.v | build
	iverilog $(IVFLAGS) -o build/alu_sim test/ALU_tb.v

# ---------------------------------------------------------------------------
# Task 2: General Purpose Register File
# ---------------------------------------------------------------------------
gpr: build/gpr_sim
	@echo "--- Running GPR testbench ---"
	./build/gpr_sim

build/gpr_sim: src/GPR.v src/Parameter.v test/GPR_tb.v | build
	iverilog $(IVFLAGS) -o build/gpr_sim test/GPR_tb.v

# ---------------------------------------------------------------------------
# Task 3: Instruction Memory
# ---------------------------------------------------------------------------
imem: build/im_sim
	@echo "--- Running InstructionMemory testbench ---"
	./build/im_sim

build/im_sim: src/InstructionMemory.v src/Parameter.v test/InstructionMemory_tb.v | build
	iverilog $(IVFLAGS) -o build/im_sim test/InstructionMemory_tb.v

# ---------------------------------------------------------------------------
# Task 4: Data Memory
# ---------------------------------------------------------------------------
dmem: build/dm_sim
	@echo "--- Running DataMemory testbench ---"
	./build/dm_sim

build/dm_sim: src/DataMemory.v src/Parameter.v test/DataMemory_tb.v | build
	iverilog $(IVFLAGS) -o build/dm_sim test/DataMemory_tb.v

# ---------------------------------------------------------------------------
# Task 5: ALU Control Unit
# ---------------------------------------------------------------------------
aluctrl: build/ac_sim
	@echo "--- Running ALU_Control testbench ---"
	./build/ac_sim

build/ac_sim: src/ALU_Control.v src/Parameter.v test/ALU_Control_tb.v | build
	iverilog $(IVFLAGS) -o build/ac_sim test/ALU_Control_tb.v

# ---------------------------------------------------------------------------
# Task 6: Main Control Unit
# ---------------------------------------------------------------------------
ctrl: build/cu_sim
	@echo "--- Running ControlUnit testbench ---"
	./build/cu_sim

build/cu_sim: src/ControlUnit.v src/Parameter.v test/ControlUnit_tb.v | build
	iverilog $(IVFLAGS) -o build/cu_sim test/ControlUnit_tb.v

# ---------------------------------------------------------------------------
# CRU: Coordinate Rotation Unit (CORDIC co-processor)
# ---------------------------------------------------------------------------
cru: build/cru_sim
	@echo "--- Running CRU testbench ---"
	./build/cru_sim

build/cru_sim: src/CRU.v test/CRU_tb.v | build
	iverilog $(IVFLAGS) -o build/cru_sim test/CRU_tb.v

# ---------------------------------------------------------------------------
# Full Processor Integration (StarCore-1 + CRU)
# ---------------------------------------------------------------------------
integration: build/star_sim
	@echo "--- Running StarCore-1 + CRU integration testbench ---"
	./build/star_sim

build/star_sim: src/StarCore1.v src/Datapath.v src/ControlUnit.v \
                src/CRU.v src/ALU.v src/GPR.v src/InstructionMemory.v \
                src/DataMemory.v src/ALU_Control.v src/Parameter.v \
                test/StarCore1_tb.v | build
	iverilog $(IVFLAGS) -o build/star_sim test/StarCore1_tb.v

# ---------------------------------------------------------------------------
# Waveform viewers
# ---------------------------------------------------------------------------
waves:
	gtkwave waves/starcore_execution.vcd &

cru_waves:
	gtkwave waves/cru_tb.vcd &

# ---------------------------------------------------------------------------
# Create build/ and waves/ directories
# ---------------------------------------------------------------------------
build:
	mkdir -p build waves

# ---------------------------------------------------------------------------
# Clean
# ---------------------------------------------------------------------------
clean:
	rm -f build/*
	rm -f waves/*.vcd
	@echo "Clean complete."
