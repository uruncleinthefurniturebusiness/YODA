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

    // ---------------------------------------------------------
    // 1. Declare Interconnect Wires
    // These wires act as the physical traces on the motherboard 
    // connecting the two chips.
    // ---------------------------------------------------------
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

    // ---------------------------------------------------------
    // 2. Instantiate the Control Unit
    // Feed it the opcode, and connect its outputs to our wires.
    // ---------------------------------------------------------
    ControlUnit main_cu (
        .opcode(wire_opcode),     // IN from Datapath
        .RegDst(wire_RegDst),     // OUT to Datapath
        .ALUsrc(wire_ALUSrc),     // OUT to Datapath
        .MemToReg(wire_MemToReg), // OUT to Datapath
        .RegWrite(wire_RegWrite), // OUT to Datapath
        .MemRd(wire_MemRd),       // OUT to Datapath
        .MemWr(wire_MemWr),       // OUT to Datapath
        .Branch(wire_Branch),     // OUT to Datapath
        .ALUOp(wire_ALUOp),       // OUT to Datapath
        .Jump(wire_Jump),         // OUT to Datapath
        .CopEn(wire_CopEn)        // OUT to Datapath (CRU co-processor)
    );

    // ---------------------------------------------------------
    // 3. Instantiate the Datapath
    // Feed it the control signals, and route the opcode out.
    // ---------------------------------------------------------
    Datapath main_dp (
        .clk(clk),
        .reset(reset),

        // Control signals IN from Control Unit
        .RegDst(wire_RegDst),
        .ALUSrc(wire_ALUSrc),
        .MemToReg(wire_MemToReg),
        .RegWrite(wire_RegWrite),
        .MemRd(wire_MemRd),
        .MemWr(wire_MemWr),
        .Branch(wire_Branch),
        .Jump(wire_Jump),
        .ALUOp(wire_ALUOp),
        .CopEn(wire_CopEn),       // CRU co-processor enable

        // Opcode OUT to Control Unit
        .opcode(wire_opcode)
    );

endmodule