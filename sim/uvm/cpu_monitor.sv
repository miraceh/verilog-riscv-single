class cpu_monitor extends uvm_monitor;

  `uvm_component_utils(cpu_monitor)

  virtual cpu_if vif;
  uvm_analysis_port #(cpu_item) analysis_port;

  function new(string name = "cpu_monitor",
               uvm_component parent = null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual cpu_if)::get(
        this, "", "vif", vif
    )) begin
      `uvm_fatal("NO_VIF", "cpu_if was not provided to cpu_monitor")
    end
  endfunction


  task run_phase(uvm_phase phase);
    cpu_item item;
    uvm_hdl_data_t value;
    bit success;

    forever begin
      @(vif.monitor_cb);

      // reset期间以及空闲NOP不发布transaction
      if (vif.monitor_cb.reset ||
          vif.monitor_cb.instr == 32'h00000013) begin
        continue;
      end

      item = cpu_item::type_id::create("item");

      item.instr       = vif.monitor_cb.instr;
      item.read_data   = vif.monitor_cb.read_data;
      item.pc          = vif.monitor_cb.pc;
      item.mem_write   = vif.monitor_cb.mem_write;
      item.alu_result  = vif.monitor_cb.alu_result;
      item.write_data  = vif.monitor_cb.write_data;

      item.rd  = item.instr[11:7];
      item.rs1 = item.instr[19:15];
      item.rs2 = item.instr[24:20];

      item.instr_type = decode_instruction(item.instr);
      item.immediate  = decode_immediate(item.instr);

// clocking block在寄存器写回前采集原始rs1操作数
      item.rs1_value = vif.monitor_cb.src_a;

      // WriteData就是寄存器堆的第二个读端口
      item.rs2_value = item.write_data;

      // 等待寄存器写回的NBA更新完成
      uvm_wait_for_nba_region();

// posedge写入PC寄存器后，读取指令执行产生的新PC
      item.next_pc = vif.pc;

      if (item.rd != 0) begin
        success = uvm_hdl_read(
            $sformatf(
                "tb_top.dut.core.dp.rf.rf[%0d]",
                item.rd
            ),
            value
        );

        if (!success) begin
          `uvm_fatal(
              "BACKDOOR",
              $sformatf("Failed to read x%0d", item.rd)
          )
        end

        item.rd_value = value[31:0];
      end
      else begin
        item.rd_value = 32'b0;
      end

      analysis_port.write(item);
    end
  endtask


  function cpu_instr_e decode_instruction(bit [31:0] instr);
    case (instr[6:0])

      7'b0110011: begin
        case ({instr[31:25], instr[14:12]})
          {7'b0000000, 3'b000}: return ADD;
          {7'b0100000, 3'b000}: return SUB;
          {7'b0000000, 3'b111}: return AND;
          {7'b0000000, 3'b110}: return OR;
          {7'b0000000, 3'b100}: return XOR;
          {7'b0000000, 3'b010}: return SLT;
          {7'b0000000, 3'b001}: return SLL;
          {7'b0000000, 3'b101}: return SRL;
          default:
            `uvm_fatal("DECODE", "Unsupported R-type instruction")
        endcase
      end

      7'b0010011: begin
        case (instr[14:12])
          3'b000: return ADDI;
          3'b111: return ANDI;
          3'b110: return ORI;
          3'b100: return XORI;
          3'b010: return SLTI;
          3'b001: return SLLI;
          3'b101: return SRLI;
          default:
            `uvm_fatal("DECODE", "Unsupported I-type instruction")
        endcase
      end

      7'b0000011: return LW;
      7'b0100011: return SW;

      7'b1100011: begin
        case (instr[14:12])
          3'b000: return BEQ;
          3'b001: return BNE;
          default:
            `uvm_fatal("DECODE", "Unsupported branch instruction")
        endcase
      end

      7'b1101111: return JAL;

      default:
        `uvm_fatal(
            "DECODE",
            $sformatf("Unsupported opcode: %07b", instr[6:0])
        )
    endcase
  endfunction


  function bit signed [20:0] decode_immediate(bit [31:0] instr);
    case (instr[6:0])

      // I-type和load
      7'b0010011,
      7'b0000011:
        return {{9{instr[31]}}, instr[31:20]};

      // Store
      7'b0100011:
        return {
          {9{instr[31]}},
          instr[31:25],
          instr[11:7]
        };

      // Branch
      7'b1100011:
        return {
          {8{instr[31]}},
          instr[31],
          instr[7],
          instr[30:25],
          instr[11:8],
          1'b0
        };

      // JAL
      7'b1101111:
        return {
          instr[31],
          instr[19:12],
          instr[20],
          instr[30:21],
          1'b0
        };

      default:
        return 21'sd0;

    endcase
  endfunction

endclass