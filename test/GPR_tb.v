`timescale 1ns / 1ps
`include "../src/Parameter.v"
`include "../src/GPR.v"

module GPR_tb;

    reg                       clk;
    reg                       write_en;
    reg  [2:0]                read_addr1;
    reg  [2:0]                read_addr2;
    reg  [2:0]                write_addr;
    reg  [`WORDWIDTH-1:0]     write_data;

    wire [`WORDWIDTH-1:0]     read_data1;
    wire [`WORDWIDTH-1:0]     read_data2;

    GPR uut (
        .clk(clk),
        .write_en(write_en),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/gpr_waves.vcd");
        $dumpvars(0, GPR_tb);

        $dumpvars(0, uut.registers[0]);
        $dumpvars(0, uut.registers[1]);
        $dumpvars(0, uut.registers[2]);
        $dumpvars(0, uut.registers[3]);
        $dumpvars(0, uut.registers[4]);
        $dumpvars(0, uut.registers[5]);
        $dumpvars(0, uut.registers[6]);
        $dumpvars(0, uut.registers[7]);

        write_en = 1'b0;
        read_addr1 = 3'b000;
        read_addr2 = 3'b000;
        write_addr = 3'b000;
        write_data = `WORDWIDTH'd0;

        $display("--- Starting GPR Tests ---");

        // Test 1: Write to R1, read back
        @(posedge clk); #1;
        write_en = 1'b1;
        write_addr = 3'b001;
        write_data = `WORDWIDTH'hAAAA;

        @(posedge clk); #1;
        write_en = 1'b0;
        read_addr1 = 3'b001;
        #10;

        if (read_data1 !== `WORDWIDTH'hAAAA)
            $display("FAIL T1: Expected 0xAAAA from R1, got 0x%04h", read_data1);
        else
            $display("PASS T1: Successfully wrote and read 0xAAAA to R1");

        // Test 2: R0 hardwired to 0
        @(posedge clk); #1;
        write_en = 1'b1;
        write_addr = 3'b000;
        write_data = `WORDWIDTH'hFFFF;

        @(posedge clk); #1;
        write_en = 1'b0;
        read_addr1 = 3'b000;
        #10;

        if (read_data1 !== `WORDWIDTH'd0)
            $display("FAIL T2: R0 was overwritten. Got 0x%04h", read_data1);
        else
            $display("PASS T2: R0 correctly hardwired to 0");

        // Test 3: Write enable gating
        @(posedge clk); #1;
        write_en = 1'b0;
        write_addr = 3'b010;
        write_data = `WORDWIDTH'hBEEF;

        @(posedge clk); #1;
        read_addr1 = 3'b010;
        #10;

        if (read_data1 === `WORDWIDTH'hBEEF)
            $display("FAIL T3: Wrote 0xBEEF to R2 while write_en was low!");
        else
            $display("PASS T3: Write Enable logic protected R2");

        // Test 4: Dual read ports
        @(posedge clk); #1;
        write_en = 1'b1;
        write_addr = 3'b010;
        write_data = `WORDWIDTH'h1234;

        @(posedge clk); #1;
        write_en = 1'b0;
        read_addr1 = 3'b001;
        read_addr2 = 3'b010;
        #10;

        if (read_data1 !== `WORDWIDTH'hAAAA || read_data2 !== `WORDWIDTH'h1234)
            $display("FAIL T4: Dual read failed. R1: 0x%04h, R2: 0x%04h", read_data1, read_data2);
        else
            $display("PASS T4: Dual asynchronous read successful");

        #20;
        $display("--- Tests Complete ---");
        $finish;
    end

endmodule
