class cpu_driver extends uvm_driver #(cpu_item);

  `uvm_component_utils(cpu_driver)

  virtual cpu_if vif;

  function new(string name = "cpu_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual cpu_if)::get(
        this, "", "vif", vif
    )) begin
      `uvm_fatal("NO_VIF", "cpu_if was not provided to cpu_driver")
    end
  endfunction


  task run_phase(uvm_phase phase);
    initialize_signals();

    forever begin
      seq_item_port.get_next_item(req);

      reset_dut();
      initialize_registers(req);
      drive_instruction(req);

      seq_item_port.item_done();
    end
  endtask


  task initialize_signals();
    vif.driver_cb.reset     <= 1'b1;
    vif.driver_cb.instr     <= 32'h00000013; // addi x0, x0, 0
    vif.driver_cb.read_data <= 32'b0;
  endtask


  task reset_dut();
    vif.driver_cb.reset     <= 1'b1;
    vif.driver_cb.instr     <= 32'h00000013;
    vif.driver_cb.read_data <= 32'b0;

    // 保持reset两个周期，确保每条指令都从PC=0开始
    repeat (2) @(vif.driver_cb);

    vif.driver_cb.reset <= 1'b0;
  endtask


  task initialize_registers(cpu_item item);
    bit success;

    // x0固定为0，不进行backdoor写入
    if (item.rs1 != 0) begin
      success = uvm_hdl_deposit(
          $sformatf(
              "tb_top.dut.core.dp.rf.rf[%0d]",
              item.rs1
          ),
          item.rs1_value
      );

      if (!success) begin
        `uvm_fatal(
            "BACKDOOR",
            $sformatf("Failed to initialize x%0d", item.rs1)
        )
      end
    end

    if (item.rs2 != 0) begin
      success = uvm_hdl_deposit(
          $sformatf(
              "tb_top.dut.core.dp.rf.rf[%0d]",
              item.rs2
          ),
          item.rs2_value
      );

      if (!success) begin
        `uvm_fatal(
            "BACKDOOR",
            $sformatf("Failed to initialize x%0d", item.rs2)
        )
      end
    end
  endtask


  task drive_instruction(cpu_item item);
    vif.driver_cb.instr     <= item.instr;
    vif.driver_cb.read_data <= item.read_data;

    // 下一个posedge执行，随后的negedge表示本条指令执行完成
    @(vif.driver_cb);

    // 避免monitor重复采集同一条指令
    vif.driver_cb.instr <= 32'h00000013;
  endtask

endclass