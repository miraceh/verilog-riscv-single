VLOG = vlog
VSIM = vsim
VCOVER := vcover
UCDB   := coverage.ucdb
COV_REPORT := coverage.txt

QUESTA_HOME ?= /opt/questa
UVM_HOME    ?= $(QUESTA_HOME)/verilog_src/uvm-1.2
SEED ?= random
UCDB ?= coverage.ucdb

TOP = tb_top

RTL_FILES = \
	src/top/core/block/adder.sv \
	src/top/core/block/flopenr.sv \
	src/top/core/block/flopr.sv \
	src/top/core/block/mux2.sv \
	src/top/core/block/mux3.sv \
	src/top/core/controller/aludec.sv \
	src/top/core/controller/maindec.sv \
	src/top/core/controller/controller.sv \
	src/top/core/datapath/alu.sv \
	src/top/core/datapath/extend.sv \
	src/top/core/datapath/regfile.sv \
	src/top/core/datapath/datapath.sv \
	src/top/core/core.sv \
	src/top/top.sv

TB_FILES = \
	sim/uvm/cpu_if.sv \
	sim/uvm/cpu_pkg.sv \
	sim/testbench.sv

VLOG_FLAGS = \
	-sv \
	+incdir+$(UVM_HOME)/src \
	+incdir+sim/uvm

VSIM_FLAGS = \
	-voptargs=+acc \
	-coverage \
	-sv_seed $(SEED)

.PHONY: all compile run coverage clean

all: compile run


work:
	vlib work


compile: work
	$(VLOG) $(VLOG_FLAGS) +cover=bcesft $(RTL_FILES)
	$(VLOG) $(VLOG_FLAGS) $(TB_FILES)


run:
	$(VSIM) -c $(VSIM_FLAGS) $(TOP) \
		-do "do sim/coverage_exclusions.do; coverage save -onexit $(UCDB); run -all; quit -f"


# 只有需要调试时才打开GUI并记录波形
wave:
	$(VSIM) $(VSIM_FLAGS) $(TOP) \
		-do "add wave -r sim:/$(TOP)/*; run -all"

coverage:
	$(VCOVER) report -details -cvg -output coverage.txt $(UCDB)
	$(VCOVER) report -details -output full_coverage.txt $(UCDB)

clean:
	rm -f transcript vsim.wlf coverage.ucdb dump.vcd coverage.txt full_coverage.txt regression/*
	vdel -all -lib work
