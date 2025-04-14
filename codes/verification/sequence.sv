//Sequence Class
class seq extends uvm_sequence#(packet);
  `uvm_object_utils(seq)
  
  packet pkt;
  
  function new(input string name = "seq");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        start_item(pkt);
        pkt.randomize();
        `uvm_info(get_type_name(),$sformatf("a: %d b:%d y:%d",pkt.a,pkt.b,pkt.y),UVM_MEDIUM);
        finish_item(pkt);
      end
  endtask
  
endclass
