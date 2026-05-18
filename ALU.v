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

module ALU (
    input       [`WORDWIDTH-1:0] a,
    input       [`WORDWIDTH-1:0] b,
    input       [2:0] ALUcnt,
    
    output reg  [`WORDWIDTH-1:0] result,
    output wire zero
);

    assign zero = (result == `WORDWIDTH'd0);

    always @(*) begin
        case (ALUcnt)
            3'b000: result = a+b;           // Additiomn
            3'b001: result = a-b;           // Subtraction
            3'b010: result = a&b;           // Bitwise AND
            3'b011: result = a|b;           // Bitwise OR
            3'b100: result = ~a;            // Bitwise Inverstion of a
            3'b101: result = a<<b[3:0];     // Left shift a of last 4 bits of b
            3'b110: result = a>>b[3:0];     // Right shift a of last 4 bits of b
            3'b111: result = (a<b) ? `WORDWIDTH'd1 : `WORDWIDTH'd0;   // Set less than 
  
        default: result = `WORDWIDTH'd0;
        endcase
    end
    



    
endmodule