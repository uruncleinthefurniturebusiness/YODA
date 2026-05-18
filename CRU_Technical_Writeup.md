# Coordinate Rotation Unit (CRU) — Technical Write-Up

**EEE4120F HPES Project — Group 11**
**Members:** Joshua Smith (SMTJOS022), Ebrahim Bhyat (BHYEBR002), Tlangalani Tembe (TMBTLA001)

---

## 1. Overview

The Coordinate Rotation Unit (CRU) is a hardware co-processor attached to the StarCore-1 processor. Its purpose is to compute trigonometric functions — specifically `cos(θ)` and `sin(θ)` — in dedicated silicon, offloading work that would otherwise require many hundreds of software instructions on the base CPU.

The motivation is satellite attitude determination. A satellite's orientation is described by rotation matrices whose entries are cosines and sines of Euler angles. Computing these in software on a processor with no multiply instruction would be extremely slow. The CRU solves this problem by computing both `cos` and `sin` simultaneously in a fixed 17-cycle latency, regardless of the input angle, using only additions and bit-shifts — operations that map directly and cheaply onto FPGA fabric.

---

## 2. The CORDIC Algorithm

### 2.1 Principle

CORDIC (COordinate Rotation DIgital Computer, Volder 1959) computes trigonometric functions through iterative vector rotation. Instead of evaluating a polynomial or reading a look-up table, it rotates a starting vector by progressively smaller angles until the accumulated rotation equals the target angle `θ`.

The key insight is that each rotation step uses only a **binary shift and an addition**, never a multiplication. This makes it uniquely suited to integer hardware with no multiplier.

### 2.2 Rotation Mode Equations

Each iteration `i` performs:

```
x[i+1] = x[i] − d[i] × (y[i] >> i)
y[i+1] = y[i] + d[i] × (x[i] >> i)
z[i+1] = z[i] − d[i] × atan(2^−i)
```

where:
- `>>` is an arithmetic right-shift (equivalent to dividing by `2^i`)
- `d[i] = +1` if `z[i] ≥ 0`, otherwise `d[i] = −1`
- `z` is the angle accumulator, converging toward zero
- `x` and `y` converge toward `cos(θ)` and `sin(θ)` respectively

The direction `d[i]` is chosen at each step to drive `z` toward zero. As `z` approaches zero, the accumulated rotations sum to the target angle `θ`, so the vector `(x, y)` has been rotated by exactly `θ`.

### 2.3 CORDIC Gain

Each rotation by `atan(2^−i)` introduces a scaling factor of `sqrt(1 + 2^(−2i))`. After `N` iterations the total gain is:

```
K_N = ∏ sqrt(1 + 2^(−2i))  for i = 0..N−1  ≈  1.6468  (for N = 15)
```

Without correction, the outputs would be `K_N × cos(θ)` and `K_N × sin(θ)`. To compensate, the starting value is pre-scaled:

```
x[0] = 1 / K_N  ≈  0.6073
y[0] = 0
z[0] = θ
```

After 15 iterations: `x → cos(θ)`, `y → sin(θ)`. No post-multiplication needed.

### 2.4 Convergence Range

CORDIC rotation mode converges for `|θ| < π/2` (approximately ±1.5708 radians). Inputs outside this range will not converge correctly. The caller is responsible for pre-rotating angles into the valid range before issuing a COP instruction.

---

## 3. Fixed-Point Representation

The CRU uses **two different Q formats** for input and output.

### 3.1 Angle Input — Q3.13

| Field | Bits | Description |
|---|---|---|
| Sign | bit 15 | Two's complement sign |
| Integer | bits 14:13 | Two integer bits |
| Fractional | bits 12:0 | 13 fractional bits |

**Scale factor: 2^13 = 8192**

```
Q3.13 integer = round(angle_radians × 8192)
```

**Range:** −4.0 to +~4.0 — covers the full ±π range since π × 8192 = 25737 < 32767 ✓

**Why not Q2.14 for the angle?** Q2.14 (scale 16384) would require π × 16384 = 51472 to represent an angle of π — this overflows a 16-bit signed integer (max 32767). Q3.13 sacrifices one bit of fractional resolution in exchange for enough integer range to hold π.

### 3.2 Cos/Sin Output — Q2.14

| Field | Bits | Description |
|---|---|---|
| Sign | bit 15 | Two's complement sign |
| Integer | bit 14 | One integer bit |
| Fractional | bits 13:0 | 14 fractional bits |

