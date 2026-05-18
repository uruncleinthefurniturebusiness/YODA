`timescale 1ns / 1ps
`include "../src/Parameter.v"
`include "../src/StarCore1.v"

module StarCore1_tb;

    reg clk;
    reg reset;

    StarCore1 uut (
        .clk(clk),
        .reset(reset)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;
    integer i;

    initial begin
        $dumpfile("waves/starcore_execution.vcd");
        $dumpvars(0, StarCore1_tb);

        for (i = 0; i < 8; i = i + 1) begin
            $dumpvars(0, uut.main_dp.register_file.registers[i]);
        end

        for (i = 0; i < 8; i = i + 1) begin
            $dumpvars(0, uut.main_dp.data_mem.dmem[i]);
        end

        $display("========================================");
        $display("--- Starting StarCore-1 Execution ---");

        reset = 1'b1;
        #10;
        reset = 1'b0;

        #400;

        $display("Execution Complete");
        $display("========================================");

        $finish;
    end

endmodule
