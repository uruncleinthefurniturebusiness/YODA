`timescale 1ns / 1ps
`include "Parameter.v"
`include "ALU.v"
// iverilog -Wall -o alu_sim ALU_tb.v && ./alu_sim && gtkwave alu_waves.vcd &
//

module ALU_tb;

    reg [`WORDWIDTH-1:0]    a;
    reg [`WORDWIDTH-1:0]    b;
    reg [2:0]               ALUcnt;

    wire [`WORDWIDTH-1:0]   result;
    wire                    zero;

    ALU uut (
        .a(a), 
        .b(b), 
        .ALUcnt(ALUcnt), 
        .result(result), 
        .zero(zero)
    );

    initial begin
        $dumpfile("alu_waves.vcd");
        $dumpvars(0, ALU_tb);
    end

    initial begin
        $display("--- Starting ALU Tests ---");

        //#############################################################################
        // Test 1: Addition (10 + 5 = 15)
        a = `WORDWIDTH'd10; 
        b = `WORDWIDTH'd5; 
        ALUcnt = 3'b000; 
        #10; // Wait 10 simulation time units for logic to settle

        if (result !== `WORDWIDTH'd15)
            $display("FAIL: ADD expected 15, got %0d", result);
        else
            $display("PASS: ADD 10 + 5 = %0d", result);

        //#############################################################################
        // Test 2: Zero Flag (7 - 7 = 0)
        a = `WORDWIDTH'd7; 
        b = `WORDWIDTH'd7; 
        ALUcnt = 3'b001; 
        #10; 

        if (zero !== 1'b1)
            $display("FAIL: Zero flag failed. Result: %0d, Zero: %b", result, zero);
        else
            $display("PASS: Zero flag working");

        //#############################################################################
        // Test 3: Subtraction 
        a = `WORDWIDTH'd10;
        b = `WORDWIDTH'd5;
        ALUcnt = 3'b001;
        #10;

        if (result !== `WORDWIDTH'd5)
            $display("FAIL: SUB expected 5, got %0d", result);
        else
            $display("PASS: SUB 10 - 5 = %0d", result);

        //#############################################################################
        // Test 4: Bitwise AND
        a = `WORDWIDTH'b0001111000010101; // 1E15
        b = `WORDWIDTH'b1111000011111111; // F0FF
        ALUcnt = 3'b010;                  // 1015
        #10;

        if (result !== `WORDWIDTH'b0001000000010101)
            $display("FAIL: AND expected b0001000000010101, got b%016d", result);
        else
            $display("PASS: AND b0001111000010101 && b1111000011111111 = b%016b", result);

        //#############################################################################
        // Test 5: Bitwise OR
        a = `WORDWIDTH'b0001111000010101;  //1E15
        b = `WORDWIDTH'b1111000011111111;  //F0FF
        ALUcnt = 3'b011;                   //FEFF
        #10;

        if (result !== `WORDWIDTH'b1111111011111111)
            $display("FAIL:  OR  expected b1111111011111111, got b%016b", result);
        else
            $display("PASS: OR  b0001111000010101 || b1111000011111111 = b%016b", result);

        // #############################################################################
        // Test 6: Bitwise NOT
        a = `WORDWIDTH'b0001111000010101;  //1E15
        b = `WORDWIDTH'b0;                 
        ALUcnt = 3'b100;                   //E1EA
        #10;

        if (result !== `WORDWIDTH'b1110000111101010)
            $display("FAIL:  expected b1110000111101010, got %016b", result);
        else
            $display("PASS: NOT b0001111000010101 = b%016b", result);

        // #############################################################################
        // Test 7: SHL by 1
        a = `WORDWIDTH'b0001111000010101;  // 1E15
        b = `WORDWIDTH'b0000000000000001;  //
        ALUcnt = 3'b101;
        #10;

        if (result !== `WORDWIDTH'b0011110000101010) // 3C2A
            $display("FAIL: SHL expected 0011110000101010, got %016b", result);
        else
            $display("PASS: SHL b0001111000010101 << 1 = %016b", result);

        // #######################################################################
        // Test 8: SHR by 8
        a = `WORDWIDTH'b0001111000010101;  // 1E15 
        b = `WORDWIDTH'b0000000000001000;  // 0008
        ALUcnt = 3'b110;
        #10;

        if (result !== `WORDWIDTH'b0000000000011110) // 001E
            $display("FAIL:  expected 0000000000011110, got %0d", result);
        else
            $display("PASS: SHR 0001111000010101 >> 8 = %016b", result);

        // #######################################################################
        // Test 9: SLT 
        a = `WORDWIDTH'b0000000000001000;
        b = `WORDWIDTH'b0000000000000100;
        ALUcnt = 3'b111;
        #10;

        if (result !== `WORDWIDTH'b0)
            $display("FAIL:  expected 0, got %0d", result);
        else
            $display("PASS: SLT 0000000000001000 < 0000000000000100 = %0d", result);

        // Test 9: SLT 
        a = `WORDWIDTH'b0000000000000100;
        b = `WORDWIDTH'b0000000000001000;
        ALUcnt = 3'b111;
        #10;

        if (result !== `WORDWIDTH'b1)
            $display("FAIL:  expected 1, got %0d", result);
        else
            $display("PASS: SLT 0000000000000100 < 0000000000001000 = %0d", result);

        /*// Test 
        a = `WORDWIDTH';
        b = `WORDWIDTH';
        ALUcnt = 3'b;
        #10;

        if (result !== `WORDWIDTH')
            $display("FAIL:  expected , got %0d", result);
        else
            $display("PASS: ", result);*/


        $display("--- Tests Complete ---");
        $finish; 
    end

endmodule