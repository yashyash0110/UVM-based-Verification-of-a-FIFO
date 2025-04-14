//Driver Class
class driver extends uvm_driver#(packet);
  `uvm_component_utils(driver)
  packet pkt;
  virtual mul_intf mif;
  
  function new(string name = "driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mul_intf)::get(this,"","mif",mif))
      `uvm_error(get_type_name(),"Unable to access Interface")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
    
    pkt = packet::type_id::create("pkt");
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(pkt);
      mif.a <= pkt.a;
      mif.b <= pkt.b;
      `uvm_info(get_type_name(),$sformatf("a:%d b:%d y:%d",pkt.a,pkt.b,pkt.y),UVM_MEDIUM);
      seq_item_port.item_done();
      #20;
    end
  endtask
  
endclass
