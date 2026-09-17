class cpu_directed_sequence extends cpu_sequence;

  `uvm_object_utils(cpu_directed_sequence)

  function new(string name = "cpu_directed_sequence");
    super.new(name);
  endfunction


  task body();
    special_values_case();
    load_high_register_case();
    branch_register_case();
    logical_immediate_mid_case();
    immediate_register_case();
    store_register_case();
    load_zero_register_case();
    shift_zero_register_case();
    immediate_alu_zero_register_case();
    register_alu_zero_register_case();
  endtask


  // Case 1: all-ones operands、zero immediate、BNE使用x24-x31
  task special_values_case();
    send_directed(
        BNE,
        5'd25,
        5'd1,
        5'd2,
        32'hffffffff,
        32'hffffffff,
        21'sd0,
        32'h0
    );
    // XORI × x24-x31
    send_directed(
        XORI,
        5'd25,
        5'd1,
        5'd3,
        32'h12345678,
        32'h0,
        21'sh0ff,
        32'h0
    );

    // SLTI × x24-x31
    send_directed(
        SLTI,
        5'd26,
        5'd1,
        5'd4,
        32'hffffffff,
        32'h0,
        21'sd1,
        32'h0
    );    
  endtask


  // Case 2: LW覆盖高位寄存器范围
  task load_high_register_case();
    send_directed(
        LW,
        5'd25,
        5'd1,
        5'd2,
        32'h00001000,
        32'h0,
        21'sd4,
        32'h12345678
    );

    send_directed(
        LW,
        5'd17,
        5'd1,
        5'd3,
        32'h00002000,
        32'h0,
        21'sd8,
        32'h87654321
    );
  endtask


  // Case 3: BEQ/BNE覆盖中、低和x0寄存器
  task branch_register_case();
    send_directed(
        BEQ,
        5'd17,
        5'd1,
        5'd2,
        32'h55,
        32'h55,
        21'sd8,
        32'h0
    );

    send_directed(
        BNE,
        5'd5,
        5'd1,
        5'd2,
        32'h10,
        32'h20,
        21'sd8,
        32'h0
    );

    send_directed(
        BEQ,
        5'd0,
        5'd1,
        5'd2,
        32'h0,
        32'h0,
        21'sd8,
        32'h0
    );

    send_directed(
        BNE,
        5'd0,
        5'd1,
        5'd2,
        32'h0,
        32'h1,
        21'sd8,
        32'h0
    );
  endtask


  // Case 4: ORI/ANDI使用x16-x23
  task logical_immediate_mid_case();
    send_directed(
        ORI,
        5'd17,
        5'd1,
        5'd2,
        32'h12340000,
        32'h0,
        21'sh0ff,
        32'h0
    );

    send_directed(
        ANDI,
        5'd18,
        5'd1,
        5'd3,
        32'hffffffff,
        32'h0,
        21'sh055,
        32'h0
    );
    // ADDI × x16-x23
    send_directed(
        ADDI,
        5'd19,
        5'd1,
        5'd4,
        32'h00000100,
        32'h0,
        21'sd16,
        32'h0
    );
  endtask


  // Case 5: SLLI/ANDI使用x8-x15
  task immediate_register_case();
    send_directed(
        SLLI,
        5'd9,
        5'd1,
        5'd2,
        32'h00000001,
        32'h0,
        21'sd4,
        32'h0
    );

    send_directed(
        ANDI,
        5'd10,
        5'd1,
        5'd3,
        32'habcdef12,
        32'h0,
        21'sh0ff,
        32'h0
    );
// XORI × x8-x15
send_directed(
    XORI,
    5'd11,
    5'd1,
    5'd4,
    32'habcdef12,
    32'h0,
    21'sh0ff,
    32'h0
);

// SLTI × x1-x7
send_directed(
    SLTI,
    5'd5,
    5'd1,
    5'd5,
    32'hffffffff,
    32'h0,
    21'sd0,
    32'h0
);
  endtask


  // Case 6: SW使用x1-x7和x0
  task store_register_case();
    send_directed(
        SW,
        5'd5,
        5'd1,
        5'd2,
        32'h00001000,
        32'hdeadbeef,
        21'sd12,
        32'h0
    );

    send_directed(
        SW,
        5'd0,
        5'd1,
        5'd2,
        32'h0,
        32'hcafebabe,
        21'sd16,
        32'h0
    );
// SW × x24-x31
send_directed(
    SW,
    5'd25,
    5'd1,
    5'd4,
    32'h00002000,
    32'h12345678,
    21'sd20,
    32'h0
);
  endtask


  // Case 7: LW使用x0
  task load_zero_register_case();
    send_directed(
        LW,
        5'd0,
        5'd1,
        5'd2,
        32'h0,
        32'h0,
        21'sd20,
        32'h13572468
    );
  endtask


  // Case 8: SRLI/SLLI使用x0
  task shift_zero_register_case();
    send_directed(
        SRLI,
        5'd0,
        5'd1,
        5'd2,
        32'h0,
        32'h0,
        21'sd4,
        32'h0
    );

    send_directed(
        SLLI,
        5'd0,
        5'd1,
        5'd3,
        32'h0,
        32'h0,
        21'sd8,
        32'h0
    );
  endtask


  // Case 9: I-type ALU指令使用x0
  task immediate_alu_zero_register_case();
    send_directed(
        SLTI,
        5'd0,
        5'd1,
        5'd2,
        32'h0,
        32'h0,
        21'sd1,
        32'h0
    );

    send_directed(
        XORI,
        5'd0,
        5'd1,
        5'd3,
        32'h0,
        32'h0,
        21'sh0ff,
        32'h0
    );

    send_directed(
        ORI,
        5'd0,
        5'd1,
        5'd4,
        32'h0,
        32'h0,
        21'sh055,
        32'h0
    );

    send_directed(
        ADDI,
        5'd0,
        5'd1,
        5'd5,
        32'h0,
        32'h0,
        21'sd10,
        32'h0
    );

// ANDI × x0
send_directed(
    ANDI,
    5'd0,
    5'd1,
    5'd6,
    32'h0,
    32'h0,
    21'sh0ff,
    32'h0
);
  endtask


  // Case 10: R-type逻辑指令使用x0
  task register_alu_zero_register_case();
    send_directed(
        OR,
        5'd0,
        5'd1,
        5'd2,
        32'h0,
        32'h12345678,
        21'sd0,
        32'h0
    );

    send_directed(
        AND,
        5'd0,
        5'd1,
        5'd3,
        32'h0,
        32'hffffffff,
        21'sd0,
        32'h0
    );
  endtask


  task send_directed(
      cpu_instr_e      instr_type,
      bit [4:0]        rs1,
      bit [4:0]        rs2,
      bit [4:0]        rd,
      bit [31:0]       rs1_value,
      bit [31:0]       rs2_value,
      bit signed [20:0] immediate,
      bit [31:0]       read_data
  );
    cpu_item item;

    item = cpu_item::type_id::create("directed_item");

    start_item(item);

    item.instr_type = instr_type;
    item.rs1        = rs1;
    item.rs2        = rs2;
    item.rd         = rd;
    item.rs1_value  = rs1_value;
    item.rs2_value  = rs2_value;
    item.immediate  = immediate;
    item.read_data  = read_data;

    encode_instruction(item);

    finish_item(item);
  endtask

endclass