typedef enum {
  ADD,
  SUB,
  AND,
  OR,
  XOR,
  SLT,
  SLL,
  SRL,
  ADDI,
  ANDI,
  ORI,
  XORI,
  SLTI,
  SLLI,
  SRLI,
  LW,
  SW,
  BEQ,
  BNE,
  JAL
} cpu_instr_e;


class cpu_item extends uvm_sequence_item;

  // Sequence产生的输入
  rand cpu_instr_e instr_type;
  rand bit [4:0]   rd;
  rand bit [4:0]   rs1;
  rand bit [4:0]   rs2;
  rand bit [31:0]  rs1_value;
  rand bit [31:0]  rs2_value;
  rand bit [31:0]  read_data;
  rand bit signed [20:0] immediate;

  // 根据以上字段编码出的完整指令
  bit [31:0] instr;

  // Monitor采集的实际结果
  bit [31:0] pc;
  bit [31:0] next_pc;
  bit        mem_write;
  bit [31:0] alu_result;
  bit [31:0] write_data;
  bit [31:0] rd_value;

  constraint register_c {
    rd  inside {[1:31]};
    rs1 inside {[0:31]};
    rs2 inside {[0:31]};
  }

  constraint immediate_c {
    if (instr_type inside {
        ADDI, ANDI, ORI, XORI, SLTI, LW
    }) {
      immediate inside {[-2048:2047]};
    }

    if (instr_type == SW) {
      immediate inside {[-2048:2047]};
    }

    if (instr_type inside {BEQ, BNE}) {
      immediate inside {[-4096:4094]};
      immediate[0] == 1'b0;
    }

    if (instr_type == JAL) {
      immediate inside {[-1048576:1048574]};
      immediate[0] == 1'b0;
    }

    if (instr_type inside {SLLI, SRLI}) {
      immediate inside {[0:31]};
    }
  }

  `uvm_object_utils_begin(cpu_item)
    `uvm_field_enum(cpu_instr_e, instr_type, UVM_DEFAULT)
    `uvm_field_int(rd,          UVM_DEFAULT)
    `uvm_field_int(rs1,         UVM_DEFAULT)
    `uvm_field_int(rs2,         UVM_DEFAULT)
    `uvm_field_int(rs1_value,   UVM_DEFAULT)
    `uvm_field_int(rs2_value,   UVM_DEFAULT)
    `uvm_field_int(read_data,   UVM_DEFAULT)
    `uvm_field_int(immediate,   UVM_DEFAULT)
    `uvm_field_int(instr,       UVM_DEFAULT)
    `uvm_field_int(pc,          UVM_DEFAULT)
    `uvm_field_int(next_pc,     UVM_DEFAULT)
    `uvm_field_int(mem_write,   UVM_DEFAULT)
    `uvm_field_int(alu_result,  UVM_DEFAULT)
    `uvm_field_int(write_data,  UVM_DEFAULT)
    `uvm_field_int(rd_value,    UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "cpu_item");
    super.new(name);
  endfunction

endclass