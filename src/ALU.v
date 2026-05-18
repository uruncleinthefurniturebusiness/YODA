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
            3'b000: result = a+b;
            3'b001: result = a-b;
            3'b010: result = a&b;
            3'b011: result = a|b;
            3'b100: result = ~a;
            3'b101: result = a<<b[3:0];
            3'b110: result = a>>b[3:0];
            3'b111: result = (a<b) ? `WORDWIDTH'd1 : `WORDWIDTH'd0;
        default: result = `WORDWIDTH'd0;
        endcase
    end

endmodule
