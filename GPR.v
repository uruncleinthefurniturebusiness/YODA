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

module GPR (
    input   clk,
    input   write_en,
    input   [2:0]  read_addr1,
    input   [2:0]  read_addr2,
    input   [2:0]  write_addr,
    input   [`WORDWIDTH-1:0] write_data,

    output  [`WORDWIDTH-1:0] read_data1,
    output  [`WORDWIDTH-1:0] read_data2
    

);

    reg     [`WORDWIDTH-1:0] registers [7:0];

    assign read_data1 = (read_addr1 == 3'b000) ? `WORDWIDTH'd0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 3'b000) ? `WORDWIDTH'd0 : registers[read_addr2];

    // Synchronous write port, won't write to R0
    always @(posedge clk) begin
        if (write_en == 1'b1 && write_addr != 3'b000) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule