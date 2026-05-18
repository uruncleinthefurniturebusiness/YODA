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

module ControlUnit (
    input [3:0] opcode,

    output reg RegDst,
    output reg ALUsrc,
    output reg MemToReg,
    output reg RegWrite,
    output reg MemRd,
    output reg MemWr,
    output reg Branch,
    output reg [1:0] ALUOp,
    output reg Jump,
    output reg CopEn    // CRU co-processor enable (opcode 1010)
);

    always @(*) begin
        // Default values
        RegDst   = 1'b0;
        ALUsrc   = 1'b0;
        MemToReg = 1'b0;
        RegWrite = 1'b0;
        MemRd    = 1'b0;
        MemWr    = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;
        Jump     = 1'b0;
        CopEn    = 1'b0;

        case (opcode)
            4'b0000: begin   // LD
                RegDst = 1'b0;
                ALUsrc = 1'b1;
                MemToReg = 1'b1;
                RegWrite = 1'b1;
                MemRd = 1'b1;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b10;
                Jump = 1'b0;
            end
            4'b0001: begin   // ST
                RegDst = 1'b0;
                ALUsrc = 1'b1;
                MemToReg = 1'b0;
                RegWrite = 1'b0;
                MemRd = 1'b0;
                MemWr = 1'b1;
                Branch = 1'b0;
                ALUOp = 2'b10;
                Jump = 1'b0;
            end
            4'b0010: begin   // ADD
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b0011: begin   // SUB
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b0100: begin   // INV
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b0101: begin   // SHL
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b0110: begin   // SHR
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b0111: begin   // AND
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b1000: begin   // OR
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b1001: begin   // SLT
                RegDst = 1'b1; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b1; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b0;
            end
            4'b1010: begin   // COP — Coordinate Rotation Unit
                RegDst   = 1'b0;
                ALUsrc   = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b0; // write-back gated by cru_done in Datapath
                MemRd    = 1'b0;
                MemWr    = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
                Jump     = 1'b0;
                CopEn    = 1'b1;
            end
            4'b1011: begin   // BEQ
                RegDst = 1'b0; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b0; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b1; ALUOp = 2'b01; Jump = 1'b0;
            end
            4'b1100: begin   // BNE
                RegDst = 1'b0; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b0; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b1; ALUOp = 2'b01; Jump = 1'b0;
            end
            4'b1101: begin   // JMP
                RegDst = 1'b0; ALUsrc = 1'b0; MemToReg = 1'b0;
                RegWrite = 1'b0; MemRd = 1'b0; MemWr = 1'b0;
                Branch = 1'b0; ALUOp = 2'b00; Jump = 1'b1;
            end
            default: ;
        endcase
    end

endmodule