**Scale factor: 2^14 = 16384**

```
real_value = Q2.14_integer / 16384.0
```

**Range:** −2.0 to +1.99994 — cosine and sine always lie in [−1, +1], well within this range. The higher precision (14 fractional bits vs 13) is used here because output quality matters more than input range.

### 3.3 Internal Format Conversion

The quadrant fold is done in Q3.13. After folding, the angle is always in (−π/2, π/2), i.e., the Q3.13 value is in (−12868, 12868). This is converted to Q2.14 for the CORDIC z-accumulator by a single arithmetic left-shift:

```
z_Q2.14 = z_Q3.13 × 2 = z_Q3.13 <<< 1
```

The left-shifted value is at most 25736, which fits safely in 16-bit signed. All 15 CORDIC iterations then operate entirely in Q2.14.

### 3.4 Key Constants

| Value | Exact | Q3.13 (angle in) | Q2.14 (output) |
|---|---|---|---|
| π/4 | 0.7854 rad | 6434 | 12868 (also = atan_lut[0]) |
| π/2 | 1.5708 rad | 12868 | 25736 |
| π | 3.1416 rad | 25737 | — (overflows Q2.14) |
| CORDIC gain x₀ = 1/K₁₅ | 0.6073 | — | 9949 |
| cos(45°) = sin(45°) = 1/√2 | 0.7071 | — | 11585 |
| cos(30°) = √3/2 | 0.8660 | — | 14189 |
| sin(30°) = 0.5 | 0.5000 | — | 8192 |

### 3.5 Arctangent Look-Up Table

The 15-entry `atan_lut` is the only memory inside the CRU. It is indexed by iteration number and holds `atan(2^−i) × 16384`:

| i | atan(2^−i) (rad) | Q2.14 |
|---|---|---|
| 0 | 0.78540 (π/4) | 12868 |
| 1 | 0.46365 | 7596 |
| 2 | 0.24498 | 4014 |
| 3 | 0.12435 | 2037 |
| 4 | 0.06242 | 1022 |
| 5 | 0.03124 | 512 |
| 6 | 0.01562 | 256 |
| 7 | 0.00781 | 128 |
| 8 | 0.00391 | 64 |
| 9 | 0.00195 | 32 |
| 10 | 0.00098 | 16 |
| 11 | 0.00049 | 8 |
| 12 | 0.00024 | 4 |
| 13 | 0.00012 | 2 |
| 14 | 0.00006 | 1 |

---

## 4. CRU Hardware Architecture

### 4.1 Module Interface

```
Module: CRU
Inputs:  clk, reset, start, angle_in[15:0]  (Q3.13 signed — radians × 8192)
Outputs: cos_out[15:0], sin_out[15:0]       (Q2.14 signed — value  × 16384)
         busy, done                          (handshake flags)
```

| Signal | Direction | Description |
|---|---|---|
| `clk` | In | System clock |
| `reset` | In | Synchronous reset to IDLE |
| `start` | In | Assert high while CRU is idle to begin |
| `angle_in` | In | Q3.13 angle in radians × 8192 (valid range ±π, i.e. ±25737) |
| `cos_out` | Out | Q2.14 cosine result × 16384 (valid when done=1) |
| `sin_out` | Out | Q2.14 sine result  × 16384 (valid when done=1) |
| `busy` | Out | High from start acceptance until computation ends |
| `done` | Out | Pulses high for exactly **one cycle** when results are ready |

### 4.2 Finite State Machine

The CRU has three states:

```
         start & ~busy & ~done
  ┌──────────────────────────────┐
  ▼                              │
IDLE ──────────────────────────► RUNNING ──► DONE ──► (back to IDLE)
  ▲                              (iter 0..14, one per clock)
  │                done=0
  └──────────────────────────────────────────────────────┘
```

**IDLE:** Clears `done`. When `start` is asserted (and CRU is free), latches `x = K_INIT`, `y = 0`, `z = angle_in`, resets `iter = 0`, asserts `busy`, transitions to RUNNING.

**RUNNING:** Executes one CORDIC micro-rotation per clock cycle. The iteration counter `iter` drives the shift amount and selects the `atan_lut` entry. After iteration 14 (the 15th step), transitions to DONE.

