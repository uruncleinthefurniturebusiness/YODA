`timescale 1ns / 1ps
`include "Parameter.v"
`include "StarCore1.v"

// iverilog -Wall -o cpu_sim StarCore1_tb.v && ./cpu_sim && gtkwave starcore_execution.vcd &

module StarCore1_tb;

    reg clk;
    reg reset;

    // Instantiate the Processor
    StarCore1 uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock
    initial clk = 1'b0;
    always #5 clk = ~clk;
    integer  i;

    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("starcore_execution.vcd");
        $dumpvars(0, StarCore1_tb);

        //FORCE ARRAYS TO DUMP 
        for (i = 0; i < 8; i = i + 1) begin
            $dumpvars(0, uut.main_dp.register_file.registers[i]);
        end
        
        for (i = 0; i < 8; i = i + 1) begin
            $dumpvars(0, uut.main_dp.data_mem.dmem[i]);
        end

        $display("========================================");
        $display("--- Starting StarCore-1 Execution ---");

        // Pulse the reset high for one clock cycle to initialize the PC
        reset = 1'b1;
        #10;
        reset = 1'b0;

        // Let the processor run! 
        // 200ns = 20 clock cycles. Adjust this if your program is longer.
        #400

        $display("Execution Complete");        
        $display("========================================");

        $finish;
    end

endmodule
