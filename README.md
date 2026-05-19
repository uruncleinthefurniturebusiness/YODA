# StarCore-1 + CRU Co-Processor

**EEE4120F HPES Project 2026 — Group 11**  
Joshua Smith (SMTJOS022) · Ebrahim Bhyat (BHYEBR002) · Tlangalani Tembe (TMBTLA001)

---

## Overview

This project extends the **StarCore-1** 16-bit single-cycle processor (implemented in Verilog as part of Practical 4) with a **Coordinate Rotation Unit (CRU)** hardware co-processor. The CRU computes `cos(θ)` and `sin(θ)` simultaneously using the CORDIC algorithm — using only additions and bit-shifts, with no multiplier required.

The motivation is satellite attitude determination: rotation matrices require trigonometric evaluation of Euler angles, which would take hundreds of cycles in software on a processor with no multiply instruction. The CRU reduces this to a fixed **17-cycle latency**.

---

## CRU Design

- **Algorithm:** CORDIC (Coordinate Rotation Digital Computer), 15 iterations
- **Input:** Q3.13 fixed-point angle (radians × 8192), valid range ±π
- **Output:** Q2.14 fixed-point cos and sin (value × 16384)
- **Quadrant folding:** Angles outside ±π/2 are folded by ±π and outputs negated, extending CORDIC's native convergence range to the full ±π
- **Latency:** 17 clock cycles (1 latch + 15 CORDIC + 1 output)

### COP Instruction (opcode `1010`)

```
[15:12] = 1010  (COP)
[11:9]  = RS1   (source register — angle in Q3.13)
[8:6]   = WS    (destination register — receives cos result)
```

The CPU stalls (PC frozen) for the duration of the computation. On completion, `cos(θ)` is written to `WS`. `sin(θ)` is available via a memory-mapped shadow register at data address 7:

```asm
COP  R1, R2    ; angle in R1, cos → R2  (stalls ~17 cycles)
LD   R3, R0+7  ; sin → R3
```

---

## Repository Structure

```
├── src/
│   ├── Parameter.v          # Shared constants and timing
│   ├── ALU.v                # 16-bit combinational ALU
│   ├── GPR.v                # 8 × 16-bit register file
│   ├── InstructionMemory.v  # 16-word instruction ROM
│   ├── DataMemory.v         # 8-word data RAM
│   ├── ALU_Control.v        # ALU control decoder
│   ├── ControlUnit.v        # Main control unit (+ CopEn output)
│   ├── Datapath.v           # Full datapath with CRU integration
│   ├── CRU.v                # CORDIC co-processor
│   └── StarCore1.v          # Top-level processor
├── test/
│   ├── test.prog            # Instruction memory contents (binary)
│   └── test.data            # Data memory initial contents (binary)
├── Makefile
└── CRU_Technical_Writeup.md # Detailed design documentation
```

---

## Build and Simulate

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) and [GTKWave](http://gtkwave.sourceforge.net/).

| Command          | Description                        |
|------------------|------------------------------------|
| `make cru`       | Run standalone CRU testbench       |
| `make integration` | Run full processor integration test |
| `make waves`     | Open waveform in GTKWave           |
| `make all`       | Run all testbenches                |
| `make clean`     | Remove build artifacts             |

---

## FPGA Resource Estimate

| Resource    | Estimate | Notes                              |
|-------------|----------|------------------------------------|
| Flip-flops  | ~110     | CORDIC state + output registers    |
| LUTs        | ~180     | Shift-add logic + mux              |
| Block RAM   | 0        | atan LUT fits in distributed LUT RAM |
| DSP blocks  | 0        | No multipliers used                |
