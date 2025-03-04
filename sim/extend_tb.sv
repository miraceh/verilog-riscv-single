`timescale 1ns/1ps

module extend_tb;
  reg [31:7] instr;
  reg [1:0] immsrc;
  wire [31:0] immext;

  // Instantiate the module under test
  extend dut (
    .instr(instr),
    .immsrc(immsrc),
    .immext(immext)
  );

  // Task for testing immediate extensions
  task testImm;
    input [31:0] instruction;
    input [1:0] immSrc;
    input [31:0] expected;
  begin
    instr = instruction[31:7]; // Assign only bits 31:7
    immsrc = immSrc;
    #10; // Wait for the result to stabilize
    $display("Instr: 0x%08X, immSrc: %b -> ImmExt: 0x%08X (Expected: 0x%08X)", 
             instruction, immSrc, immext, expected);
    if (immext !== expected)
      $display("❌ ERROR: Expected 0x%08X, but got 0x%08X", expected, immext);
    else
      $display("✅ Passed");
  end
  endtask

  initial begin
    $display("Starting Extend Testbench...");
    
    // **Test J-type instruction (JAL)**
    testImm(32'h00008067, 2'b11, 32'hFFF00000); // imm = -1048576

    $display("Extend Testbench Completed.");
    $stop;
  end
endmodule
