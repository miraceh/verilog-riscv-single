module testbench ();
  logic clk;
  logic reset;
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;
  // instantiate device to be tested
  top dut (
      clk,
      reset,
      WriteData,
      DataAdr,
      MemWrite
  );
  // initialize test
  initial begin
    reset <= 1;
    #22;
    reset <= 0;
  end
  // generate clock to sequence tests
  always begin
    clk <= 1;
    #5;
    clk <= 0;
    #5;
  end
  // check results
  always @(negedge clk) begin
    // test1.hex
    // if (MemWrite) begin
    //     if (DataAdr === 100 & WriteData === 25) begin
    //     $display("-------Test1 Simulation succeeded-------");
    //     $stop;
    //     end else if (DataAdr !== 96) begin
    //     $display("Simulation failed");
    //     $stop;
    //     end
    // end

    // test2.hex
    if (MemWrite) begin
      if (DataAdr === 216 & WriteData === 4140) begin
        $display("Test2 Simulation succeeded!");
        $stop;
      end
    end
  end
endmodule
