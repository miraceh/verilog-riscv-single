class cpu_coverage extends uvm_subscriber #(cpu_item);

  `uvm_component_utils(cpu_coverage)

  cpu_item sampled_item;
  bit branch_taken;

  covergroup instruction_cg;
    option.per_instance = 1;

    cp_instruction: coverpoint sampled_item.instr_type;

    cp_rd: coverpoint sampled_item.rd {
      bins x1_x7   = {[1:7]};
      bins x8_x15  = {[8:15]};
      bins x16_x23 = {[16:23]};
      bins x24_x31 = {[24:31]};
    }

    cp_rs1: coverpoint sampled_item.rs1 {
      bins x0      = {0};
      bins x1_x7   = {[1:7]};
      bins x8_x15  = {[8:15]};
      bins x16_x23 = {[16:23]};
      bins x24_x31 = {[24:31]};
    }

    cp_rs2: coverpoint sampled_item.rs2 {
      bins x0      = {0};
      bins x1_x7   = {[1:7]};
      bins x8_x15  = {[8:15]};
      bins x16_x23 = {[16:23]};
      bins x24_x31 = {[24:31]};
    }

    cp_rs1_value: coverpoint sampled_item.rs1_value {
      bins zero     = {32'h00000000};
      bins positive = {[32'h00000001:32'h7fffffff]};
      bins negative = {[32'h80000000:32'hfffffffe]};
      bins all_ones = {32'hffffffff};
    }

    cp_rs2_value: coverpoint sampled_item.rs2_value {
      bins zero     = {32'h00000000};
      bins positive = {[32'h00000001:32'h7fffffff]};
      bins negative = {[32'h80000000:32'hfffffffe]};
      bins all_ones = {32'hffffffff};
    }

    cp_immediate: coverpoint sampled_item.immediate
        iff (sampled_item.instr_type inside {
          ADDI, ANDI, ORI, XORI, SLTI,
          LW, SW, BEQ, BNE, JAL
        }) {
      bins negative = {[-1048576:-1]};
      bins zero     = {0};
      bins positive = {[1:1048574]};
    }

    cp_branch_taken: coverpoint branch_taken
        iff (sampled_item.instr_type inside {BEQ, BNE}) {
      bins not_taken = {0};
      bins taken     = {1};
    }

    instruction_register_cross:
      cross cp_instruction, cp_rs1;

  endgroup


  function new(string name = "cpu_coverage",
               uvm_component parent = null);
    super.new(name, parent);
    instruction_cg = new();
  endfunction


  function void write(cpu_item t);
    sampled_item = t;

    branch_taken = 1'b0;

    case (t.instr_type)
      BEQ:
        branch_taken = t.rs1_value == t.rs2_value;

      BNE:
        branch_taken = t.rs1_value != t.rs2_value;

      default:
        branch_taken = 1'b0;
    endcase

    instruction_cg.sample();
  endfunction


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(
        "COVERAGE",
        $sformatf(
            "Functional coverage: %0.2f%%",
            instruction_cg.get_inst_coverage()
        ),
        UVM_NONE
    )
  endfunction

endclass