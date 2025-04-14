//Scoreboard Class
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp#(packet,scoreboard) recv;
  
  function new(string name = "scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("Receiver Port",this);
  endfunction
  
  virtual function void write(packet pkt);
    if(pkt.y == (pkt.a * pkt.b))
      `uvm_info(get_type_name(),$sformatf("Test Passed -> a:%d b:%d y:%d",pkt.a,pkt.b,pkt.y),UVM_MEDIUM)
    else
      `uvm_error(get_type_name(),$sformatf("Test Failed -> a:%d b:%d y:%d",pkt.a,pkt.b,pkt.y))
    $display("---------------------------------------------------");
  endfunction
  
endclass
