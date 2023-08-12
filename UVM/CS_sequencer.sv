class CS_sequencer extends uvm_sequencer#(CS_transaction);
`uvm_component_utils(CS_sequencer)

function new(input string inst = "CS_sequencer", uvm_component parent);
super.new(inst,parent);
endfunction : new

endclass