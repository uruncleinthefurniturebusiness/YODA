`timescale 1ns / 1ps
`include "../src/Parameter.v"
`include "../src/ALU_Control.v"

module ALU_Control_tb;

    reg [1:0] ALUOp;
    reg [3:0] opcode;

    wire [2:0] ALUcnt;

    ALU_Control uut (
        .ALUOp(ALUOp),
        .opcode(opcode),
        .ALUcnt(ALUcnt)
    );

    initial begin
        $dumpfile("waves/alu_control_waves.vcd");
        $dumpvars(0, ALU_Control_tb);

        $display("--- Starting ALU Control Unit Tests ---");

        // Test 1: Load/Store (ALUOp = 10) → ADD
        ALUOp = 2'b10;
        opcode = 4'b0000;
        #10;
        if (ALUcnt !== 3'b000) $display("FAIL T1: Load/Store did not output 000. Got: %b", ALUcnt);
        else $display("PASS T1: Load/Store (ALUOp=10) forced ADD (000)");

        // Test 2: Branch (ALUOp = 01) → SUB
        ALUOp = 2'b01;
        opcode = 4'b1011;
        #10;
        if (ALUcnt !== 3'b001) $display("FAIL T2: Branch did not output 001. Got: %b", ALUcnt);
        else $display("PASS T2: Branch (ALUOp=01) forced SUB (001)");

        // Test 3: R-Type (ALUOp = 00)
        ALUOp = 2'b00;

        opcode = 4'b0010; #10;
        if (ALUcnt !== 3'b000) $display("FAIL T3.1: R-Type ADD wrong. Got: %b", ALUcnt);
        else $display("PASS T3.1: R-Type ADD (0010) → 000");

        opcode = 4'b0011; #10;
        if (ALUcnt !== 3'b001) $display("FAIL T3.2: R-Type SUB wrong. Got: %b", ALUcnt);
        else $display("PASS T3.2: R-Type SUB (0011) → 001");

        opcode = 4'b0100; #10;
        if (ALUcnt !== 3'b100) $display("FAIL T3.3: R-Type INV wrong. Got: %b", ALUcnt);
        else $display("PASS T3.3: R-Type INV (0100) → 100");

        opcode = 4'b0101; #10;
        if (ALUcnt !== 3'b101) $display("FAIL T3.4: R-Type SHL wrong. Got: %b", ALUcnt);
        else $display("PASS T3.4: R-Type SHL (0101) → 101");

        opcode = 4'b0110; #10;
        if (ALUcnt !== 3'b110) $display("FAIL T3.5: R-Type SHR wrong. Got: %b", ALUcnt);
        else $display("PASS T3.5: R-Type SHR (0110) → 110");

        opcode = 4'b0111; #10;
        if (ALUcnt !== 3'b010) $display("FAIL T3.6: R-Type AND wrong. Got: %b", ALUcnt);
        else $display("PASS T3.6: R-Type AND (0111) → 010");

        opcode = 4'b1000; #10;
        if (ALUcnt !== 3'b011) $display("FAIL T3.7: R-Type OR wrong. Got: %b", ALUcnt);
        else $display("PASS T3.7: R-Type OR  (1000) → 011");

        opcode = 4'b1001; #10;
        if (ALUcnt !== 3'b111) $display("FAIL T3.8: R-Type SLT wrong. Got: %b", ALUcnt);
        else $display("PASS T3.8: R-Type SLT (1001) → 111");

        #20;
        $display("--- ALU Control Tests Complete ---");
        $finish;
    end

endmodule
