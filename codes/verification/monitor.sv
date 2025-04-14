//Monitor Class
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  packet pkt;
  virtual mul_intf mif;
  
  uvm_analysis_port #(packet) mon_port;
  
  function new(string name = "monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mul_intf)::get(this,"","mif",mif))
      `uvm_error(get_type_name(),"Unable to access Interface")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
    
    mon_port = new("Monitor Port",this);
    pkt = packet::type_id::create("pkt",this);
  
  endfunction
    
  virtual task run_phase(uvm_phase phase);
    forever begin
      #20;
      pkt.a = mif.a;
      pkt.b = mif.b;
      pkt.y = mif.y;
      `uvm_info(get_type_name(),$sformatf("a:%d b:%d y:%d",pkt.a,pkt.b,pkt.y),UVM_MEDIUM);
      mon_port.write(pkt);
    end
  endtask
  
endclass
