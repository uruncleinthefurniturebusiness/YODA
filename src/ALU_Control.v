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

module ALU_Control (
    input [1:0] ALUOp,
    input [3:0] opcode,

    output reg [2:0] ALUcnt
);
    always @(*) begin
        ALUcnt = 3'b000;

        case (ALUOp)
            2'b00: begin
                case (opcode)
                    4'b0010: ALUcnt = 3'b000; // ADD
                    4'b0011: ALUcnt = 3'b001; // SUB
                    4'b0100: ALUcnt = 3'b100; // NOT
                    4'b0101: ALUcnt = 3'b101; // SHL
                    4'b0110: ALUcnt = 3'b110; // SHR
                    4'b0111: ALUcnt = 3'b010; // AND
                    4'b1000: ALUcnt = 3'b011; // OR
                    4'b1001: ALUcnt = 3'b111; // SLT
                    default: ALUcnt = 3'b000;
                endcase
            end
            2'b01: ALUcnt = 3'b001; // Branch: force SUB
            2'b10: ALUcnt = 3'b000; // Load/Store: force ADD
            default: ALUcnt = 3'b000;
        endcase
    end

endmodule
