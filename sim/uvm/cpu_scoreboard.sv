class cpu_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(cpu_scoreboard)

  uvm_analysis_imp #(cpu_item, cpu_scoreboard) analysis_export;

  int unsigned total_count;
  int unsigned pass_count;
  int unsigned fail_count;

  function new(string name = "cpu_scoreboard",
               uvm_component parent = null);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction


  function void write(cpu_item item);
    bit [31:0] expected_alu;
    bit [31:0] expected_rd;
    bit [31:0] expected_next_pc;
    bit [31:0] expected_store_data;
    bit        expected_mem_write;

    bit check_alu;
    bit check_rd;
    bit check_store_data;
    bit item_pass;

    logic signed [31:0] signed_rs1;
    logic signed [31:0] signed_rs2;
    logic signed [31:0] signed_imm;

    total_count++;
    item_pass = 1'b1;

    signed_rs1 = item.rs1_value;
    signed_rs2 = item.rs2_value;
    signed_imm = item.immediate;

    expected_alu        = 32'b0;
    expected_rd         = 32'b0;
    expected_next_pc    = item.pc + 32'd4;
    expected_store_data = item.rs2_value;
    expected_mem_write  = 1'b0;

    check_alu        = 1'b1;
    check_rd         = 1'b0;
    check_store_data = 1'b0;

    case (item.instr_type)

      ADD: begin
        expected_alu = item.rs1_value + item.rs2_value;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      SUB: begin
        expected_alu = item.rs1_value - item.rs2_value;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      AND: begin
        expected_alu = item.rs1_value & item.rs2_value;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      OR: begin
        expected_alu = item.rs1_value | item.rs2_value;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      XOR: begin
        expected_alu = item.rs1_value ^ item.rs2_value;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      SLT: begin
        expected_alu = signed_rs1 < signed_rs2;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      SLL: begin
        expected_alu = item.rs1_value << item.rs2_value[4:0];
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      SRL: begin
        expected_alu = item.rs1_value >> item.rs2_value[4:0];
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      ADDI: begin
        expected_alu = item.rs1_value + signed_imm;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      ANDI: begin
        expected_alu = item.rs1_value & signed_imm;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      ORI: begin
        expected_alu = item.rs1_value | signed_imm;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      XORI: begin
        expected_alu = item.rs1_value ^ signed_imm;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      SLTI: begin
        expected_alu = signed_rs1 < signed_imm;
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      SLLI: begin
        expected_alu = item.rs1_value << item.immediate[4:0];
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      SRLI: begin
        expected_alu = item.rs1_value >> item.immediate[4:0];
        expected_rd  = expected_alu;
        check_rd     = 1'b1;
      end

      LW: begin
        expected_alu = item.rs1_value + signed_imm;
        expected_rd  = item.read_data;
        check_rd     = 1'b1;
      end

      SW: begin
        expected_alu        = item.rs1_value + signed_imm;
        expected_mem_write  = 1'b1;
        expected_store_data = item.rs2_value;
        check_store_data    = 1'b1;
      end

      BEQ: begin
        expected_alu = item.rs1_value - item.rs2_value;

        if (item.rs1_value == item.rs2_value)
          expected_next_pc = item.pc + signed_imm;
      end

      BNE: begin
        expected_alu = item.rs1_value - item.rs2_value;

        if (item.rs1_value != item.rs2_value)
          expected_next_pc = item.pc + signed_imm;
      end

      JAL: begin
        // JAL的ALUResult不参与架构结果
        check_alu        = 1'b0;
        expected_rd      = item.pc + 32'd4;
        expected_next_pc = item.pc + signed_imm;
        check_rd         = 1'b1;
      end

      default: begin
        `uvm_fatal("SCOREBOARD", "Unsupported instruction type")
      end

    endcase

    compare_value(
        "MemWrite",
        item.mem_write,
        expected_mem_write,
        item,
        item_pass
    );

    compare_value(
        "Next PC",
        item.next_pc,
        expected_next_pc,
        item,
        item_pass
    );

    if (check_alu) begin
      compare_value(
          "ALU result",
          item.alu_result,
          expected_alu,
          item,
          item_pass
      );
    end

    if (check_rd) begin
      compare_value(
          "Register result",
          item.rd_value,
          expected_rd,
          item,
          item_pass
      );
    end

    if (check_store_data) begin
      compare_value(
          "Store data",
          item.write_data,
          expected_store_data,
          item,
          item_pass
      );
    end

    if (item_pass) begin
      pass_count++;

      `uvm_info(
          "SCOREBOARD",
          $sformatf(
              "PASS: %s instr=0x%08h",
              item.instr_type.name(),
              item.instr
          ),
          UVM_HIGH
      )
    end
    else begin
      fail_count++;
    end
  endfunction


  function void compare_value(
      string       field_name,
      bit [31:0]   actual,
      bit [31:0]   expected,
      cpu_item     item,
      ref bit      item_pass
  );
    if (actual !== expected) begin
      item_pass = 1'b0;

      `uvm_error(
          "MISMATCH",
          $sformatf(
              "%s: %s instr=0x%08h actual=0x%08h expected=0x%08h",
              item.instr_type.name(),
              field_name,
              item.instr,
              actual,
              expected
          )
      )
    end
  endfunction


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(
        "SCOREBOARD",
        $sformatf(
            "Total=%0d Passed=%0d Failed=%0d",
            total_count,
            pass_count,
            fail_count
        ),
        UVM_NONE
    )
  endfunction

endclass