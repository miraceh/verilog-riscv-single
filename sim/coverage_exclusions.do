# Legal RISC-V opcodes always have Instr[1:0] == 2'b11
coverage exclude -scope /tb_top/dut              -togglenode {Instr[0]}
coverage exclude -scope /tb_top/dut              -togglenode {Instr[1]}
coverage exclude -scope /tb_top/dut/core         -togglenode {Instr[0]}
coverage exclude -scope /tb_top/dut/core         -togglenode {Instr[1]}
coverage exclude -scope /tb_top/dut/core/c       -togglenode {op[0]}
coverage exclude -scope /tb_top/dut/core/c       -togglenode {op[1]}
coverage exclude -scope /tb_top/dut/core/c/md    -togglenode {op[0]}
coverage exclude -scope /tb_top/dut/core/c/md    -togglenode {op[1]}
coverage exclude -scope /tb_top/dut/core/dp      -togglenode {Instr[0]}
coverage exclude -scope /tb_top/dut/core/dp      -togglenode {Instr[1]}

# PC is 4-byte aligned, so bit 0 cannot toggle
coverage exclude -scope /tb_top/dut              -togglenode {PC[0]}
coverage exclude -scope /tb_top/dut/core         -togglenode {PC[0]}
coverage exclude -scope /tb_top/dut/core/dp      -togglenode {PC[0]}
coverage exclude -scope /tb_top/dut/core/dp      -togglenode {PCNext[0]}
coverage exclude -scope /tb_top/dut/core/dp      -togglenode {PCPlus4[0]}
coverage exclude -scope /tb_top/dut/core/dp/pcreg -togglenode {d[0]}
coverage exclude -scope /tb_top/dut/core/dp/pcreg -togglenode {q[0]}

# pcadd4 uses the constant input 32'd4
coverage exclude -scope /tb_top/dut/core/dp/pcadd4 -togglenode {a[0]}
coverage exclude -scope /tb_top/dut/core/dp/pcadd4 -togglenode {b}
coverage exclude -scope /tb_top/dut/core/dp/pcadd4 -togglenode {y[0]}

# Other signals derived from aligned PC
coverage exclude -scope /tb_top/dut/core/dp/pcaddbranch -togglenode {a[0]}
coverage exclude -scope /tb_top/dut/core/dp/pcmux       -togglenode {d0[0]}
coverage exclude -scope /tb_top/dut/core/dp/pcmux       -togglenode {y[0]}
coverage exclude -scope /tb_top/dut/core/dp/resultmux   -togglenode {d2[0]}