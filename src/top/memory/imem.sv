module imem (
    input  logic [31:0] a,
    output logic [31:0] rd
);
  logic [31:0] RAM[63:0];
  // initial $readmemh("mem1.hex", RAM, 0);
  initial $readmemh("resource/test.hex", RAM, 0);
  assign rd = RAM[a[31:2]];  // word aligned
endmodule
