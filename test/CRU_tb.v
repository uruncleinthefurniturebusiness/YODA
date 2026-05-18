// =========================================================================
// EEE4120F HPES Project — CRU Testbench
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
// Verifies the CORDIC engine across the full ±π range.
//
// Angle input format:  Q3.13  (scale = 8192)
//   angle_in = round(angle_radians × 8192)
//
// Output format:  Q2.14  (scale = 16384)
//   result = round(cos_or_sin × 16384)
//
// Pass criterion: |result - expected| <= 8  (~0.05% of full scale)
// =========================================================================

`timescale 1ns / 1ps
`include "../src/CRU.v"

module CRU_tb;

    reg         clk;
    reg         reset;
    reg         start;
    reg  signed [15:0] angle_in;

    wire signed [15:0] cos_out;
    wire signed [15:0] sin_out;
    wire               busy;
    wire               done;

    CRU uut (
        .clk      (clk),
        .reset    (reset),
        .start    (start),
        .angle_in (angle_in),
        .cos_out  (cos_out),
        .sin_out  (sin_out),
        .busy     (busy),
        .done     (done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count;
    integer fail_count;

    task run_test;
        input signed [15:0] angle;
        input signed [15:0] exp_cos;
        input signed [15:0] exp_sin;
        input [255:0]        label;

        integer cos_err, sin_err;
        integer timeout;
        begin
            @(negedge clk);
            angle_in = angle;
            start    = 1'b1;
            @(posedge clk);
            #1;
            start = 1'b0;

            timeout = 0;
            while (!done && timeout < 30) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            if (timeout >= 30) begin
                $display("TIMEOUT  [%s]  angle=%0d", label, angle);
                fail_count = fail_count + 1;
            end else begin
                cos_err = cos_out - exp_cos;
                sin_err = sin_out - exp_sin;
                if (cos_err < 0) cos_err = -cos_err;
                if (sin_err < 0) sin_err = -sin_err;

                if (cos_err <= 8 && sin_err <= 8) begin
                    $display("PASS  [%s]  cos=%6d (exp %6d)  sin=%6d (exp %6d)",
                             label, cos_out, exp_cos, sin_out, exp_sin);
                    pass_count = pass_count + 1;
                end else begin
                    $display("FAIL  [%s]  cos=%6d (exp %6d, err=%0d)  sin=%6d (exp %6d, err=%0d)",
                             label, cos_out, exp_cos, cos_err, sin_out, exp_sin, sin_err);
                    fail_count = fail_count + 1;
                end
            end

            @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("waves/cru_tb.vcd");
        $dumpvars(0, CRU_tb);

        pass_count = 0;
        fail_count = 0;
        start      = 0;
        angle_in   = 0;

        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
        @(negedge clk);

        $display("=======================================================");
        $display("   CRU CORDIC Testbench — Full ±pi Range (Q3.13 in)   ");
        $display("=======================================================");
        $display("  Angle in: Q3.13 (×8192).  Out: Q2.14 (×16384).");
        $display("  Pass threshold: |err| <= 8 (~0.05%%)");
        $display("-------------------------------------------------------");
        $display("  --- Acute angles (no quadrant fold) ---");

        run_test(16'sd0,      16'sd16384, 16'sd0,     "theta = 0       ");
        run_test(16'sd4291,   16'sd14189, 16'sd8192,  "theta = pi/6    ");
        run_test(16'sd6434,   16'sd11585, 16'sd11585, "theta = pi/4    ");
        run_test(16'sd8579,   16'sd8192,  16'sd14189, "theta = pi/3    ");

        $display("  --- Boundary angles ---");

        run_test(16'sd12868,  16'sd0,     16'sd16384, "theta = pi/2    ");
        run_test(16'sd25737, -16'sd16384, 16'sd0,     "theta = pi      ");

        $display("  --- Obtuse angles (quadrant fold applied) ---");

        run_test(16'sd17157, -16'sd8192,  16'sd14189, "theta = 2pi/3   ");
        run_test(16'sd19302, -16'sd11585, 16'sd11585, "theta = 3pi/4   ");
        run_test(16'sd21446, -16'sd14189, 16'sd8192,  "theta = 5pi/6   ");

        $display("  --- Negative angles ---");

        run_test(-16'sd6434,  16'sd11585,-16'sd11585, "theta = -pi/4   ");
        run_test(-16'sd12868, 16'sd0,    -16'sd16384, "theta = -pi/2   ");
        run_test(-16'sd19302,-16'sd11585,-16'sd11585, "theta = -3pi/4  ");

        $display("  --- Back-to-back IDLE recovery ---");

        run_test(16'sd0,      16'sd16384, 16'sd0,     "theta = 0 again ");

        $display("-------------------------------------------------------");
        $display("  Results: %0d passed, %0d failed", pass_count, fail_count);
        $display("=======================================================");
        $finish;
    end

endmodule
