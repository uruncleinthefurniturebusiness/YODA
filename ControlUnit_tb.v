`timescale 1ns / 1ps
`include "Parameter.v"
`include "ControlUnit.v"

// iverilog -Wall -o cu_sim ControlUnit_tb.v && ./cu_sim && gtkwave control_unit_waves.vcd &

module ControlUnit_tb;

    reg [3:0] opcode;

    wire RegDst; 
    wire ALUsrc;
    wire MemToReg;
    wire RegWrite;
    wire MemRd;
    wire MemWr;
    wire Branch;
    wire [1:0] ALUOp;
    wire Jump;

    ControlUnit uut (
        .opcode(opcode),
        .RegDst(RegDst),
        .ALUsrc(ALUsrc),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .MemRd(MemRd),
        .MemWr(MemWr),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .Jump(Jump)
    );

    // Variable for the loop
    integer i;

    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("control_unit_waves.vcd");
        $dumpvars(0, ControlUnit_tb);

        $display("--- Starting Control Unit Tests ---");
        
        // Print a nice header for our truth table
        $display("OPC | RegDst ALUsrc MemToReg RegWrite MemRd MemWr Branch ALUOp Jump");
        $display("-------------------------------------------------------------------");

        // Loop through all 16 possible 4-bit opcodes
        for (i = 0; i < 16; i = i + 1) begin
            opcode = i;
            #10; // Wait for combinational logic to settle
            
            // Print the current state of all output wires
            $display(" %2h |   %b      %b       %b        %b       %b     %b      %b      %b    %b", 
                     opcode, RegDst, ALUsrc, MemToReg, RegWrite, MemRd, MemWr, Branch, ALUOp, Jump);

            // Explicitly test the safety requirement for the Co-Processor opcode (10)
            if (opcode == 4'b1010) begin
                if ({RegDst, ALUsrc, MemToReg, RegWrite, MemRd, MemWr, Branch, ALUOp, Jump} !== 10'b0) begin
                    $display(">> FAIL: Reserved Opcode 1010 did NOT produce all zeros!");
                end else begin
                    $display(">> PASS: Reserved Opcode 1010 safely produced all zeros.");
                end
            end
        end

        #20;
        $display("--- Control Unit Tests Complete ---");
        $finish;
    end

endmodule