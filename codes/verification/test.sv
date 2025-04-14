//Test Class
class test extends uvm_test;
  `uvm_component_utils(test)
  
  env envmt;
  seq sq;
  
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    envmt = env::type_id::create("envmt",this);
    sq = seq::type_id::create("sq" );
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    sq.start(envmt.agnt.seqr);
    #20;
    phase.drop_objection(this);
  endtask
  
endclass
