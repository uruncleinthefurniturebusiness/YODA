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
`include "ALU.v"
`include "GPR.v"
`include "InstructionMemory.v"
`include "DataMemory.v"
`include "ALU_Control.v"
`include "CRU.v"

module Datapath(

    input clk,
    input reset,

    // inputs from the control unit
    input RegDst,
    input ALUSrc,
    input MemToReg,
    input RegWrite,
    input MemRd,
    input MemWr,
    input Branch,
    input [1:0] ALUOp,
    input Jump,
    input CopEn,    // co-processor enable from ControlUnit

    output [3:0] opcode

);

    // --- Internal Wires ---
    reg  [`WORDWIDTH-1:0] pc;
    wire [`WORDWIDTH-1:0] next_pc;
    wire [`WORDWIDTH-1:0] current_instruction;
    
    // GPR Wires
    wire [2:0]            write_reg_addr;
    wire [`WORDWIDTH-1:0] write_data;
    wire [`WORDWIDTH-1:0] read_data1;
    wire [`WORDWIDTH-1:0] read_data2;

    // ALU Wires
    wire [2:0]            alu_control_code;
    wire [`WORDWIDTH-1:0] alu_input_b;
    wire [`WORDWIDTH-1:0] alu_result;
    wire alu_zero;
    
    // Data Memory Wires
    wire [`WORDWIDTH-1:0] memory_read_data;

    // CRU Wires
    wire        cru_busy;
    wire        cru_done;
    wire signed [`WORDWIDTH-1:0] cru_cos;
    wire signed [`WORDWIDTH-1:0] cru_sin;

    // CRU starts only when COP is being decoded and the CRU is free.
    // The ~busy & ~done guard prevents a retrigger on the cycle when
    // done=1 but PC has not yet advanced to the next instruction.
    wire cru_start = CopEn & ~cru_busy & ~cru_done;

    // PC freezes for every cycle COP is in-flight (busy or not yet acked).
    wire cru_stall = CopEn & ~cru_done;

    assign opcode = current_instruction[15:12];

    // ---------------------------------------------------------
    // INSTRUCTION MEMORY
    // ---------------------------------------------------------
    InstructionMemory inst_mem (
        .pc(pc), 
        .instruction(current_instruction)
    );

    // ---------------------------------------------------------
    // MULTIPLEXER: RegDst
    // R-Type uses bits [5:3] and I-Type uses bits [8:6]
    assign write_reg_addr = (RegDst == 1'b1) ? current_instruction[5:3] : current_instruction[8:6];

    // ---------------------------------------------------------
    // GENERAL PURPOSE REGISTERS (GPR)
    // For COP: write cos to WS (inst[8:6]) when cru_done pulses.
    // RegWrite handles all other instructions normally.
    // ---------------------------------------------------------
    wire gpr_write_en = RegWrite | (CopEn & cru_done);

    GPR register_file (
        .clk(clk),
        .write_en(gpr_write_en),
        .read_addr1(current_instruction[11:9]),
        .read_addr2(current_instruction[8:6]),
        .write_addr(write_reg_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ---------------------------------------------------------
    // ALU CONTROL UNIT
    // ---------------------------------------------------------
    ALU_Control alu_ctrl (
        .ALUOp(ALUOp),                       // From Control Unit IN port
        .opcode(current_instruction[15:12]),
        .ALUcnt(alu_control_code)
    );

    // ---------------------------------------------------------
    // COORDINATE ROTATION UNIT (CORDIC co-processor)
    // angle_in = RS1 register value (Q2.14, range ±π/2)
    // cos result written to WS register on cru_done (see PC / GPR logic)
    // sin result readable via LD Rd, R0+7  (data address 7 is intercepted)
    // ---------------------------------------------------------
    CRU cru_unit (
        .clk      (clk),
        .reset    (reset),
        .start    (cru_start),
        .angle_in (read_data1),   // RS1 holds the input angle
        .cos_out  (cru_cos),
        .sin_out  (cru_sin),
        .busy     (cru_busy),
        .done     (cru_done)
    );

    // ---------------------------------------------------------
    // MULTIPLEXER: ALUSrc (Choose between Reg2 or Immediate)
    // ---------------------------------------------------------
    // Note: You will need to sign-extend the immediate value. 
    // Sign-extend the 6-bit offset [5:0] to 16 bits
    wire [`WORDWIDTH-1:0] sign_extended_imm = {{10{current_instruction[5]}}, current_instruction[5:0]};
    
    assign alu_input_b = (ALUSrc == 1'b1) ? sign_extended_imm : read_data2;

    // THE ALU
    ALU main_alu (
        .a(read_data1),
        .b(alu_input_b),          // From the ALUSrc MUX
        .ALUcnt(alu_control_code),// From the ALU_Control
        .result(alu_result),
        .zero(alu_zero)
    );

    // DATA MEMORY
    DataMemory data_mem (
        .clk(clk),
        .MemRd(MemRd),
        .MemWr(MemWr),
        .addr(alu_result[2:0]),   // Usually, the ALU calculates the memory address
        .write_data(read_data2),  // The data we want to store comes from Register 2
        .read_data(memory_read_data)
    );

    // Data memory read with CRU sin intercept:
    // A load from address 7 returns the CRU sin result instead of RAM[7].
    wire [`WORDWIDTH-1:0] mem_read_data_muxed =
        (MemRd && alu_result[2:0] == 3'd7) ? cru_sin : memory_read_data;

    // MULTIPLEXER: MemToReg / COP write-back
    //   COP done  → write cos to destination register
    //   MemToReg  → write data memory read (with sin intercept at addr 7)
    //   default   → write ALU result
    assign write_data = (CopEn & cru_done) ? cru_cos  :
                        MemToReg           ? mem_read_data_muxed :
                                             alu_result;


    // --- PC Calculation Logic ---
    wire [`WORDWIDTH-1:0] pc_plus_2 = pc + 2;
    
    // Branch Target: Shift the sign-extended immediate left by 1, then add to PC+2
    wire [`WORDWIDTH-1:0] branch_offset = sign_extended_imm << 1;
    wire [`WORDWIDTH-1:0] branch_target = pc_plus_2 + branch_offset;
    
    // Jump Target: Upper 3 bits of PC, 12-bit offset, and a 0 at the end
    wire [`WORDWIDTH-1:0] jump_target = {pc[15:13], current_instruction[11:0], 1'b0};

    // Determine if we actually take the branch based on BEQ/BNE rules
    wire is_beq = (opcode == 4'b1011);
    wire is_bne = (opcode == 4'b1100);
    wire take_branch = Branch & ((is_beq & alu_zero) | (is_bne & ~alu_zero));

    // The sequential PC Update
    // cru_stall holds the PC frozen while the CRU is running.
    // The stall clears on the same cycle cru_done rises, so the
    // COS write-back and PC advance happen together at that posedge.
    always @(posedge clk) begin
        if (reset) begin
            pc <= `WORDWIDTH'd0;
        end else if (cru_stall) begin
            pc <= pc;               // CRU in-flight: freeze PC
        end else if (Jump) begin
            pc <= jump_target;      // Execute JMP
        end else if (take_branch) begin
            pc <= branch_target;    // Execute BEQ or BNE
        end else begin
            pc <= pc_plus_2;        // Standard execution
        end
    end

endmodule
    