**DONE:** Latches `x → cos_out` and `y → sin_out`, asserts `done = 1`, clears `busy`, returns to IDLE. The IDLE state immediately clears `done` on the next cycle.

### 4.3 Timing Diagram

```
Cycle:   0      1      2      3   ...   15     16     17
         │      │      │      │         │      │      │
start ───┘      │      │      │         │      │      │
busy    ────────────────────────────────┘      │      │
done                                           ┌──┐   │
                                               │  │   │
state: IDLE  RUN0  RUN1  RUN2 ... RUN14  DONE  IDLE
                                          ↑           ↑
                                     cos/sin       done
                                     latched      cleared
```

Total latency from `start` to valid outputs: **17 clock cycles**
- Cycle 0: IDLE → RUNNING, inputs latched
- Cycles 1–15: 15 CORDIC iterations
- Cycle 16: DONE, results latched, `done = 1`
- Cycle 17: IDLE, `done` cleared

---

## 5. Integration with StarCore-1

### 5.1 Design Philosophy

The CRU is a **co-processor** attached to the StarCore-1 via the reserved opcode `1010`. The project brief explicitly reserves this opcode for a co-processor interface. The key design decisions were:

1. **Stall the CPU** while the CRU is running (transparent to the programmer — no polling required)
2. **Write cosine directly** back to a GPR destination register on completion (same write port as normal instructions)
3. **Make sine available** via a memory-mapped shadow register at data address 7, readable with a normal `LD` instruction

This approach requires no new architectural features — only a stall signal and a few multiplexers.

### 5.2 New Instruction: `COP`

```
Encoding (16-bit):
  [15:12] = 1010    (opcode — COP)
  [11:9]  = RS1     (source register containing the input angle)
  [8:6]   = WS      (destination register for cos result)
  [5:0]   = 000000  (unused)
```

**Semantics:**
```
WS      ← cos(Q2.14(RS1))     (written when CRU finishes)
mem[7]  ← sin(Q2.14(RS1))     (available via LD Rd, R0+7)
```

**Programmer model:**
```asm
COP  R1, R2       ; angle in R1, cos → R2 (stalls ~17 cycles)
LD   R3, R0+7     ; sin → R3  (address 7 is the CRU shadow register)
```

### 5.3 Control Unit Changes

The `ControlUnit` module gains one new output: `CopEn`. For all other opcodes, `CopEn = 0`. For opcode `1010`:

```verilog
CopEn    = 1'b1;   // signal Datapath to engage the CRU
RegWrite = 1'b0;   // write-back is gated by cru_done in the Datapath
// all other signals remain 0
```

`RegWrite` is deliberately left 0 because the write must be deferred until the CRU finishes — the Datapath handles this gate itself.

### 5.4 Datapath Changes

Four additions to the Datapath:

#### (a) CRU Instantiation
The CRU is instantiated with `angle_in` wired to `read_data1` (the RS1 register output, combinatorially available):

```verilog
wire cru_start = CopEn & ~cru_busy & ~cru_done;
CRU cru_unit (.clk(clk), .reset(reset), .start(cru_start),
              .angle_in(read_data1), ...);
```

The `~busy & ~done` guard on `start` prevents the CRU from being re-triggered on the cycle when `done = 1` (at which point the CPU PC is about to advance but the same COP instruction is still being decoded for one more cycle).

#### (b) PC Stall Logic
```verilog
wire cru_stall = CopEn & ~cru_done;

always @(posedge clk) begin
    if      (reset)      pc <= 0;
    else if (cru_stall)  pc <= pc;      // freeze: CRU in-flight
    else if (Jump)       pc <= jump_target;
    else if (take_branch)pc <= branch_target;
    else                 pc <= pc_plus_2;
end
```

The PC stays frozen at the COP instruction address for all 16 cycles while `cru_stall` is high. On the cycle that `cru_done` rises, `cru_stall` goes low, and the PC advances on that same posedge. The GPR write-back also happens on that same posedge (see below), so both events are atomic.

#### (c) GPR Write-Back Mux
```verilog
wire gpr_write_en = RegWrite | (CopEn & cru_done);

assign write_data = (CopEn & cru_done) ? cru_cos  :
                    MemToReg           ? mem_read_data_muxed :
                                         alu_result;
```

When the CRU finishes (`CopEn & cru_done`), the cos result overrides the normal write-back path and is stored into the WS register. This uses the existing single GPR write port with no extra hardware.

