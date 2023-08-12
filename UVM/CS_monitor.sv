class CS_monitor extends uvm_monitor;
`uvm_component_utils(CS_monitor)

//Interface Handler
virtual CS_if vif;
//Analysis Port Handler
uvm_analysis_port #(CS_transaction) analysis_port;

//Constructor
function new(input string inst = "MON", uvm_component parent);
super.new(inst,parent);
analysis_port = new("analysis_port", this);
endfunction : new

//Build phase
virtual function void build_phase (uvm_phase phase);
super.build_phase(phase);
  if(!uvm_config_db#(virtual CS_if)::get(this, "", "vif", vif))
    `uvm_fatal("NOVIF","Interface Not Found");
endfunction : build_phase

//Run phase
virtual task run_phase (uvm_phase phase);
forever begin 
CS_transaction transaction;

@vif.cb;
transaction = CS_transaction::type_id::create("transaction");
capture(transaction);
analysis_port.write(transaction);
end
endtask : run_phase

task capture(output CS_transaction transaction);
CS_transaction temp = CS_transaction::type_id::create("transaction");
//monitoring
temp.RESET = vif.RESET;
temp.addA = vif.addA;
temp.addB = vif.addB;
temp.addC = vif.addC;

temp.OPERATION = vif.OPERATION;

temp.DQ = vif.cb.DQ;
temp.overflow = vif.cb.overflow;

transaction = temp;
endtask
endclass: CS_monitor 