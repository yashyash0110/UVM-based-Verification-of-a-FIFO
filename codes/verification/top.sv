//Top Module
`include "uvm_macros.svh" //Gives access to all the macros  that we frequently use in the verification environment
import uvm_pkg::*; //Gives access to the base class from which we can build the verification environment 

`include "packet.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"

`include "interface.sv"

module top;
  
  mul_intf mif();
  
  mul_4bit dut(.input1(mif.a),.input2(mif.b),.mul_output(mif.y));
  
  initial begin
    uvm_config_db#(virtual mul_intf)::set(null,"*","mif",mif);
  end
  
  initial begin
    run_test("test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