#### (d) Sin Shadow Register (address 7 intercept)
```verilog
wire [`WORDWIDTH-1:0] mem_read_data_muxed =
    (MemRd && alu_result[2:0] == 3'd7) ? cru_sin : memory_read_data;
```

When the CPU executes `LD Rd, R0+7`, the ALU computes address `0+7 = 7`. The Datapath intercepts this specific address and returns the CRU's `sin_out` register instead of the actual RAM word. This is invisible to the programmer — it looks exactly like a normal load.

### 5.5 Why These Specific Design Choices

| Decision | Rationale |
|---|---|
| **Stall over polling** | A polling loop (`BNE done_flag, loop`) would cost 3–4 instructions per poll and requires a status register. Stalling is simpler and wastes no instruction slots. |
| **Cos via GPR write-back** | Reuses existing write port and register file; no new registers needed. |
| **Sin via address-7 intercept** | Avoids adding a second GPR write port. One `LD` is a natural follow-up to a trig computation. |
| **Q2.14 format** | Covers the full CORDIC input range (±π/2) with 16384 quanta of resolution. Outputs (cos/sin ∈ [−1,1]) fit cleanly in the same format. |
| **No quadrant extension** | Q2.14 cannot represent π (would need 51472, overflowing 16-bit signed). Range ±π/2 covers the primary use case; full-range angles are handled by the programmer in software. |

---

## 6. Verification Strategy

### 6.1 Standalone CRU Testbench (`CRU_tb.v`)

The testbench verifies the CORDIC engine in isolation — no CPU involved. It applies six test vectors and checks that `|result − expected| ≤ 2` (one Q2.14 LSB of tolerance, ≈ 0.006% of full scale):

| Test | Angle (Q2.14) | Expected cos | Expected sin |
|---|---|---|---|
| θ = 0 | 0 | 16384 | 0 |
| θ = π/6 | 8581 | 14189 | 8192 |
| θ = π/4 | 12868 | 11585 | 11585 |
| θ = π/3 | 17157 | 8192 | 14189 |
| θ = −π/4 | −12868 | 11585 | −11585 |
| θ = 0 (back-to-back) | 0 | 16384 | 0 |

The back-to-back test specifically verifies that the CRU returns to IDLE correctly after a computation and can accept a new `start` immediately.

Run with:
```bash
make cru
```

### 6.2 Integration Testing

For full-system verification, write a test program to `test/test.prog` that:
1. Loads a known angle from data memory
2. Issues a COP instruction
3. Loads the sin result
4. Stores both to memory for inspection

Then run:
```bash
make integration
make waves   # inspect in GTKWave
```

Key signals to inspect in GTKWave:
- `uut.main_dp.cru_unit.state` — FSM state (IDLE/RUNNING/DONE)
- `uut.main_dp.cru_unit.iter` — CORDIC iteration counter
- `uut.main_dp.cru_stall` — CPU stall signal
- `uut.main_dp.pc` — confirm PC is frozen during CRU execution
- `uut.main_dp.register_file.registers[2]` — cos result register

---

## 7. Resource Estimate

On a typical FPGA (e.g., Xilinx Artix-7):

| Resource | Estimate | Notes |
|---|---|---|
| Flip-flops | ~110 | x, y, z (16b each) + state, iter, busy, done, negate (9b) + cos_out, sin_out (32b) |
| LUTs | ~180 | Adder/subtractor for CORDIC step + mux logic |
| Block RAM | 0 | atan_lut fits in distributed LUT RAM (15 × 16-bit) |
| DSP blocks | 0 | Pure shift-add, no multipliers |

The CRU adds minimal area overhead relative to the base StarCore-1 CPU.

---

## 8. Limitations and Future Work

| Limitation | Impact | Possible Extension |
|---|---|---|
| Input range limited to ±π/2 | Cannot directly process angles > 90° | Add a pre-rotation module that folds ±π into ±π/2 using 32-bit subtraction |
| 17-cycle fixed latency | No early-exit for simple angles (0°, 90°) | Add configurable iteration count via an instruction immediate field |
| Sin result via memory (addr 7) | Requires an extra LD instruction | Add a second GPR write port to write both cos and sin simultaneously |
| No status register | No way for software to poll without stalling | Add a `COP_DONE` bit to a control/status register |
| Q2.14 precision only | ~4 decimal digits | Extend to 32-bit with Q2.30 for higher-precision applications |
