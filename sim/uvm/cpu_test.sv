class cpu_test extends uvm_test;

  `uvm_component_utils(cpu_test)

  cpu_env env;

  function new(string name = "cpu_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = cpu_env::type_id::create(
        "env", this
    );
  endfunction


task run_phase(uvm_phase phase);
  cpu_sequence seq;

  phase.raise_objection(this);

  seq = cpu_sequence::type_id::create(
      "seq"
  );

  seq.transaction_count = 500;

  seq.start(env.agent.sequencer);

  // 等待最后一条指令被monitor采集
  repeat (2) @(env.agent.driver.vif.monitor_cb);

  phase.drop_objection(this);
endtask

endclass