class CS_agent extends uvm_agent;
`uvm_component_utils(CS_agent)

//Constructor
function new(input string inst = "AGT", uvm_component parent);
super.new(inst,parent);
endfunction : new

//Agent components
CS_driver    drv;
CS_sequencer seqr;
CS_monitor   mon;

//Build phase
virtual function void build_phase (uvm_phase phase);
super.build_phase(phase);

//check if Agent is ACTIVE
if(get_is_active() == UVM_ACTIVE) begin
  drv = CS_driver::type_id::create("drv", this);
  seqr = CS_sequencer::type_id::create("seqr", this);
end
mon = CS_monitor::type_id::create("mon", this);
endfunction : build_phase

//Connect phase
function void connect_phase(uvm_phase phase);
//check if Agent is ACTIVE
if(get_is_active() == UVM_ACTIVE) begin
  drv.seq_item_port.connect(seqr.seq_item_export);
end
endfunction : connect_phase

endclass: CS_agent 