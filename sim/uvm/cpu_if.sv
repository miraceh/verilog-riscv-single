interface cpu_if (
    input logic clk
);

  logic        reset;
  logic [31:0] instr;
  logic [31:0] read_data;

  logic [31:0] pc;
  logic        mem_write;
  logic [31:0] alu_result;
  logic [31:0] write_data;

  logic [31:0] src_a;

  // Driver在下降沿发送指令，给组合逻辑半个周期的稳定时间
  clocking driver_cb @(negedge clk);
    output reset;
    output instr;
    output read_data;
  endclocking

  // Monitor在上升沿采集该指令的执行结果
  clocking monitor_cb @(posedge clk);
    input reset;
    input instr;
    input read_data;
    input pc;
    input mem_write;
    input alu_result;
    input write_data;
    input src_a;
  endclocking

  modport DRIVER (
      clocking driver_cb
  );

  modport MONITOR (
      clocking monitor_cb
  );

endinterface