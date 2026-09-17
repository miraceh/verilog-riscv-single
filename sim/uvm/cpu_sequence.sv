class cpu_sequence extends uvm_sequence #(cpu_item);

  int unsigned transaction_count = 500;

  `uvm_object_utils(cpu_sequence)

  function new(string name = "cpu_sequence");
    super.new(name);
  endfunction


  task body();
    repeat (transaction_count) begin
      req = cpu_item::type_id::create("req");

      start_item(req);

      // 避免rs1和rs2指向同一个寄存器却要求不同初始值
      assert(req.randomize() with {
        rs1 != rs2;
      });

      encode_instruction(req);

      finish_item(req);
    end
  endtask


  function void encode_instruction(cpu_item item);
    case (item.instr_type)

      ADD:  item.instr = encode_r(
          7'b0000000, item.rs2, item.rs1, 3'b000, item.rd
      );

      SUB:  item.instr = encode_r(
          7'b0100000, item.rs2, item.rs1, 3'b000, item.rd
      );

      AND:  item.instr = encode_r(
          7'b0000000, item.rs2, item.rs1, 3'b111, item.rd
      );

      OR:   item.instr = encode_r(
          7'b0000000, item.rs2, item.rs1, 3'b110, item.rd
      );

      XOR:  item.instr = encode_r(
          7'b0000000, item.rs2, item.rs1, 3'b100, item.rd
      );

      SLT:  item.instr = encode_r(
          7'b0000000, item.rs2, item.rs1, 3'b010, item.rd
      );

      SLL:  item.instr = encode_r(
          7'b0000000, item.rs2, item.rs1, 3'b001, item.rd
      );

      SRL:  item.instr = encode_r(
          7'b0000000, item.rs2, item.rs1, 3'b101, item.rd
      );

      ADDI: item.instr = encode_i(
          item.immediate[11:0], item.rs1, 3'b000, item.rd, 7'b0010011
      );

      ANDI: item.instr = encode_i(
          item.immediate[11:0], item.rs1, 3'b111, item.rd, 7'b0010011
      );

      ORI:  item.instr = encode_i(
          item.immediate[11:0], item.rs1, 3'b110, item.rd, 7'b0010011
      );

      XORI: item.instr = encode_i(
          item.immediate[11:0], item.rs1, 3'b100, item.rd, 7'b0010011
      );

      SLTI: item.instr = encode_i(
          item.immediate[11:0], item.rs1, 3'b010, item.rd, 7'b0010011
      );

      SLLI: item.instr = encode_i(
          {7'b0000000, item.immediate[4:0]},
          item.rs1,
          3'b001,
          item.rd,
          7'b0010011
      );

      SRLI: item.instr = encode_i(
          {7'b0000000, item.immediate[4:0]},
          item.rs1,
          3'b101,
          item.rd,
          7'b0010011
      );

      LW: item.instr = encode_i(
          item.immediate[11:0], item.rs1, 3'b010, item.rd, 7'b0000011
      );

      SW: item.instr = encode_s(
          item.immediate[11:0], item.rs2, item.rs1, 3'b010
      );

      BEQ: item.instr = encode_b(
          item.immediate[12:0], item.rs2, item.rs1, 3'b000
      );

      BNE: item.instr = encode_b(
          item.immediate[12:0], item.rs2, item.rs1, 3'b001
      );

      JAL: item.instr = encode_j(
          item.immediate[20:0], item.rd
      );

      default: `uvm_fatal("ENCODE", "Unsupported instruction type")

    endcase
  endfunction


  function bit [31:0] encode_r(
      bit [6:0] funct7,
      bit [4:0] rs2,
      bit [4:0] rs1,
      bit [2:0] funct3,
      bit [4:0] rd
  );
    return {funct7, rs2, rs1, funct3, rd, 7'b0110011};
  endfunction


  function bit [31:0] encode_i(
      bit [11:0] immediate,
      bit [4:0]  rs1,
      bit [2:0]  funct3,
      bit [4:0]  rd,
      bit [6:0]  opcode
  );
    return {immediate, rs1, funct3, rd, opcode};
  endfunction


  function bit [31:0] encode_s(
      bit [11:0] immediate,
      bit [4:0]  rs2,
      bit [4:0]  rs1,
      bit [2:0]  funct3
  );
    return {
      immediate[11:5],
      rs2,
      rs1,
      funct3,
      immediate[4:0],
      7'b0100011
    };
  endfunction


  function bit [31:0] encode_b(
      bit [12:0] immediate,
      bit [4:0]  rs2,
      bit [4:0]  rs1,
      bit [2:0]  funct3
  );
    return {
      immediate[12],
      immediate[10:5],
      rs2,
      rs1,
      funct3,
      immediate[4:1],
      immediate[11],
      7'b1100011
    };
  endfunction


  function bit [31:0] encode_j(
      bit [20:0] immediate,
      bit [4:0]  rd
  );
    return {
      immediate[20],
      immediate[10:1],
      immediate[11],
      immediate[19:12],
      rd,
      7'b1101111
    };
  endfunction

endclass