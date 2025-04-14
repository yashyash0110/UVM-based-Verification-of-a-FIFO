//Environment Class
class env extends uvm_env;
  `uvm_component_utils(env)
  
  scoreboard scd;
  agent agnt;
  
  function new(string name = "env", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    scd = scoreboard::type_id::create("scd",this);
    agnt = agent::type_id::create("agnt",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agnt.mon.mon_port.connect(scd.recv);
  endfunction
  
endclass
