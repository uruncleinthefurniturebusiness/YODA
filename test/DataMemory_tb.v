`timescale 1ns / 1ps
`include "../src/Parameter.v"
`include "../src/DataMemory.v"

module DataMemory_tb;

    reg clk;
    reg MemWr;
    reg MemRd;
    reg [2:0] addr;
    reg [`WORDWIDTH-1:0] write_data;

    wire [`WORDWIDTH-1:0] read_data;

    DataMemory uut (
        .clk(clk),
        .MemWr(MemWr),
        .MemRd(MemRd),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/dmem_waves.vcd");
        $dumpvars(0, DataMemory_tb);

        $dumpvars(0, uut.dmem[0]);
        $dumpvars(0, uut.dmem[1]);
        $dumpvars(0, uut.dmem[2]);
        $dumpvars(0, uut.dmem[3]);
        $dumpvars(0, uut.dmem[4]);
        $dumpvars(0, uut.dmem[5]);
        $dumpvars(0, uut.dmem[6]);
        $dumpvars(0, uut.dmem[7]);

        MemWr = 1'b0;
        MemRd = 1'b0;
        addr = 3'b000;
        write_data = `WORDWIDTH'd0;

        $display("--- Starting Data Memory Tests ---");
        @(posedge clk); #1;

        // Test 1: Gated read (MemRd = 0)
        addr = 3'b001;
        MemRd = 1'b0;
        #10;

        if (read_data !== `WORDWIDTH'd0)
            $display("FAIL T1: Expected 0 due to MemRd=0, got 0x%04h", read_data);
        else
            $display("PASS T1: Gated read correctly output 0");

        // Test 2: Read initialisation data
        addr = 3'b000;
        MemRd = 1'b1;
        #10;
        $display("INFO T2: Value at address 0 from file is: 0x%04h", read_data);

        // Test 3/4: Synchronous write, then read back
        @(posedge clk); #1;
        MemWr = 1'b1;
        MemRd = 1'b0;
        addr = 3'b101;
        write_data = `WORDWIDTH'hBEEF;

        @(posedge clk); #1;
        MemWr = 1'b0;
        addr = 3'b101;
        MemRd = 1'b1;
        #10;

        if (read_data !== `WORDWIDTH'hBEEF)
            $display("FAIL T3/4: Expected 0xBEEF at address 5, got 0x%04h", read_data);
        else
            $display("PASS T3/4: Successfully wrote and read back 0xBEEF");

        #20;
        $display("--- Data Memory Tests Complete ---");
        $finish;
    end

endmodule
