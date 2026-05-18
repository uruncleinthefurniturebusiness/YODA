`timescale 1ns / 1ps
`include "../src/Parameter.v"
`include "../src/InstructionMemory.v"

module InstructionMemory_tb;

    reg  [`WORDWIDTH-1:0] pc;
    wire [`WORDWIDTH-1:0] instruction;

    InstructionMemory uut (
        .pc(pc),
        .instruction(instruction)
    );

    integer i;

    initial begin
        $dumpfile("waves/imem_waves.vcd");
        $dumpvars(0, InstructionMemory_tb);

        $dumpvars(0, uut.imem[0]);
        $dumpvars(0, uut.imem[1]);
        $dumpvars(0, uut.imem[2]);
        $dumpvars(0, uut.imem[3]);
        $dumpvars(0, uut.imem[4]);
        $dumpvars(0, uut.imem[5]);
        $dumpvars(0, uut.imem[6]);
        $dumpvars(0, uut.imem[7]);
        $dumpvars(0, uut.imem[8]);
        $dumpvars(0, uut.imem[9]);
        $dumpvars(0, uut.imem[10]);
        $dumpvars(0, uut.imem[11]);
        $dumpvars(0, uut.imem[12]);
        $dumpvars(0, uut.imem[13]);
        $dumpvars(0, uut.imem[14]);
        $dumpvars(0, uut.imem[15]);

        $display("--- Starting Instruction Memory Test ---");

        for (i = 0; i < 16; i = i + 1) begin
            pc = i * 2;
            #10;
            $display("Time: %0t | PC: %02d (0x%04h) | Fetched Instruction: %4h", $time, pc, pc, instruction);
        end

        #20;
        $display("--- Instruction Memory Test Complete ---");
        $finish;
    end

endmodule
