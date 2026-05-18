// =========================================================================
// EEE4120F HPES Project — Coordinate Rotation Unit (CRU)
// CORDIC Co-Processor for StarCore-1
// =========================================================================
//
// GROUP NUMBER: 11
//
// MEMBERS:
//   - Joshua Smith,  SMTJOS022
//   - Ebrahim Bhyat, BHYEBR002
//   - Tlangalani Tembe, TMBTLA001
//
// -------------------------------------------------------------------------
// Algorithm: CORDIC rotation mode (15 iterations)
//
// TWO fixed-point formats are used:
//
//   Angle input  — Q3.13  (scale = 2^13 = 8192)
//     1 sign bit, 2 integer bits, 13 fractional bits. Range: [-4.0, ~4.0]
//     Covers the full ±π range:  π × 8192 = 25737  (<32767 ✓)
//     Caller encodes:  angle_in = round(angle_radians × 8192)
//
//   Cos/sin output  — Q2.14  (scale = 2^14 = 16384)
//     1 sign bit, 1 integer bit, 14 fractional bits. Range: [-2.0, ~2.0]
//     Output values lie in [-1, 1]:  ±1.0 → ±16384
//
// Quadrant extension:
//   CORDIC converges for |z| < π/2.  Angles in (-π, -π/2] or [π/2, π)
//   are folded by ±π before the CORDIC loop, and both outputs are negated
//   on the way out:
//       cos(θ ± π) = -cos(θ)    sin(θ ± π) = -sin(θ)
//
//   The folded angle (Q3.13) is converted to Q2.14 via a left-shift-by-1
//   before being loaded into z.  After folding, |z_Q3_13| ≤ 12868,
//   so z_Q2_14 = z_Q3_13 << 1 ≤ 25736 — safely within 16-bit signed. ✓
//
// Interface:
//   - Assert start=1 while CRU is idle to begin a computation.
//   - busy goes high on the cycle start is accepted.
//   - done pulses high for exactly one cycle when results are valid.
//   - Total latency: 17 clock cycles  (1 latch + 15 CORDIC + 1 output).
// =========================================================================

`timescale 1ns / 1ps

module CRU (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  start,       // trigger: high while idle to begin
    input  wire signed [15:0]    angle_in,    // Q3.13: angle in radians × 8192

    output reg  signed [15:0]    cos_out,     // Q2.14: cosine result × 16384
    output reg  signed [15:0]    sin_out,     // Q2.14: sine result  × 16384
    output reg                   busy,        // high during computation
    output reg                   done         // high for one cycle when valid
);

    // -----------------------------------------------------------------------
    // Constants
    // -----------------------------------------------------------------------
    localparam signed [15:0] HALF_PI_Q3_13 = 16'sd12868;
    localparam signed [15:0] PI_Q3_13      = 16'sd25737;
    localparam signed [15:0] K_INIT        = 16'sd9949;  // 1/K_15 × 16384

    // atan(2^-i) × 16384 for i = 0..14   (Q2.14)
    reg signed [15:0] atan_lut [0:14];
    initial begin
        atan_lut[0]  = 16'sd12868;
        atan_lut[1]  = 16'sd7596;
        atan_lut[2]  = 16'sd4014;
        atan_lut[3]  = 16'sd2037;
        atan_lut[4]  = 16'sd1022;
        atan_lut[5]  = 16'sd512;
        atan_lut[6]  = 16'sd256;
        atan_lut[7]  = 16'sd128;
        atan_lut[8]  = 16'sd64;
        atan_lut[9]  = 16'sd32;
        atan_lut[10] = 16'sd16;
        atan_lut[11] = 16'sd8;
        atan_lut[12] = 16'sd4;
        atan_lut[13] = 16'sd2;
        atan_lut[14] = 16'sd1;
    end

    // -----------------------------------------------------------------------
    // FSM states
    // -----------------------------------------------------------------------
    localparam [1:0] IDLE    = 2'd0;
    localparam [1:0] RUNNING = 2'd1;
    localparam [1:0] DONE    = 2'd2;

    reg [1:0]         state;
    reg [3:0]         iter;
    reg               negate;

    reg signed [15:0] x, y, z;

    // -----------------------------------------------------------------------
    // CORDIC FSM
    // -----------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            state   <= IDLE;
            busy    <= 1'b0;
            done    <= 1'b0;
            iter    <= 4'd0;
            negate  <= 1'b0;
            cos_out <= 16'sd0;
            sin_out <= 16'sd0;
            x       <= 16'sd0;
            y       <= 16'sd0;
            z       <= 16'sd0;

        end else begin
            case (state)

                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        busy <= 1'b1;
                        iter <= 4'd0;
                        x    <= K_INIT;
                        y    <= 16'sd0;

                        if (angle_in >= HALF_PI_Q3_13) begin
                            z      <= (angle_in - PI_Q3_13) <<< 1;
                            negate <= 1'b1;
                        end else if (angle_in <= -HALF_PI_Q3_13) begin
                            z      <= (angle_in + PI_Q3_13) <<< 1;
                            negate <= 1'b1;
                        end else begin
                            z      <= angle_in <<< 1;
                            negate <= 1'b0;
                        end

                        state <= RUNNING;
                    end
                end

                RUNNING: begin
                    if (z >= 16'sd0) begin
                        x <= x - (y >>> iter);
                        y <= y + (x >>> iter);
                        z <= z - atan_lut[iter];
                    end else begin
                        x <= x + (y >>> iter);
                        y <= y - (x >>> iter);
                        z <= z + atan_lut[iter];
                    end

                    if (iter == 4'd14)
                        state <= DONE;
                    else
                        iter <= iter + 4'd1;
                end

                DONE: begin
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    cos_out <= negate ? -x : x;
                    sin_out <= negate ? -y : y;
                    state   <= IDLE;
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
