`timescale 1ns/1ps

module tb_top;

  import uvm_pkg::*;
  import cpu_pkg::*;

  logic clk = 1'b0;

  always #5 clk = ~clk;


  cpu_if intf (
      .clk(clk)
  );


  top dut (
      .clk        (clk),
      .reset      (intf.reset),
      .Instr      (intf.instr),
      .ReadData   (intf.read_data),
      .PC         (intf.pc),
      .MemWrite   (intf.mem_write),
      .ALUResult  (intf.alu_result),
      .WriteData  (intf.write_data)
  );

// 将执行前的rs1操作数提供给monitor采样
assign intf.src_a = dut.core.dp.SrcA;

  initial begin
    intf.reset     = 1'b1;
    intf.instr     = 32'h00000013; // addi x0, x0, 0
    intf.read_data = 32'b0;

    uvm_config_db #(virtual cpu_if)::set(
        null,
        "uvm_test_top.env.agent.*",
        "vif",
        intf
    );

    run_test("cpu_test");
  end


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule