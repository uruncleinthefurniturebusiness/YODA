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

module InstructionMemory(
    input  [`WORDWIDTH-1:0] pc,
    output [`WORDWIDTH-1:0] instruction
);
    reg [`WORDWIDTH-1:0] imem [`INSTRUCTION_DEPTH-1:0];

    initial begin
        $readmemb("test/test.prog", imem);
    end

    assign instruction = imem[pc[4:1]];

endmodule
