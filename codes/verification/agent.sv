//Agent Class
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  sequencer seqr;
  driver drv;
  monitor mon;
  
  function new(string name = "agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = sequencer::type_id::create("seqr",this);
    drv = driver::type_id::create("drv",this);
    mon = monitor::type_id::create("mon",this);  
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
endclass
