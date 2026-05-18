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
            4'b0000: begin   // OP = 0, LD I-Type Instruction 
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
            4'b0001: begin   // OP = 1, STR I-Type Instruction
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
            4'b0010: begin   // OP = 2, ADD R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b0011: begin   // OP = 3, SUB R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b0100: begin   // OP = 4, INV R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b0101: begin   // OP = 5, SHL R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b0110: begin   // OP = 6, SHR R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b0111: begin   // OP = 7, AND R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b1000: begin   // OP = 8, OR R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b1001: begin   // OP = 9, SLT R-Type Instruction
                RegDst = 1'b1;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b1010: begin   // OP = 10, COP — Coordinate Rotation Unit
                RegDst   = 1'b0; // WS from inst[8:6] (I-type field)
                ALUsrc   = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b0; // write-back gated by cru_done in Datapath
                MemRd    = 1'b0;
                MemWr    = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
                Jump     = 1'b0;
                CopEn    = 1'b1; // signal Datapath to run CRU
            end
            4'b1011: begin   // OP = 11, BEQ
                RegDst = 1'b0;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b0;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b1;
                ALUOp = 2'b01;
                Jump = 1'b0;

            end
            4'b1100: begin   // OP = 12, BNE
                RegDst = 1'b0;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b0;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b1;
                ALUOp = 2'b01;
                Jump = 1'b0;
            end
            4'b1101: begin   // OP = 13, JMP
                RegDst = 1'b0;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b0;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b1;

            end
            4'b1110: begin   // OP = 14
                RegDst = 1'b0;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b0;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            4'b1111: begin   // OP = 15
                RegDst = 1'b0;
                ALUsrc = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b0;
                MemRd = 1'b0;
                MemWr = 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end



        default: ;

        endcase
    end

endmodule