module top (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData,

    output logic [31:0] PC,
    output logic        MemWrite,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData
);

  riscvsingle core (
      .clk       (clk),
      .reset     (reset),
      .PC        (PC),
      .Instr     (Instr),
      .MemWrite  (MemWrite),
      .ALUResult (ALUResult),
      .WriteData (WriteData),
      .ReadData  (ReadData)
  );

endmodule