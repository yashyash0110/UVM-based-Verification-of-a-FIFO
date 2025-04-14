//Transaction or Packet or sequence item Class
class packet extends uvm_sequence_item;
  `uvm_object_utils(packet)
  
  rand bit [3:0] a;
  rand bit [3:0] b;
  bit [7:0] y;
  
  function new(input string name = "packet");
    super.new(name);
  endfunction
  
endclass
