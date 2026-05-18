`timescale 1ns / 1ps
`include "Parameter.v"
`include "DataMemory.v"

// iverilog -Wall -o dmem_sim DataMemory_tb.v && ./dmem_sim && gtkwave dmem_waves.vcd &

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
        // Setup waveform dumping for GTKWave
        $dumpfile("dmem_waves.vcd");
        $dumpvars(0, DataMemory_tb);

        $dumpvars(0, uut.dmem[0]);
        $dumpvars(0, uut.dmem[1]);
        $dumpvars(0, uut.dmem[2]);
        $dumpvars(0, uut.dmem[3]);
        $dumpvars(0, uut.dmem[4]);
        $dumpvars(0, uut.dmem[5]);
        $dumpvars(0, uut.dmem[6]);
        $dumpvars(0, uut.dmem[7]);


        // Initialize all inputs to 0
        MemWr = 1'b0;
        MemRd = 1'b0;
        addr = 3'b000;
        write_data = `WORDWIDTH'd0;

        $display("--- Starting Data Memory Tests ---");
        @(posedge clk); #1; // Wait for the first clock cycle to settle

        // Test 1: Gated Read (MemRd = 0)
        // Ensure the memory outputs 0 when we aren't explicitly reading
        addr = 3'b001;
        MemRd = 1'b0;
        #10; // Wait for combinational logic
        
        if (read_data !== `WORDWIDTH'd0)
            $display("FAIL T1: Expected 0 due to MemRd=0, got 0x%04h", read_data);
        else
            $display("PASS T1: Gated read correctly output 0");

        // Test 2: Read Initialization Data (MemRd = 1)
        // Verify $readmemb actually loaded the file
        addr = 3'b000;
        MemRd = 1'b1;
        #10;
        $display("INFO T2: Value initialized at address 0 from file is: 0x%04h", read_data);

        // Test 3 & 4: Synchronous Write and Read-Back
        // Write a known value to address 5, then read it back
        @(posedge clk); #1;
        MemWr = 1'b1;               // Enable writing
        MemRd = 1'b0;               // Disable reading
        addr = 3'b101;              // Target address 5
        write_data = `WORDWIDTH'hBEEF; // Test data
        
        @(posedge clk); #1;         // Wait for clock edge to write
        MemWr = 1'b0;               // Turn off write enable immediately to protect data
        
        // Now attempt to read it back
        addr = 3'b101;
        MemRd = 1'b1;
        #10;

        if (read_data !== `WORDWIDTH'hBEEF)
            $display("FAIL T3/4: Expected 0xBEEF at address 5, got 0x%04h", read_data);
        else
            $display("PASS T3/4: Successfully synchronously wrote and asynchronously read 0xBEEF");

        #20;
        $display("--- Data Memory Tests Complete ---");
        $finish;
    end

endmodule