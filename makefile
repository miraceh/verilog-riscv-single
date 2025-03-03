# 目标文件名
TOP_MODULE=top
TB=testbench
OUT=sim.out

# iverilog 编译选项
IVERILOG=iverilog
VVP=vvp
GTKWAVE=gtkwave

# 查找所有 Verilog/SystemVerilog 文件
SRCDIR=src/top
VFILES=$(wildcard $(SRCDIR)/core/*.sv \
                  $(SRCDIR)/core/block/*.sv \
                  $(SRCDIR)/core/controller/*.sv \
                  $(SRCDIR)/core/datapath/*.sv \
                  $(SRCDIR)/memory/*.sv)

# 默认目标
all: compile run

# 编译
compile:
	$(IVERILOG) -g2012 -o $(OUT) \
	    -I $(SRCDIR) -I $(SRCDIR)/core -I $(SRCDIR)/memory \
	    $(SRCDIR)/top.sv $(VFILES) sim/$(TB).sv

# 运行仿真
run:
	$(VVP) $(OUT)

# 查看波形
wave:
	$(GTKWAVE) dump.vcd &

# 清理编译输出
clean:
	rm -f $(OUT) dump.vcd
