// =========================================================================
// Practical 4: StarCore-1 — Single-Cycle Processor in Verilog
// =========================================================================
//
// GROUP NUMBER: 11
//
// MEMBERS:
//   - Joshua Smith,    SMTJOS022
//   - Ebrahim Bhyat,   BHYEBR002
//   - Tlangalani Tembe, TMBTLA001

`include "Parameter.v"
`include "Datapath.v"
`include "ControlUnit.v"

module StarCore1 (
    input clk,
    input reset
);

    wire [3:0] wire_opcode;

    wire       wire_RegDst;
    wire       wire_ALUSrc;
    wire       wire_MemToReg;
    wire       wire_RegWrite;
    wire       wire_MemRd;
    wire       wire_MemWr;
    wire       wire_Branch;
    wire       wire_Jump;
    wire [1:0] wire_ALUOp;
    wire       wire_CopEn;

    ControlUnit main_cu (
        .opcode(wire_opcode),
        .RegDst(wire_RegDst),
        .ALUsrc(wire_ALUSrc),
        .MemToReg(wire_MemToReg),
        .RegWrite(wire_RegWrite),
        .MemRd(wire_MemRd),
        .MemWr(wire_MemWr),
        .Branch(wire_Branch),
        .ALUOp(wire_ALUOp),
        .Jump(wire_Jump),
        .CopEn(wire_CopEn)
    );

    Datapath main_dp (
        .clk(clk),
        .reset(reset),
        .RegDst(wire_RegDst),
        .ALUSrc(wire_ALUSrc),
        .MemToReg(wire_MemToReg),
        .RegWrite(wire_RegWrite),
        .MemRd(wire_MemRd),
        .MemWr(wire_MemWr),
        .Branch(wire_Branch),
        .Jump(wire_Jump),
        .ALUOp(wire_ALUOp),
        .CopEn(wire_CopEn),
        .opcode(wire_opcode)
    );

endmodule
