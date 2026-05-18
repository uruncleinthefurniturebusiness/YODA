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

module DataMemory(
    input clk,
    input MemWr,
    input MemRd,
    input [2:0] addr,
    input  [`WORDWIDTH-1:0] write_data,
    output [`WORDWIDTH-1:0] read_data
);
    reg [`WORDWIDTH-1:0] dmem [`DATA_DEPTH-1:0];

    initial begin
        $readmemb("test/test.data", dmem);
    end

    assign read_data = (MemRd == 1'b1) ? dmem[addr] : `WORDWIDTH'd0;

    always @(posedge clk) begin
        if (MemWr == 1'b1) begin
            dmem[addr] <= write_data;
        end
    end

endmodule
