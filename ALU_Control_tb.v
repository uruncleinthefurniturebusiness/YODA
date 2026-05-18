`timescale 1ns / 1ps
`include "Parameter.v"
`include "ALU_Control.v" 

// iverilog -Wall -o aluctrl_sim ALU_Control_tb.v && ./aluctrl_sim && gtkwave alu_control_waves.vcd &

module ALU_Control_tb;

    reg [1:0] ALUOp;
    reg [3:0] opcode;

    wire [2:0] ALUcnt;

    // UUT
    ALU_Control uut (
        .ALUOp(ALUOp),
        .opcode(opcode),
        .ALUcnt(ALUcnt)
    );

    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("alu_control_waves.vcd");
        $dumpvars(0, ALU_Control_tb);

        $display("--- Starting ALU Control Unit Tests ---");

        // Test 1: Load/Store (ALUOp = 10)
        // Should force an ADD (000), ignoring the opcode
        ALUOp = 2'b10; 
        opcode = 4'b0000; // Supplying LD opcode, but it shouldn't matter
        #10;
        
        if (ALUcnt !== 3'b000) $display("FAIL T1: Load/Store did not output 000. Got: %b", ALUcnt);
        else $display("PASS T1: Load/Store (ALUOp=10) forced ADD (000)");

        // Test 2: Branch (ALUOp = 01)
        // Should force a SUB (001), ignoring the opcode
        ALUOp = 2'b01; 
        opcode = 4'b1011; // Supplying BEQ opcode, but it shouldn't matter
        #10;
        
        if (ALUcnt !== 3'b001) $display("FAIL T2: Branch did not output 001. Got: %b", ALUcnt);
        else $display("PASS T2: Branch (ALUOp=01) forced SUB (001)");

        // Test 3: R-Type Instructions (ALUOp = 00)
        // Should translate based entirely on the opcode
        ALUOp = 2'b00;

        // Test ADD
        opcode = 4'b0010; #10;
        if (ALUcnt !== 3'b000) $display("FAIL T3.1: R-Type ADD output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.1: R-Type ADD (0010) correctly mapped to 000");

        // Test SUB
        opcode = 4'b0011; #10;
        if (ALUcnt !== 3'b001) $display("FAIL T3.2: R-Type SUB output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.2: R-Type SUB (0011) correctly mapped to 001");

        // Test INV
        opcode = 4'b0100; #10;
        if (ALUcnt !== 3'b100) $display("FAIL T3.3: R-Type INV output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.3: R-Type INV (0100) correctly mapped to 100");

        // Test SHL
        opcode = 4'b0101; #10;
        if (ALUcnt !== 3'b101) $display("FAIL T3.4: R-Type SHL output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.4: R-Type SHL (0101) correctly mapped to 101");

        // Test SHR
        opcode = 4'b0110; #10;
        if (ALUcnt !== 3'b110) $display("FAIL T3.5: R-Type SHR output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.5: R-Type SHR (0110) correctly mapped to 110");

        // Test AND
        opcode = 4'b0111; #10;
        if (ALUcnt !== 3'b010) $display("FAIL T3.6: R-Type AND output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.6: R-Type AND (0111) correctly mapped to 010");

        // Test OR
        opcode = 4'b1000; #10;
        if (ALUcnt !== 3'b011) $display("FAIL T3.7: R-Type OR output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.7: R-Type OR  (1000) correctly mapped to 011");

        // Test SLT
        opcode = 4'b1001; #10;
        if (ALUcnt !== 3'b111) $display("FAIL T3.8: R-Type SLT output wrong. Got: %b", ALUcnt);
        else $display("PASS T3.8: R-Type SLT (1001) correctly mapped to 111");

        #20;
        $display("--- ALU Control Tests Complete ---");
        $finish;
    end

endmodule