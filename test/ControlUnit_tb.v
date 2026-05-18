`timescale 1ns / 1ps
`include "../src/Parameter.v"
`include "../src/ControlUnit.v"

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
    wire CopEn;

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
        .Jump(Jump),
        .CopEn(CopEn)
    );

    integer i;

    initial begin
        $dumpfile("waves/control_unit_waves.vcd");
        $dumpvars(0, ControlUnit_tb);

        $display("--- Starting Control Unit Tests ---");
        $display("OPC | RegDst ALUsrc MemToReg RegWrite MemRd MemWr Branch ALUOp Jump CopEn");
        $display("--------------------------------------------------------------------------");

        for (i = 0; i < 16; i = i + 1) begin
            opcode = i;
            #10;
            $display(" %2h |   %b      %b       %b        %b       %b     %b      %b      %b    %b     %b",
                     opcode, RegDst, ALUsrc, MemToReg, RegWrite, MemRd, MemWr, Branch, ALUOp, Jump, CopEn);

            if (opcode == 4'b1010) begin
                if ({RegDst, ALUsrc, MemToReg, RegWrite, MemRd, MemWr, Branch, ALUOp, Jump} !== 10'b0)
                    $display(">> FAIL: COP opcode did NOT produce all zeros on standard signals!");
                else if (CopEn !== 1'b1)
                    $display(">> FAIL: COP opcode did not assert CopEn!");
                else
                    $display(">> PASS: COP opcode correctly asserts CopEn, all other signals zero.");
            end
        end

        #20;
        $display("--- Control Unit Tests Complete ---");
        $finish;
    end

endmodule
