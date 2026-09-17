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
  cpu_sequence          random_seq;
  cpu_directed_sequence directed_seq;

  phase.raise_objection(this);

  // 先运行500条constrained-random指令
  random_seq = cpu_sequence::type_id::create(
      "random_seq"
  );

  random_seq.transaction_count = 500;
  random_seq.start(env.agent.sequencer);


  // 再运行10个directed cases，补随机测试遗漏的coverage
  directed_seq = cpu_directed_sequence::type_id::create(
      "directed_seq"
  );

  directed_seq.start(env.agent.sequencer);


  // 等待最后一条指令被monitor采集
  repeat (2) @(env.agent.driver.vif.monitor_cb);

  phase.drop_objection(this);
endtask

endclass